-- The hearth board. It opens from the flame on the guild panel, or from
-- /eldgrim log. The look comes from EldgrimSkin.lua.

local Skin = EldgrimSkin
local C = Skin.C

-- An ember is completed only through Discord, never on the board. How is
-- said only in the question-mark tooltip, after the card's own hint.
local EMBER_PROOF = "To complete it, post a screenshot in the Eldgrim channel with @Eldgrim and the word ember. "
    .. "When another Amberhearth member Roars it, Eldgrim adds you to the ones who completed it within a day or two."

local function questHow(creator, mode)
    local who = mode == "one"
        and "This quest is for one member: the first to accept it takes it off the board. "
        or "Every member may complete this quest once. "
    return who .. "Whoever takes it marks it complete when it is done. Then "
        .. (creator or "its creator") .. " confirms it, and it is completed. "
        .. "You can be on one quest at a time. "
        .. "The quest stays until " .. (creator or "its creator") .. " deletes it."
end

local MODE_WORDS = { one = "for one member", all = "for everyone" }
-- Window and column sizes, in UI units.
local WIDTH, HEIGHT = 900, 600
local SIDE, TOP, FOOT = 46, 78, 46
local GAP = 12
local LEFT_W, MIDDLE_W = 270, 250
local RIGHT_W = WIDTH - SIDE * 2 - LEFT_W - MIDDLE_W - GAP * 2
local COLUMN_H = HEIGHT - TOP - FOOT
local PAD = 16
local ROW_H = 38

local hearth
local ember = {}
local list = {}
local detail = {}
local form = {}
local notes = {}
local selectedId
-- While on a quest the middle column is the notebook. "board" shows the list instead.
local middleView = "notebook"
local onQuest

-- The full "First Surname", as the sync knows it.
local function ownName()
    if EldgrimSync and type(EldgrimSync.OwnName) == "function" then
        return EldgrimSync.OwnName()
    end
    if type(UnitName) ~= "function" then
        return nil
    end
    return UnitName("player")
end

-- Layout helpers ---------------------------------------------------------

local function column(x, width, seed)
    local frame = CreateFrame("Frame", nil, hearth)
    frame:SetSize(width, COLUMN_H)
    frame:SetPoint("TOPLEFT", hearth, "TOPLEFT", x, -TOP)
    Skin.Frame(frame, "minor", width, COLUMN_H, seed)
    return frame
end

local function textBlock(parent, style, width)
    local text = Skin.Text(parent, style)
    text:SetWidth(width)
    text:SetWordWrap(true)
    return text
end

-- A read-only scroll area holding one block of text.
local function scrollText(parent, width, height)
    local scroll = Skin.Scroll(parent, width, height)
    local text = textBlock(scroll.content, "body", width - 16)
    text:SetPoint("TOPLEFT", scroll.content, "TOPLEFT", 0, 0)
    if text.SetSpacing then
        text:SetSpacing(2)
    end
    scroll.text = text
    function scroll:SetBody(value)
        text:SetText(value or "")
        self:SetContentHeight(text:GetStringHeight() + 4)
        self.ScrollTo(0)
    end
    return scroll
end

local function limitLines(text, lines)
    if text.SetMaxLines then
        text:SetMaxLines(lines)
    end
end

-- Ember (left column) -----------------------------------------------------

local function buildEmber(parent)
    local inner = LEFT_W - PAD * 2
    ember.header = Skin.Header(parent, "Eldgrim's Ember", inner - 24)
    ember.header:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD, -PAD)
    ember.help = Skin.IconButton(parent, "help", "helpLit", 22)
    ember.help:SetPoint("LEFT", ember.header, "RIGHT", 2, 0)

    ember.title = textBlock(parent, "name", inner)
    ember.title:SetPoint("TOPLEFT", ember.header, "BOTTOMLEFT", 0, -12)
    limitLines(ember.title, 2)

    -- From the bottom up: how it is proved, the note, who completed it.
    ember.note = textBlock(parent, "small", inner)
    ember.note:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", PAD, PAD)
    ember.done = scrollText(parent, inner + 6, 54)
    ember.done:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", PAD, PAD + 22)
    ember.doneHeader = Skin.Header(parent, "Completed by", inner)
    ember.doneHeader:SetPoint("BOTTOMLEFT", ember.done, "TOPLEFT", 0, 8)

    ember.story = scrollText(parent, inner + 6, nil)
    ember.story:SetPoint("TOPLEFT", ember.title, "BOTTOMLEFT", 0, -10)
    ember.story:SetPoint("BOTTOM", ember.doneHeader, "TOP", 0, 16)
