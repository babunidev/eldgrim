-- Mock test for the Eldgrim Forever addon. This does not replace in-game testing.

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
        profession2Name = "Blacksmithing",
        profession2Rank = 180,
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
local communityInfo
local communityClubId = 44
local communityStreamId = 10
local communityClubType = 2
local focusCalls = 0
local registeredEvents = {}
local frame = {}

function CreateFrame(kind)
    assert(kind == "Frame")
    return frame
end

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
    GetStreams = function(id)
        assert(id == 44)
        return {
            { streamId = 10, streamType = 1 },
            { streamId = 11, streamType = 2 },
        }
    end,
    GetInfoFromLastCommunityChatLine = function()
        return communityInfo, communityClubId, communityStreamId, communityClubType
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

assert(registeredEvents.CHAT_MSG_GUILD, "guild chat must be registered")
assert(registeredEvents.CHAT_MSG_OFFICER, "officer chat must be registered")
assert(registeredEvents.CHAT_MSG_YELL, "yell must be registered")
assert(registeredEvents.CHAT_MSG_WHISPER, "incoming whispers must be registered")
assert(registeredEvents.CHAT_MSG_WHISPER_INFORM, "outgoing whispers must be registered")
assert(registeredEvents.CHAT_MSG_PARTY, "party chat must be registered")
assert(registeredEvents.CHAT_MSG_RAID, "raid chat must be registered")
assert(registeredEvents.CHAT_MSG_CHANNEL, "custom channels must be registered")
assert(registeredEvents.CHAT_MSG_INSTANCE_CHAT, "instance chat must be registered")
assert(registeredEvents.CLUB_MEMBER_UPDATED, "member profile updates must be registered")
assert(registeredEvents.CLUB_MEMBER_ROLE_UPDATED, "member rank updates must be registered")
assert(registeredEvents.CLUB_SELF_MEMBER_ROLE_UPDATED, "self rank updates must be registered")
assert(registeredEvents.CLUB_ADDED, "guild club addition must be registered")
assert(registeredEvents.CLUB_REMOVED, "guild removal must be registered")
assert(frame.hidden == true, "event frame should remain hidden")

frame.onEvent(frame, "INITIAL_CLUBS_LOADED")
assert(focusCalls == 1, "guild member focus should be requested once")
assert(EldgrimDB.members["Test Character"] == nil, "roster must wait until members are ready")
membersReady = true
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)
assert(EldgrimDB.schemaVersion == 2)
assert(EldgrimDB.members["Test Character"], "self roster entry should be created")
assert(EldgrimDB.members["Other Member"], "other roster entry should be created")
assert(EldgrimDB.members["Test Character"].isGuildMember == true)
assert(EldgrimDB.members["Test Character"].guildRank == "Guild Master")
assert(EldgrimDB.members["Test Character"].race == "Dwarf")
assert(EldgrimDB.members["Test Character"].class == "Warrior")
assert(EldgrimDB.members["Test Character"].level == 42)
assert(EldgrimDB.members["Test Character"].faction == "Alliance")
assert(EldgrimDB.members["Test Character"].zone == "Ironforge")
assert(EldgrimDB.members["Test Character"].achievementPoints == 123)
assert(EldgrimDB.members["Test Character"].professions[1].name == "Mining")
assert(EldgrimDB.members["Test Character"].messages[1] == nil, "roster-only members start with empty history")
assert(focusCalls == 1, "ordinary roster refreshes must not refocus the same guild")

