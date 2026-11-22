-- Eldgrim - World of Warcraft Forever
-- Passive local archive: full guild-chat lines, plus a guild roster refreshed once a day
-- and again when a rank changes or a member joins.
-- /eldgrim whispers the guild invitation to the current target.

local GUILD_CLUB_TYPE = 2
local RECENT_MESSAGE_KEY_LIMIT = 128
local ROSTER_UPDATE_INTERVAL = 24 * 60 * 60
local GUILD_INVITE_WHISPER = "Greetings, adventurer! I see ye've no guild banner! Fancy joining <Amberhearth>? We wander, swap tales, an' gather by the bonfire every Sunday eve for Eldgrim's stories, a dance, or a good laugh. No fuss, just good company. Cheers!"

-- Forever race IDs: eight original races plus the two faction-specific Skyborne records.
-- High Order Skyborne ID 95 is documented in the 1.60.1 pre-launch race data;
-- confirm that mapping against the installed live client during in-game testing.
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

-- Community message identifiers are used only in memory to avoid reusing a
-- stale GetInfoFromLastCommunityChatLine() result. They are never saved.
local recentMessageKeys = {}
local recentMessageQueue = {}
local nextRecentMessageSlot = 1

if type(EldgrimDB) ~= "table" then
    EldgrimDB = {}
end

if type(EldgrimRoster) ~= "table" then
    EldgrimRoster = {}
end

local rosterRequestPending = false

local function isChatMessagingLockedDown()
    local api = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown
    if type(api) ~= "function" then
        -- Fail closed: the event payload is restricted when lockdown is active.
        return true
    end

    local ok, restricted = pcall(api)
    return not ok or restricted ~= false
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