end

local function refreshEmber(card)
    card = card or {}
    if card.id then
        ember.title:SetText(card.title or "")
        ember.story:SetBody(card.story or "")
        ember.title:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
    else
        ember.title:SetText("No ember yet")
        ember.title:SetTextColor(C.dim[1], C.dim[2], C.dim[3])
        ember.story:SetBody("")
    end
    if card.id then
        local hint = card.hint or ""
        ember.help.tooltip = (hint ~= "" and (hint .. "\n\n") or "") .. EMBER_PROOF
        ember.help:Show()
    else
        ember.help.tooltip = nil
        ember.help:Hide()
    end
    local names = {}
    for index = 1, #(card.completedBy or {}) do
        names[#names + 1] = card.completedBy[index].name
    end
    if #names > 0 then
        ember.done:SetBody(table.concat(names, ", "))
        ember.done.text:SetTextColor(C.text[1], C.text[2], C.text[3])
    else
        ember.done:SetBody("No one yet.")
        ember.done.text:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
    end
    ember.note:SetText(card.note or "")
end

-- Quest list (middle column) ------------------------------------------------

local function selectQuest(id)
    selectedId = id
    if form.panel then
        form.panel:Hide()
    end
    EldgrimRefreshHearth()
end

local function makeRows(scroll, store, count)
    for index = #store + 1, count do
        local row = Skin.Row(scroll.content, MIDDLE_W - PAD * 2 - 12, ROW_H)
        row:SetPoint("TOPLEFT", scroll.content, "TOPLEFT", 0, -(index - 1) * ROW_H)
        row:SetScript("OnClick", function(self)
            selectQuest(self.questId)
        end)
        store[index] = row
    end
end

local function fillRows(scroll, store, quests, ended, empty)
    makeRows(scroll, store, #quests)
    for index = 1, #store do
        local row = store[index]
        local quest = quests[index]
        if quest then
            row.questId = quest.id
            row.title:SetText(quest.title or "")
            -- A quest for one member says so first, so a long name cannot hide it.
            local sub = quest.mode == "one" and ("One member  ·  " .. (quest.creator or "?"))
                or ("Set by " .. (quest.creator or "?"))
            if not quest.confirmed then
                sub = sub .. "  ·  unconfirmed"
            end
            row.sub:SetText(sub)
            row:SetDimmed(ended)
            row:SetChosen(quest.id == selectedId)
            row:Show()
        else
            row:Hide()
            row.questId = nil
        end
    end
    scroll:SetContentHeight(#quests * ROW_H)
    if #quests == 0 then
        empty:Show()
    else
        empty:Hide()
    end
end

local function buildList(parent)
    local inner = MIDDLE_W - PAD * 2
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints(parent)
    list.panel = panel
    list.header = Skin.Header(panel, "Open quests", inner)
    list.header:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, -PAD)
    list.open = Skin.Scroll(panel, inner, ROW_H * 9)
    list.open:SetPoint("TOPLEFT", list.header, "BOTTOMLEFT", 0, -8)
    list.openEmpty = textBlock(panel, "small", inner - 10)
    list.openEmpty:SetPoint("TOPLEFT", list.open, "TOPLEFT", 4, -8)
    list.openEmpty:SetText("No open quests. Set the first one.")
    list.openRows = {}

    -- Back to the notebook, shown only while on a quest.
    list.back = Skin.Button(panel, "Notebook", inner, 28)
    list.back:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD, PAD + 28 + 8)
    list.back.tooltip = "Back to the quest you are on."
    list.back:SetScript("OnClick", function()
        middleView = "notebook"
        selectedId = onQuest
        if form.panel then
            form.panel:Hide()
        end
        EldgrimRefreshHearth()
    end)

    list.create = Skin.Button(panel, "Create quest", inner, 28)
    list.create:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD, PAD)
    list.create:SetScript("OnClick", function()
        EldgrimOpenQuestForm()
    end)
