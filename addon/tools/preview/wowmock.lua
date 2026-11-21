-- A small stand-in for the WoW frame API, enough to lay out the hearth board
-- and dump what would be drawn. It is a preview aid, not a client: fonts,
-- text measurement and pixel snapping are approximations.

local Mock = {}
local unpack = unpack or table.unpack
local regions = {}
local order = 0

local LAYERS = { BACKGROUND = 1, BORDER = 2, ARTWORK = 3, OVERLAY = 4, HIGHLIGHT = 5 }
local STRATA = { BACKGROUND = 1, LOW = 2, MEDIUM = 3, HIGH = 4, DIALOG = 5, FULLSCREEN = 6, TOOLTIP = 8 }

local function nextOrder()
    order = order + 1
    return order
end

-- Character advances measured from the preview's stand-in fonts, as a share
-- of the font size. Without them, a rough guess is used.
local METRICS = nil
local ok, measured = pcall(require, "metrics")
if ok then
    METRICS = measured
end

local function charWidth(ch, size)
    if METRICS and METRICS.body[ch] then
        return size * METRICS.body[ch]
    end
    if ch == " " then
        return size * 0.28
    elseif ch:match("[%.,'%:;!|il]") then
        return size * 0.26
    elseif ch:match("[A-Z]") then
        return size * 0.66
    elseif ch:match("[mwMW]") then
        return size * 0.78
    end
    return size * 0.50
end

local function textWidth(text, size)
    local width = 0
    for ch in tostring(text):gmatch(".") do
        width = width + charWidth(ch, size)
    end
    return width
end

local function wrapCount(text, size, width)
    if not width or width <= 0 then
        local lines = 1
        for _ in tostring(text):gmatch("\n") do
            lines = lines + 1
        end
        return lines
    end
    local lines = 0
    for para in (tostring(text) .. "\n"):gmatch("(.-)\n") do
        local line = 0
        lines = lines + 1
        for word in para:gmatch("%S+") do
            local w = textWidth(word .. " ", size)
            if line > 0 and line + w > width then
                lines = lines + 1
                line = w
            else
                line = line + w
            end
        end
    end
    return lines
end

local Region = {}
Region.__index = Region

