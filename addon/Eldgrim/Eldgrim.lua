-- Eldgrim - World of Warcraft Forever
-- Passive local counters for current guild members' chat activity.
-- Message contents are never read, stored, displayed, or transmitted.
-- No UI, slash commands, chat output, notifications, sounds, or addon messaging.

local GUILD_CLUB_TYPE = 2
local DATABASE_SCHEMA_VERSION = 3

local ACTIVITY_TYPES = {
    GUILD = true,
    OFFICER = true,
    SAY = true,
    YELL = true,
    WHISPER_IN = true,
    WHISPER_OUT = true,
    PARTY = true,
    RAID = true,
    RAID_WARNING = true,
    INSTANCE = true,
    CHANNEL = true,
    COMMUNITY = true,
    EMOTE = true,
}

-- Each delivered player-chat event becomes one counter increment.
-- The event's message-text argument is deliberately not assigned or inspected.
local CHAT_EVENTS = {
    CHAT_MSG_GUILD = "GUILD",
    CHAT_MSG_OFFICER = "OFFICER",
    CHAT_MSG_SAY = "SAY",
    CHAT_MSG_YELL = "YELL",
    CHAT_MSG_WHISPER = "WHISPER_IN",
    CHAT_MSG_WHISPER_INFORM = "WHISPER_OUT",
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
    CHAT_MSG_TEXT_EMOTE = "EMOTE",
}

local memberNameLookup = {}
local selfMemberName
local currentGuildClubId
local focusedGuildClubId
local clubsInitialized = false
local rosterRefreshPending = false

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

local function cleanCount(value)
    if type(value) == "number" and value >= 0 then
        return math.floor(value)
    end

    return 0
end

local function emptyActivity()
    return {
        total = 0,
        byType = {},
        byDay = {},
    }
end

local function getDayKey(timestamp)
    if type(date) == "function" then
        local ok, dayKey = pcall(date, "%Y-%m-%d", timestamp)
        if ok and type(dayKey) == "string" and dayKey ~= "" then
            return dayKey
        end
    end

    -- Fallback is an epoch-day key, not an individual event timestamp.
    return tostring(math.floor(timestamp / 86400))
end

local function copyTypeCounts(source)
    local result = {}
    if type(source) ~= "table" then
        return result
    end

    for activityType in pairs(ACTIVITY_TYPES) do
        local count = cleanCount(source[activityType])
        if count > 0 then
            result[activityType] = count
        end
    end

    return result
end

local function sumCounts(counts)
    local total = 0
    for _, count in pairs(counts) do
        total = total + count
    end
    return total
end

local function sanitizeActivity(source)
    local activity = emptyActivity()
    if type(source) ~= "table" then
        return activity
    end

    activity.byType = copyTypeCounts(source.byType)
    activity.total = cleanCount(source.total)
    if activity.total == 0 then
        activity.total = sumCounts(activity.byType)
    end

    if type(source.byDay) == "table" then
        for dayKey, sourceDay in pairs(source.byDay) do
            if (type(dayKey) == "string" or type(dayKey) == "number")
                and type(sourceDay) == "table" then
                local day = {
                    total = 0,
                    byType = copyTypeCounts(sourceDay.byType),
                }
                day.total = cleanCount(sourceDay.total)
                if day.total == 0 then
                    day.total = sumCounts(day.byType)
                end

                if day.total > 0 then
                    activity.byDay[tostring(dayKey)] = day
                end
            end
        end
    end

    return activity
end

local function incrementActivity(activity, activityType, dayKey)
    if type(activity) ~= "table" or not ACTIVITY_TYPES[activityType] then
        return
    end

    if type(activity.byType) ~= "table" then
        activity.byType = {}
    end
    if type(activity.byDay) ~= "table" then
        activity.byDay = {}
    end

    activity.total = cleanCount(activity.total) + 1
    activity.byType[activityType] = cleanCount(activity.byType[activityType]) + 1

    if type(dayKey) == "string" and dayKey ~= "" then
        local day = activity.byDay[dayKey]
        if type(day) ~= "table" then
            day = {
                total = 0,
                byType = {},
            }
            activity.byDay[dayKey] = day
        elseif type(day.byType) ~= "table" then
            day.byType = {}
        end

        day.total = cleanCount(day.total) + 1
        day.byType[activityType] = cleanCount(day.byType[activityType]) + 1
    end
end

local function legacyActivityType(messageRecord)
    if type(messageRecord) ~= "table" then
        return nil
    end

    local channel = messageRecord.channel
    if channel == nil then
        channel = "GUILD"
    end

    if channel == "WHISPER" then
        if messageRecord.direction == "OUT" then
            return "WHISPER_OUT"
        end
        return "WHISPER_IN"
    end

    if channel == "TEXT_EMOTE" then
        return "EMOTE"
    end

    if ACTIVITY_TYPES[channel] then
        return channel
    end

    return nil
end

