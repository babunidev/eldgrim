-- Eldgrim - World of Warcraft Forever
-- Passive local archive of current guild members' player-chat messages.
-- No UI, slash commands, chat output, notifications, sounds, or addon messaging.

local GUILD_CLUB_TYPE = 2
local GUILD_STREAM_TYPE = 1
local OFFICER_STREAM_TYPE = 2
local DATABASE_SCHEMA_VERSION = 2
local RECENT_MESSAGE_KEY_LIMIT = 128

local RACE_NAMES = {
    [1] = "Human",
    [2] = "Orc",
    [3] = "Dwarf",
    [4] = "Night Elf",
    [5] = "Undead",
    [6] = "Tauren",
    [7] = "Gnome",
    [8] = "Troll",
    [95] = "High Order Skyborne",
    [96] = "Windshaper Skyborne",
}

local CLASS_TOKENS = {
    WARRIOR = true,
    PALADIN = true,
    HUNTER = true,
    ROGUE = true,
    PRIEST = true,
    SHAMAN = true,
    MAGE = true,
    WARLOCK = true,
    DRUID = true,
}

local FACTION_NAMES = {
    [0] = "Horde",
    [1] = "Alliance",
}

-- Only player-authored in-game chat events are registered. System, NPC,
-- combat-log, addon, Battle.net, and Discord-relay messages are excluded.
local CHAT_EVENTS = {
    CHAT_MSG_GUILD = "GUILD",
    CHAT_MSG_OFFICER = "OFFICER",
    CHAT_MSG_SAY = "SAY",
    CHAT_MSG_YELL = "YELL",
    CHAT_MSG_WHISPER = "WHISPER",
    CHAT_MSG_WHISPER_INFORM = "WHISPER",
    CHAT_MSG_PARTY = "PARTY",
    CHAT_MSG_PARTY_LEADER = "PARTY",
    CHAT_MSG_RAID = "RAID",
    CHAT_MSG_RAID_LEADER = "RAID",
    CHAT_MSG_RAID_WARNING = "RAID_WARNING",
    CHAT_MSG_INSTANCE_CHAT = "INSTANCE",
    CHAT_MSG_INSTANCE_CHAT_LEADER = "INSTANCE",
    CHAT_MSG_CHANNEL = "CHANNEL",
    CHAT_MSG_COMMUNITIES_CHANNEL = "COMMUNITY",
    CHAT_MSG_EMOTE = "EMOTE",
    CHAT_MSG_TEXT_EMOTE = "TEXT_EMOTE",
}

local recentMessageKeys = {}
local recentMessageQueue = {}
local nextRecentMessageSlot = 1

local memberNameLookup = {}
local selfMemberName
local currentGuildClubId
local focusedGuildClubId
local guildStreamId
local officerStreamId
local clubsInitialized = false
local rosterRefreshPending = false
local streamsRefreshPending = false

local function normalizeCharacterName(name)
    if type(name) ~= "string" then
        return nil
    end

    name = name:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
    if name == "" then
        return nil
    end

    return string.lower(name)
end

local function addNameAlias(lookup, alias, canonicalName)
    local key = normalizeCharacterName(alias)
    if key and (lookup[key] == nil or lookup[key] == canonicalName) then
        lookup[key] = canonicalName
    end
end

local function addMemberNameToLookup(lookup, name)
    addNameAlias(lookup, name, name)

    -- Forever names may be displayed with either a space or a hyphen between
    -- the two name parts. Keep the complete name; never match first name only.
    local spaced = name:gsub("%-", " ")
    if spaced ~= name then
        addNameAlias(lookup, spaced, name)
    end

    local hyphenated = name:gsub("%s+", "-")
    if hyphenated ~= name then
        addNameAlias(lookup, hyphenated, name)
    end
end

local function isChatMessagingLockedDown()
    local api = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown
    if type(api) ~= "function" then
        return true
    end

    local ok, restricted = pcall(api)
    return not ok or restricted ~= false
end