local function buildCharacterProfile(author)
    local profile = {}

    local raceName = RACE_NAMES[author.race]
    if raceName then
        profile.race = raceName
    end

    local classID = author.classID
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

    if type(author.level) == "number" and author.level > 0 then
        profile.level = author.level
    end

    local factionName = FACTION_NAMES[author.faction]
    if factionName then
        profile.faction = factionName
    end

    if type(author.zone) == "string" and author.zone ~= "" then
        profile.zone = author.zone
    end

    if type(author.achievementPoints) == "number" and author.achievementPoints >= 0 then
        profile.achievementPoints = author.achievementPoints
    end

    local professions = {}

    local function addProfession(name, skill)
        if type(name) ~= "string" or name == "" then
            return
        end

        local profession = {
            name = name,
        }

        if type(skill) == "number" and skill >= 0 then
            profession.skill = skill
        end

        professions[#professions + 1] = profession
    end

    addProfession(author.profession1Name, author.profession1Rank)
    addProfession(author.profession2Name, author.profession2Rank)

    if #professions > 0 then
        profile.professions = professions
    end

    return profile
end

local function getMatchedCommunityData(message, sender)
    local api = C_Club and C_Club.GetInfoFromLastCommunityChatLine
    if type(api) ~= "function" then
        return nil, nil
    end

    local ok, profile, timestamp, messageKey = pcall(function()
        local messageInfo, _, _, clubType = api()
        if clubType ~= GUILD_CLUB_TYPE or type(messageInfo) ~= "table" then
            return nil
        end

        local author = messageInfo.author
        if type(author) ~= "table" then
            return nil
        end

        if type(messageInfo.content) ~= "string" or messageInfo.content ~= message then
            return nil
        end

        if type(author.name) ~= "string" or author.name ~= sender then
            return nil
        end

        local matchedTimestamp
        local matchedKey
        local messageID = messageInfo.messageId
        if type(messageID) == "table" then
            local epoch = messageID.epoch
            local position = messageID.position

            if type(epoch) == "number" and epoch > 0 then
                matchedTimestamp = math.floor(epoch / 1000000)
            end

            if type(epoch) == "number" and epoch > 0 and type(position) == "number" then
                matchedKey = tostring(epoch) .. ":" .. tostring(position)
                if recentMessageKeys[matchedKey] then
                    return nil
                end
            end
        end

        return buildCharacterProfile(author), matchedTimestamp, matchedKey
    end)

    if not ok or type(timestamp) ~= "number" then
        -- A matched author record without a usable timestamp can still enrich
        -- the profile; the caller will use local receipt time for the message.
        if not ok or profile == nil then
            return nil, nil
        end
    end

    if messageKey then
        rememberMessageKey(messageKey)
    end

    return profile, timestamp
end

local function playerInGuild()
    if type(IsInGuild) ~= "function" then
        return false
    end

    local ok, inGuild = pcall(IsInGuild)
    return ok and not not inGuild
end

local function rosterIsDue()
    local updated = EldgrimRoster.updated
    if type(updated) ~= "number" then
        return true
    end

    if type(time) ~= "function" then
        return false
    end

    local now = time()
    return type(now) == "number" and (now - updated) >= ROSTER_UPDATE_INTERVAL
end

local function characterName(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    if type(GetRealmName) == "function" then
        local ok, realm = pcall(GetRealmName)
        if ok and type(realm) == "string" and realm ~= "" then
            local suffix = "-" .. realm
            if name:sub(-#suffix) == suffix then
                name = name:sub(1, -#suffix - 1)
            end
        end
    end

    if name == "" then
        return nil
    end

    return name
end

local function copyMemberProfile(target, member)
    if type(member.class) == "string" and member.class ~= "" then
        target.class = member.class
    end

    if type(member.level) == "number" and member.level > 0 then
        target.level = member.level
    end

    if type(member.race) == "string" and member.race ~= "" then
        target.race = member.race
    end

    if type(member.rank) == "string" and member.rank ~= "" then
        target.rank = member.rank
    end

    if type(member.faction) == "string" and member.faction ~= "" then
        target.faction = member.faction
    end

    if type(member.achievementPoints) == "number" and member.achievementPoints >= 0 then
        target.achievementPoints = member.achievementPoints
    end

    if type(member.zone) == "string" and member.zone ~= "" then
        target.zone = member.zone
    end

    if type(member.professions) == "table" and #member.professions > 0 then
        local professions = {}
        for index = 1, #member.professions do
            local profession = member.professions[index]
            if type(profession) == "table" and type(profession.name) == "string" and profession.name ~= "" then
                local copy = {
                    name = profession.name,
                }
                if type(profession.skill) == "number" and profession.skill >= 0 then
                    copy.skill = profession.skill
                end
                professions[#professions + 1] = copy
            end
        end

        if #professions > 0 then
            target.professions = professions
        end
    end
end

local function readLastOnline(index)
    if type(GetGuildRosterLastOnline) ~= "function" then
        return nil
    end

    local ok, years, months, days, hours = pcall(GetGuildRosterLastOnline, index)
    if not ok then
        return nil
    end

    local lastOnline = {}
    if type(years) == "number" and years > 0 then
        lastOnline.years = years
    end
    if type(months) == "number" and months > 0 then
        lastOnline.months = months
    end
    if type(days) == "number" and days > 0 then
        lastOnline.days = days
    end
    if type(hours) == "number" and hours > 0 then
        lastOnline.hours = hours
    end

    if next(lastOnline) == nil then
        return nil
    end

    return lastOnline
end

local function enrichMembersFromClub(members)
    if type(C_Club) ~= "table" then
        return
    end

    local getClubId = C_Club.GetGuildClubId
    local getMembers = C_Club.GetClubMembers
    local getMemberInfo = C_Club.GetMemberInfo
    if type(getClubId) ~= "function" or type(getMembers) ~= "function" or type(getMemberInfo) ~= "function" then
        return
    end

    local ok, clubId = pcall(getClubId)
    if not ok or clubId == nil then
        return
    end

    local membersOk, memberIds = pcall(getMembers, clubId)
    if not membersOk or type(memberIds) ~= "table" then
        return
    end

    for index = 1, #memberIds do
        local infoOk, info = pcall(getMemberInfo, clubId, memberIds[index])
        if infoOk and type(info) == "table" then
            local name = characterName(info.name)
            local member = name and members[name]
            if member then
                local profile = buildCharacterProfile(info)
                copyMemberProfile(member, profile)
                if type(info.guildRank) == "string" and info.guildRank ~= "" then
                    member.rank = info.guildRank
                end
            end
        end
    end
end

local function saveGuildRoster()
    if type(GetNumGuildMembers) ~= "function" or type(GetGuildRosterInfo) ~= "function" then
        return false
    end

    local countOk, count = pcall(GetNumGuildMembers)
    if not countOk or type(count) ~= "number" or count <= 0 then
        return false
    end

    local faction
    if type(UnitFactionGroup) == "function" then
        local factionOk, factionName = pcall(UnitFactionGroup, "player")
        if factionOk and (factionName == "Alliance" or factionName == "Horde") then
            faction = factionName
        end
    end

    local members = {}
    local seen = 0

    for index = 1, count do
        local infoOk, name, rankName, rankIndex, level, className, zone, publicNote, _, isOnline, _, _, achievementPoints = pcall(GetGuildRosterInfo, index)
        name = infoOk and characterName(name) or nil
        if name then
            local online = isOnline == true or isOnline == 1
            local member = {
                online = online,
            }

            if type(rankName) == "string" and rankName ~= "" then
                member.rank = rankName
            end
            if type(rankIndex) == "number" and rankIndex >= 0 then
                member.rankIndex = rankIndex
            end
            if type(level) == "number" and level > 0 then
                member.level = level
            end
            if type(className) == "string" and className ~= "" then
                member.class = className
            end
            if type(zone) == "string" and zone ~= "" then
                member.zone = zone
            end
            if type(publicNote) == "string" and publicNote ~= "" then
                member.note = publicNote
            end
            if type(achievementPoints) == "number" and achievementPoints >= 0 then
                member.achievementPoints = achievementPoints
            end
            if faction then
                member.faction = faction
            end

            local lastOnline = readLastOnline(index)
            if lastOnline and not online then
                member.lastOnline = lastOnline
            end

            members[name] = member
            seen = seen + 1
        end
    end

    if seen == 0 then
        return false
    end

    enrichMembersFromClub(members)

    for name, character in pairs(EldgrimDB) do
        local member = members[name]
        if type(character) == "table" and type(member) == "table" then
            copyMemberProfile(character, member)
        end
    end

    local guildName
    if type(GetGuildInfo) == "function" then
        local guildOk, name = pcall(GetGuildInfo, "player")
        if guildOk and type(name) == "string" and name ~= "" then
            guildName = name
        end
    end

    local now = type(time) == "function" and time() or nil
    if type(now) ~= "number" then
        return false
    end

    EldgrimRoster.guild = guildName
    EldgrimRoster.updated = now
    EldgrimRoster.members = members
    return true
end

-- A promotion or a new member should not wait a day. When the client reports a
-- roster update anyway, compare ranks and names with the saved roster, and save
-- at once if a listed member's rank changed or a new member appeared. A shorter
-- list waits for the daily refresh, so a partly loaded roster removes nobody.
local function rosterChanged()
    local saved = EldgrimRoster.members
    if type(saved) ~= "table" then
        return false
    end
    if type(GetNumGuildMembers) ~= "function" or type(GetGuildRosterInfo) ~= "function" then
        return false
    end
    local countOk, count = pcall(GetNumGuildMembers)
    if not countOk or type(count) ~= "number" or count <= 0 then
        return false
    end
    local savedCount = 0
    for _ in pairs(saved) do
        savedCount = savedCount + 1
    end
    if count < savedCount then
        return false
    end
    for index = 1, count do
        local ok, name, rankName = pcall(GetGuildRosterInfo, index)
        name = ok and characterName(name) or nil
        if name then
            local member = saved[name]
            if type(member) ~= "table" then
                return true
            end
            if type(rankName) == "string" and rankName ~= "" and member.rank ~= rankName then
                return true
            end
        end
    end
    return false
end

local function requestRosterIfDue()
    if rosterRequestPending or not rosterIsDue() or not playerInGuild() then
        return
    end

    local api = C_GuildInfo and C_GuildInfo.GuildRoster
    if type(api) ~= "function" then
        api = GuildRoster
    end
    if type(api) ~= "function" then
        return
    end

    rosterRequestPending = true
    if not pcall(api) then
        rosterRequestPending = false
    end
end

local function getCharacterRecord(sender)
    local character = EldgrimDB[sender]
    if type(character) ~= "table" then
        character = {}
        EldgrimDB[sender] = character
    end

    if type(character.messages) ~= "table" then
        character.messages = {}
    end

    return character
end

local function recordGuildMessage(message, sender)
    if type(message) ~= "string" or message == ""
        or type(sender) ~= "string" or sender == "" then
        return
    end

    local profile, communityTimestamp = getMatchedCommunityData(message, sender)
    local character = getCharacterRecord(sender)

    if type(profile) == "table" then
        for field, value in pairs(profile) do
            character[field] = value
        end
    end

    local rosterMember = EldgrimRoster.members and EldgrimRoster.members[sender]
    if type(rosterMember) == "table" then
        copyMemberProfile(character, rosterMember)
    end

    local timestamp = communityTimestamp
    if type(timestamp) ~= "number" then
        timestamp = type(time) == "function" and time() or nil
    end

    if type(timestamp) ~= "number" then
        return
    end

    -- Keep the full line. The list length is the count; the text is the record.
    character.messages[#character.messages + 1] = {
        timestamp = timestamp,
        message = message,
    }
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_GUILD")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "CHAT_MSG_GUILD" then
        -- Do not inspect any event payload until the chat restriction check passes.
        if isChatMessagingLockedDown() then
            return
        end

        local message, sender = ...
        if type(EldgrimHoldGuildLine) == "function" and EldgrimHoldGuildLine(message, sender) then
            return
        end
        recordGuildMessage(message, sender)
        return
    end

    if event == "GUILD_ROSTER_UPDATE" then
        local canRequestRosterUpdate = ...
        if canRequestRosterUpdate == true then
            requestRosterIfDue()
            return
        end

        if rosterRequestPending or rosterIsDue() or rosterChanged() then
            if saveGuildRoster() then
                rosterRequestPending = false
            end
        end
        return
    end

    requestRosterIfDue()
end)
eventFrame:Hide()

local function eldgrimSay(text)
    print("Eldgrim: " .. text)
end

local function whisperPlayerName(unit)
    if type(UnitExists) ~= "function" or not UnitExists(unit) then
        return nil, "notarget"
    end

    if type(UnitIsPlayer) == "function" then
        local ok, isPlayer = pcall(UnitIsPlayer, unit)
        if not ok or not isPlayer then
            return nil, "notplayer"
        end
    end

    if type(UnitIsUnit) == "function" then
        local ok, isSelf = pcall(UnitIsUnit, unit, "player")
        if ok and isSelf then
            return nil, "self"
        end
    end

    if type(UnitIsInMyGuild) == "function" then
        local ok, inGuild = pcall(UnitIsInMyGuild, unit)
        if ok and inGuild then
            return nil, "guild"
        end
    end

    if type(UnitName) ~= "function" then
        return nil, "notarget"
    end

    local ok, name, realm = pcall(UnitName, unit)
    if not ok or type(name) ~= "string" or name == "" or name == UNKNOWNOBJECT then
        return nil, "notarget"
    end

    if type(realm) == "string" and realm ~= "" then
        name = name .. "-" .. realm
    end

    return name
end

local function alreadyOnRoster(name)
    local members = EldgrimRoster and EldgrimRoster.members
    if type(members) ~= "table" or type(name) ~= "string" then
        return false
    end

    if members[name] then
        return true
    end

    local shortName = characterName(name)
    return shortName ~= nil and members[shortName] ~= nil
end

local function sendGuildInviteWhisper(target)
    local api = C_ChatInfo and C_ChatInfo.SendChatMessage
    if type(api) == "function" and pcall(api, GUILD_INVITE_WHISPER, "WHISPER", nil, target) then
        return true
    end

    if type(SendChatMessage) == "function" then
        return pcall(SendChatMessage, GUILD_INVITE_WHISPER, "WHISPER", nil, target)
    end

    return false
end

local function inviteTarget(rawName)
    local target = type(rawName) == "string" and rawName:match("^%s*(.-)%s*$") or ""
    if target == "" then
        local name, reason = whisperPlayerName("target")
        if not name then
            if reason == "notplayer" then
                eldgrimSay("Target a player.")
            elseif reason == "self" then
                eldgrimSay("You cannot invite yourself.")
            elseif reason == "guild" then
                eldgrimSay("That player is already in the guild.")
            else
                eldgrimSay("Target a player first.")
            end
            return
        end
        target = name
    elseif alreadyOnRoster(target) then
        eldgrimSay("That player is already in the guild.")
        return
    end

    if sendGuildInviteWhisper(target) then
        return
    end

    eldgrimSay("The whisper could not be sent.")
end

SLASH_ELDGRIM1 = "/eldgrim"
SlashCmdList["ELDGRIM"] = function(message)
    -- The board opens only when the text after the command is exactly "log".
    if message == "log" then
        if type(EldgrimOpenHearth) == "function" then
            EldgrimOpenHearth()
        end
        return
    end
    inviteTarget(message)
end
