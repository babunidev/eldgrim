-- Mock test for the Eldgrim Forever addon. This does not replace in-game testing.

local addonFile = arg and arg[1] or "addon/Eldgrim/Eldgrim.lua"
local chunk, syntaxError = loadfile(addonFile)
assert(chunk, syntaxError)

local lockdown = false
local communityInfo
local communityClubType = 2
local frame = {}

function CreateFrame(kind)
    assert(kind == "Frame")
    return frame
end

function frame:RegisterEvent(event)
    self.registeredEvent = event
end

function frame:SetScript(scriptName, callback)
    assert(scriptName == "OnEvent")
    self.onEvent = callback
end

function frame:Hide()
    self.hidden = true
end

C_ChatInfo = {
    InChatMessagingLockdown = function()
        return lockdown
    end,
}

C_Club = {
    GetInfoFromLastCommunityChatLine = function()
        return communityInfo, 44, 2, communityClubType
    end,
}

C_CreatureInfo = {
    GetClassInfo = function(classID)
        if classID == 1 then
            return { className = "Warrior", classFile = "WARRIOR" }
        end
        return nil
    end,
}

time = function()
    return 1800000099
end

EldgrimDB = nil
dofile(addonFile)

assert(frame.registeredEvent == "CHAT_MSG_GUILD", "only guild chat should be registered")
assert(frame.hidden == true, "event frame should remain hidden")

communityInfo = {
    content = "Hello guild",
    messageId = { epoch = 1800000000123456, position = 7 },
    author = {
        name = "Testchar",
        race = 3,
        classID = 1,
        level = 42,
        faction = 1,
        zone = "Ironforge",
        achievementPoints = 123,
        profession1Name = "Mining",
        profession1Rank = 225,
        profession2Name = "Blacksmithing",
        profession2Rank = 180,
        guid = "must-not-be-saved",
        memberId = 999,
        bnetAccountId = 888,
    },
}

frame.onEvent(frame, "CHAT_MSG_GUILD", "Hello guild", "Testchar")
local character = EldgrimDB.Testchar
assert(character and #character.messages == 1)
assert(character.race == "Dwarf")
assert(character.class == "Warrior")
assert(character.level == 42)
assert(character.faction == "Alliance")
assert(character.zone == "Ironforge")
assert(character.achievementPoints == 123)
assert(character.professions[1].name == "Mining" and character.professions[1].skill == 225)
assert(character.professions[2].name == "Blacksmithing" and character.professions[2].skill == 180)
assert(character.messages[1].timestamp == 1800000000)
assert(character.messages[1].message == "Hello guild")

-- A later matched message updates known profile fields without replacing history.
communityInfo = {
    content = "Profile update",
    messageId = { epoch = 1800000001123456, position = 8 },
    author = { name = "Testchar", race = 3, classID = 1, level = 43, faction = 1 },
}
frame.onEvent(frame, "CHAT_MSG_GUILD", "Profile update", "Testchar")
assert(character.level == 43)
assert(#character.messages == 2)
assert(character.messages[1].message == "Hello guild")
assert(character.messages[2].message == "Profile update")

-- The same transient community identifier is not reused for a later event.
communityInfo = {
    content = "Hello guild",
    messageId = { epoch = 1800000000123456, position = 7 },
    author = { name = "Testchar", race = 3, classID = 1, level = 42, faction = 1 },
}
frame.onEvent(frame, "CHAT_MSG_GUILD", "Hello guild", "Testchar")
assert(#character.messages == 3)
assert(character.messages[3].timestamp == 1800000099, "duplicate correlation should use local receipt time")

-- A different author/content must not enrich the current speaker.
communityInfo = {
    content = "Different message",
    messageId = { epoch = 1800000001123456, position = 8 },
    author = { name = "Otherchar", race = 2, classID = 1, level = 10, faction = 0 },
}
frame.onEvent(frame, "CHAT_MSG_GUILD", "Current message", "Currentchar")
assert(EldgrimDB.Currentchar.messages[1].message == "Current message")
assert(EldgrimDB.Currentchar.race == nil and EldgrimDB.Currentchar.class == nil)
assert(EldgrimDB.Currentchar.messages[1].timestamp == 1800000099)

-- A non-guild community record must not enrich the speaker.
communityClubType = 0
communityInfo = {
    content = "Wrong community type",
    messageId = { epoch = 1800000003123456, position = 10 },
    author = { name = "OtherTypechar", race = 2, classID = 1, level = 10, faction = 0 },
}
frame.onEvent(frame, "CHAT_MSG_GUILD", "Wrong community type", "OtherTypechar")
assert(EldgrimDB.OtherTypechar.race == nil)
communityClubType = 2

-- A non-guild event is ignored.
frame.onEvent(frame, "CHAT_MSG_OFFICER", "Officer message", "Officerchar")
assert(EldgrimDB.Officerchar == nil)

-- Lockdown is fail-closed.
lockdown = true
frame.onEvent(frame, "CHAT_MSG_GUILD", "Restricted message", "Restrictedchar")
assert(EldgrimDB.Restrictedchar == nil)
lockdown = false

-- Unknown race and class values are omitted rather than guessed.
communityInfo = {
    content = "Unknown profile",
    messageId = { epoch = 1800000002123456, position = 9 },
    author = { name = "Unknownchar", race = 999, classID = 999, level = 1, faction = 0 },
}
frame.onEvent(frame, "CHAT_MSG_GUILD", "Unknown profile", "Unknownchar")
assert(EldgrimDB.Unknownchar.race == nil and EldgrimDB.Unknownchar.class == nil)

-- Technical identifiers from API records must never enter SavedVariables.
local forbiddenFields = {
    guid = true,
    memberId = true,
    bnetAccountId = true,
    clubId = true,
    streamId = true,
    messageId = true,
    classID = true,
    raceID = true,
}

local function inspectSavedData(value)
    if type(value) ~= "table" then
        return
    end

    for key, nested in pairs(value) do
        assert(not forbiddenFields[key], "technical identifier persisted: " .. tostring(key))
        inspectSavedData(nested)
    end
end

inspectSavedData(EldgrimDB)
print("Eldgrim mock tests passed. These are not in-game tests.")
