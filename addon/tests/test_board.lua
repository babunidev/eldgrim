-- Mock checks for the hearth window: it builds, its buttons act, and the
-- quest form refuses a bad date. Layout and looks are checked with the
-- preview in addon/tools/preview. This does not replace a game test.
--
--   lua addon/tests/test_board.lua addon/Eldgrim

local root = arg and arg[1] or "addon/Eldgrim"
package.path = root .. "/../tools/preview/?.lua;" .. package.path
local Mock = require("wowmock")

local failures = 0
local function check(ok, message)
    if ok then
        print("ok - " .. message)
    else
        failures = failures + 1
        print("not ok - " .. message)
    end
end

Mock.Reset(1100, 720)
local NOW = 1795132800 -- 2026-11-20 00:00 UTC
function GetServerTime()
    return NOW
end
function UnitName()
    return "Sample Wren"
end

local calls = {}
local quest = {
    id = "Sample Torva#1",
    title = "Sample quest",
    creator = "Sample Torva",
    expires = NOW + 3 * 86400,
    confirmed = true,
    story = "Sample story.",
    objective = "Sample objective.",
    accepts = { "Sample Brannoc" },
    waiting = { "Sample Brannoc" },
    done = {},
}
local mine = {
    id = "Sample Wren#2",
    title = "My sample quest",
    creator = "Sample Wren",
    expires = NOW + 5 * 86400,
    confirmed = true,
    story = "Mine.",
    objective = "Mine.",
    accepts = { "Sample Brannoc", "Sample Hale" },
    waiting = { "Sample Hale" },
    done = { ["Sample Brannoc"] = true },
}
EldgrimSync = {
    BoardData = function()
        return {
            ember = { id = "e1", title = "Sample ember", story = "Sample.", hint = "", completedBy = { { name = "Sample Wren" } } },
            open = { quest, mine },
        }
    end,
    QuestDetail = function(id)
        if id == quest.id then
            return quest
        elseif id == mine.id then
            return mine
        end
    end,
    Button = function(id)
        if id == mine.id then
            return { delete = true }
        end
        return { label = "Accept", enabled = true, action = "accept" }
    end,
    AcceptQuest = function(id)
        calls[#calls + 1] = { "accept", id }
    end,
    ConfirmQuest = function(id, name)
        calls[#calls + 1] = { "confirm", id, name }
    end,
    CreateQuest = function(title, story, objective, extra)
        calls[#calls + 1] = { "create", title, story, objective, extra }
        return "Sample Wren#2"
    end,
}

dofile(root .. "/EldgrimSkin.lua")
dofile(root .. "/EldgrimBoard.lua")

EldgrimOpenHearth()
local hearth = EldgrimHearthFrame
check(hearth and hearth:IsShown(), "the window opens")
check(UISpecialFrames[1] == "EldgrimHearthFrame", "Escape closes the window")

local function find(test, node)
    node = node or hearth
    if test(node) then
        return node
    end
    for _, child in ipairs(node.children or {}) do
        local found = find(test, child)
        if found then
            return found
        end
    end
end
local function button(text)
    return find(function(r)
        local label = (r.caption and r.caption.text) or (r.title and r.title.text) or (r.words and r.words.text)
        return r.kind == "Button" and label == text and r:IsVisible()
    end)
end

check(button("Mark complete") == nil, "the ember has no button to complete it on the board")
local shown = find(function(r)
    return r.kind == "FontString" and r:IsVisible() and (r.text or ""):find("word ember", 1, true)
end)
check(shown == nil, "how to complete the ember is not written on the board")
local emberHelp = find(function(r)
    return r.kind == "Button" and r:IsVisible() and (r.tooltip or ""):find("word ember", 1, true)
end)
check(emberHelp ~= nil, "the question mark tells how to complete the ember")

local row = button("Sample quest")
row.scripts.OnClick(row)
local accept = button("Accept")
check(accept ~= nil, "choosing a quest shows its Accept button")
accept.scripts.OnClick(accept)
check(calls[#calls][1] == "accept" and calls[#calls][2] == quest.id, "Accept takes the chosen quest")
check(button("Confirm Sample Brannoc") == nil, "only the creator is offered Confirm")
local own = button("My sample quest")
own.scripts.OnClick(own)
local confirm = button("Confirm Sample Hale")
check(confirm ~= nil, "the creator is offered Confirm for the one who marked it complete")
confirm.scripts.OnClick(confirm)
check(calls[#calls][1] == "confirm" and calls[#calls][3] == "Sample Hale", "Confirm names the one who marked it complete")
check(button("Delete") ~= nil, "the creator can delete the quest")
local questHelp = find(function(r)
    return r.kind == "Button" and r:IsVisible() and (r.tooltip or ""):find("Sample Wren confirms it", 1, true)
end)
check(questHelp ~= nil, "the quest's question mark tells how it is completed")
local written = find(function(r)
    return r.kind == "FontString" and r:IsVisible() and (r.text or ""):find("confirms it", 1, true)
end)
check(written == nil, "how to complete the quest is not written in the quest")

local create = button("Create quest")
create.scripts.OnClick(create)
local fields = {}
find(function(r)
    if r.kind == "EditBox" and r:IsVisible() then
        fields[#fields + 1] = r
    end
end)
check(#fields == 3, "the form has three text fields")
check(Mock.focus == fields[1], "the title field takes focus")

local hint = find(function(r)
    return r.kind == "FontString" and r.text == "A name for the quest"
end)
fields[1]:SetText("Sample title")
check(not hint:IsShown(), "the placeholder hides once there is text")

fields[2]:SetText("Sample story.")
fields[3]:SetText("Sample objective.")
check(button("7 d") == nil and #fields == 3, "the form has no end date")
local set = button("Set quest")
set.scripts.OnClick(set)
local sent = calls[#calls]
check(sent[1] == "create" and sent[2] == "Sample title" and sent[4] == "Sample objective." and sent[5] == "all",
    "the form sends what was written, for everyone by default, with no end date")
create = button("Create quest")
create.scripts.OnClick(create)
local single = button("One member")
check(single ~= nil and button("Everyone, once each") ~= nil, "the form asks who can complete the quest")
single.scripts.OnClick(single)
fields[1]:SetText("Only one")
fields[3]:SetText("Sample objective.")
set = button("Set quest")
set.scripts.OnClick(set)
check(calls[#calls][1] == "create" and calls[#calls][5] == "one", "a quest for one member is sent as one")

-- On a quest: the notebook takes the middle column, the quest stays on the right.
local current = quest.id
local written = {}
local boardData = EldgrimSync.BoardData
EldgrimSync.BoardData = function()
    local data = boardData()
    data.current = current
    return data
end
EldgrimSync.Button = function(id)
    if id == current then
        return { label = "Mark complete", enabled = true, action = "complete", abandon = true }
    end
    return { label = "On another quest", enabled = false }
end
EldgrimSync.Notes = function()
    local copy = {}
    for index, text in ipairs(written) do
        copy[index] = { text = text }
    end
    return copy
end
EldgrimSync.AddNote = function(text)
    written[#written + 1] = text
    EldgrimRefreshHearth()
    return true
end
EldgrimSync.CheckNote = function(index)
    table.remove(written, index)
    EldgrimRefreshHearth()
    return true
end
EldgrimSync.AbandonQuest = function(id)
    calls[#calls + 1] = { "abandon", id }
end
EldgrimRefreshHearth()
local function visibleText(text)
    return find(function(r)
        return r.kind == "FontString" and r:IsVisible() and (r.text or ""):find(text, 1, true)
    end)
end
check(visibleText("QUEST NOTEBOOK") ~= nil, "on a quest the middle column is the notebook")
check(visibleText("OPEN QUESTS") == nil, "the quest list is not shown while on a quest")
check(button("Mark complete") ~= nil and button("Abandon") ~= nil, "the quest stays on the right, with Mark complete and Abandon")
local abandon = button("Abandon")
abandon.scripts.OnClick(abandon)
check(calls[#calls][1] == "abandon" and calls[#calls][2] == quest.id, "Abandon gives up the quest on the right")

local noteBox = find(function(r)
    return r.kind == "EditBox" and r:IsVisible()
end)
check(noteBox ~= nil, "the notebook has a field to write in")
noteBox:SetText("Ask the innkeeper about the lantern")
noteBox.scripts.OnEnterPressed(noteBox)
check(written[1] == "Ask the innkeeper about the lantern", "Enter adds the note")
check((noteBox:GetText() or "") == "", "the field is empty again after Enter")
check(visibleText("Ask the innkeeper") ~= nil, "the note is listed")
noteBox:SetText("Wait for the lamplighter")
noteBox.scripts.OnEnterPressed(noteBox)
local tick = find(function(r)
    return r.kind == "Button" and r:IsVisible() and r.tooltip == nil and r.index == 1
end)
check(tick ~= nil, "each note has a check mark")
tick.scripts.OnClick(tick)
check(#written == 1 and written[1] == "Wait for the lamplighter", "checking a note off removes it")
check(visibleText("Ask the innkeeper") == nil, "a checked note disappears")

local toBoard = button("Board")
toBoard.scripts.OnClick(toBoard)
check(visibleText("OPEN QUESTS") ~= nil, "Board shows the quest list while on a quest")
local other = button("My sample quest")
other.scripts.OnClick(other)
local back = button("Notebook")
check(back ~= nil, "the list offers the way back to the notebook")
back.scripts.OnClick(back)
check(visibleText("QUEST NOTEBOOK") ~= nil and button("Abandon") ~= nil, "Notebook returns to the notebook and the quest on it")

current = nil
EldgrimRefreshHearth()
check(visibleText("OPEN QUESTS") ~= nil and visibleText("QUEST NOTEBOOK") == nil, "off a quest the list comes back")

-- The guild window loads later. Its crest overlay sits high above the
-- portrait; the flame must still land in front of it.
local hooks = {}
function hooksecurefunc(owner, method, fn)
    hooks[method] = fn
end
local guild = CreateFrame("Frame", "CommunitiesFrame", UIParent)
guild:SetSize(800, 500)
guild:SetPoint("CENTER")
guild:SetFrameLevel(10)
guild.PortraitContainer = CreateFrame("Frame", nil, guild)
guild.PortraitContainer:SetSize(62, 62)
guild.PortraitContainer:SetPoint("TOPLEFT", guild, "TOPLEFT", -5, 7)
guild.PortraitOverlay = CreateFrame("Frame", nil, guild)
guild.PortraitOverlay:SetFrameLevel(500)
local banner = CreateFrame("Frame", nil, guild.PortraitOverlay)
banner:SetFrameLevel(510)
function guild:SetDisplayMode() end
for _, region in ipairs(Mock.Regions()) do
    if region.scripts.OnEvent and region.parent == nil then
        region.scripts.OnEvent(region, "ADDON_LOADED", "Blizzard_Communities")
    end
end
local flame = EldgrimFlameButton
check(flame and flame:GetParent() == guild, "the flame is attached to the guild window")
check(flame and flame:GetFrameLevel() > 510, "the flame sits above the crest overlay")
check(guild.PortraitOverlay:GetAlpha() == 0 and guild.PortraitContainer:GetAlpha() == 0, "the crest under the flame is faded")
local fl, fb, fr, ft = Mock.Rect(flame)
local pl, pb, pr, pt = Mock.Rect(guild.PortraitContainer)
check(math.abs((fl + fr) - (pl + pr)) < 0.01 and math.abs((fb + ft) - (pb + pt)) < 0.01, "the flame is centred on the portrait")
banner:SetFrameLevel(700)
hooks.SetDisplayMode()
check(flame:GetFrameLevel() > 700, "the flame is lifted again when the guild view changes")
guild.PortraitOverlay:SetAlpha(1)
guild.scripts.OnShow(guild)
check(guild.PortraitOverlay:GetAlpha() == 0, "the crest is faded again when the window opens")

if failures > 0 then
    print(failures .. " failed")
    os.exit(1)
end
print("all board checks passed")
