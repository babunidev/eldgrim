-- Lay out the hearth board on sample data and print what would be drawn.
--
--   luajit addon/tools/preview/preview.lua <scene> [ember file] > scene.json
--   python3 addon/tools/preview/render.py scene.json out.png
--
-- Scenes: board, form, empty, notebook. Every name and text here is sample data.

local here = (arg[0]:match("^(.*)/[^/]*$") or ".")
local addon = here .. "/../../Eldgrim"
package.path = here .. "/?.lua;" .. package.path
local Mock = require("wowmock")
local scene = arg[1] or "board"

Mock.Reset(1100, 720)
local NOW = 1795132800 -- 2026-11-20 00:00 UTC
function GetServerTime()
    return NOW
end
function UnitName()
    return "Sample Wren"
end
function GetPhysicalScreenSize()
    return 1920, 1080
end

local DAY = 86400
local quests = {
    {
        id = "Sample Torva#1",
        title = "Carry a lit torch from Goldshire to Stormwind",
        creator = "Sample Torva",
        expires = NOW + 6 * DAY,
        confirmed = true,
        story = "A sample story. The road is dark after the inn, and a flame carried the whole way is worth more than one lit at the gate. Walk it without letting the light go out.",
        objective = "Arrive at the Stormwind gate with the torch still burning, and have a witness meet you there.",
        accepts = { "Sample Brannoc", "Sample Wren" },
        waiting = { "Sample Wren" },
        done = { ["Sample Brannoc"] = true },
    },
    {
        id = "Sample Hale#2",
        mode = "one",
        holder = "Sample Wren",
        title = "Bring three bundles of dry wood to the hearth",
        creator = "Sample Hale",
        expires = NOW + 20 * DAY,
        confirmed = true,
        story = "A sample story about the guild's fire.",
        objective = "Three bundles.",
        accepts = {},
        done = {},
    },
    {
        id = "Sample Ivo#3",
        title = "Keep the night watch at the Lakeshire bridge",
        creator = "Sample Ivo",
        expires = NOW + 1 * DAY + 3600,
        confirmed = false,
        story = "A sample story.",
        objective = "Stand the watch until dawn.",
        accepts = {},
        done = {},
    },
    {
        id = "Sample Quill#4",
        title = "Write down a song the old miners sing",
        creator = "Sample Quill",
        expires = NOW + 45 * DAY,
        confirmed = true,
        story = "A sample story.",
        objective = "Post the words.",
        accepts = {},
        done = {},
    },
}
local empty = scene == "empty"
-- In the notebook scene this character is on the second quest, with notes.
local onQuest = scene == "notebook" and "Sample Hale#2" or nil
-- An ember file given as the second argument replaces the sample card.
local emberFile = arg[2]
if emberFile then
    dofile(emberFile)
end
EldgrimSync = {}
function EldgrimSync.BoardData()
    local card = emberFile and EldgrimEmberFile and EldgrimEmberFile.current
    if card then
        return {
            ember = { id = card.id, title = card.title, story = card.story, hint = card.hint, completedBy = {} },
            open = empty and {} or quests,
        }
    end
    if empty then
        return { ember = { note = "The next ember has not arrived.", completedBy = {} }, open = {} }
    end
    return {
        ember = {
            id = "ember-sample",
            title = "The Ember of the Long Road",
            story = "This is sample text for the preview. A card like this holds the week's ember: a few sentences of story, set by the guild master, that anyone in the guild may answer before Sunday turns. The words wrap and scroll inside the column, and the hint sits behind the question mark.",
            hint = "A sample hint.",
            completedBy = { { name = "Sample Brannoc" }, { name = "Sample Hale" }, { name = "Sample Ivo" } },
        },
        open = quests,
        current = onQuest,
    }
end
function EldgrimSync.QuestDetail(id)
    for _, list in ipairs({ quests }) do
        for _, q in ipairs(list) do
            if q.id == id then
                local copy = {}
                for k, v in pairs(q) do
                    copy[k] = v
                end
                copy.accepts = copy.accepts or {}
                copy.done = copy.done or {}
                copy.waiting = copy.waiting or {}
                copy.expired = q.expires <= NOW
                return copy
            end
        end
    end
end
local sampleNotes = {
    { text = "Ask the innkeeper in Kharanos where the dry wood is kept" },
    { text = "Two bundles so far" },
    { text = "Bring a third before the Sunday fire, and do not let the rain at it on the way back up the hill" },
}
function EldgrimSync.Notes()
    return onQuest and sampleNotes or {}
end
function EldgrimSync.Button(id)
    if id == onQuest then
        return { label = "Mark complete", enabled = true, action = "complete", abandon = true }
    end
    if id == "Sample Torva#1" then
        return { label = "Waiting for Sample Torva", enabled = false }
    end
    return { label = "Accept", enabled = true, action = "accept" }
end
for _, name in ipairs({ "FinishEmber", "AcceptQuest", "CompleteQuest", "ConfirmQuest", "DeleteQuest", "AbandonQuest", "AddNote", "CheckNote" }) do
    EldgrimSync[name] = function() end
end
function EldgrimSync.CreateQuest()
    return nil, "Sample refusal."
end

dofile(addon .. "/EldgrimSkin.lua")
dofile(addon .. "/EldgrimBoard.lua")

EldgrimOpenHearth()
local hearth = EldgrimHearthFrame

-- Find a region by a predicate, depth first.
local function find(root, test)
    if test(root) then
        return root
    end
    for _, child in ipairs(root.children or {}) do
        local found = find(child, test)
        if found then
            return found
        end
    end
end
local function textOf(r)
    if r.caption and r.caption.text then
        return r.caption.text
    end
    if r.title and r.title.text then
        return r.title.text
    end
    if r.words and r.words.text then
        return r.words.text
    end
end
local function byText(text)
    return find(hearth, function(r)
        return (r.kind == "Button") and textOf(r) == text
    end)
end

if scene == "board" then
    -- Choose the first quest, hover the second row and one button.
    local row = byText(quests[1].title)
    row.scripts.OnClick(row)
    local other = byText(quests[3].title)
    other.scripts.OnEnter(other)
    local create = byText("Create quest")
    create.scripts.OnEnter(create)
elseif scene == "form" then
    EldgrimOpenQuestForm()
    local fields = {}
    find(hearth, function(r)
        if r.kind == "EditBox" and r:IsVisible() then
            fields[#fields + 1] = r
        end
    end)
    fields[1]:SetText("Find the lost lantern of Brightwood")
    fields[2]:SetText("A sample story. Someone left a lantern burning in the woods and never came back for it.")
    fields[2]:SetFocus()
    local cancel = byText("Cancel")
    cancel.held = true
    cancel.scripts.OnMouseDown(cancel)
elseif scene == "notebook" then
    local field = find(hearth, function(r)
        return r.kind == "EditBox" and r:IsVisible()
    end)
    field:SetText("Look behind the stable")
    field:SetFocus()
end

io.write(Mock.Dump())