end

local function refreshList(data)
    fillRows(list.open, list.openRows, data.open or {}, false, list.openEmpty)
    list.header:SetHeading("Open quests  (" .. #(data.open or {}) .. ")")
    if data.current then
        list.back:Show()
    else
        list.back:Hide()
    end
end

-- Quest notebook (middle column, while on a quest) ---------------------------

local NOTE_GAP = 4

local function makeNoteRows(count)
    local width = MIDDLE_W - PAD * 2 - 12
    for index = #notes.rows + 1, count do
        local row = CreateFrame("Frame", nil, notes.scroll.content)
        row:SetWidth(width)
        local bullet = Skin.Glyph(row, "diamond", "ARTWORK", 10)
        bullet:SetPoint("TOPLEFT", row, "TOPLEFT", 2, -5)
        local text = textBlock(row, "body", width - 46)
        text:SetPoint("TOPLEFT", row, "TOPLEFT", 18, -3)
        local check = Skin.IconButton(row, "check", "check", 20, "Done. Check it off.")
        check:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -1)
        check.icon:SetVertexColor(0.36, 0.86, 0.38)
        check:SetScript("OnClick", function(self)
            if self.index then
                EldgrimSync.CheckNote(self.index)
            end
        end)
        local rule = row:CreateTexture(nil, "BACKGROUND")
        rule:SetColorTexture(C.orange[1], C.orange[2], C.orange[3], 0.12)
        rule:SetHeight(1)
        rule:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 16, 0)
        rule:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -4, 0)
        row.text = text
        row.check = check
        notes.rows[index] = row
    end
end

local function buildNotebook(parent)
    local inner = MIDDLE_W - PAD * 2
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints(parent)
    panel:Hide()
    notes.panel = panel
    notes.header = Skin.Header(panel, "Quest notebook", inner)
    notes.header:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, -PAD)

    -- From the bottom up: the way back to the board, the field, the notes.
    notes.board = Skin.Button(panel, "Board", inner, 28)
    notes.board:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD, PAD)
    notes.board.tooltip = "See the quest list. You stay on your quest."
    notes.board:SetScript("OnClick", function()
        middleView = "board"
        EldgrimRefreshHearth()
    end)
    notes.field = Skin.Field(panel, inner, 26, {
        placeholder = "Write a note, then press Enter",
        maxLetters = 120,
    })
    notes.field:SetPoint("BOTTOMLEFT", notes.board, "TOPLEFT", 0, 26)
    notes.field.edit:SetScript("OnEnterPressed", function(self)
        local ok = EldgrimSync.AddNote(notes.field:GetValue())
        if ok then
            notes.field:SetValue("")
        end
        self:SetFocus()
    end)

    notes.scroll = Skin.Scroll(panel, inner + 6, nil)
    notes.scroll:SetPoint("TOPLEFT", notes.header, "BOTTOMLEFT", 0, -10)
    notes.scroll:SetPoint("BOTTOM", notes.field, "TOP", 0, 26)
    notes.empty = textBlock(panel, "small", inner - 10)
    notes.empty:SetPoint("TOPLEFT", notes.scroll, "TOPLEFT", 4, -6)
    notes.empty:SetText("Nothing written yet. What you write here stays on this computer, and goes when the quest ends.")
    notes.rows = {}
end

