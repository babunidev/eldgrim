-- Eldgrim - World of Warcraft Forever
-- First milestone: passive, local guild-chat recording only.

local GUILD_CLUB_TYPE = 2
local RECENT_MESSAGE_KEY_LIMIT = 128

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

    local timestamp = communityTimestamp
    if type(timestamp) ~= "number" then
        timestamp = type(time) == "function" and time() or nil
    end

    if type(timestamp) ~= "number" then
        return
    end

    character.messages[#character.messages + 1] = {
        timestamp = timestamp,
        message = message,
    }
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_GUILD")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event ~= "CHAT_MSG_GUILD" then
        return
    end

    -- Do not inspect any event payload until the chat restriction check passes.
    if isChatMessagingLockedDown() then
        return
    end

    local message, sender = ...
    recordGuildMessage(message, sender)
end)
eventFrame:Hide()