local function buildCharacterProfile(source)
    if type(source) ~= "table" then
        return {}
    end

    local profile = {}
    local raceName = RACE_NAMES[source.race]
    if raceName then
        profile.race = raceName
    end

    local classID = source.classID
    local classAPI = C_CreatureInfo and C_CreatureInfo.GetClassInfo
    if type(classID) == "number" and type(classAPI) == "function" then
        local ok, classInfo = pcall(classAPI, classID)
        if ok and type(classInfo) == "table"
            and type(classInfo.classFile) == "string"
            and CLASS_TOKENS[classInfo.classFile]
            and type(classInfo.className) == "string"
            and classInfo.className ~= "" then
            profile.class = classInfo.className
        end
    end

    if type(source.level) == "number" and source.level > 0 then
        profile.level = source.level
    end

    local factionName = FACTION_NAMES[source.faction]
    if factionName then
        profile.faction = factionName
    end

    if type(source.zone) == "string" and source.zone ~= "" then
        profile.zone = source.zone
    end

    if type(source.achievementPoints) == "number" and source.achievementPoints >= 0 then
        profile.achievementPoints = source.achievementPoints
    end

    local professions = {}

    local function addProfession(name, skill)
        if type(name) ~= "string" or name == "" then
            return
        end

        local profession = { name = name }
        if type(skill) == "number" and skill >= 0 then
            profession.skill = skill
        end
        professions[#professions + 1] = profession
    end

    addProfession(source.profession1Name, source.profession1Rank)
    addProfession(source.profession2Name, source.profession2Rank)

    if #professions > 0 then
        profile.professions = professions
    end

    return profile
end

local function applyCharacterProfile(character, source)
    local profile = buildCharacterProfile(source)
    for field, value in pairs(profile) do
        character[field] = value
    end

    if type(source) == "table"
        and type(source.guildRank) == "string"
        and source.guildRank ~= "" then
        character.guildRank = source.guildRank
    end
end

local function getMemberRecord(name)
    local members = EldgrimDB.members
    local character = members[name]
    if type(character) ~= "table" then
        character = { messages = {} }
        members[name] = character
    elseif type(character.messages) ~= "table" then
        character.messages = {}
    end

    return character
end

local function initializeDatabase()
    if type(EldgrimDB) ~= "table" then
        EldgrimDB = {
            schemaVersion = DATABASE_SCHEMA_VERSION,
            members = {},
        }
        return
    end

    if EldgrimDB.schemaVersion == DATABASE_SCHEMA_VERSION
        and type(EldgrimDB.members) == "table" then
        return
    end

    -- Migrate the original name-keyed guild archive without discarding history.
    -- Every message in the old schema came from CHAT_MSG_GUILD, so its channel
    -- can be labelled accurately during migration.
    local migratedMembers = {}
    for name, character in pairs(EldgrimDB) do
        if type(name) == "string" and type(character) == "table" then
            if type(character.messages) ~= "table" then
                character.messages = {}
            end

            for _, messageRecord in ipairs(character.messages) do
                if type(messageRecord) == "table" and messageRecord.channel == nil then
                    messageRecord.channel = "GUILD"
                end
            end

            migratedMembers[name] = character
        end
    end

    EldgrimDB = {
        schemaVersion = DATABASE_SCHEMA_VERSION,
        members = migratedMembers,
    }
end

local function rememberMessageKey(key)
    local oldKey = recentMessageQueue[nextRecentMessageSlot]
    if oldKey then
        recentMessageKeys[oldKey] = nil
    end

    recentMessageQueue[nextRecentMessageSlot] = key
    recentMessageKeys[key] = true
    nextRecentMessageSlot = (nextRecentMessageSlot % RECENT_MESSAGE_KEY_LIMIT) + 1
end

local function clearCurrentRosterLookup()
    memberNameLookup = {}
    selfMemberName = nil
end

local function markAllMembersFormer()
    for _, character in pairs(EldgrimDB.members) do
        if type(character) == "table" then
            character.isGuildMember = false
        end
    end
end

local function readGuildStreamIDs(clubId)
    local api = C_Club and C_Club.GetStreams
    if type(api) ~= "function" then
        return nil, nil
    end

    local ok, streams = pcall(api, clubId)
    if not ok or type(streams) ~= "table" then
        return nil, nil
    end

    local foundGuildStream
    local foundOfficerStream
    for _, stream in ipairs(streams) do
        if type(stream) == "table" and type(stream.streamId) == "number" then
            if stream.streamType == GUILD_STREAM_TYPE then
                foundGuildStream = stream.streamId
            elseif stream.streamType == OFFICER_STREAM_TYPE then
                foundOfficerStream = stream.streamId
            end
        end
    end

    return foundGuildStream, foundOfficerStream
end

local function refreshGuildRoster()
    if isChatMessagingLockedDown() then
        return false
    end

    local getGuildClubId = C_Club and C_Club.GetGuildClubId
    local getClubInfo = C_Club and C_Club.GetClubInfo
    local areMembersReady = C_Club and C_Club.AreMembersReady
    local getClubMembers = C_Club and C_Club.GetClubMembers
    local getMemberInfo = C_Club and C_Club.GetMemberInfo
    local focusMembers = C_Club and C_Club.FocusMembers

    if type(getGuildClubId) ~= "function"
        or type(getClubInfo) ~= "function"
        or type(areMembersReady) ~= "function"
        or type(getClubMembers) ~= "function"
        or type(getMemberInfo) ~= "function"
        or type(focusMembers) ~= "function" then
        return false
    end

    local ok, clubId = pcall(getGuildClubId)
    if not ok then
        return false
    end

    if clubId == nil then
        if clubsInitialized then
            currentGuildClubId = nil
            focusedGuildClubId = nil
            guildStreamId = nil
            officerStreamId = nil
            streamsRefreshPending = false
            clearCurrentRosterLookup()
            markAllMembersFormer()
            return true
        end
        return false
    end

    if currentGuildClubId ~= nil and currentGuildClubId ~= clubId then
        clearCurrentRosterLookup()
    end

    local clubInfoOK, clubInfo = pcall(getClubInfo, clubId)
    if not clubInfoOK or type(clubInfo) ~= "table"
        or clubInfo.clubType ~= GUILD_CLUB_TYPE then
        return false
    end

    if focusedGuildClubId ~= clubId then
        local focusOK = pcall(focusMembers, clubId)
        if not focusOK then
            return false
        end
        focusedGuildClubId = clubId
    end

    local readyOK, membersReady = pcall(areMembersReady, clubId)
    if not readyOK or membersReady ~= true then
        return false
    end

    local membersOK, memberIDs = pcall(getClubMembers, clubId)
    if not membersOK or type(memberIDs) ~= "table" then
        return false
    end

    local nextLookup = {}
    local nextCurrentMembers = {}
    local nextSelfMemberName
    local scanComplete = true

    for _, memberId in ipairs(memberIDs) do
        local memberOK, memberInfo = pcall(getMemberInfo, clubId, memberId)
        if not memberOK or type(memberInfo) ~= "table" then
            scanComplete = false
        else
            local name = memberInfo.name
            if type(name) ~= "string" or name == "" then
                scanComplete = false
            else
                local character = getMemberRecord(name)
                character.isGuildMember = true
                applyCharacterProfile(character, memberInfo)
                nextCurrentMembers[name] = true
                addMemberNameToLookup(nextLookup, name)

                if memberInfo.isSelf == true then
                    nextSelfMemberName = name
                end
            end
        end
    end

    -- Do not mark missing entries as former unless every roster row was read.
    -- A partial API response must not erase a member's current status.
    if scanComplete then
        for name, character in pairs(EldgrimDB.members) do
            if type(character) == "table" then
                character.isGuildMember = nextCurrentMembers[name] == true
            end
        end
    end

    memberNameLookup = nextLookup
    selfMemberName = nextSelfMemberName
    currentGuildClubId = clubId
    guildStreamId, officerStreamId = readGuildStreamIDs(clubId)
    streamsRefreshPending = false

    -- A partial read is still a completed attempt: known members are eligible,
    -- unread names fail closed, and missing records are not marked former.
    return true
end

local function resolveCurrentMemberName(name)
    local key = normalizeCharacterName(name)
    return key and memberNameLookup[key] or nil
end

local function getMatchedCommunityData(event, message, senderName, canonicalName)
    local expectedStreamId
    if event == "CHAT_MSG_GUILD" then
        expectedStreamId = guildStreamId
    elseif event == "CHAT_MSG_OFFICER" then
        expectedStreamId = officerStreamId
    else
        return nil, nil
    end

    if expectedStreamId == nil or currentGuildClubId == nil then
        return nil, nil
    end

    local api = C_Club and C_Club.GetInfoFromLastCommunityChatLine
    if type(api) ~= "function" then
        return nil, nil
    end

    local ok, messageInfo, clubId, streamId, clubType = pcall(api)
    if not ok or type(messageInfo) ~= "table"
        or clubId ~= currentGuildClubId
        or streamId ~= expectedStreamId
        or clubType ~= GUILD_CLUB_TYPE then
        return nil, nil
    end

    local author = messageInfo.author
    if type(author) ~= "table"
        or type(messageInfo.content) ~= "string"
        or messageInfo.content ~= message
        or type(author.name) ~= "string"
        or resolveCurrentMemberName(author.name) ~= canonicalName
        or resolveCurrentMemberName(senderName) ~= canonicalName then
        return nil, nil
    end

    local timestamp
    local messageKey
    local messageId = messageInfo.messageId
    if type(messageId) == "table" then
        local epoch = messageId.epoch
        local position = messageId.position

        if type(epoch) == "number" and epoch > 0 then
            timestamp = math.floor(epoch / 1000000)
        end

        if type(epoch) == "number" and epoch > 0 and type(position) == "number" then
            messageKey = tostring(clubId) .. ":" .. tostring(streamId)
                .. ":" .. tostring(epoch) .. ":" .. tostring(position)
            if recentMessageKeys[messageKey] then
                return nil, nil
            end
        end
    end

    if messageKey then
        rememberMessageKey(messageKey)
    end

    return buildCharacterProfile(author), timestamp
end

local function recordChatEvent(event, ...)
    -- The lockdown check must happen before reading or comparing chat payloads.
    if isChatMessagingLockedDown() then
        return
    end

    if rosterRefreshPending then
        clearCurrentRosterLookup()
        -- Retry readiness after a deferred/early event. Member enumeration only
        -- begins once AreMembersReady reports true; FocusMembers is called once.
        rosterRefreshPending = not refreshGuildRoster()
    end

    if streamsRefreshPending and currentGuildClubId ~= nil then
        guildStreamId, officerStreamId = readGuildStreamIDs(currentGuildClubId)
        streamsRefreshPending = false
    end

    local message, playerName, _, channelName, _, _, _, _, channelBaseName,
        _, _, _, _, _, _, _, _, discordInfo = ...
    if type(message) ~= "string" or message == "" or type(discordInfo) == "table" then
        return
    end

    local senderName = playerName
    local direction
    local recipient

    if event == "CHAT_MSG_WHISPER" then
        direction = "IN"
    elseif event == "CHAT_MSG_WHISPER_INFORM" then
        -- For outgoing whispers, playerName is the recipient. The speaker is
        -- the local character, identified from the guild roster's isSelf row.
        senderName = selfMemberName
        direction = "OUT"
        recipient = playerName
    end

    local canonicalName = resolveCurrentMemberName(senderName)
    if not canonicalName then
        return
    end

    local character = EldgrimDB.members[canonicalName]
    if type(character) ~= "table" or character.isGuildMember ~= true then
        return
    end

    local profile, communityTimestamp = getMatchedCommunityData(
        event, message, senderName, canonicalName
    )
    if type(profile) == "table" then
        for field, value in pairs(profile) do
            character[field] = value
        end
    end

    local timestamp = communityTimestamp
    if type(timestamp) ~= "number" then
        timestamp = type(time) == "function" and time() or nil
    end
    if type(timestamp) ~= "number" then
        return
    end

    local messageRecord = {
        timestamp = timestamp,
        channel = CHAT_EVENTS[event],
        message = message,
    }

    if direction then
        messageRecord.direction = direction
    end
    if type(recipient) == "string" and recipient ~= "" then
        messageRecord.recipient = recipient
    end

    if CHAT_EVENTS[event] == "CHANNEL" or CHAT_EVENTS[event] == "COMMUNITY" then
        local displayName = type(channelBaseName) == "string" and channelBaseName ~= ""
            and channelBaseName or channelName
        if type(displayName) == "string" and displayName ~= "" then
            messageRecord.channelName = displayName
        end
    end

    character.messages[#character.messages + 1] = messageRecord
end

initializeDatabase()

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        if isChatMessagingLockedDown() then
            rosterRefreshPending = true
            return
        end
        rosterRefreshPending = not refreshGuildRoster()
        return
    end

    if event == "INITIAL_CLUBS_LOADED" then
        clubsInitialized = true
        if isChatMessagingLockedDown() then
            clearCurrentRosterLookup()
            rosterRefreshPending = true
            return
        end
        rosterRefreshPending = not refreshGuildRoster()
        return
    end

    if event == "PLAYER_GUILD_UPDATE" then
        clearCurrentRosterLookup()
        if isChatMessagingLockedDown() then
            rosterRefreshPending = true
            return
        end
        rosterRefreshPending = not refreshGuildRoster()
        return
    end

    if event == "CLUB_MEMBER_ADDED" or event == "CLUB_MEMBER_REMOVED" then
        if isChatMessagingLockedDown() then
            clearCurrentRosterLookup()
            rosterRefreshPending = true
            return
        end

        local eventClubId = ...
        local getGuildClubId = C_Club and C_Club.GetGuildClubId
        if type(getGuildClubId) == "function" then
            local ok, guildClubId = pcall(getGuildClubId)
            if ok and guildClubId ~= nil and eventClubId ~= nil
                and eventClubId ~= guildClubId then
                return
            end
        end

        -- The aggregate CLUB_MEMBERS_UPDATED event normally follows. Defer the
        -- full scan until then; the next chat event is a safe fallback trigger.
        clearCurrentRosterLookup()
        rosterRefreshPending = true
        return
    end

    if event == "CLUB_MEMBERS_UPDATED"
        or event == "CLUB_ADDED"
        or event == "CLUB_REMOVED" then
        if isChatMessagingLockedDown() then
            clearCurrentRosterLookup()
            rosterRefreshPending = true
            return
        end

        local eventClubId = ...
        local getGuildClubId = C_Club and C_Club.GetGuildClubId
        if type(getGuildClubId) == "function" then
            local ok, guildClubId = pcall(getGuildClubId)
            if ok and guildClubId ~= nil and eventClubId ~= nil
                and eventClubId ~= guildClubId then
                return
            end
        end

        clearCurrentRosterLookup()
        rosterRefreshPending = not refreshGuildRoster()
        return
    end

    if event == "CLUB_MEMBER_UPDATED" or event == "CLUB_MEMBER_ROLE_UPDATED" then
        if isChatMessagingLockedDown() then
            clearCurrentRosterLookup()
            rosterRefreshPending = true
            return
        end

        local eventClubId, memberId = ...
        if currentGuildClubId == nil or eventClubId ~= currentGuildClubId then
            return
        end

        local getMemberInfo = C_Club and C_Club.GetMemberInfo
        if type(getMemberInfo) ~= "function" then
            return
        end

        local ok, memberInfo = pcall(getMemberInfo, currentGuildClubId, memberId)
        if not ok or type(memberInfo) ~= "table"
            or type(memberInfo.name) ~= "string" or memberInfo.name == "" then
            return
        end

        local canonicalName = resolveCurrentMemberName(memberInfo.name)
        local character = canonicalName and EldgrimDB.members[canonicalName]
        if type(character) == "table" and character.isGuildMember == true then
            applyCharacterProfile(character, memberInfo)
        end
        return
    end

    if event == "CLUB_SELF_MEMBER_ROLE_UPDATED" then
        clearCurrentRosterLookup()
        if isChatMessagingLockedDown() then
            rosterRefreshPending = true
            return
        end
        rosterRefreshPending = not refreshGuildRoster()
        return
    end

    if event == "CLUB_STREAMS_LOADED" then
        if isChatMessagingLockedDown() then
            streamsRefreshPending = true
            return
        end

        local eventClubId = ...
        if currentGuildClubId ~= nil and eventClubId == currentGuildClubId then
            guildStreamId, officerStreamId = readGuildStreamIDs(currentGuildClubId)
            streamsRefreshPending = false
        end
        return
    end

    if CHAT_EVENTS[event] then
        recordChatEvent(event, ...)
    end
end)

local function registerEvent(event)
    -- Some event variants are not emitted by every Forever build. Register the
    -- documented event when present without allowing one missing event to stop
    -- the rest of the recorder from loading.
    pcall(eventFrame.RegisterEvent, eventFrame, event)
end

registerEvent("PLAYER_LOGIN")
registerEvent("PLAYER_GUILD_UPDATE")
registerEvent("INITIAL_CLUBS_LOADED")
registerEvent("CLUB_MEMBERS_UPDATED")
registerEvent("CLUB_ADDED")
registerEvent("CLUB_MEMBER_ADDED")
registerEvent("CLUB_MEMBER_REMOVED")
registerEvent("CLUB_MEMBER_UPDATED")
registerEvent("CLUB_MEMBER_ROLE_UPDATED")
registerEvent("CLUB_SELF_MEMBER_ROLE_UPDATED")
registerEvent("CLUB_REMOVED")
registerEvent("CLUB_STREAMS_LOADED")

for event in pairs(CHAT_EVENTS) do
    registerEvent(event)
end

eventFrame:Hide()