-- Guild message: matched guild stream, author and content provide the source timestamp.
communityInfo = {
    content = "Hello guild",
    messageId = { epoch = 1800000000123456, position = 7 },
    author = { name = "Test Character", race = 3, classID = 1, level = 43, faction = 1 },
}
communityStreamId = 10
frame.onEvent(frame, "CHAT_MSG_GUILD", "Hello guild", "Test Character")
local self = EldgrimDB.members["Test Character"]
assert(#self.messages == 1)
assert(self.messages[1].channel == "GUILD")
assert(self.messages[1].timestamp == 1800000000)
assert(self.messages[1].message == "Hello guild")
assert(self.level == 43)

-- Officer messages use the officer stream, not a stale guild-stream record.
communityInfo = {
    content = "Officer message",
    messageId = { epoch = 1800000001123456, position = 8 },
    author = { name = "Other Member", race = 2, classID = 1, level = 36, faction = 0 },
}
communityStreamId = 11
frame.onEvent(frame, "CHAT_MSG_OFFICER", "Officer message", "Other Member")
local other = EldgrimDB.members["Other Member"]
assert(#other.messages == 1)
assert(other.messages[1].channel == "OFFICER")
assert(other.messages[1].timestamp == 1800000001)

-- A wrong stream cannot enrich the message; it still records with local receipt time.
communityInfo = {
    content = "Wrong stream",
    messageId = { epoch = 1800000002123456, position = 9 },
    author = { name = "Other Member", race = 2, classID = 1, level = 36, faction = 0 },
}
communityStreamId = 10
frame.onEvent(frame, "CHAT_MSG_OFFICER", "Wrong stream", "Other Member")
assert(#other.messages == 2)
assert(other.messages[2].timestamp == 1800000099)
assert(other.messages[2].channel == "OFFICER")

-- Case and Forever display separator variants resolve to the full roster name.
frame.onEvent(frame, "CHAT_MSG_YELL", "A yell", "other-member")
assert(other.messages[3].channel == "YELL")
assert(other.messages[3].timestamp == 1800000099)

-- Incoming whisper is filed under the member who sent it.
frame.onEvent(frame, "CHAT_MSG_WHISPER", "Incoming whisper", "Other Member")
assert(other.messages[4].channel == "WHISPER")
assert(other.messages[4].direction == "IN")

-- Outgoing whisper's event playerName is the target; file it under the local member.
frame.onEvent(frame, "CHAT_MSG_WHISPER_INFORM", "Outgoing whisper", "Nonmember Recipient")
assert(self.messages[2].channel == "WHISPER")
assert(self.messages[2].direction == "OUT")
assert(self.messages[2].recipient == "Nonmember Recipient")
frame.onEvent(frame, "CHAT_MSG_SAY", "My own say", "Test Character")
frame.onEvent(frame, "CHAT_MSG_YELL", "My own yell", "Test Character")
assert(self.messages[3].channel == "SAY")
assert(self.messages[4].channel == "YELL")

-- Other supported player-authored channels are captured for guild members.
frame.onEvent(frame, "CHAT_MSG_SAY", "Say", "Other Member")
frame.onEvent(frame, "CHAT_MSG_PARTY", "Party", "Other Member")
frame.onEvent(frame, "CHAT_MSG_PARTY_LEADER", "Party leader", "Other Member")
frame.onEvent(frame, "CHAT_MSG_RAID", "Raid", "Other Member")
frame.onEvent(frame, "CHAT_MSG_RAID_LEADER", "Raid leader", "Other Member")
frame.onEvent(frame, "CHAT_MSG_RAID_WARNING", "Raid warning", "Other Member")
frame.onEvent(frame, "CHAT_MSG_INSTANCE_CHAT", "Instance", "Other Member")
frame.onEvent(frame, "CHAT_MSG_INSTANCE_CHAT_LEADER", "Instance leader", "Other Member")
frame.onEvent(frame, "CHAT_MSG_CHANNEL", "Trade", "Other Member", "", "Trade - Ironforge", "", 0, 2, "Trade - Ironforge")
frame.onEvent(frame, "CHAT_MSG_COMMUNITIES_CHANNEL", "Community", "Other Member", "", "Hearth", "", "", 0, 1, "Hearth")
local beforeDiscordRelay = #other.messages
frame.onEvent(frame, "CHAT_MSG_COMMUNITIES_CHANNEL", "Discord relay", "Other Member", "", "Hearth", "", "", 0, 1, "Hearth", nil, nil, nil, nil, nil, nil, nil, nil, { userName = "Discord User" })
assert(#other.messages == beforeDiscordRelay, "Discord-relayed community messages must be excluded")
frame.onEvent(frame, "CHAT_MSG_EMOTE", "waves", "Other Member")
frame.onEvent(frame, "CHAT_MSG_TEXT_EMOTE", "Other Member waves.", "Other Member")

local foundChannelName = false
local foundCommunityName = false
for _, record in ipairs(other.messages) do
    if record.channel == "CHANNEL" and record.channelName == "Trade - Ironforge" then
        foundChannelName = true
    elseif record.channel == "COMMUNITY" and record.channelName == "Hearth" then
        foundCommunityName = true
    end
end
assert(foundChannelName, "custom channel name should be saved")
assert(foundCommunityName, "community stream name should be saved")

-- Messages from non-members and unregistered system events are ignored.
local countBefore = #other.messages
frame.onEvent(frame, "CHAT_MSG_YELL", "Nonmember yell", "Unlisted Player")
frame.onEvent(frame, "CHAT_MSG_SYSTEM", "System line", "Other Member")
frame.onEvent(frame, "CHAT_MSG_GUILD_DISCORD", "Discord relay", "Other Member")
assert(#other.messages == countBefore)
assert(EldgrimDB.members["Unlisted Player"] == nil)

-- Roster update: retain departed member history, add new members, and update current flags.
memberIDs = { 101, 103 }
memberInfo[103] = { name = "New Member", isSelf = false, guildRank = "Member" }
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)
assert(other.isGuildMember == false, "departed member should be retained but marked former")
assert(#other.messages == countBefore, "departed member history must be preserved")
assert(EldgrimDB.members["New Member"] and #EldgrimDB.members["New Member"].messages == 0)
assert(EldgrimDB.members["New Member"].isGuildMember == true)
assert(self.isGuildMember == true)

-- Targeted member updates refresh human-readable profile fields only.
memberInfo[101].guildRank = "Officer"
memberInfo[101].level = 44
frame.onEvent(frame, "CLUB_MEMBER_ROLE_UPDATED", 44, 101, 2)
assert(self.guildRank == "Officer")
assert(self.level == 44)

-- Partial roster scans must not mark unreturned records as former.
memberIDs = { 101, 102, 104 }
memberInfo[104] = nil
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)
assert(other.isGuildMember == true, "partial scan must not mark an unread member former")

-- Lockdown blocks both chat capture and roster API access. A roster change
-- observed during lockdown is refreshed on the next accessible chat event.
local rosterCalls = 0
local focusCallsBeforeLockdown = focusCalls
local originalGetClubMembers = C_Club.GetClubMembers
C_Club.GetClubMembers = function(...)
    rosterCalls = rosterCalls + 1
    return originalGetClubMembers(...)
end
memberIDs = { 101, 103 }
lockdown = true
local lockedCount = #self.messages
frame.onEvent(frame, "CHAT_MSG_GUILD", "Restricted message", "Test Character")
frame.onEvent(frame, "CLUB_MEMBERS_UPDATED", 44)
assert(#self.messages == lockedCount)
assert(rosterCalls == 0, "roster APIs must not be called during lockdown")
assert(focusCalls == focusCallsBeforeLockdown, "FocusMembers must not be called during lockdown")
lockdown = false
frame.onEvent(frame, "CHAT_MSG_YELL", "After lockdown", "New Member")
assert(rosterCalls == 1, "pending roster refresh should run after lockdown")
assert(EldgrimDB.members["New Member"].messages[1].message == "After lockdown")
assert(other.isGuildMember == false, "member removed during lockdown should become former after refresh")

-- Leaving the guild marks every known member former without deleting history.
clubId = nil
frame.onEvent(frame, "PLAYER_GUILD_UPDATE", "player")
assert(self.isGuildMember == false)
assert(other.isGuildMember == false)
assert(EldgrimDB.members["New Member"].isGuildMember == false)
assert(#self.messages == lockedCount)

-- Technical identifiers, notes, presence and account data never enter SavedVariables.
local forbiddenFields = {
    guid = true,
    memberId = true,
    bnetAccountId = true,
    clubId = true,
    streamId = true,
    messageId = true,
    classID = true,
    raceID = true,
    memberNote = true,
    officerNote = true,
    presence = true,
    isMobile = true,
}

local function inspectSavedData(value)
    if type(value) ~= "table" then
        return
    end

    for key, nested in pairs(value) do
        assert(not forbiddenFields[key], "forbidden field persisted: " .. tostring(key))
        inspectSavedData(nested)
    end
end

inspectSavedData(EldgrimDB)

-- Legacy schema migration preserves guild messages and labels their known channel.
EldgrimDB = {
    ["Legacy Member"] = {
        level = 12,
        messages = {
            { timestamp = 1800000000, message = "Old guild message" },
        },
    },
}
local migrationFrame = {}
function CreateFrame(kind)
    assert(kind == "Frame")
    return migrationFrame
end
function migrationFrame:RegisterEvent() end
function migrationFrame:SetScript(scriptName, callback)
    assert(scriptName == "OnEvent")
    self.onEvent = callback
end
function migrationFrame:Hide() end
-- Re-execute in a fresh Lua environment to exercise the actual migration path.
local env = setmetatable({
    CreateFrame = CreateFrame,
    C_ChatInfo = C_ChatInfo,
    C_Club = C_Club,
    C_CreatureInfo = C_CreatureInfo,
    time = time,
    EldgrimDB = EldgrimDB,
    pairs = pairs,
    ipairs = ipairs,
    type = type,
    tostring = tostring,
    string = string,
    math = math,
    pcall = pcall,
}, { __index = _G })
local migrationChunk
if type(setfenv) == "function" then
    migrationChunk = assert(loadfile(addonFile))
    setfenv(migrationChunk, env)
else
    migrationChunk = assert(loadfile(addonFile, "t", env))
end
migrationChunk()
assert(env.EldgrimDB.schemaVersion == 2)
assert(env.EldgrimDB.members["Legacy Member"].messages[1].channel == "GUILD")
assert(env.EldgrimDB.members["Legacy Member"].messages[1].message == "Old guild message")

print("Eldgrim roster and chat mock tests passed. These are not in-game tests.")
