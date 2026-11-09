-- Mock tests for the Eldgrim Forever activity counter.
-- These tests do not replace in-game verification.

local addonFile = arg and arg[1] or "addon/Eldgrim/Eldgrim.lua"
local chunk, syntaxError = loadfile(addonFile)
assert(chunk, syntaxError)

local lockdown = false
local clubId = 44
local memberIDs = { 101, 102 }
local membersReady = false
local memberInfo = {
    [101] = {
        name = "Test Character",
        isSelf = true,
        race = 3,
        classID = 1,
        level = 42,
        faction = 1,
        zone = "Ironforge",
        achievementPoints = 123,
        profession1Name = "Mining",
        profession1Rank = 225,
        guildRank = "Guild Master",
        guid = "must-not-be-saved",
        memberId = 101,
        bnetAccountId = 888,
        memberNote = "must-not-be-saved",
        officerNote = "must-not-be-saved",
    },
    [102] = {
        name = "Other Member",
        isSelf = false,
        race = 2,
        classID = 1,
        level = 35,
        faction = 0,
        zone = "Orgrimmar",
        guildRank = "Member",
    },
}
local focusCalls = 0
local communityInfoCalls = 0
local registeredEvents = {}
local frames = {}
local now = 1800000099

function CreateFrame(kind)
    assert(kind == "Frame")
    local frame = {}
    frames[#frames + 1] = frame
    function frame:RegisterEvent(event)
        registeredEvents[event] = true
    end
    function frame:SetScript(scriptName, callback)
        assert(scriptName == "OnEvent")
        self.onEvent = callback
    end
    function frame:Hide()
        self.hidden = true
    end
    return frame
end

C_ChatInfo = {
    InChatMessagingLockdown = function()
        return lockdown
    end,
}

C_Club = {
    GetGuildClubId = function()
        return clubId
    end,
    GetClubInfo = function(id)
        assert(id == 44)
        return { clubType = 2 }
    end,
    FocusMembers = function(id)
        assert(id == 44)
        focusCalls = focusCalls + 1
    end,
    AreMembersReady = function(id)
        assert(id == 44)
        return membersReady
    end,
    GetClubMembers = function(id)
        assert(id == 44)
        return memberIDs
    end,
    GetMemberInfo = function(id, memberID)
        assert(id == 44)
        return memberInfo[memberID]
    end,
    GetInfoFromLastCommunityChatLine = function()
        communityInfoCalls = communityInfoCalls + 1
        error("message-content community API must not be called")
    end,
}

time = function()
    return now
end

date = function(format, timestamp)
    assert(format == "%Y-%m-%d")
    return "day-" .. tostring(math.floor(timestamp / 86400))
end

EldgrimDB = nil
dofile(addonFile)
local frame = frames[#frames]

assert(EldgrimDB.schemaVersion == 3)
assert(registeredEvents.CHAT_MSG_GUILD, "guild chat must be registered")
assert(registeredEvents.CHAT_MSG_OFFICER, "officer chat must be registered")
assert(registeredEvents.CHAT_MSG_SAY, "say must be registered")
assert(registeredEvents.CHAT_MSG_YELL, "yell must be registered")
assert(registeredEvents.CHAT_MSG_WHISPER, "incoming whispers must be registered")
assert(registeredEvents.CHAT_MSG_WHISPER_INFORM, "outgoing whispers must be registered")
assert(registeredEvents.CHAT_MSG_PARTY, "party chat must be registered")
assert(registeredEvents.CHAT_MSG_RAID, "raid chat must be registered")
assert(registeredEvents.CHAT_MSG_CHANNEL, "custom channels must be registered")
assert(registeredEvents.CHAT_MSG_INSTANCE_CHAT, "instance chat must be registered")
assert(registeredEvents.CHAT_MSG_EMOTE, "emotes must be registered")
assert(registeredEvents.CHAT_MSG_TEXT_EMOTE, "text emotes must be registered")
assert(frame.hidden == true, "event frame should remain hidden")

frame.onEvent(frame, "INITIAL_CLUBS_LOADED")
assert(focusCalls == 1, "guild member focus should be requested once")
assert(EldgrimDB.members["Test Character"] == nil, "roster must wait until members are ready")
membersReady = true
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)

local self = EldgrimDB.members["Test Character"]
local other = EldgrimDB.members["Other Member"]
assert(self and other, "every current guild member should receive an entry")
assert(self.isGuildMember == true)
assert(other.isGuildMember == true)
assert(self.activity.total == 0, "roster-only members start with zero activity")
assert(type(self.activity.byType) == "table")
assert(type(self.activity.byDay) == "table")
assert(self.guildRank == nil and self.race == nil and self.class == nil,
    "character profile details must not be stored")
assert(self.messages == nil, "message arrays must not exist")
assert(focusCalls == 1, "ordinary roster refreshes must not refocus the same guild")

local function fire(event, textPayload, sender, ...)
    frame.onEvent(frame, event, textPayload, sender, ...)
end

-- Each player-chat event increments a counter. The content strings below are
-- deliberately sensitive test fixtures and must never appear in SavedVariables.
fire("CHAT_MSG_GUILD", "private guild phrase", "Other Member")
fire("CHAT_MSG_OFFICER", "private officer phrase", "Other Member")
fire("CHAT_MSG_SAY", "private say phrase", "Other Member")
fire("CHAT_MSG_YELL", "private yell phrase", "Other Member")
fire("CHAT_MSG_WHISPER", "private incoming whisper", "Other Member")
fire("CHAT_MSG_PARTY", "private party phrase", "Other Member")
fire("CHAT_MSG_PARTY_LEADER", "private party leader phrase", "Other Member")
fire("CHAT_MSG_RAID", "private raid phrase", "Other Member")
fire("CHAT_MSG_RAID_LEADER", "private raid leader phrase", "Other Member")
fire("CHAT_MSG_RAID_WARNING", "private raid warning", "Other Member")
fire("CHAT_MSG_INSTANCE_CHAT", "private instance phrase", "Other Member")
fire("CHAT_MSG_INSTANCE_CHAT_LEADER", "private instance leader phrase", "Other Member")
fire("CHAT_MSG_CHANNEL", "private trade phrase", "Other Member", "", "Trade - Ironforge")
fire("CHAT_MSG_COMMUNITIES_CHANNEL", "private community phrase", "Other Member")
fire("CHAT_MSG_EMOTE", "private emote text", "Other Member")
fire("CHAT_MSG_TEXT_EMOTE", "Other Member waves privately.", "Other Member")

-- Both emote event families become one general EMOTE activity category.
assert(other.activity.total == 16)
assert(other.activity.byType.GUILD == 1)
assert(other.activity.byType.OFFICER == 1)
assert(other.activity.byType.SAY == 1)
assert(other.activity.byType.YELL == 1)
assert(other.activity.byType.WHISPER_IN == 1)
assert(other.activity.byType.PARTY == 2)
assert(other.activity.byType.RAID == 2)
assert(other.activity.byType.RAID_WARNING == 1)
assert(other.activity.byType.INSTANCE == 2)
assert(other.activity.byType.CHANNEL == 1)
assert(other.activity.byType.COMMUNITY == 1)
assert(other.activity.byType.EMOTE == 2)
assert(other.activity.byDay["day-" .. tostring(math.floor(now / 86400))].total == 16)

-- A Discord-relayed community event is not an in-game guild-member activity.
local beforeDiscordRelay = other.activity.total
frame.onEvent(frame, "CHAT_MSG_COMMUNITIES_CHANNEL",
    "private Discord relay", "Other Member",
    "", "Hearth", "", "", 0, 1, "Hearth",
    nil, nil, nil, nil, nil, nil, nil, nil, { userName = "Discord User" })
assert(other.activity.total == beforeDiscordRelay)

-- Outgoing whisper activity belongs to the local guild member. The recipient
-- and the text are not stored, even when the recipient is not a guild member.
fire("CHAT_MSG_WHISPER_INFORM", "private outgoing whisper", "Nonmember Recipient")
assert(self.activity.total == 1)
assert(self.activity.byType.WHISPER_OUT == 1)

-- Own guild/say/yell messages count under the local character as well.
fire("CHAT_MSG_GUILD", "my private guild phrase", "Test Character")
fire("CHAT_MSG_SAY", "my private say phrase", "Test Character")
fire("CHAT_MSG_YELL", "my private yell phrase", "Test Character")
assert(self.activity.total == 4)
assert(self.activity.byType.GUILD == 1)
assert(self.activity.byType.SAY == 1)
assert(self.activity.byType.YELL == 1)

-- Nonmembers and unrelated system events do not create entries or counters.
local countBefore = other.activity.total
fire("CHAT_MSG_YELL", "private nonmember phrase", "Unlisted Player")
fire("CHAT_MSG_SYSTEM", "system text", "Other Member")
assert(other.activity.total == countBefore)
assert(EldgrimDB.members["Unlisted Player"] == nil)

-- Full names and separator variants resolve to the existing guild member.
fire("CHAT_MSG_YELL", "another private yell", "other-member")
assert(other.activity.byType.YELL == 2)
assert(other.activity.total == 17)

-- Roster update: retain former member's aggregates, add a new member.
memberIDs = { 101, 103 }
memberInfo[103] = { name = "New Member", isSelf = false }
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)
assert(other.isGuildMember == false, "departed member should be retained but marked former")
assert(other.activity.total == 17, "former member activity must be preserved")
assert(EldgrimDB.members["New Member"], "new member should receive an entry")
assert(EldgrimDB.members["New Member"].activity.total == 0)
assert(EldgrimDB.members["New Member"].isGuildMember == true)
assert(self.isGuildMember == true)