local function newRegion(kind, parent)
    local r = setmetatable({
        kind = kind,
        parent = parent,
        points = {},
        shown = true,
        alpha = 1,
        scripts = {},
        children = {},
        order = nextOrder(),
    }, Region)
    if parent then
        parent.children[#parent.children + 1] = r
    end
    regions[#regions + 1] = r
    return r
end

function Region:SetPoint(point, a, b, c, d)
    local rel, relPoint, x, y
    if type(a) == "number" or a == nil and b == nil then
        rel, relPoint, x, y = self.parent, point, a or 0, b or 0
    else
        rel = a
        if type(rel) == "string" then
            rel = _G[rel]
        end
        if type(b) == "string" then
            relPoint, x, y = b, c or 0, d or 0
        else
            relPoint, x, y = point, b or 0, c or 0
        end
    end
    rel = rel or self.parent
    for i = #self.points, 1, -1 do
        if self.points[i].point == point then
            table.remove(self.points, i)
        end
    end
    self.points[#self.points + 1] = { point = point, rel = rel, relPoint = relPoint, x = x, y = y }
end
function Region:ClearAllPoints()
    self.points = {}
end
function Region:SetAllPoints(rel)
    rel = rel or self.parent
    self:SetPoint("TOPLEFT", rel, "TOPLEFT", 0, 0)
    self:SetPoint("BOTTOMRIGHT", rel, "BOTTOMRIGHT", 0, 0)
end
function Region:SetSize(w, h)
    self.w, self.h = w, h
end
function Region:SetWidth(w)
    self.w = w
end
function Region:SetHeight(h)
    self.h = h
end
function Region:GetWidth()
    local l, _, r = Mock.Rect(self)
    return l and (r - l) or (self.w or 0)
end
function Region:GetHeight()
    local _, b, _, t = Mock.Rect(self)
    return b and (t - b) or (self.h or 0)
end
function Region:GetSize()
    return self:GetWidth(), self:GetHeight()
end
function Region:Show()
    self.shown = true
    if self.scripts.OnShow then
        self.scripts.OnShow(self)
    end
end
function Region:Hide()
    self.shown = false
end
function Region:SetShown(on)
    if on then
        self:Show()
    else
        self:Hide()
    end
end
function Region:IsShown()
    return self.shown
end
function Region:IsVisible()
    local r = self
    while r do
        if not r.shown then
            return false
        end
        r = r.parent
    end
    return true
end
function Region:SetAlpha(a)
    self.alpha = a
end
function Region:GetAlpha()
    return self.alpha
end
function Region:GetParent()
    return self.parent
end
function Region:GetEffectiveScale()
    return 1
end
function Region:GetName()
    return self.name
end
function Region:CreateAnimationGroup()
    local group = {}
    function group:CreateAnimation()
        local anim = {}
        setmetatable(anim, { __index = function()
            return function() end
        end })
        return anim
    end
    function group:SetLooping() end
    function group:Play() end
    function group:Stop() end
    return group
end

-- Textures and font strings ------------------------------------------------

local function layered(r, layer, sub)
    r.layer = layer or "ARTWORK"
    r.sub = sub or 0
end

function Region:SetDrawLayer(layer, sub)
    layered(self, layer, sub)
end
function Region:SetTexture(file)
    self.file = file
    self.color = nil
end
function Region:SetColorTexture(r, g, b, a)
    self.color = { r, g, b, a or 1 }
    self.file = nil
end
function Region:SetTexCoord(l, r, t, b)
    self.coords = { l, r, t, b }
end
function Region:SetVertexColor(r, g, b, a)
    self.vertex = { r, g, b, a or 1 }
end
function Region:SetBlendMode(mode)
    self.blend = mode
end
function Region:SetDesaturated(on)
    self.desaturated = on
end
function Region:SetSnapToPixelGrid() end
function Region:SetTexelSnappingBias() end

local FONT_OBJECTS = {
    GameFontNormal = 12,
    GameFontNormalSmall = 10,
    GameFontNormalLarge = 16,
    GameFontHighlight = 12,
    GameFontHighlightSmall = 10,
    ChatFontNormal = 14,
}

function Region:SetFont(path, size, flags)
    self.font = path
    self.size = size
    self.flags = flags
    return true
end
function Region:GetFont()
    return self.font or "Fonts\\FRIZQT__.TTF", self.size or 12, self.flags or ""
end
function Region:SetFontObject(object)
    self.size = FONT_OBJECTS[object] or 12
    self.font = "Fonts\\FRIZQT__.TTF"
end
function Region:SetText(text)
    self.text = text and tostring(text) or ""
    if self.kind == "EditBox" and self.scripts.OnTextChanged then
        self.scripts.OnTextChanged(self, false)
    end
end
function Region:GetText()
    return self.text or ""
end
function Region:SetTextColor(r, g, b, a)
    self.textColor = { r, g, b, a or 1 }
end
function Region:SetJustifyH(v)
    self.justifyH = v
end
function Region:SetJustifyV(v)
    self.justifyV = v
end
function Region:SetWordWrap(v)
    self.wrap = v
end
function Region:SetSpacing(v)
    self.spacing = v
end
function Region:SetShadowOffset(x, y)
    self.shadow = { x, y }
end
function Region:SetShadowColor() end
function Region:GetStringWidth()
    return textWidth(self.text or "", self.size or 12)
end
function Region:GetStringHeight()
    local size = self.size or 12
    local lines = wrapCount(self.text or "", size, self.w)
    if (self.text or "") == "" then
        return 0
    end
    return lines * (size * 1.25 + (self.spacing or 0))
end

-- Frames -------------------------------------------------------------------

function Region:CreateTexture(_, layer, _, sub)
    local t = newRegion("Texture", self)
    layered(t, layer, sub)
    return t
end
function Region:CreateFontString(_, layer, template)
    local t = newRegion("FontString", self)
    layered(t, layer or "OVERLAY")
    t.size = FONT_OBJECTS[template] or 12
    t.font = "Fonts\\FRIZQT__.TTF"
    t.wrap = true
    return t
end
function Region:CreateMaskTexture()
    return self:CreateTexture()
end
function Region:SetScript(name, fn)
    self.scripts[name] = fn
end
function Region:GetScript(name)
    return self.scripts[name]
end
function Region:HookScript(name, fn)
    local old = self.scripts[name]
    self.scripts[name] = function(...)
        if old then
            old(...)
        end
        fn(...)
    end
end
function Region:RegisterEvent() end
function Region:UnregisterEvent() end
function Region:RegisterForDrag() end
function Region:RegisterForClicks() end
function Region:EnableMouse() end
function Region:EnableMouseWheel() end
function Region:EnableKeyboard() end
function Region:SetMovable() end
function Region:SetResizable() end
function Region:SetClampedToScreen() end
function Region:SetToplevel() end
function Region:StartMoving() end
function Region:StopMovingOrSizing() end
function Region:SetFrameStrata(s)
    self.strata = s
end
function Region:GetFrameStrata()
    local r = self
    while r do
        if r.strata then
            return r.strata
        end
        r = r.parent
    end
    return "MEDIUM"
end
function Region:SetFrameLevel(level)
    self.level = level
end
function Region:GetFrameLevel()
    if self.level then
        return self.level
    end
    if self.parent and self.parent.GetFrameLevel then
        return self.parent:GetFrameLevel() + 1
    end
    return 0
end
function Region:GetChildren()
    local out = {}
    for _, c in ipairs(self.children) do
        if c.kind ~= "Texture" and c.kind ~= "FontString" then
            out[#out + 1] = c
        end
    end
    return unpack(out)
end
function Region:IsEnabled()
    return not self.disabled
end
function Region:Enable()
    self.disabled = false
    if self.scripts.OnEnable then
        self.scripts.OnEnable(self)
    end
end
function Region:Disable()
    self.disabled = true
    if self.scripts.OnDisable then
        self.scripts.OnDisable(self)
    end
end
function Region:SetEnabled(on)
    if on then
        self:Enable()
    else
        self:Disable()
    end
end
-- EditBox
function Region:SetMultiLine(v)
    self.multiLine = v
end
function Region:SetAutoFocus() end
function Region:SetMaxLetters(n)
    self.maxLetters = n
end
function Region:SetTextInsets() end
function Region:HighlightText() end
function Region:SetFocus()
    if Mock.focus and Mock.focus ~= self and Mock.focus.scripts.OnEditFocusLost then
        local old = Mock.focus
        Mock.focus = nil
        old.scripts.OnEditFocusLost(old)
    end
    Mock.focus = self
    if self.scripts.OnEditFocusGained then
        self.scripts.OnEditFocusGained(self)
    end
end
function Region:ClearFocus()
    if Mock.focus == self then
        Mock.focus = nil
        if self.scripts.OnEditFocusLost then
            self.scripts.OnEditFocusLost(self)
        end
    end
end
function Region:HasFocus()
    return Mock.focus == self
end
-- ScrollFrame
function Region:SetScrollChild(child)
    self.scrollChild = child
    child.scrollParent = self
end
function Region:SetVerticalScroll(v)
    self.vscroll = v
end
function Region:GetVerticalScroll()
    return self.vscroll or 0
end
function Region:GetVerticalScrollRange()
    return 0
end

function CreateFrame(kind, name, parent)
    local f = newRegion(kind or "Frame", parent)
    f.name = name
    if name then
        _G[name] = f
    end
    return f
end

-- Layout -------------------------------------------------------------------

local cache = {}

local function pointXY(point)
    local h = point:find("LEFT") and 0 or (point:find("RIGHT") and 1 or 0.5)
    local v = point:find("TOP") and 1 or (point:find("BOTTOM") and 0 or 0.5)
    return h, v
end

-- Returns left, bottom, right, top in UIParent units, y up.
function Mock.Rect(r)
    if Mock.caching and cache[r] then
        return unpack(cache[r])
    end
    if r == Mock.UIParent then
        return 0, 0, r.w, r.h
    end
    if r.scrollParent then
        local l, _, _, t = Mock.Rect(r.scrollParent)
        local w = r.w or 0
        local h = r.h or 0
        t = t + (r.scrollParent.vscroll or 0)
        local rect = { l, t - h, l + w, t }
        cache[r] = rect
        return unpack(rect)
    end
    local xs, ys = {}, {}
    for _, p in ipairs(r.points) do
        local rl, rb, rr, rt = Mock.Rect(p.rel)
        local rh, rv = pointXY(p.relPoint)
        local ax = rl + (rr - rl) * rh + p.x
        local ay = rb + (rt - rb) * rv + p.y
        local h, v = pointXY(p.point)
        xs[h] = ax
        ys[v] = ay
    end
    local w = r.w
    local h = r.h
    if r.kind == "FontString" then
        local size = r.size or 12
        if not w and not (xs[0] and xs[1]) then
            w = textWidth(r.text or "", size)
        end
    end
    local left, right
    if xs[0] and xs[1] then
        left, right = xs[0], xs[1]
    elseif xs[0] then
        left, right = xs[0], xs[0] + (w or 0)
    elseif xs[1] then
        left, right = xs[1] - (w or 0), xs[1]
    elseif xs[0.5] then
        left, right = xs[0.5] - (w or 0) / 2, xs[0.5] + (w or 0) / 2
    else
        left, right = 0, w or 0
    end
    if r.kind == "FontString" and not h then
        -- A string with no width of its own does not wrap.
        local saved = r.w
        if saved or (xs[0] and xs[1]) then
            r.w = right - left
        end
        h = r:GetStringHeight()
        r.w = saved
    end
    local bottom, top
    if ys[0] and ys[1] then
        bottom, top = ys[0], ys[1]
    elseif ys[1] then
        bottom, top = ys[1] - (h or 0), ys[1]
    elseif ys[0] then
        bottom, top = ys[0], ys[0] + (h or 0)
    elseif ys[0.5] then
        bottom, top = ys[0.5] - (h or 0) / 2, ys[0.5] + (h or 0) / 2
    else
        bottom, top = 0, h or 0
    end
    local rect = { left, bottom, right, top }
    cache[r] = rect
    return unpack(rect)
end

local function visible(r)
    while r do
        if not r.shown then
            return false
        end
        r = r.parent
    end
    return true
end

local function alphaOf(r)
    local a = 1
    while r do
        a = a * (r.alpha or 1)
        r = r.parent
    end
    return a
end

local function clipOf(r)
    local p = r
    while p do
        if p.scrollParent then
            local l, b, rr, t = Mock.Rect(p.scrollParent)
            return { l, b, rr, t }
        end
        p = p.parent
    end
    return nil
end

local function frameOf(r)
    if r.kind == "Texture" or r.kind == "FontString" then
        return r.parent
    end
    return r
end

local function json(value)
    local t = type(value)
    if t == "table" then
        if #value > 0 or next(value) == nil then
            local out = {}
            for i = 1, #value do
                out[i] = json(value[i])
            end
            return "[" .. table.concat(out, ",") .. "]"
        end
        local out = {}
        for k, v in pairs(value) do
            out[#out + 1] = string.format("%q", tostring(k)) .. ":" .. json(v)
        end
        return "{" .. table.concat(out, ",") .. "}"
    elseif t == "string" then
        return '"' .. value:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub("\n", "\\n") .. '"'
    elseif t == "number" then
        return string.format("%.4f", value)
    elseif t == "boolean" then
        return tostring(value)
    end
    return "null"
end

-- Everything visible, in drawing order, as JSON.
function Mock.Dump()
    cache = {}
    Mock.caching = true
    local items = {}
    for _, r in ipairs(regions) do
        if visible(r) and r ~= Mock.UIParent then
            local frame = frameOf(r)
            local l, b, rr, t = Mock.Rect(r)
            local item = {
                kind = r.kind,
                rect = { l, b, rr, t },
                clip = clipOf(r),
                alpha = alphaOf(r),
                strata = STRATA[frame:GetFrameStrata()] or 3,
                level = frame:GetFrameLevel(),
                layer = LAYERS[r.layer or "ARTWORK"] or 3,
                sub = r.sub or 0,
                order = r.order,
            }
            if r.kind == "Texture" then
                item.file = r.file
                item.color = r.color
                item.coords = r.coords
                item.vertex = r.vertex
                item.blend = r.blend
                item.desaturated = r.desaturated or false
                items[#items + 1] = item
            elseif r.kind == "FontString" then
                if (r.text or "") ~= "" then
                    local sized = r.w or #r.points > 1
                    item.autoWidth = not sized
                    item.text = r.text
                    item.font = r.font
                    item.size = r.size
                    item.color = r.textColor or { 1, 0.82, 0 }
                    item.justifyH = r.justifyH or "CENTER"
                    item.justifyV = r.justifyV or "MIDDLE"
                    item.wrap = r.wrap ~= false
                    item.spacing = r.spacing or 0
                    items[#items + 1] = item
                end
            elseif r.kind == "EditBox" then
                item.layer = 6
                item.text = r.text or ""
                item.font = r.font
                item.size = r.size or 14
                item.color = r.textColor or { 1, 1, 1 }
                item.multiLine = r.multiLine or false
                item.focus = Mock.focus == r
                items[#items + 1] = item
            end
        end
    end
    table.sort(items, function(a, c)
        if a.strata ~= c.strata then
            return a.strata < c.strata
        elseif a.level ~= c.level then
            return a.level < c.level
        elseif a.layer ~= c.layer then
            return a.layer < c.layer
        elseif a.sub ~= c.sub then
            return a.sub < c.sub
        end
        return a.order < c.order
    end)
    return json({ width = Mock.UIParent.w, height = Mock.UIParent.h, items = items })
end

function Mock.Regions()
    return regions
end

function Mock.Reset(width, height)
    regions = {}
    order = 0
    Mock.focus = nil
    UIParent = newRegion("Frame", nil)
    UIParent.w, UIParent.h = width, height
    Mock.UIParent = UIParent
    UISpecialFrames = {}
    ChatFontNormal = "ChatFontNormal"
    GameTooltip = setmetatable({}, { __index = function()
        return function() end
    end })
    function GetCursorPosition()
        return 0, 0
    end
end

return Mock
