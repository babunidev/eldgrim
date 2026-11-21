-- Eldgrim's look: the cut-corner frame, buttons, text fields, lists and
-- scroll areas used by the hearth board.
--
-- The textures are drawn by addon/tools/hearth_art.py. The frame geometry
-- below (corner size, cut, and each line's offset and width) must match that
-- script. Change both together.

local Skin = {}
EldgrimSkin = Skin

local PATH = "Interface\\AddOns\\Eldgrim\\"
local TITLE_FONT = "Fonts\\MORPHEUS.TTF"

local C = {
    coal = { 0.075, 0.060, 0.052 },
    panel = { 0.110, 0.085, 0.070 },
    orange = { 0.90, 0.42, 0.10 },
    gold = { 1.00, 0.76, 0.32 },
    red = { 0.72, 0.17, 0.07 },
    amber = { 0.86, 0.55, 0.20 },
    pale = { 1.00, 0.95, 0.72 },
    text = { 0.96, 0.87, 0.68 },
    heading = { 1.00, 0.66, 0.24 },
    dim = { 0.66, 0.56, 0.45 },
    muted = { 0.44, 0.38, 0.33 },
    warn = { 1.00, 0.45, 0.30 },
}
Skin.C = C

-- Each line is { offset from the outer edge, width, colour, broken }.
local FRAMES = {
    major = {
        file = "EldgrimCorner",
        size = 64,
        quadrants = true,
        fill = C.coal,
        lines = {
            { 0, 4, C.orange },
            { 6, 2, C.gold, true },
            { 10, 1, C.red },
            { 16, 2, C.amber },
        },
    },
    minor = {
        file = "EldgrimCornerSmall",
        size = 32,
        fill = C.panel,
        lines = {
            { 0, 2, C.orange },
            { 4, 1, C.red },
        },
    },
}
Skin.BAND = 18

-- The glyph sheet is a 4 x 4 grid. See glyph_atlas() in hearth_art.py.
local GLYPH = {
    close = 0,
    closeLit = 1,
    diamond = 2,
    flame = 3,
    help = 4,
    helpLit = 5,
    check = 6,
    radio = 7,
    radioOn = 8,
    glow = 9,
    fadeRight = 10,
    fadeUp = 11,
    arrow = 12,
    thumb = 14,
    track = 15,
}
Skin.GLYPH = GLYPH

local function paint(texture, colour, alpha)
    texture:SetColorTexture(colour[1], colour[2], colour[3], alpha or 1)
    return texture
end

local function tint(texture, colour, alpha)
    texture:SetVertexColor(colour[1], colour[2], colour[3], alpha or 1)
    return texture
end

function Skin.Glyph(parent, name, layer, size)
    local texture = parent:CreateTexture(nil, layer or "ARTWORK")
    texture:SetTexture(PATH .. "EldgrimGlyphs")
    Skin.SetGlyph(texture, name)
    if size then
        texture:SetSize(size, size)
    end
    return texture
end

function Skin.SetGlyph(texture, name)
    local index = GLYPH[name] or 0
    local col = index % 4
    local row = math.floor(index / 4)
    local edge = 0.5 / 128
    texture:SetTexCoord(col * 0.25 + edge, col * 0.25 + 0.25 - edge, row * 0.25 + edge, row * 0.25 + 0.25 - edge)
end

-- One physical pixel in this frame's units, so a thin line never rounds
-- away. Nil when the client does not say.
local function onePixel(frame)
    if type(GetPhysicalScreenSize) ~= "function" or type(frame.GetEffectiveScale) ~= "function" then
        return nil
    end
    local ok, _, height = pcall(GetPhysicalScreenSize)
    local scale = frame:GetEffectiveScale()
    if not ok or type(height) ~= "number" or height <= 0 or type(scale) ~= "number" or scale <= 0 then
        return nil
    end
    return 768 / height / scale
end

-- A small seeded generator, so a frame's broken line keeps its pattern.
local function generator(seed)
    local state = math.floor(seed) % 2147483647
    if state <= 0 then
        state = state + 2147483646
    end
    return function()
        state = (state * 16807) % 2147483647
        return (state - 1) / 2147483646
    end
end

local function seedOf(text)
    local value = 7
    for index = 1, #text do
        value = (value * 31 + text:byte(index)) % 2147483647
    end
    return value
end

-- A straight piece of frame line. side is top, bottom, left or right.
local function piece(frame, side, offset, from, length, width, colour)
    local texture = frame:CreateTexture(nil, "BORDER")
    paint(texture, colour)
    if side == "top" then
        texture:SetPoint("TOPLEFT", frame, "TOPLEFT", from, -offset)
        texture:SetSize(length, width)
    elseif side == "bottom" then
        texture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", from, offset)
        texture:SetSize(length, width)
    elseif side == "left" then
        texture:SetPoint("TOPLEFT", frame, "TOPLEFT", offset, -from)
        texture:SetSize(width, length)
    else
        texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -offset, -from)
        texture:SetSize(width, length)
    end
    return texture