local function aggregateLegacyMessages(activity, messages)
    if type(messages) ~= "table" then
        return
    end

    for _, messageRecord in ipairs(messages) do
        local activityType = legacyActivityType(messageRecord)
        if activityType then
            local dayKey
            if type(messageRecord.timestamp) == "number"
                and messageRecord.timestamp > 0 then
                dayKey = getDayKey(messageRecord.timestamp)
            end

            -- Deliberately never read the old text field, recipient, message ID,
            -- chat-line ID, or any other message payload.
            incrementActivity(activity, activityType, dayKey)
        end
    end
end

local function initializeDatabase()
    local existing = EldgrimDB
    if type(existing) ~= "table" then
        EldgrimDB = {
            schemaVersion = DATABASE_SCHEMA_VERSION,
            members = {},
        }
        return
    end

    local sourceMembers = existing.members
    if type(sourceMembers) ~= "table" then
        -- Version 1 used the character-name map as the database root.
        sourceMembers = existing
    end

    local migratedMembers = {}
    for name, sourceMember in pairs(sourceMembers) do
        if type(name) == "string" and type(sourceMember) == "table" then
            local activity = sanitizeActivity(sourceMember.activity)

            if existing.schemaVersion ~= DATABASE_SCHEMA_VERSION then
                aggregateLegacyMessages(activity, sourceMember.messages)
            end

            -- Whitelist only the character name (the map key), membership
            -- state, and aggregate activity. All profile/message fields vanish.
            migratedMembers[name] = {
                isGuildMember = sourceMember.isGuildMember == true,
                activity = activity,
            }
        end
    end

    EldgrimDB = {
        schemaVersion = DATABASE_SCHEMA_VERSION,
        members = migratedMembers,
    }
end

local function getMemberRecord(name)
    local members = EldgrimDB.members
    local character = members[name]
    if type(character) ~= "table" then
        character = {
            activity = emptyActivity(),
        }
        members[name] = character
    elseif type(character.activity) ~= "table" then
        character.activity = emptyActivity()
    end

    return character
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
                nextCurrentMembers[name] = true
                addMemberNameToLookup(nextLookup, name)

                if memberInfo.isSelf == true then
                    nextSelfMemberName = name
                end
            end
        end
    end

    -- Do not mark missing entries as former unless every roster row was read.
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

    -- A partial scan is fail-closed for capture: only names read successfully
    -- are eligible, and unread members are not marked former.
    return true
end

local function resolveCurrentMemberName(name)
    local key = normalizeCharacterName(name)
    return key and memberNameLookup[key] or nil
end

local function recordChatEvent(event, ...)
    -- Do not inspect chat payloads while the client has chat-messaging lockdown.
    if isChatMessagingLockedDown() then
        return
    end

    if rosterRefreshPending then
        clearCurrentRosterLookup()
        rosterRefreshPending = not refreshGuildRoster()
    end

    local activityType = CHAT_EVENTS[event]
    if not activityType then
        return
    end

    -- select(2, ...) retrieves only the speaker field. The first argument,
    -- containing message text, is never assigned to a local or inspected.
    local playerName = select(2, ...)

    -- Community events may represent Discord relays rather than in-game chat.
    if event == "CHAT_MSG_COMMUNITIES_CHANNEL"
        and select("#", ...) >= 18
        and type(select(18, ...)) == "table" then
        return
    end

    local speakerName = playerName
    if event == "CHAT_MSG_WHISPER_INFORM" then
        -- Outgoing whisper events identify the recipient in playerName.
        -- Count the activity for this local character, without saving recipient.
        speakerName = selfMemberName
    end

    local canonicalName = resolveCurrentMemberName(speakerName)
    if not canonicalName then
        return
    end

    local character = EldgrimDB.members[canonicalName]
    if type(character) ~= "table" or character.isGuildMember ~= true then
        return
    end

    local dayKey
    if type(time) == "function" then
        local ok, timestamp = pcall(time)
        if ok and type(timestamp) == "number" and timestamp > 0 then
            dayKey = getDayKey(timestamp)
        end
    end

    incrementActivity(character.activity, activityType, dayKey)
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

        -- The aggregate CLUB_MEMBERS_UPDATED event normally follows.
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

    if CHAT_EVENTS[event] then
        recordChatEvent(event, ...)
    end
end)

local function registerEvent(event)
    -- Some event variants are not emitted by every Forever build. Register
    -- documented variants without allowing one missing event to stop loading.
    pcall(eventFrame.RegisterEvent, eventFrame, event)
end

registerEvent("PLAYER_LOGIN")
registerEvent("PLAYER_GUILD_UPDATE")
registerEvent("INITIAL_CLUBS_LOADED")
registerEvent("CLUB_MEMBERS_UPDATED")
registerEvent("CLUB_ADDED")
registerEvent("CLUB_MEMBER_ADDED")
registerEvent("CLUB_MEMBER_REMOVED")
registerEvent("CLUB_REMOVED")

for event in pairs(CHAT_EVENTS) do
    registerEvent(event)
end

eventFrame:Hide()