-- Rejoining restores the existing member entry and its accumulated counters.
memberIDs = { 101, 102, 103 }
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)
assert(other.isGuildMember == true, "a rejoining member should become current again")

-- A partial roster scan must not mark a currently known member as former.
memberIDs = { 101, 102, 103, 104 }
memberInfo[104] = nil
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)
assert(other.isGuildMember == true,
    "an incomplete scan must not mark a known current member as former")

-- Lockdown blocks both chat counting and roster API access.
local rosterCalls = 0
local originalGetClubMembers = C_Club.GetClubMembers
C_Club.GetClubMembers = function(...)
    rosterCalls = rosterCalls + 1
    return originalGetClubMembers(...)
end
memberIDs = { 101, 103 }
lockdown = true
local lockedCount = self.activity.total
frame.onEvent(frame, "CHAT_MSG_GUILD", "restricted private message", "Test Character")
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)
assert(self.activity.total == lockedCount)
assert(rosterCalls == 0, "roster APIs must not be called during lockdown")
lockdown = false
fire("CHAT_MSG_YELL", "private message after lockdown", "New Member")
assert(rosterCalls == 1, "pending roster refresh should run after lockdown")
assert(EldgrimDB.members["New Member"].activity.byType.YELL == 1)
assert(other.isGuildMember == false)