end

-- Dress a frame of the given size in the cut-corner frame.
-- kind is "major" (the window) or "minor" (a column). seed keeps the
-- pattern of the broken line the same each time the window is built.
function Skin.Frame(frame, kind, width, height, seed)
    local spec = FRAMES[kind] or FRAMES.minor
    local size = spec.size
    local pixel = onePixel(frame)
    local random = generator(seedOf(seed or kind))

    -- The ground. The corners carry their own, inside the cut.
    local fills = {
        -- point, relative point, x, y; then the opposite corner.
        { "TOPLEFT", "TOPLEFT", size, 0, "BOTTOMRIGHT", "BOTTOMRIGHT", -size, 0 },
        { "TOPLEFT", "TOPLEFT", 0, -size, "BOTTOMRIGHT", "BOTTOMLEFT", size, size },
        { "TOPLEFT", "TOPRIGHT", -size, -size, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, size },
    }
    for index = 1, #fills do
        local f = fills[index]
        local texture = frame:CreateTexture(nil, "BACKGROUND")
        paint(texture, spec.fill)
        texture:SetPoint(f[1], frame, f[2], f[3], f[4])
        texture:SetPoint(f[5], frame, f[6], f[7], f[8])
    end

    -- The corners.
    local points = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }
    local mirrored = {
        { 0, 1, 0, 1 },
        { 1, 0, 0, 1 },
        { 0, 1, 1, 0 },
        { 1, 0, 1, 0 },
    }
    local edge = 0.5 / 512
    local quadrants = {
        { 0, 0.5 - edge, 0, 0.5 - edge },
        { 0.5 + edge, 1, 0, 0.5 - edge },
        { 0, 0.5 - edge, 0.5 + edge, 1 },
        { 0.5 + edge, 1, 0.5 + edge, 1 },
    }
    for index = 1, 4 do
        local texture = frame:CreateTexture(nil, "BORDER")
        texture:SetDrawLayer("BORDER", 1)
        texture:SetTexture(PATH .. spec.file)
        local coords = spec.quadrants and quadrants[index] or mirrored[index]
        texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        texture:SetSize(size, size)
        texture:SetPoint(points[index], frame, points[index], 0, 0)
    end

    -- The straight lines between the corners.
    local sides = {
        { "top", width },
        { "bottom", width },
        { "left", height },
        { "right", height },
    }
    for s = 1, #sides do
        local side, span = sides[s][1], sides[s][2]
        local length = span - size * 2
        if length > 0 then
            for index = 1, #spec.lines do
                local line = spec.lines[index]
                local thickness = line[2]
                if pixel and thickness < pixel then
                    thickness = pixel
                end
                if line[4] then
                    -- Dashes of random length with short random breaks.
                    local at = 0
                    while at < length do
                        local dash = 10 + random() * 38
                        if length - (at + dash) < 8 then
                            dash = length - at
                        end
                        piece(frame, side, line[1], size + at, dash, thickness, line[3])
                        at = at + dash + 2 + random() * 4
                    end
                else
                    piece(frame, side, line[1], size, length, thickness, line[3])
                end
            end
        end
    end

    -- A low warmth along the bottom, as from coals. It lies over the
    -- corners too, but stays inside the cut.
    if kind == "major" then
        local warmth = Skin.Glyph(frame, "fadeUp", "ARTWORK")
        warmth:SetDrawLayer("ARTWORK", -1)
        warmth:SetBlendMode("ADD")
        tint(warmth, C.orange, 0.09)
        warmth:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", Skin.BAND + 14, Skin.BAND)
        warmth:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -Skin.BAND - 14, Skin.BAND)
        warmth:SetHeight(math.min(170, height / 3))
    end