local function refreshNotebook()
    local items = EldgrimSync.Notes and EldgrimSync.Notes() or {}
    makeNoteRows(#items)
    local y = 0
    for index = 1, #notes.rows do
        local row = notes.rows[index]
        local item = items[index]
        if item then
            row.text:SetText(item.text or "")
            local height = math.max(24, row.text:GetStringHeight() + 10)
            row:SetHeight(height)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", notes.scroll.content, "TOPLEFT", 0, -y)
            row.check.index = index
            row:Show()
            y = y + height + NOTE_GAP
        else
            row.check.index = nil
            row:Hide()
        end
    end
    notes.scroll:SetContentHeight(y)
    notes.header:SetHeading("Quest notebook  (" .. #items .. ")")
    if #items == 0 then
        notes.empty:Show()
    else
        notes.empty:Hide()
    end
end

-- Quest detail (right column) ------------------------------------------------

local function buildDetail(parent)
    local inner = RIGHT_W - PAD * 2
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints(parent)
    detail.panel = panel

    detail.title = textBlock(panel, "name", inner - 28)
    detail.help = Skin.IconButton(panel, "help", "helpLit", 22)
    detail.help:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PAD + 4, -PAD)
    detail.title:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, -PAD - 2)
    limitLines(detail.title, 3)
    detail.meta = textBlock(panel, "small", inner)
    detail.meta:SetPoint("TOPLEFT", detail.title, "BOTTOMLEFT", 0, -6)
    detail.warn = textBlock(panel, "small", inner)
    detail.warn:SetPoint("TOPLEFT", detail.meta, "BOTTOMLEFT", 0, -4)
    detail.warn:SetTextColor(C.warn[1], C.warn[2], C.warn[3])

    detail.action = Skin.Button(panel, "Accept", inner - 96, 28)
    detail.action:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD, PAD)
    detail.action:SetScript("OnClick", function(self)
        if not selectedId then
            return
        end
        if self.action == "accept" then
            EldgrimSync.AcceptQuest(selectedId)
        elseif self.action == "complete" then
            EldgrimSync.CompleteQuest(selectedId)
        end
    end)
    detail.abandon = Skin.Button(panel, "Abandon", 88, 28)
    detail.abandon:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PAD, PAD)
    detail.abandon.tooltip = "Give up this quest. You can take another."
    detail.abandon:SetScript("OnClick", function()
        if selectedId then
            EldgrimSync.AbandonQuest(selectedId)
        end
    end)
    detail.delete = Skin.Button(panel, "Delete", 88, 28)
    detail.delete:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PAD, PAD)
    detail.delete.tooltip = "Remove this quest for everyone."
    detail.delete:SetScript("OnClick", function()
        if selectedId then
            EldgrimSync.DeleteQuest(selectedId)
            selectedId = nil
            EldgrimRefreshHearth()
        end
    end)
    detail.confirm = Skin.Button(panel, "Confirm", inner, 28)
    detail.confirm:SetPoint("BOTTOMLEFT", detail.action, "TOPLEFT", 0, 8)
    detail.confirm:SetScript("OnClick", function(self)
        if selectedId and self.claimant then
            EldgrimSync.ConfirmQuest(selectedId, self.claimant)
        end
    end)

    -- Story, objective and who took it up, in one scroll area.
    local body = Skin.Scroll(panel, inner + 6, nil)
    body:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD, PAD + 28 + 8 + 28 + 12)
    detail.body = body
    local width = inner - 10
    local content = body.content
    detail.story = textBlock(content, "body", width)
    detail.story:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    if detail.story.SetSpacing then
        detail.story:SetSpacing(2)
    end
    detail.objectiveHeader = Skin.Header(content, "Objective", width)
    detail.objectiveHeader:SetPoint("TOPLEFT", detail.story, "BOTTOMLEFT", 0, -14)
    detail.objective = textBlock(content, "body", width)
    detail.objective:SetPoint("TOPLEFT", detail.objectiveHeader, "BOTTOMLEFT", 0, -8)
    detail.peopleHeader = Skin.Header(content, "Taken up by", width)
    detail.peopleHeader:SetPoint("TOPLEFT", detail.objective, "BOTTOMLEFT", 0, -14)
    detail.people = textBlock(content, "body", width)
    detail.people:SetPoint("TOPLEFT", detail.peopleHeader, "BOTTOMLEFT", 0, -8)

    -- Shown when nothing is chosen.
    local empty = CreateFrame("Frame", nil, parent)
    empty:SetAllPoints(parent)
    local glow = Skin.Glow(empty, 200, C.orange, 0.18)
    glow:SetPoint("CENTER", empty, "CENTER", 0, 30)
    local mark = empty:CreateTexture(nil, "ARTWORK")
    mark:SetTexture("Interface\\AddOns\\Eldgrim\\EldgrimFlame")
    mark:SetSize(96, 96)
    mark:SetPoint("CENTER", empty, "CENTER", 0, 30)
    mark:SetAlpha(0.55)
    local words = textBlock(empty, "small", inner)
    words:SetJustifyH("CENTER")
    words:SetPoint("TOP", mark, "BOTTOM", 0, -14)
    words:SetText("Choose a quest to read it,\nor set a new one for the guild.")
    detail.empty = empty