-- Leaving the guild marks all known members former without deleting aggregates.
clubId = nil
frame.onEvent(frame, "PLAYER_GUILD_UPDATE", "player")
assert(self.isGuildMember == false)
assert(other.isGuildMember == false)
assert(EldgrimDB.members["New Member"].isGuildMember == false)
assert(self.activity.total == lockedCount)

-- Ensure the database contains no message text, individual message records,
-- exact event timestamps, recipients, profile details, or technical IDs.
local forbiddenKeys = {
    messages = true,
    message = true,
    timestamp = true,
    messageId = true,
    chatLineId = true,
    recipient = true,
    direction = true,
    channelName = true,
    guid = true,
    memberId = true,
    clubId = true,
    streamId = true,
    bnetAccountId = true,
    classID = true,
    raceID = true,
    guildRank = true,
    race = true,
    class = true,
    level = true,
    faction = true,
    zone = true,
    professions = true,
    achievementPoints = true,
    memberNote = true,
    officerNote = true,
    presence = true,
    isMobile = true,
}
local forbiddenValues = {
    ["private guild phrase"] = true,
    ["private officer phrase"] = true,
    ["private say phrase"] = true,
    ["private yell phrase"] = true,
    ["private incoming whisper"] = true,
    ["private party phrase"] = true,
    ["private party leader phrase"] = true,
    ["private raid phrase"] = true,
    ["private raid leader phrase"] = true,
    ["private raid warning"] = true,
    ["private instance phrase"] = true,
    ["private instance leader phrase"] = true,
    ["private trade phrase"] = true,
    ["private community phrase"] = true,
    ["private emote text"] = true,
    ["Other Member waves privately."] = true,
    ["private Discord relay"] = true,
    ["private outgoing whisper"] = true,
    ["my private guild phrase"] = true,
    ["my private say phrase"] = true,
    ["my private yell phrase"] = true,
    ["private nonmember phrase"] = true,
    ["system text"] = true,
    ["another private yell"] = true,
    ["restricted private message"] = true,
    ["private message after lockdown"] = true,
    ["Nonmember Recipient"] = true,
    ["old private guild text"] = true,
    ["old private officer text"] = true,
    ["old private whisper text"] = true,
    ["old private emote text"] = true,
    ["Old Recipient"] = true,
    ["old v1 guild text"] = true,
}