end

-- Text ------------------------------------------------------------------

local STYLES = {
    title = { "GameFontNormalLarge", 24, C.gold, TITLE_FONT },
    name = { "GameFontNormalLarge", 18, C.gold, TITLE_FONT },
    heading = { "GameFontNormalSmall", 11, C.heading },
    body = { "GameFontHighlight", 13, C.text },
    small = { "GameFontHighlightSmall", 11, C.dim },
    label = { "GameFontNormalSmall", 11, C.dim },
    button = { "GameFontNormal", 12, C.gold },
}

function Skin.Text(parent, style, layer)
    local spec = STYLES[style] or STYLES.body
    local text = parent:CreateFontString(nil, layer or "OVERLAY", spec[1])
    local font, _, flags = text:GetFont()
    local set = false
    if spec[4] then
        set = text:SetFont(spec[4], spec[2], "") ~= false
    end
    if not set and font then
        text:SetFont(font, spec[2], flags)
    end
    text:SetTextColor(spec[3][1], spec[3][2], spec[3][3])
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if text.SetShadowOffset then
        text:SetShadowOffset(1, -1)
        text:SetShadowColor(0, 0, 0, 0.9)
    end
    return text
end

-- A section heading: a gem, the words, and a line running to the right.
function Skin.Header(parent, text, width)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(width, 16)
    local gem = Skin.Glyph(holder, "diamond", "ARTWORK", 12)
    gem:SetPoint("LEFT", holder, "LEFT", -2, 0)
    local words = Skin.Text(holder, "heading")
    words:SetPoint("LEFT", gem, "RIGHT", 3, 0)
    words:SetText(string.upper(text))
    local line = holder:CreateTexture(nil, "ARTWORK")
    paint(line, C.orange, 0.55)
    line:SetHeight(1)
    line:SetPoint("LEFT", words, "RIGHT", 8, 0)
    line:SetPoint("RIGHT", holder, "RIGHT", -2, 0)
    local tip = holder:CreateTexture(nil, "ARTWORK")
    paint(tip, C.orange, 0.9)
    tip:SetSize(4, 4)
    tip:SetPoint("CENTER", line, "RIGHT", 0, 0)
    holder.words = words
    holder.line = line
    function holder:SetHeading(value)
        words:SetText(string.upper(value))
    end
    return holder
end

-- Buttons ---------------------------------------------------------------

local BUTTON_ROWS = { normal = 0, hover = 1, pressed = 2, disabled = 3 }

local function buttonRow(button)
    if not button:IsEnabled() then
        return "disabled"
    elseif button.held then
        return "pressed"
    elseif button.hover or button.lit then
        return "hover"
    end
    return "normal"
end

local function paintButton(button)
    local state = buttonRow(button)
    local row = BUTTON_ROWS[state] + (button.plain and 4 or 0)
    local edge = 0.5 / 256
    local top = row * 0.125 + edge
    local bottom = row * 0.125 + 0.125 - edge
    button.left:SetTexCoord(0, 0.125, top, bottom)
    button.middle:SetTexCoord(0.125, 0.875, top, bottom)
    button.right:SetTexCoord(0.875, 1, top, bottom)
    local colour = C.gold
    if state == "disabled" then
        colour = C.muted
    elseif state == "hover" then
        colour = C.pale
    end
    button.caption:SetTextColor(colour[1], colour[2], colour[3])
    button.caption:ClearAllPoints()
    if state == "pressed" then
        button.caption:SetPoint("CENTER", button, "CENTER", 1, -1)
    else
        button.caption:SetPoint("CENTER", button, "CENTER", 0, 0)
    end
end