end

local function refreshDetail()
    local quest = selectedId and EldgrimSync and EldgrimSync.QuestDetail(selectedId) or nil
    if not quest then
        detail.panel:Hide()
        detail.empty:Show()
        return
    end
    detail.empty:Hide()
    detail.panel:Show()
    detail.title:SetText(quest.title or "")
    local meta = "Set by " .. (quest.creator or "?") .. "  ·  " .. (MODE_WORDS[quest.mode] or MODE_WORDS.all)
    if quest.mode == "one" and quest.holder then
        meta = meta .. "\nTaken by " .. quest.holder
    end
    detail.meta:SetText(meta)
    detail.help.tooltip = questHow(quest.creator, quest.mode)
    detail.body:ClearAllPoints()
    detail.body:SetPoint("BOTTOMLEFT", detail.panel, "BOTTOMLEFT", PAD, PAD + 28 + 8 + 28 + 12)
    if quest.confirmed then
        detail.warn:SetText("")
        detail.warn:Hide()
        detail.body:SetPoint("TOPLEFT", detail.meta, "BOTTOMLEFT", 0, -14)
    else
        detail.warn:SetText("Passed on by another member. Not yet confirmed.")
        detail.warn:Show()
        detail.body:SetPoint("TOPLEFT", detail.warn, "BOTTOMLEFT", 0, -14)
    end

    detail.story:SetText(quest.story or "")
    detail.objective:SetText(quest.objective or "")
    local people = {}
    for index = 1, #quest.accepts do
        local name = quest.accepts[index]
        local waiting = false
        for _, other in ipairs(quest.waiting or {}) do
            waiting = waiting or other == name
        end
        if quest.done[name] then
            people[#people + 1] = name .. " (completed)"
        elseif waiting then
            people[#people + 1] = name .. " (marked complete)"
        else
            people[#people + 1] = name
        end
    end
    if #people > 0 then
        detail.people:SetText(table.concat(people, ", "))
        detail.people:SetTextColor(C.text[1], C.text[2], C.text[3])
    else
        detail.people:SetText("No one yet.")
        detail.people:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
    end
    detail.body:SetContentHeight(detail.story:GetStringHeight() + detail.objective:GetStringHeight()
        + detail.people:GetStringHeight() + (14 + 16 + 8) * 2 + 6)
    detail.body.ScrollTo(0)

    local state = EldgrimSync.Button(quest.id)
    if state and state.label then
        detail.action:SetLabel(state.label)
        detail.action:SetActive(state.enabled ~= false)
        detail.action.action = state.action
        detail.action:Show()
    else
        detail.action.action = nil
        detail.action:Hide()
    end
    local inner = RIGHT_W - PAD * 2
    if state and state.delete then
        detail.delete:Show()
        detail.abandon:Hide()
        detail.action:SetWidth(inner - 96)
    elseif state and state.abandon then
        detail.delete:Hide()
        detail.abandon:Show()
        detail.action:SetWidth(inner - 96)
    else
        detail.delete:Hide()
        detail.abandon:Hide()
        detail.action:SetWidth(inner)
    end

    -- Only the creator confirms, one name at a time.
    local claimant = nil
    if ownName() == quest.creator then
        claimant = (quest.waiting or {})[1]
    end
    if claimant then
        detail.confirm.claimant = claimant
        detail.confirm:SetLabel("Confirm " .. claimant)
        detail.confirm:Show()
    else
        detail.confirm.claimant = nil
        detail.confirm:Hide()
    end
end

-- New quest form (right column) ----------------------------------------------

local function buildForm(parent)
    local inner = RIGHT_W - PAD * 2
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints(parent)
    panel:Hide()
    form.panel = panel

    local header = Skin.Header(panel, "Set a quest", inner)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, -PAD)

    form.title = Skin.Field(panel, inner, 26, {
        label = "Title",
        placeholder = "A name for the quest",
        maxLetters = 60,
    })
    form.title:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -26)

    form.story = Skin.Field(panel, inner, 72, {
        label = "Story",
        placeholder = "What is happening, and why it matters",
        maxLetters = 400,
        multiLine = true,
    })
    form.story:SetPoint("TOPLEFT", form.title, "BOTTOMLEFT", 0, -26)

    form.objective = Skin.Field(panel, inner, 48, {
        label = "Objective",
        placeholder = "What has to be done",
        maxLetters = 200,
        multiLine = true,
    })
    form.objective:SetPoint("TOPLEFT", form.story, "BOTTOMLEFT", 0, -26)

    local modeLabel = Skin.Text(panel, "label")
    modeLabel:SetPoint("TOPLEFT", form.objective, "BOTTOMLEFT", 1, -12)
    modeLabel:SetText("Who can complete it")
    form.mode = Skin.Choice(panel, inner, {
        { "all", "Everyone, once each", "Every member may take it up and complete it once." },
        { "one", "One member", "The first to accept it takes it off the board." },
    }, 1)
    form.mode:SetPoint("TOPLEFT", modeLabel, "BOTTOMLEFT", -1, -4)

    local how = textBlock(panel, "small", inner)
    how:SetPoint("TOPLEFT", form.mode, "BOTTOMLEFT", 0, -10)
    how:SetText("Whoever takes the quest marks it complete when it is done. Then you confirm it. It stays until you delete it.")

    form.error = textBlock(panel, "small", inner)
    form.error:SetTextColor(C.warn[1], C.warn[2], C.warn[3])
    form.error:SetPoint("TOPLEFT", how, "BOTTOMLEFT", 0, -12)

    form.title.nextField = form.story
    form.story.nextField = form.objective
    form.objective.nextField = form.title

    form.create = Skin.Button(panel, "Set quest", inner - 104, 28)
    form.create:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD, PAD)
    form.cancel = Skin.Button(panel, "Cancel", 96, 28)
    form.cancel:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PAD, PAD)
    form.cancel:SetScript("OnClick", function()
        panel:Hide()
        EldgrimRefreshHearth()
    end)
    form.create:SetScript("OnClick", function()
        local id, err = EldgrimSync.CreateQuest(form.title:GetValue(), form.story:GetValue(), form.objective:GetValue(), form.mode.value)
        if not id then
            form.error:SetText(err or "That quest was refused.")
            return
        end
        selectQuest(id)
    end)