local function inspectSavedData(value)
    if type(value) ~= "table" then
        if type(value) == "string" then
            assert(not forbiddenValues[value], "message content or recipient was persisted")
        end
        return
    end

    for key, nested in pairs(value) do
        assert(not forbiddenKeys[key], "forbidden field persisted: " .. tostring(key))
        inspectSavedData(nested)
    end
end

inspectSavedData(EldgrimDB)
assert(communityInfoCalls == 0,
    "message-content community API must not be called for activity counting")

-- Schema 2 migration aggregates old message records, then discards every
-- message string and character-profile field.
EldgrimDB = {
    schemaVersion = 2,
    members = {
        ["Legacy Member"] = {
            isGuildMember = true,
            guildRank = "Officer",
            race = "Dwarf",
            class = "Warrior",
            level = 60,
            messages = {
                { timestamp = 1800000000, channel = "GUILD", message = "old private guild text" },
                { timestamp = 1800000060, channel = "OFFICER", message = "old private officer text" },
                { timestamp = 1800000120, channel = "WHISPER", direction = "OUT",
                    recipient = "Old Recipient", message = "old private whisper text" },
                { timestamp = 1800000180, channel = "TEXT_EMOTE", message = "old private emote text" },
            },
        },
    },
}
dofile(addonFile)
frame = frames[#frames]
local legacy = EldgrimDB.members["Legacy Member"]
assert(EldgrimDB.schemaVersion == 3)
assert(legacy.activity.total == 4)
assert(legacy.activity.byType.GUILD == 1)
assert(legacy.activity.byType.OFFICER == 1)
assert(legacy.activity.byType.WHISPER_OUT == 1)
assert(legacy.activity.byType.EMOTE == 1)
assert(legacy.messages == nil)
assert(legacy.guildRank == nil and legacy.race == nil and legacy.class == nil and legacy.level == nil)
assert(legacy.activity.byDay["day-" .. tostring(math.floor(1800000000 / 86400))].total == 4)
inspectSavedData(EldgrimDB)

-- A schema-3 database is also sanitized on load, so stale extra fields cannot
-- survive a future manual edit or interrupted upgrade.
EldgrimDB = {
    schemaVersion = 3,
    members = {
        ["Clean Member"] = {
            isGuildMember = true,
            guildRank = "must-be-dropped",
            messages = { { message = "must-be-dropped" } },
            activity = {
                total = 2,
                byType = { GUILD = 2 },
                byDay = {},
            },
        },
    },
}
dofile(addonFile)
local clean = EldgrimDB.members["Clean Member"]
assert(clean.activity.total == 2)
assert(clean.messages == nil and clean.guildRank == nil)
inspectSavedData(EldgrimDB)

-- The original schema-1 database used the member-name map as its root.
EldgrimDB = {
    ["Legacy V1 Member"] = {
        level = 10,
        messages = {
            { timestamp = 1800000240, message = "old v1 guild text" },
        },
    },
}
dofile(addonFile)
local legacyV1 = EldgrimDB.members["Legacy V1 Member"]
assert(EldgrimDB.schemaVersion == 3)
assert(legacyV1.activity.total == 1)
assert(legacyV1.activity.byType.GUILD == 1)
assert(legacyV1.messages == nil and legacyV1.level == nil)
inspectSavedData(EldgrimDB)

print("Eldgrim privacy-first activity-counter mock tests passed. These are not in-game tests.")