-- A real button: cut corners, gems at the ends, and a face that lights on
-- hover, sinks when pressed and greys out when it cannot be used. A plain
-- button has no gems, for narrow buttons.
function Skin.Button(parent, text, width, height, plain)
    height = height or 26
    local button = CreateFrame("Button", nil, parent)
    button.plain = plain and true or false
    button:SetSize(width, height)
    local cap = height / 2
    local file = PATH .. "EldgrimButton"
    button.left = button:CreateTexture(nil, "BACKGROUND")
    button.left:SetTexture(file)
    button.left:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    button.left:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
    button.left:SetWidth(cap)
    button.right = button:CreateTexture(nil, "BACKGROUND")
    button.right:SetTexture(file)
    button.right:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
    button.right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
    button.right:SetWidth(cap)
    button.middle = button:CreateTexture(nil, "BACKGROUND")
    button.middle:SetTexture(file)
    button.middle:SetPoint("TOPLEFT", button.left, "TOPRIGHT", 0, 0)
    button.middle:SetPoint("BOTTOMRIGHT", button.right, "BOTTOMLEFT", 0, 0)
    button.caption = Skin.Text(button, "button")
    button.caption:SetJustifyH("CENTER")
    button.caption:SetJustifyV("MIDDLE")
    button.caption:SetText(text or "")

    button:SetScript("OnEnter", function(self)
        self.hover = true
        paintButton(self)
        if self.tooltip and GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.tooltip, 1, 0.86, 0.6, 1, true)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function(self)
        self.hover = false
        self.held = false
        paintButton(self)
        if self.tooltip and GameTooltip then
            GameTooltip:Hide()
        end
    end)
    button:SetScript("OnMouseDown", function(self)
        if self:IsEnabled() then
            self.held = true
            paintButton(self)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self.held = false
        paintButton(self)
    end)

    function button:SetLabel(value)
        self.caption:SetText(value or "")
    end
    function button:SetActive(on)
        if on then
            self:Enable()
        else
            self:Disable()
        end
        paintButton(self)
    end
    function button:SetLit(on)
        self.lit = on and true or false
        paintButton(self)
    end
    paintButton(button)
    return button
end

-- A small square button showing one glyph, with a lit glyph on hover.
function Skin.IconButton(parent, glyph, litGlyph, size, tooltip)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size, size)
    local icon = Skin.Glyph(button, glyph, "ARTWORK")
    icon:SetAllPoints(button)
    button.icon = icon
    button:SetScript("OnEnter", function(self)
        Skin.SetGlyph(icon, litGlyph)
        local tip = self.tooltip or tooltip
        if tip and tip ~= "" and GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tip, 1, 0.86, 0.6, 1, true)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        Skin.SetGlyph(icon, glyph)
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    button:SetScript("OnMouseDown", function()
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    end)
    button:SetScript("OnMouseUp", function()
        icon:ClearAllPoints()
        icon:SetAllPoints(button)
    end)
    return button
end

-- Text fields -----------------------------------------------------------

-- Nine pieces cut from a 32-pixel cell of the field sheet, corners 8 pixels.
local WELL_CORNER = 6
local WELL_SPOTS = {
    -- column, row, anchor points with offsets
    { 1, 1, { "TOPLEFT", 0, 0 } },
    { 2, 1, { "TOPLEFT", 1, 0 }, { "TOPRIGHT", -1, 0 } },
    { 3, 1, { "TOPRIGHT", 0, 0 } },
    { 1, 2, { "TOPLEFT", 0, -1 }, { "BOTTOMLEFT", 0, 1 } },
    { 2, 2, { "TOPLEFT", 1, -1 }, { "BOTTOMRIGHT", -1, 1 } },
    { 3, 2, { "TOPRIGHT", 0, -1 }, { "BOTTOMRIGHT", 0, 1 } },
    { 1, 3, { "BOTTOMLEFT", 0, 0 } },
    { 2, 3, { "BOTTOMLEFT", 1, 0 }, { "BOTTOMRIGHT", -1, 0 } },
    { 3, 3, { "BOTTOMRIGHT", 0, 0 } },
}