end

function EldgrimOpenQuestForm()
    if not hearth then
        return
    end
    form.title:SetValue("")
    form.story:SetValue("")
    form.objective:SetValue("")
    form.mode:SetValue("all")
    form.error:SetText("")
    detail.panel:Hide()
    detail.empty:Hide()
    form.panel:Show()
    form.title.edit:SetFocus()
end

-- The window ---------------------------------------------------------------

local function build()
    if hearth then
        return
    end
    hearth = CreateFrame("Frame", "EldgrimHearthFrame", UIParent)
    hearth:SetSize(WIDTH, HEIGHT)
    hearth:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    hearth:SetFrameStrata("HIGH")
    hearth:SetToplevel(true)
    hearth:SetMovable(true)
    hearth:EnableMouse(true)
    hearth:SetClampedToScreen(true)
    hearth:RegisterForDrag("LeftButton")
    hearth:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    hearth:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    Skin.Frame(hearth, "major", WIDTH, HEIGHT, "hearth")
    if type(UISpecialFrames) == "table" then
        table.insert(UISpecialFrames, "EldgrimHearthFrame")
    end

    -- The crest sits on the top edge, over the lines, and breathes.
    local crest = CreateFrame("Frame", nil, hearth)
    crest:SetSize(84, 84)
    crest:SetPoint("CENTER", hearth, "TOP", 0, 2)
    crest:SetFrameLevel(hearth:GetFrameLevel() + 5)
    local glow = Skin.Glow(crest, 170, C.orange, 0.55, 2.4)
    glow:SetPoint("CENTER", crest, "CENTER", 0, 0)
    local mark = crest:CreateTexture(nil, "ARTWORK")
    mark:SetTexture("Interface\\AddOns\\Eldgrim\\EldgrimFlame")
    mark:SetAllPoints(crest)

    local title = Skin.Text(hearth, "title")
    title:SetJustifyH("CENTER")
    title:SetPoint("TOP", hearth, "TOP", 0, -46)
    title:SetText("Eldgrim's Hearth")
    for side = -1, 1, 2 do
        local line = hearth:CreateTexture(nil, "ARTWORK")
        line:SetColorTexture(C.orange[1], C.orange[2], C.orange[3], 0.7)
        line:SetSize(150, 1)
        local gem = Skin.Glyph(hearth, "diamond", "ARTWORK", 12)
        if side < 0 then
            line:SetPoint("RIGHT", title, "LEFT", -14, -1)
            gem:SetPoint("CENTER", line, "LEFT", 0, 0)
        else
            line:SetPoint("LEFT", title, "RIGHT", 14, -1)
            gem:SetPoint("CENTER", line, "RIGHT", 0, 0)
        end
    end

    local close = Skin.IconButton(hearth, "close", "closeLit", 26, "Close")
    close:SetPoint("CENTER", hearth, "TOPRIGHT", -84, -9)
    close:SetFrameLevel(hearth:GetFrameLevel() + 5)
    close:SetScript("OnClick", function()
        hearth:Hide()
    end)

    local left = column(SIDE, LEFT_W, "ember")
    local middle = column(SIDE + LEFT_W + GAP, MIDDLE_W, "quests")
    local right = column(SIDE + LEFT_W + GAP + MIDDLE_W + GAP, RIGHT_W, "detail")
    buildEmber(left)
    buildList(middle)
    buildNotebook(middle)
    buildDetail(right)
    buildForm(right)

    if hearth.CreateAnimationGroup then
        local group = hearth:CreateAnimationGroup()
        local fade = group:CreateAnimation("Alpha")
        fade:SetFromAlpha(0)
        fade:SetToAlpha(1)
        fade:SetDuration(0.18)
        hearth.opening = group
    end
    hearth:Hide()
