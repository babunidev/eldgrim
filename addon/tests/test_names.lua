-- Mock check of own-name lookup and ember publishing. In Forever,
-- UnitName("player") gives only "Jasmine"; the guild roster, which arrives
-- after login, has "Jasmine Amberbrew". Not an in-game test.
--
--   lua addon/tests/test_names.lua addon/Eldgrim

local root = arg and arg[1] or "addon/Eldgrim"
local function embers()
    EldgrimEmberFile = {
        revision = 2,
        current = { id = "e-now", starts = 1795132800, title = "Sample now", story = "A sample story, long enough to be split: " .. string.rep("ember, ", 40), hint = "A sample hint." },
        next = { id = "e-next", starts = 1795305600, title = "Sample next", story = "Another sample story.", hint = "" },
    }
end
local frames, short, now, clock = {}, "Jasmine", 1795132800 + 3600 * 22, 1000
local rosterReady = false
function CreateFrame()
    local f = { scripts = {} }
    function f:RegisterEvent() end
    function f:SetScript(n, c) self.scripts[n] = c end
    function f:Show() end
    function f:Hide() end
    frames[#frames + 1] = f
    return f
end
local me
function UnitName() return short end
function UnitGUID() return "Player-0-" .. short end
function GetServerTime() return now end
function GetTime() return clock end
function IsInGuild() return true end
local roster = {
    { name = "Jasmine Atwood", online = true, guid = "Player-0-Other" },
    { name = "Jasmine Amberbrew", online = true, guid = "Player-0-Jasmine" },
    { name = "Sample Wren", online = true, guid = "Player-0-Wren" },
}
function GetNumGuildMembers() return rosterReady and #roster or 0 end
function GetGuildRosterInfo(i)
    local m = roster[i]
    return m.name, "", 0, 60, "Mage", "", "", "", m.online and 1 or nil, 0, "MAGE", 0, 0, false, false, 0, m.guid
end
C_ChatInfo = { InChatMessagingLockdown = function() return false end, RegisterAddonMessagePrefix = function() end, SendAddonMessage = function() end }
math.random = function(a, b) return b or a end
local function boot()
    frames = {}; EldgrimQuests = nil; EldgrimDB = {}; EldgrimRoster = { members = {} }; EldgrimSync = nil
    embers()
    dofile(root .. "/EldgrimSync.lua")
end
local function pump() for _ = 1, 60 do clock = clock + 0.25; EldgrimSync.Pump() end end
local function event(name) frames[1].scripts.OnEvent(frames[1], name) end
local function check(ok, msg) print((ok and "ok - " or "NOT OK - ") .. msg); if not ok then FAILED = true end end

boot()
event("PLAYER_LOGIN")
pump()
check(EldgrimQuests.ember.revision == 0, "nothing is published before the roster has named her")
rosterReady = true
event("GUILD_ROSTER_UPDATE")
pump()
check(EldgrimSync.OwnName() == "Jasmine Amberbrew", "her full name comes from her own roster entry, not the other Jasmine")
local data = EldgrimSync.BoardData()
check(data.ember.title == "Sample now", "her board shows the current ember")
check(EldgrimQuests.ember.revision == 2, "revision 2 is saved")
local sent = {}
local longest = 0
for i, m in ipairs(EldgrimSync.Sent) do sent[i] = m; if #m.text > longest then longest = #m.text end end
check(longest <= 255, "no message is over 255 bytes (" .. longest .. ")")

-- Sample Wren receives those messages, sent by "Jasmine Amberbrew".
short = "Sample"
roster[3].guid = "Player-0-Sample"
boot()
for _, m in ipairs(sent) do EldgrimSync.Handle(m.chatType or "GUILD", "Jasmine Amberbrew", m.text) end
pump()
embers()
local file = EldgrimEmberFile
local got = EldgrimQuests.ember
check(got.current and got.current.story == file.current.story and got.current.hint == file.current.hint, "a member gets the current card word for word")
check(got.next and got.next.story == file.next.story and got.next.title == file.next.title, "a member gets the next card word for word")
now = 1795305600 + 60
local after = EldgrimSync.BoardData().ember
check(after.title == "Sample next" and not after.ended, "on Sunday 00:00 UTC the next card takes over")
if FAILED then os.exit(1) end
print("all name checks passed")