local function well(frame, cellIndex, layer)
    local pieces = {}
    local u0 = cellIndex * 0.5
    local u = { u0, u0 + 0.125, u0 + 0.375, u0 + 0.5 }
    local v = { 0, 0.25, 0.75, 1 }
    for index = 1, #WELL_SPOTS do
        local spot = WELL_SPOTS[index]
        local col, row = spot[1], spot[2]
        local texture = frame:CreateTexture(nil, layer)
        texture:SetTexture(PATH .. "EldgrimField")
        texture:SetTexCoord(u[col], u[col + 1], v[row], v[row + 1])
        if col ~= 2 then
            texture:SetWidth(WELL_CORNER)
        end
        if row ~= 2 then
            texture:SetHeight(WELL_CORNER)
        end
        -- Offsets of 1 mean one corner's width inward.
        for p = 3, #spot do
            local point = spot[p]
            texture:SetPoint(point[1], frame, point[1], point[2] * WELL_CORNER, point[3] * WELL_CORNER)
        end
        pieces[#pieces + 1] = texture
    end
    return pieces
end

local function showPieces(pieces, on)
    for index = 1, #pieces do
        if on then
            pieces[index]:Show()
        else
            pieces[index]:Hide()
        end
    end
end

-- A sunk text field with a placeholder and a letter count.
-- options: label, placeholder, maxLetters, multiLine.
function Skin.Field(parent, width, height, options)
    options = options or {}
    local box = CreateFrame("Frame", nil, parent)
    box:SetSize(width, height)
    box:EnableMouse(true)
    local rest = well(box, 0, "BACKGROUND")
    local lit = well(box, 1, "BORDER")
    showPieces(lit, false)

    local edit
    local scroll
    if options.multiLine then
        scroll = CreateFrame("ScrollFrame", nil, box)
        scroll:SetPoint("TOPLEFT", box, "TOPLEFT", 8, -6)
        scroll:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -8, 6)
        edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetSize(width - 16, height - 12)
        scroll:SetScrollChild(edit)
        scroll:EnableMouseWheel(true)
        scroll:SetScript("OnMouseWheel", function(self, delta)
            local range = math.max(0, edit:GetHeight() - self:GetHeight())
            local value = math.min(range, math.max(0, self:GetVerticalScroll() - delta * 14))
            self:SetVerticalScroll(value)
        end)
        edit:SetScript("OnCursorChanged", function(_, _, y, _, lineHeight)
            local top = -y
            local view = scroll:GetHeight()
            local current = scroll:GetVerticalScroll()
            if top < current then
                scroll:SetVerticalScroll(top)
            elseif top + lineHeight > current + view then
                scroll:SetVerticalScroll(top + lineHeight - view)
            end
        end)
    else
        edit = CreateFrame("EditBox", nil, box)
        edit:SetPoint("TOPLEFT", box, "TOPLEFT", 8, 0)
        edit:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -8, 0)
    end
    edit:SetFontObject(ChatFontNormal)
    edit:SetTextColor(C.text[1], C.text[2], C.text[3])
    edit:SetAutoFocus(false)
    if options.maxLetters then
        edit:SetMaxLetters(options.maxLetters)
    end
    box.edit = edit
    box.scroll = scroll

    local hint = Skin.Text(box, "small", "ARTWORK")
    hint:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
    if options.multiLine then
        hint:SetPoint("TOPLEFT", box, "TOPLEFT", 9, -7)
        hint:SetPoint("RIGHT", box, "RIGHT", -9, 0)
    else
        hint:SetPoint("LEFT", box, "LEFT", 9, 0)
        hint:SetPoint("RIGHT", box, "RIGHT", -9, 0)
        hint:SetJustifyV("MIDDLE")
    end
    hint:SetText(options.placeholder or "")

    if options.label then
        local label = Skin.Text(box, "label")
        label:SetPoint("BOTTOMLEFT", box, "TOPLEFT", 1, 4)
        label:SetText(options.label)
        box.label = label
    end
    local count
    if options.maxLetters then
        count = Skin.Text(box, "small")
        count:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
        count:SetJustifyH("RIGHT")
        count:SetPoint("BOTTOMRIGHT", box, "TOPRIGHT", -1, 4)
        box.count = count
    end

    local function update()
        local text = edit:GetText() or ""
        if text == "" and not edit:HasFocus() then
            hint:Show()
        else
            hint:Hide()
        end
        if count then
            local length = string.len(text)
            count:SetText(length .. " / " .. options.maxLetters)
            local colour = length >= options.maxLetters and C.heading or C.muted
            count:SetTextColor(colour[1], colour[2], colour[3])
        end
    end
    box.Update = update

    edit:SetScript("OnEditFocusGained", function()
        showPieces(lit, true)
        showPieces(rest, false)
        update()
    end)
    edit:SetScript("OnEditFocusLost", function()
        showPieces(lit, false)
        showPieces(rest, true)
        if edit.HighlightText then
            edit:HighlightText(0, 0)
        end
        update()
    end)
    edit:SetScript("OnTextChanged", update)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    edit:SetScript("OnTabPressed", function()
        if box.nextField then
            box.nextField.edit:SetFocus()
        end
    end)
    if not options.multiLine then
        edit:SetScript("OnEnterPressed", function(self)
            if box.nextField then
                box.nextField.edit:SetFocus()
            else
                self:ClearFocus()
            end
        end)
    end
    box:SetScript("OnMouseDown", function()
        edit:SetFocus()
    end)

    function box:GetValue()
        return edit:GetText() or ""
    end
    function box:SetValue(value)
        edit:SetText(value or "")
        update()
    end
    update()
    return box