end

local function refresh()
    if not hearth or not EldgrimSync or type(EldgrimSync.BoardData) ~= "function" then
        return
    end
    local data = EldgrimSync.BoardData()
    refreshEmber(data.ember)
    -- On a quest: the notebook in the middle and that quest on the right.
    if data.current ~= onQuest then
        onQuest = data.current
        middleView = "notebook"
        if onQuest then
            selectedId = onQuest
        end
    end
    if onQuest and middleView == "notebook" then
        selectedId = onQuest
        list.panel:Hide()
        notes.panel:Show()
        refreshNotebook()
    else
        notes.panel:Hide()
        list.panel:Show()
    end
    refreshList(data)
    if form.panel:IsShown() then
        detail.panel:Hide()
        detail.empty:Hide()
    else
        refreshDetail()
    end
end

local function show()
    build()
    form.panel:Hide()
    -- Opening the window on a quest always starts at its notebook.
    middleView = "notebook"
    if onQuest then
        selectedId = onQuest
    end
    hearth:Show()
    if hearth.opening then
        hearth.opening:Play()
    end
    refresh()
end

function EldgrimOpenHearth()
    show()
end

function EldgrimRefreshHearth()
    if hearth and hearth:IsShown() then
        refresh()
    end
end

-- The flame on the guild panel ----------------------------------------------
--
-- The guild window is the Communities frame. Its top-left crest is the
-- portrait and, for a guild, a tabard overlay drawn above it. The flame is
-- attached to the guild window itself, centred on the portrait, and raised
-- above every frame in that window whenever the window opens. The crest
-- pieces under it are faded with SetAlpha(0). Nothing is reparented.

local CREST_KEYS = { "PortraitOverlay", "PortraitContainer", "PortraitButton", "portrait" }
local mark
local root

local function guildRoot()
    if type(_G.CommunitiesFrame) == "table" then
        return _G.CommunitiesFrame
    end
    if type(_G.GuildFrame) == "table" then
        return _G.GuildFrame
    end
    return nil
end

