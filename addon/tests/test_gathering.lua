-- Mock checks for the Sunday gathering record. These do not replace a game test.
-- Run from the repository root: lua addon/tests/test_gathering.lua addon/Eldgrim

local root = arg and arg[1] or "addon/Eldgrim"
local frames = {}
local player = "Bob Hill"
local now = 1795372200 -- Sunday 22 November 2026, 19:30 CET
local clock = 1000
local roster = {}
local group = {}
local raid = false
local lockdown = false

function CreateFrame()
    local frame = { events = {}, scripts = {} }
    function frame:RegisterEvent(event)
        self.events[event] = true
    end
    function frame:SetScript(name, callback)
        self.scripts[name] = callback
    end
    function frame:Show() end
    function frame:Hide() end
    frames[#frames + 1] = frame
    return frame
end

function UnitName(unit)
    if unit == "player" then
        return player
    end
    local index = tonumber(unit:match("%d+"))
    return group[index]
end

function GetNumGroupMembers()
    if #group == 0 then
        return 0
    end
    return raid and #group or #group + 1
end

function IsInRaid()
    return raid
end

function GetServerTime()
    return now
end

function GetTime()
    return clock
end

function IsInGuild()
    return true
end

function GetNumGuildMembers()
    return #roster
end

function GetGuildRosterInfo(index)
    local member = roster[index]
    return member.name, "", member.rankIndex or 4, 60, "Mage", "Ironforge", "", "", member.online and 1 or nil
end

C_ChatInfo = {
    InChatMessagingLockdown = function()
        return lockdown
    end,
    RegisterAddonMessagePrefix = function() end,
    SendAddonMessage = function() end,
}

math.random = function(low, high)
    return high or low
end

local function boot()
    frames = {}
    EldgrimQuests = nil
    EldgrimGathering = nil
    EldgrimDB = {}
    EldgrimRoster = { members = {} }
    EldgrimSync = nil
    dofile(root .. "/EldgrimEmbers.lua")
    dofile(root .. "/EldgrimSync.lua")
end

local function fire(event, ...)
    for _, frame in ipairs(frames) do
        if frame.events[event] and frame.scripts.OnEvent then
            frame.scripts.OnEvent(frame, event, ...)
        end
    end
end

local function pump(seconds)
    for _ = 1, (seconds or 4) * 4 do
        clock = clock + 0.25
        EldgrimSync.Pump()
    end
end

local function sentOf(kind)
    local found = {}
    for _, item in ipairs(EldgrimSync.Sent) do
        local text = item.text
        local itemKind = text:match("#%x%x%x%x#M%d+#%d+#%d+#([^|]+)|") or text:match("#%x%x%x%x#([^|]+)|")
        if itemKind == kind then
            found[#found + 1] = item
        end
    end
    return found
end

local passed = 0
local function check(condition, message)
    if not condition then
        error("not ok - " .. message, 2)
    end
    passed = passed + 1
    print("ok - " .. message)
end

local function members(...)
    roster = {}
    for _, name in ipairs({ ... }) do
        roster[#roster + 1] = { name = name, online = true }
    end
end

-- The hour, in winter and in summer time.
boot()
local day = EldgrimSync.GatheringDay
check(day(1795372200) == "2026-11-22", "Sunday 19:30 CET is in the gathering")
check(day(1795370340) == nil, "Sunday 18:59 is before the gathering")
check(day(1795374000) == nil, "Sunday 20:00 is after the gathering")
check(day(1795285800) == nil, "Saturday 19:30 is not a gathering")
check(day(1780853400) == "2026-06-07", "Sunday 19:30 CEST (summer time) is in the gathering")
check(day(1780857000) == nil, "Sunday 20:30 summer time is after the gathering")
check(day(1774805400) == "2026-03-29", "the day summer time starts uses summer time")
check(day(1792953000) == "2026-10-25", "the day summer time ends uses winter time")

-- The master records /say from guild members and her group, only in the hour.
player = "Jasmine Amberbrew"
members("Jasmine Amberbrew", "Ran Estuary", "Faenra Greenleaf", "Entai Dreamfall")
boot()
fire("PLAYER_LOGIN")
fire("CHAT_MSG_SAY", "What a fire!", "Ran Estuary")
fire("CHAT_MSG_SAY", "Hello there", "Stranger Danger")
group = { "Faenra" }
fire("GROUP_ROSTER_UPDATE")
local list = EldgrimGathering["2026-11-22"]
check(type(list) == "table" and #list == 3, "a say line, the master and her group member are recorded")
check(list[1].speaker == "Ran Estuary" and list[1].kind == "say" and list[1].text == "What a fire!", "the say line keeps speaker and text")
local names = {}
for _, row in ipairs(list) do
    names[row.speaker .. ":" .. row.kind] = row
    check(row.passedBy == nil, "the master's own record has no passedBy: " .. row.speaker)
end
check(names["Faenra Greenleaf:group"] ~= nil, "a short unit name is matched to the full roster name")
check(names["Stranger Danger:say"] == nil, "someone outside the guild is not recorded")
fire("GROUP_ROSTER_UPDATE")
check(#EldgrimGathering["2026-11-22"] == 3, "a group member is marked once per gathering")

now = 1795374000 + 60
fire("CHAT_MSG_SAY", "Goodnight", "Ran Estuary")
check(#EldgrimGathering["2026-11-22"] == 3, "nothing is recorded after 20:00")

lockdown = true
now = 1795372300
fire("CHAT_MSG_SAY", "Locked line", "Entai Dreamfall")
check(#EldgrimGathering["2026-11-22"] == 3, "nothing is read during chat lockdown")
lockdown = false

-- A member holds the record and whispers it to the master when she is heard.
player = "Ran Estuary"
members("Jasmine Amberbrew", "Ran Estuary", "Faenra Greenleaf", "Entai Dreamfall")
group = {}
raid = false
now = 1795372200
boot()
fire("PLAYER_LOGIN")
fire("CHAT_MSG_SAY", "The road is bright", "Entai Dreamfall")
group = { "Entai Dreamfall" }
fire("GROUP_ROSTER_UPDATE")
check(EldgrimGathering == nil, "a member does not keep the master's record")
check(#EldgrimQuests.gathering == 3, "a member holds the say line, itself and its group")
pump()
check(#sentOf("GATH") == 0, "nothing is whispered while the master has not been heard")

now = 1795374000 + 5
pump()
check(#sentOf("GATH") == 0, "the hour's end does not send when the master is not online")

-- The master logs in later: her hello leads the member to whisper the batch.
EldgrimSync.Handle("GUILD", "Jasmine Amberbrew", (function()
    -- A minimal hello: revision 0, no records, and her online-since time.
    local body = "HELLO|0|0|00000000|" .. tostring(now) .. "|"
    local sum = 0
    for index = 1, #body do
        sum = (sum + body:byte(index)) % 65536
    end
    return "1#" .. string.format("%04X", sum) .. "#" .. body
end)())
pump()
local batches = sentOf("GATH")
check(#batches >= 1, "the held record is whispered once the master is heard")
check(batches[1].chatType == "WHISPER" and batches[1].target == "Jasmine Amberbrew", "the batch goes by whisper to the master")
local outgoing = {}
for _, item in ipairs(EldgrimSync.Sent) do
    outgoing[#outgoing + 1] = item
end
local batchId = EldgrimQuests.pendingGathering and EldgrimQuests.pendingGathering.id

-- The master takes the batch. A forged line outside the hour is refused.
player = "Jasmine Amberbrew"
now = 1795375000
boot()
fire("PLAYER_LOGIN")
for _, item in ipairs(outgoing) do
    if item.chatType == "WHISPER" then
        EldgrimSync.Handle("WHISPER", "Ran Estuary", item.text)
    end
end
local kept = EldgrimGathering["2026-11-22"]
check(type(kept) == "table" and #kept == 3, "the master stores the member's three records")
for _, row in ipairs(kept) do
    check(row.passedBy == "Ran Estuary", "a passed-on record names who passed it: " .. row.speaker .. ":" .. row.kind)
end
pump()
local acks = sentOf("GACK")
check(#acks == 1 and acks[1].target == "Ran Estuary", "the master acknowledges the batch")

-- A second member's copy of the same group mark removes passedBy.
EldgrimSync.Sent = {}
local function gathPayload(sender, fields)
    local escaped = {}
    for index, value in ipairs(fields) do
        escaped[index] = tostring(value)
    end
    local body = "GATH|b1|" .. table.concat(escaped, "|")
    local sum = 0
    for index = 1, #body do
        sum = (sum + body:byte(index)) % 65536
    end
    EldgrimSync.Handle("WHISPER", sender, "1#" .. string.format("%04X", sum) .. "#" .. body)
end
gathPayload("Faenra Greenleaf", { "2026-11-22", "Entai Dreamfall", "group", "", 1795372300 })
local entai = nil
for _, row in ipairs(EldgrimGathering["2026-11-22"]) do
    if row.speaker == "Entai Dreamfall" and row.kind == "group" then
        entai = row
    end
end
check(entai ~= nil and entai.passedBy == nil, "a mark from two members is no longer single-witness")
gathPayload("Faenra Greenleaf", { "2026-11-22", "Faenra Greenleaf", "group", "", 1795285800 })
local faenra = 0
for _, row in ipairs(EldgrimGathering["2026-11-22"]) do
    if row.speaker == "Faenra Greenleaf" then
        faenra = faenra + 1
    end
end
check(faenra == 0, "a mark whose time is outside the hour is refused")
gathPayload("Stranger Danger", { "2026-11-22", "Entai Dreamfall", "say", "hi", 1795372300 })
check(#EldgrimGathering["2026-11-22"] == 3, "a batch from someone off the roster is refused")

-- The member deletes exactly the acknowledged batch.
player = "Ran Estuary"
now = 1795375000
boot()
EldgrimQuests = {
    gathering = {
        { id = "a", day = "2026-11-22", speaker = "Entai Dreamfall", kind = "group", received = 1795372300 },
        { id = "b", day = "2026-11-22", speaker = "Ran Estuary", kind = "group", received = 1795372300 },
    },
    pendingGathering = { id = "g1", ids = { "a" }, sentAt = clock },
}
local body = "GACK|g1"
local sum = 0
for index = 1, #body do
    sum = (sum + body:byte(index)) % 65536
end
EldgrimSync.Handle("WHISPER", "Jasmine Amberbrew", "1#" .. string.format("%04X", sum) .. "#" .. body)
check(#EldgrimQuests.gathering == 1 and EldgrimQuests.gathering[1].id == "b", "only the acknowledged lines are deleted")

print("all " .. passed .. " gathering checks passed. These are not in-game tests.")