end

-- Scroll areas ----------------------------------------------------------

-- A scroll area with a slim flame-coloured bar that shows only when needed.
-- Give a height, or leave it nil and anchor the top and bottom instead.
function Skin.Scroll(parent, width, height)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetWidth(width)
    if height then
        scroll:SetHeight(height)
    end
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(width - 12, height or 1)
    scroll:SetScrollChild(content)
    scroll.content = content
    scroll.contentHeight = 0

    local track = Skin.Glyph(scroll, "track", "ARTWORK")
    track:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 2, 0)
    track:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 2, 0)
    track:SetWidth(8)
    local thumb = CreateFrame("Frame", nil, scroll)
    thumb:SetWidth(8)
    thumb:EnableMouse(true)
    local thumbArt = Skin.Glyph(thumb, "thumb", "OVERLAY")
    thumbArt:SetAllPoints(thumb)

    local function view()
        return height or scroll:GetHeight()
    end
    local function range()
        return math.max(0, scroll.contentHeight - view())
    end
    local function place()
        local r = range()
        if r <= 0 then
            track:Hide()
            thumb:Hide()
            return
        end
        track:Show()
        thumb:Show()
        local h = view()
        local size = math.max(18, h * h / scroll.contentHeight)
        local at = (h - size) * (scroll:GetVerticalScroll() / r)
        thumb:SetHeight(size)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 2, -at)
    end
    local function scrollTo(value)
        scroll:SetVerticalScroll(math.min(range(), math.max(0, value)))
        place()
    end
    scroll.ScrollTo = scrollTo

    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        scrollTo(self:GetVerticalScroll() - delta * 28)
    end)
    scroll:SetScript("OnSizeChanged", function()
        scrollTo(scroll:GetVerticalScroll())
    end)
    thumb:SetScript("OnMouseDown", function(self)
        local _, cursor = GetCursorPosition()
        self.grab = cursor / self:GetEffectiveScale()
        self.from = scroll:GetVerticalScroll()
        self:SetScript("OnUpdate", function()
            local _, now = GetCursorPosition()
            now = now / self:GetEffectiveScale()
            local travel = view() - self:GetHeight()
            if travel > 0 then
                scrollTo(self.from + (self.grab - now) * range() / travel)
            end
        end)
    end)
    thumb:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    function scroll:SetContentHeight(value)
        self.contentHeight = value
        content:SetHeight(math.max(value, 1))
        scrollTo(self:GetVerticalScroll())
    end
    place()
    return scroll
end

-- List rows -------------------------------------------------------------

-- A list entry: flame bullet, title, a dim line under it, a glow on hover
-- and a gold bar when chosen.
function Skin.Row(parent, width, height)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(width, height)
    local glow = Skin.Glyph(row, "fadeRight", "BACKGROUND")
    glow:SetBlendMode("ADD")
    glow:SetAllPoints(row)
    glow:Hide()
    local chosen = Skin.Glyph(row, "fadeRight", "BACKGROUND")
    chosen:SetBlendMode("ADD")
    tint(chosen, C.orange, 0.28)
    chosen:SetAllPoints(row)
    chosen:Hide()
    local bar = row:CreateTexture(nil, "ARTWORK")
    paint(bar, C.gold)
    bar:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -3)
    bar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 3)
    bar:SetWidth(2)
    bar:Hide()
    local icon = Skin.Glyph(row, "flame", "ARTWORK", 16)
    icon:SetPoint("LEFT", row, "LEFT", 6, 0)
    local title = Skin.Text(row, "body")
    title:SetPoint("TOPLEFT", row, "TOPLEFT", 28, -5)
    title:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    title:SetWordWrap(false)
    title:SetHeight(15)
    local sub = Skin.Text(row, "small")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    sub:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    sub:SetWordWrap(false)
    sub:SetHeight(13)
    local rule = row:CreateTexture(nil, "BACKGROUND")
    paint(rule, C.orange, 0.12)
    rule:SetHeight(1)
    rule:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 26, 0)
    rule:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -4, 0)
    row.title = title
    row.sub = sub
    row.icon = icon

    row:SetScript("OnEnter", function()
        tint(glow, C.orange, 0.16)
        glow:Show()
        title:SetTextColor(C.pale[1], C.pale[2], C.pale[3])
    end)
    row:SetScript("OnLeave", function(self)
        glow:Hide()
        local colour = self.dimmed and C.dim or C.text
        title:SetTextColor(colour[1], colour[2], colour[3])
    end)
    function row:SetChosen(on)
        if on then
            chosen:Show()
            bar:Show()
        else
            chosen:Hide()
            bar:Hide()
        end
    end
    function row:SetDimmed(on)
        self.dimmed = on
        local colour = on and C.dim or C.text
        title:SetTextColor(colour[1], colour[2], colour[3])
        icon:SetDesaturated(on and true or false)
        icon:SetAlpha(on and 0.55 or 1)
    end
    return row