local function highestLevel(frame, depth)
    local level = frame.GetFrameLevel and frame:GetFrameLevel() or 0
    if depth > 12 or type(frame.GetChildren) ~= "function" then
        return level
    end
    local children = { frame:GetChildren() }
    for index = 1, #children do
        local child = children[index]
        if child ~= mark and type(child) == "table" then
            local below = highestLevel(child, depth + 1)
            if below > level then
                level = below
            end
        end
    end
    return level
end

local function crestAnchor()
    local keys = { "PortraitContainer", "PortraitOverlay", "portrait" }
    for index = 1, #keys do
        local piece = root[keys[index]]
        if type(piece) == "table" and piece.GetWidth then
            return piece
        end
    end
    local legacy = _G.GuildFrameTabard
    if type(legacy) == "table" then
        return legacy
    end
    return nil
end

-- Fade the crest and lift the flame above everything in the guild window.
local function bringForward()
    if not mark or not root then
        return
    end
    for index = 1, #CREST_KEYS do
        local piece = root[CREST_KEYS[index]]
        if type(piece) == "table" and piece.SetAlpha then
            piece:SetAlpha(0)
        end
    end
    local legacy = { _G.GuildFrameTabard, _G.GuildFrameTabardBackground }
    for index = 1, #legacy do
        if type(legacy[index]) == "table" and legacy[index].SetAlpha then
            legacy[index]:SetAlpha(0)
        end
    end
    if root.GetFrameStrata then
        mark:SetFrameStrata(root:GetFrameStrata())
    end
    mark:SetFrameLevel(math.min(highestLevel(root, 0) + 5, 9000))
    mark:Show()
end

local function attachGuildButton()
    if mark then
        bringForward()
        return
    end
    root = guildRoot()
    if not root then
        return
    end
    mark = CreateFrame("Button", "EldgrimFlameButton", root)
    mark:SetSize(60, 60)
    local anchor = crestAnchor()
    if anchor then
        mark:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    else
        mark:SetPoint("TOPLEFT", root, "TOPLEFT", -6, 7)
    end
    local glow = Skin.Glow(mark, 104, C.orange, 0.0)
    glow:SetPoint("CENTER", mark, "CENTER", 0, 0)
    local texture = mark:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(mark)
    texture:SetTexture("Interface\\AddOns\\Eldgrim\\EldgrimFlame")
    mark:SetScript("OnClick", function()
        build()
        if hearth:IsShown() then
            hearth:Hide()
        else
            show()
        end
    end)
    mark:SetScript("OnMouseDown", function()
        texture:ClearAllPoints()
        texture:SetPoint("TOPLEFT", mark, "TOPLEFT", 1, -1)
        texture:SetPoint("BOTTOMRIGHT", mark, "BOTTOMRIGHT", 1, -1)
    end)
    mark:SetScript("OnMouseUp", function()
        texture:ClearAllPoints()
        texture:SetAllPoints(mark)
    end)
    mark:SetScript("OnEnter", function(self)
        glow:SetVertexColor(C.orange[1], C.orange[2], C.orange[3], 0.7)
        if not GameTooltip then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Eldgrim's Hearth", C.gold[1], C.gold[2], C.gold[3])
        GameTooltip:Show()
    end)
    mark:SetScript("OnLeave", function()
        glow:SetVertexColor(C.orange[1], C.orange[2], C.orange[3], 0)
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    -- The window builds its guild view after it opens and when the view
    -- changes, so lift the flame again then, and once more a moment later.
    local function soon()
        bringForward()
        if type(C_Timer) == "table" and type(C_Timer.After) == "function" then
            C_Timer.After(0, bringForward)
        end
    end
    if root.HookScript then
        root:HookScript("OnShow", soon)
    end
    if type(hooksecurefunc) == "function" then
        for _, method in ipairs({ "SetDisplayMode", "UpdatePortrait", "OnClubSelected" }) do
            if type(root[method]) == "function" then
                hooksecurefunc(root, method, soon)
            end
        end
    end
    soon()
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("ADDON_LOADED")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name ~= "Blizzard_Communities" and name ~= "Blizzard_GuildUI" then
        return
    end
    attachGuildButton()
end)