end

-- Choices ---------------------------------------------------------------

-- One choice out of several, as gem radio marks in a grid.
-- options: list of { value, label, tooltip }.
function Skin.Choice(parent, width, options, columns)
    columns = columns or 2
    local holder = CreateFrame("Frame", nil, parent)
    local rows = math.ceil(#options / columns)
    local cell = width / columns
    holder:SetSize(width, rows * 22)
    holder.marks = {}
    local function paintAll()
        for index = 1, #holder.marks do
            local mark = holder.marks[index]
            local on = mark.value == holder.value
            Skin.SetGlyph(mark.gem, on and "radioOn" or "radio")
            local colour = on and C.gold or C.text
            if mark.hover then
                colour = C.pale
            end
            mark.words:SetTextColor(colour[1], colour[2], colour[3])
        end
    end
    for index = 1, #options do
        local option = options[index]
        local mark = CreateFrame("Button", nil, holder)
        mark:SetSize(cell - 4, 20)
        local col = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        mark:SetPoint("TOPLEFT", holder, "TOPLEFT", col * cell, -row * 22)
        mark.gem = Skin.Glyph(mark, "radio", "ARTWORK", 18)
        mark.gem:SetPoint("LEFT", mark, "LEFT", 0, 0)
        mark.words = Skin.Text(mark, "body")
        mark.words:SetPoint("LEFT", mark.gem, "RIGHT", 4, 0)
        mark.words:SetJustifyV("MIDDLE")
        mark.words:SetText(option[2])
        mark.value = option[1]
        mark:SetScript("OnClick", function(self)
            holder:SetValue(self.value)
            if holder.onChange then
                holder.onChange(self.value)
            end
        end)
        mark:SetScript("OnEnter", function(self)
            self.hover = true
            paintAll()
            if option[3] and GameTooltip then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(option[2], 1, 0.76, 0.32)
                GameTooltip:AddLine(option[3], 1, 0.9, 0.75, true)
                GameTooltip:Show()
            end
        end)
        mark:SetScript("OnLeave", function(self)
            self.hover = false
            paintAll()
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        holder.marks[#holder.marks + 1] = mark
    end
    function holder:SetValue(value)
        self.value = value
        paintAll()
    end
    holder:SetValue(options[1] and options[1][1])
    return holder
end

-- A soft glow behind something, tinted, that can breathe slowly.
function Skin.Glow(parent, size, colour, alpha, breathe)
    local glow = Skin.Glyph(parent, "glow", "BACKGROUND")
    glow:SetBlendMode("ADD")
    tint(glow, colour or C.orange, alpha or 0.5)
    glow:SetSize(size, size)
    if breathe and glow.CreateAnimationGroup then
        local group = glow:CreateAnimationGroup()
        local fade = group:CreateAnimation("Alpha")
        fade:SetFromAlpha(1)
        fade:SetToAlpha(0.45)
        fade:SetDuration(breathe)
        if fade.SetSmoothing then
            fade:SetSmoothing("IN_OUT")
        end
        group:SetLooping("BOUNCE")
        group:Play()
        glow.breath = group
    end
    return glow
end
