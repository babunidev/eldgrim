-- Guild sync for the hearth board.
-- Plain text, a version digit, and a short checksum. No cipher.
-- The 255-byte cap, the rate, addon whispers to a two-part name, and whether
-- a payload keeps "#" are still unchecked on Forever 1.60.1.

local PREFIX = "ELDGRIM"
local MASTER = "Jasmine Amberbrew"
local VERSION = "1"
local MAX_BYTES = 255
local PART_TIMEOUT = 60
local HOLD_LIMIT = 7 * 24 * 60 * 60
local SEND_GAP = 0.25
local MATCH_WINDOW = 10
local TITLE_MAX = 60
local STORY_MAX = 400
local OBJECTIVE_MAX = 200
local OPEN_LIMIT = 3
local HISTORY_LIMIT = 4
-- A member quest is completed when the one who took it marks it complete
-- and its creator confirms. There is no other proof.
local PROOF = "creator"

-- Rank index 0 is always an invite rank. The rest of Amberhearth's invite
-- ranks are not written down yet, so they are not on this list.
-- GuildControlGetRankFlags is not the check.
local INVITE_RANKS = {
    [0] = true,
}

local queue = {}
local lastSendAt = -1
local partials = {}
local summaries = {}
local awaiting = nil
local decideAt = nil
local announced = false
local masterHeard = false
local nextHoldId = 1
local nextBatchId = 1
local nextMessageId = 1
local pendingReply = nil
local summarySentFor = nil
local sessionStart = nil
-- The Sunday gathering: set further down, used by noteMaster.
local sendGathering = nil
local gatheringOpen = nil
local gatheringCheckAt = 0
local nextGatheringId = 1

EldgrimSync = EldgrimSync or {}
EldgrimSync.Sent = {}

local function bxor(a, b)
    local result = 0
    local bitValue = 1
    for _ = 1, 32 do
        if a % 2 ~= b % 2 then
            result = result + bitValue
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bitValue = bitValue * 2
    end
    return result
end

local function mul32(a, b)
    a = a % 4294967296
    b = b % 4294967296
    local aLow = a % 65536
    local aHigh = math.floor(a / 65536)
    local bLow = b % 65536
    local bHigh = math.floor(b / 65536)
    local low = aLow * bLow
    local mid = aHigh * bLow + aLow * bHigh
    return (low + (mid % 65536) * 65536) % 4294967296
end

local function hash32(text)
    local hash = 2166136261
    for index = 1, #text do
        hash = bxor(hash, text:byte(index))
        hash = mul32(hash, 16777619)
    end
    return string.format("%08X", hash)
end

local function checksum(text)
    local sum = 0
    for index = 1, #text do
        sum = (sum + text:byte(index)) % 65536
    end
    return string.format("%04X", sum)
end

local function serverNow()
    if type(GetServerTime) == "function" then
        local ok, value = pcall(GetServerTime)
        if ok and type(value) == "number" then
            return value
        end
    end
    return 0
end

local function mono()
    if type(GetTime) == "function" then
        local ok, value = pcall(GetTime)
        if ok and type(value) == "number" then
            return value
        end
    end
    return serverNow()
end

local function stripRealm(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    local dash = name:find("-", 1, true)
    if dash then
        name = name:sub(1, dash - 1)
    end
    if name == "" then
        return nil
    end
    return name
end

-- In Forever, UnitName("player") gives only the first name, while guild chat,
-- addon messages and the guild roster use the full "First Surname". The full
-- name is taken from this client's own roster entry: the one whose GUID is the
-- player's, or else the only entry that starts with the first name and a space.
-- The GUID is compared and dropped; it is never saved.
local fullOwnName = nil

local function rosterOwnName(first)
    if type(GetNumGuildMembers) ~= "function" or type(GetGuildRosterInfo) ~= "function" then
        return nil
    end
    local countOk, count = pcall(GetNumGuildMembers)
    if not countOk or type(count) ~= "number" or count <= 0 then
        return nil
    end
    local guid = nil
    if type(UnitGUID) == "function" then
        local ok, value = pcall(UnitGUID, "player")
        if ok and type(value) == "string" and value ~= "" then
            guid = value
        end
    end
    local prefix = first .. " "
    local match = nil
    local matches = 0
    for index = 1, count do
        local info = { pcall(GetGuildRosterInfo, index) }
        local name = info[1] and stripRealm(info[2]) or nil
        if name then
            if guid and info[18] == guid then
                return name
            end
            if name == first or name:sub(1, #prefix) == prefix then
                match = name
                matches = matches + 1
            end
        end
    end
    if matches == 1 then
        return match
    end
    return nil
end

local function ownName()
    if fullOwnName then
        return fullOwnName
    end
    if type(UnitName) ~= "function" then
        return nil
    end
    local ok, name = pcall(UnitName, "player")
    if not ok then
        return nil
    end
    name = stripRealm(name)
    if not name then
        return nil
    end
    if name:find(" ", 1, true) then
        fullOwnName = name
        return name
    end
    local full = rosterOwnName(name)
    if full then
        fullOwnName = full
        return full
    end
    return name
end

function EldgrimSync.OwnName()
    return ownName()
end

local function isMaster()
    return ownName() == MASTER
end

local function inGuild()
    if type(IsInGuild) ~= "function" then
        return false
    end
    local ok, value = pcall(IsInGuild)
    return ok and not not value
end

local function locked()
    local api = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown
    if type(api) ~= "function" then
        return true
    end
    local ok, restricted = pcall(api)
    return not ok or restricted ~= false
end

local function db()
    if type(EldgrimQuests) ~= "table" then
        EldgrimQuests = {}
    end
    local saved = EldgrimQuests
    if type(saved.ember) ~= "table" then
        saved.ember = {}
    end
    if type(saved.ember.revision) ~= "number" then
        saved.ember.revision = 0
    end
    if type(saved.ember.history) ~= "table" then
        saved.ember.history = {}
    end
    if type(saved.ember.completions) ~= "table" then
        saved.ember.completions = {}
    end
    if type(saved.ember.verified) ~= "number" then
        saved.ember.verified = 0
    end
    if type(saved.quests) ~= "table" then
        saved.quests = {}
    end
    if type(saved.tombstones) ~= "table" then
        saved.tombstones = {}
    end
    if type(saved.held) ~= "table" then
        saved.held = {}
    end
    if type(saved.inbox) ~= "table" then
        saved.inbox = {}
    end
    if type(saved.gathering) ~= "table" then
        saved.gathering = {}
    end
    return saved
end

-- A member quest has no end date: it stays until its creator deletes it.
-- One saved before quests were confirmed by their creator is removed.
local function dropOldQuests()
    local quests = db().quests
    for id, quest in pairs(quests) do
        if type(quest) ~= "table" or quest.proof ~= PROOF then
            quests[id] = nil
        end
    end
end

local function refreshBoard()
    if type(EldgrimRefreshHearth) == "function" then
        EldgrimRefreshHearth()
    end
end

local function rosterEntry(name)
    name = stripRealm(name)
    if not name then
        return nil
    end
    if type(GetNumGuildMembers) == "function" and type(GetGuildRosterInfo) == "function" then
        local countOk, count = pcall(GetNumGuildMembers)
        if countOk and type(count) == "number" then
            for index = 1, count do
                local ok, memberName, _, rankIndex, _, _, _, _, _, isOnline = pcall(GetGuildRosterInfo, index)
                memberName = ok and stripRealm(memberName) or nil
                if memberName == name then
                    return {
                        rankIndex = rankIndex,
                        online = isOnline == true or isOnline == 1,
                        listed = true,
                    }
                end
            end
        end
    end
    local members = EldgrimRoster and EldgrimRoster.members
    local saved = type(members) == "table" and members[name] or nil
    if type(saved) == "table" then
        return {
            rankIndex = saved.rankIndex,
            online = saved.online == true or saved.online == 1,
            listed = true,
        }
    end
    return nil
end

local function onRoster(name)
    local entry = rosterEntry(name)
    return entry ~= nil and entry.listed == true
end

local function isOnline(name)
    local entry = rosterEntry(name)
    return entry ~= nil and entry.online == true
end

local function isOfficer(name)
    local entry = rosterEntry(name)
    return entry ~= nil and type(entry.rankIndex) == "number" and INVITE_RANKS[entry.rankIndex] == true
end

local function masterOfflineOnRoster()
    local entry = rosterEntry(MASTER)
    return entry ~= nil and entry.online ~= true
end

local function masterIsOnline()
    if isMaster() then
        return true
    end
    if masterOfflineOnRoster() then
        masterHeard = false
        return false
    end
    return masterHeard
end

function EldgrimSync.WeekEnd(starts)
    if type(starts) ~= "number" then
        return nil
    end
    local day = math.floor(starts / 86400)
    local weekday = (day + 4) % 7
    local ahead = (7 - weekday) % 7
    if ahead == 0 then
        ahead = 7
    end
    return (day + ahead) * 86400
end

local function copyEmber(card)
    if type(card) ~= "table" then
        return nil
    end
    if type(card.id) ~= "string" or card.id == "" then
        return nil
    end
    if type(card.starts) ~= "number" then
        return nil
    end
    if type(card.title) ~= "string" or type(card.story) ~= "string" then
        return nil
    end
    return {
        id = card.id,
        starts = card.starts,
        title = card.title,
        story = card.story,
        hint = type(card.hint) == "string" and card.hint or "",
    }
end

local function promote()
    local ember = db().ember
    local now = serverNow()
    local current = ember.current
    if type(current) ~= "table" or type(current.starts) ~= "number" then
        return false
    end
    local ending = EldgrimSync.WeekEnd(current.starts)
    if type(ending) ~= "number" or now < ending or type(ember.next) ~= "table" then
        return false
    end
    ember.history[#ember.history + 1] = current
    while #ember.history > HISTORY_LIMIT do
        table.remove(ember.history, 1)
    end
    ember.current = ember.next
    ember.next = nil
    return true
end

local function escape(text)
    text = tostring(text or "")
    return (text:gsub("\\", "\\\\"):gsub("|", "\\|"):gsub("#", "\\#"):gsub("%^", "\\^"):gsub(",", "\\,"))
end

local function unescape(text)
    local out = {}
    local index = 1
    while index <= #text do
        local char = text:sub(index, index)
        if char == "\\" and index < #text then
            out[#out + 1] = text:sub(index + 1, index + 1)
            index = index + 2
        else
            out[#out + 1] = char
            index = index + 1
        end
    end
    return table.concat(out)
end

local function splitSep(text, sep)
    local parts = {}
    local current = {}
    local index = 1
    while index <= #text do
        local char = text:sub(index, index)
        if char == "\\" and index < #text then
            current[#current + 1] = text:sub(index, index + 1)
            index = index + 2
        elseif char == sep then
            parts[#parts + 1] = table.concat(current)
            current = {}
            index = index + 1
        else
            current[#current + 1] = char
            index = index + 1
        end
    end
    parts[#parts + 1] = table.concat(current)
    return parts
end

local function encode(fields)
    local encoded = {}
    for index = 1, #fields do
        encoded[index] = escape(fields[index])
    end
    return table.concat(encoded, "|")
end

local function decode(text)
    local parts = splitSep(text, "|")
    for index = 1, #parts do
        parts[index] = unescape(parts[index])
    end
    return parts
end

local function pack(body)
    return VERSION .. "#" .. checksum(body) .. "#" .. body
end

local function enqueue(chatType, target, text)
    if type(text) ~= "string" or #text > MAX_BYTES or #text == 0 then
        return
    end
    queue[#queue + 1] = {
        chatType = chatType,
        target = target,
        text = text,
    }
end

local function transmit(chatType, target, kind, payload)
    payload = payload or ""
    local single = kind .. "|" .. payload
    if #pack(single) <= MAX_BYTES then
        enqueue(chatType, target, pack(single))
        return
    end
    local messageId = nextMessageId
    nextMessageId = nextMessageId + 1
    local function header(part, total)
        return "M" .. messageId .. "#" .. part .. "#" .. total .. "#" .. kind .. "|"
    end
    local function chunkSize(total)
        local room = MAX_BYTES - #pack(header(1, total))
        if room < 24 then
            room = 24
        end
        return room
    end
    local function split(room)
        local chunks = {}
        local index = 1
        while index <= #payload do
            chunks[#chunks + 1] = payload:sub(index, index + room - 1)
            index = index + room
        end
        if #chunks == 0 then
            chunks[1] = ""
        end
        return chunks
    end
    local chunks = split(chunkSize(99))
    chunks = split(chunkSize(#chunks))
    for part, chunk in ipairs(chunks) do
        enqueue(chatType, target, pack(header(part, #chunks) .. chunk))
    end
end

local function knownIds()
    local ids = {}
    local saved = db()
    for id in pairs(saved.quests) do
        if type(id) == "string" then
            ids[#ids + 1] = id
        end
    end
    for id in pairs(saved.tombstones) do
        if type(id) == "string" then
            ids[#ids + 1] = id
        end
    end
    table.sort(ids)
    return ids
end

local function helloPayload()
    dropOldQuests()
    local saved = db()
    local ids = knownIds()
    local since = ""
    if isMaster() then
        since = tostring(sessionStart or serverNow())
    end
    local joined = {}
    for index = 1, #ids do
        joined[index] = escape(ids[index])
    end
    return encode({
        saved.ember.revision,
        #ids,
        hash32(table.concat(ids, "#")),
        since,
    }) .. "|" .. table.concat(joined, ",")
end

local function sendHello()
    if not inGuild() or locked() then
        return
    end
    transmit("GUILD", nil, "HELLO", helloPayload())
end

local function sendEmber(chatType, target)
    if not isMaster() then
        return
    end
    local ember = db().ember
    local current = ember.current or {}
    local upcoming = ember.next or {}
    transmit(chatType or "GUILD", target, "EMBER", encode({
        ember.revision,
        current.id, current.starts, current.title, current.story, current.hint,
        upcoming.id, upcoming.starts, upcoming.title, upcoming.story, upcoming.hint,
    }))
end

local function sendVerified()
    if not isMaster() or locked() or not inGuild() then
        return
    end
    local ember = db().ember
    if ember.verified <= 0 then
        return
    end
    local fields = { ember.verified }
    local ids = {}
    for id in pairs(ember.completions) do
        ids[#ids + 1] = id
    end
    table.sort(ids)
    for _, id in ipairs(ids) do
        for _, entry in ipairs(ember.completions[id]) do
            fields[#fields + 1] = id
            fields[#fields + 1] = entry.name
        end
    end
    transmit("GUILD", nil, "DONE", encode(fields))
end

-- The daily run writes EldgrimVerified.lua on the master's machine: each
-- entry is a character whose Discord proof was witnessed, and the week it
-- counted for, given as the Sunday 00:00 UTC that week ends. A week names the
-- card whose week ends then.
local function applyVerifiedFile()
    if not isMaster() then
        return false
    end
    local file = EldgrimVerifiedFile
    local ember = db().ember
    if type(file) ~= "table" or type(file.revision) ~= "number" or file.revision <= ember.verified then
        return false
    end
    local cards = { ember.current, ember.next }
    for _, card in ipairs(ember.history) do
        cards[#cards + 1] = card
    end
    local byWeek = {}
    for _, card in ipairs(cards) do
        if type(card) == "table" and type(card.starts) == "number" then
            local ending = EldgrimSync.WeekEnd(card.starts)
            if ending then
                byWeek[ending] = card.id
            end
        end
    end
    local completions = {}
    local seen = {}
    for _, entry in ipairs(type(file.embers) == "table" and file.embers or {}) do
        local id = type(entry) == "table" and byWeek[tonumber(entry.week)] or nil
        local name = type(entry) == "table" and entry.name or nil
        if id and type(name) == "string" and name ~= "" and not seen[id .. "#" .. name] then
            seen[id .. "#" .. name] = true
            local list = completions[id] or {}
            list[#list + 1] = { name = name }
            completions[id] = list
        end
    end
    ember.completions = completions
    ember.verified = file.revision
    return true
end

local function sendAnswer(toName, theirRevision)
    if not isMaster() or locked() then
        return
    end
    local revision = db().ember.revision
    transmit("GUILD", nil, "ANSWER", encode({ sessionStart or serverNow(), revision }))
    if type(theirRevision) == "number" and revision > theirRevision then
        sendEmber("GUILD", nil)
    end
    sendVerified()
end

local function purgeHeld()
    local now = serverNow()
    local kept = {}
    for _, line in ipairs(db().held) do
        if type(line.received) == "number" and now - line.received < HOLD_LIMIT then
            kept[#kept + 1] = line
        end
    end
    db().held = kept
end

local function dropHeldAfter(since)
    if type(since) ~= "number" then
        return
    end
    local kept = {}
    for _, line in ipairs(db().held) do
        if type(line.received) ~= "number" or line.received <= since then
            kept[#kept + 1] = line
        end
    end
    db().held = kept
end

local function sendSummary()
    if isMaster() or locked() then
        return
    end
    purgeHeld()
    local lines = db().held
    if #lines == 0 then
        return
    end
    local oldest = lines[1].received
    local newest = lines[1].received
    for index = 1, #lines do
        local received = lines[index].received
        if received < oldest then
            oldest = received
        end
        if received > newest then
            newest = received
        end
    end
    transmit("WHISPER", MASTER, "SUM", encode({ #lines, oldest, newest }))
end

local function noteMaster(since)
    masterHeard = true
    if sendGathering then
        sendGathering()
    end
    if type(since) == "number" then
        dropHeldAfter(since)
        if summarySentFor ~= since then
            summarySentFor = since
            sendSummary()
        end
    end
end

local function storeDirect(speaker, text, received)
    if type(EldgrimDB) ~= "table" then
        EldgrimDB = {}
    end
    local character = EldgrimDB[speaker]
    if type(character) ~= "table" then
        character = {}
        EldgrimDB[speaker] = character
    end
    if type(character.messages) ~= "table" then
        character.messages = {}
    end
    character.messages[#character.messages + 1] = {
        timestamp = received,
        message = text,
    }
end

local function commitLocalHeld()
    if not isMaster() then
        return
    end
    purgeHeld()
    for _, line in ipairs(db().held) do
        if type(line.speaker) == "string" and type(line.text) == "string" and type(line.received) == "number" then
            storeDirect(line.speaker, line.text, line.received)
        end
    end
    db().held = {}
end

local function findRelay(speaker, text, received)
    local character = type(EldgrimDB) == "table" and EldgrimDB[speaker] or nil
    if type(character) ~= "table" or type(character.messages) ~= "table" then
        return nil
    end
    for _, row in ipairs(character.messages) do
        if row.message == text and type(row.timestamp) == "number" and math.abs(row.timestamp - received) <= MATCH_WINDOW then
            return row
        end
    end
    return nil
end

local function storeRelay(speaker, text, received, passer)
    if type(EldgrimDB) ~= "table" then
        EldgrimDB = {}
    end
    local existing = findRelay(speaker, text, received)
    if existing then
        if existing.passedBy and existing.passedBy ~= passer then
            existing.passedBy = nil
        end
        return
    end
    local character = EldgrimDB[speaker]
    if type(character) ~= "table" then
        character = {}
        EldgrimDB[speaker] = character
    end
    if type(character.messages) ~= "table" then
        character.messages = {}
    end
    character.messages[#character.messages + 1] = {
        timestamp = received,
        message = text,
        passedBy = passer,
    }
end

local function publishFile()
    if not isMaster() then
        return
    end
    local file = EldgrimEmberFile
    if type(file) ~= "table" or type(file.revision) ~= "number" then
        return
    end
    local ember = db().ember
    if file.revision <= ember.revision then
        return
    end
    local current = nil
    local upcoming = nil
    if file.current ~= nil then
        current = copyEmber(file.current)
        if not current then
            return
        end
    end
    if file.next ~= nil then
        upcoming = copyEmber(file.next)
        if not upcoming then
            return
        end
    end
    ember.revision = file.revision
    ember.current = current
    ember.next = upcoming
    sendEmber("GUILD", nil)
end

local function applyEmber(sender, payload)
    if sender ~= MASTER then
        return
    end
    local fields = decode(payload)
    local revision = tonumber(fields[1])
    if not revision then
        return
    end
    local ember = db().ember
    if revision <= ember.revision then
        return
    end
    local function cardAt(offset)
        if fields[offset] == nil or fields[offset] == "" then
            return nil
        end
        return copyEmber({
            id = fields[offset],
            starts = tonumber(fields[offset + 1]),
            title = fields[offset + 2],
            story = fields[offset + 3],
            hint = fields[offset + 4] or "",
        })
    end
    local current = cardAt(2)
    local upcoming = cardAt(7)
    if fields[2] ~= nil and fields[2] ~= "" and not current then
        return
    end
    if fields[7] ~= nil and fields[7] ~= "" and not upcoming then
        return
    end
    ember.revision = revision
    ember.current = current
    ember.next = upcoming
    refreshBoard()
end

local function tombstoned(id)
    return db().tombstones[id] ~= nil
end

local function questConfirmed(quest)
    return type(quest) == "table" and quest.confirmed == true
end

local function applyQuest(sender, fields)
    local creator = fields[2]
    local id = fields[3]
    local title = fields[4]
    local story = fields[5]
    local objective = fields[6]
    local proof = fields[7]
    local created = tonumber(fields[9])
    if type(id) ~= "string" or id == "" or type(creator) ~= "string" or creator == "" then
        return
    end
    if tombstoned(id) then
        return
    end
    if proof ~= PROOF or not created then
        return
    end
    local confirmed = sender == creator
    local existing = db().quests[id]
    if type(existing) == "table" and existing.confirmed and not confirmed then
        return
    end
    if type(existing) == "table" and existing.confirmed and confirmed then
        return
    end
    db().quests[id] = {
        id = id,
        creator = creator,
        title = type(title) == "string" and title or "",
        story = type(story) == "string" and story or "",
        objective = type(objective) == "string" and objective or "",
        proof = proof,
        created = created,
        confirmed = confirmed,
        accepts = type(existing) == "table" and existing.accepts or {},
        claims = type(existing) == "table" and existing.claims or {},
        completions = type(existing) == "table" and existing.completions or {},
    }
end

local function applyAccept(sender, fields)
    local id = fields[2]
    local claimant = fields[3]
    local at = tonumber(fields[4])
    local quest = db().quests[id]
    if type(quest) ~= "table" or type(claimant) ~= "string" or not at then
        return
    end
    if claimant == quest.creator then
        return
    end
    quest.accepts = quest.accepts or {}
    local existing = quest.accepts[claimant]
    local confirmed = sender == claimant
    if type(existing) == "table" and existing.confirmed then
        return
    end
    if not confirmed and type(existing) == "table" then
        return
    end
    quest.accepts[claimant] = {
        at = at,
        confirmed = confirmed,
    }
end

-- C: the one who took the quest says it is done. It counts when they sent it.
local function applyClaim(sender, fields)
    local id = fields[2]
    local claimant = fields[3]
    local at = tonumber(fields[4])
    local quest = db().quests[id]
    if type(quest) ~= "table" or type(claimant) ~= "string" or not at then
        return
    end
    if claimant == quest.creator then
        return
    end
    quest.claims = quest.claims or {}
    local existing = quest.claims[claimant]
    if type(existing) == "table" and existing.confirmed then
        return
    end
    local confirmed = sender == claimant
    if not confirmed and type(existing) == "table" then
        return
    end
    quest.claims[claimant] = { at = at, confirmed = confirmed }
end

-- F: the creator confirms it. It counts when the creator sent it.
local function applyFinish(sender, fields)
    local id = fields[2]
    local claimant = fields[3]
    local at = tonumber(fields[4])
    local quest = db().quests[id]
    if type(quest) ~= "table" or type(claimant) ~= "string" or not at then
        return
    end
    if claimant == quest.creator then
        return
    end
    quest.completions = quest.completions or {}
    local existing = quest.completions[claimant]
    if type(existing) == "table" and existing.confirmed then
        return
    end
    local confirmed = quest.confirmed == true and sender == quest.creator
    if not confirmed and type(existing) == "table" then
        return
    end
    quest.completions[claimant] = { at = at, confirmed = confirmed }
end

local function applyDelete(sender, fields)
    local id = fields[2]
    local at = tonumber(fields[3]) or serverNow()
    local quest = db().quests[id]
    local creator = type(quest) == "table" and quest.creator or nil
    local allowed = (creator and sender == creator) or isOfficer(sender)
    if not allowed then
        return
    end
    db().quests[id] = nil
    db().tombstones[id] = {
        by = sender,
        at = at,
    }
end

local function applyRecord(sender, record)
    local fields = decode(record)
    local kind = fields[1]
    if kind == "Q" then
        applyQuest(sender, fields)
    elseif kind == "A" then
        applyAccept(sender, fields)
    elseif kind == "C" then
        applyClaim(sender, fields)
    elseif kind == "F" then
        applyFinish(sender, fields)
    elseif kind == "D" then
        applyDelete(sender, fields)
    end
end

local function applyRecords(sender, payload)
    if payload == "" then
        return
    end
    for _, record in ipairs(splitSep(payload, "^")) do
        if record ~= "" then
            applyRecord(sender, record)
        end
    end
    refreshBoard()
end

local function flushInbox()
    local inbox = db().inbox
    if #inbox == 0 then
        return
    end
    local pending = inbox
    db().inbox = {}
    for _, item in ipairs(pending) do
        applyRecord(item.sender, item.record)
    end
end

local function recordsExcept(skip)
    dropOldQuests()
    local chunks = {}
    local saved = db()
    for id, quest in pairs(saved.quests) do
        if quest.confirmed and not skip[id] then
            chunks[#chunks + 1] = encode({
                "Q", quest.creator, id, quest.title, quest.story, quest.objective,
                quest.proof, 0, quest.created,
            })
            for name, accept in pairs(quest.accepts or {}) do
                if accept.confirmed then
                    chunks[#chunks + 1] = encode({ "A", id, name, accept.at })
                end
            end
            for name, claim in pairs(quest.claims or {}) do
                if claim.confirmed then
                    chunks[#chunks + 1] = encode({ "C", id, name, claim.at })
                end
            end
            for name, done in pairs(quest.completions or {}) do
                if done.confirmed then
                    chunks[#chunks + 1] = encode({ "F", id, name, done.at })
                end
            end
        end
    end
    for id, stone in pairs(saved.tombstones) do
        if not skip[id] then
            chunks[#chunks + 1] = encode({ "D", id, stone.at })
        end
    end
    return table.concat(chunks, "^")
end

local function parseHello(payload)
    local head, idList = payload:match("^([^|]*%|[^|]*%|[^|]*%|[^|]*)|(.*)$")
    if not head then
        head = payload
        idList = ""
    end
    local fields = decode(head)
    local ids = {}
    if idList ~= "" then
        for _, escaped in ipairs(splitSep(idList, ",")) do
            local id = unescape(escaped)
            if id ~= "" then
                ids[id] = true
            end
        end
    end
    return {
        revision = tonumber(fields[1]) or 0,
        count = tonumber(fields[2]) or 0,
        hash = fields[3] or "",
        since = tonumber(fields[4]),
        ids = ids,
    }
end

local function scheduleReply(asker, hello)
    if isMaster() or masterIsOnline() or asker == ownName() then
        return
    end
    local wait = math.random(5, 20)
    pendingReply = {
        asker = asker,
        hello = hello,
        fireAt = mono() + wait,
    }
end

local function fireReply()
    local pending = pendingReply
    pendingReply = nil
    if not pending or isMaster() or masterIsOnline() or locked() then
        return
    end
    local ids = knownIds()
    if pending.hello.hash == hash32(table.concat(ids, "#")) and pending.hello.count == #ids then
        return
    end
    local payload = recordsExcept(pending.hello.ids)
    if payload == "" then
        return
    end
    transmit("GUILD", nil, "RECS", payload)
end

local function onHello(sender, payload)
    local hello = parseHello(payload)
    if sender == MASTER then
        noteMaster(hello.since)
        return
    end
    if sender == ownName() then
        return
    end
    if isMaster() then
        sendAnswer(sender, hello.revision)
        return
    end
    if masterIsOnline() then
        return
    end
    scheduleReply(sender, hello)
end

local function onAnswer(sender, payload)
    if sender ~= MASTER then
        return
    end
    local fields = decode(payload)
    noteMaster(tonumber(fields[1]))
end

-- Ember completions come only from the master, as one list: the verified
-- revision, then pairs of ember id and character name. A newer list replaces
-- the older one.
local function onEmberDone(sender, payload)
    if sender ~= MASTER or isMaster() then
        return
    end
    local fields = decode(payload)
    local revision = tonumber(fields[1])
    local ember = db().ember
    if not revision or revision <= ember.verified then
        return
    end
    local completions = {}
    local index = 2
    while fields[index] ~= nil and fields[index + 1] ~= nil do
        local id, name = fields[index], fields[index + 1]
        if id ~= "" and name ~= "" then
            local list = completions[id] or {}
            list[#list + 1] = { name = name }
            completions[id] = list
        end
        index = index + 2
    end
    ember.completions = completions
    ember.verified = revision
    refreshBoard()
end

local function askNext()
    if not isMaster() or awaiting then
        return
    end
    local bestName = nil
    local bestOldest = nil
    for name, summary in pairs(summaries) do
        if summary.count > 0 and isOnline(name) then
            if not bestOldest or summary.oldest < bestOldest then
                bestName = name
                bestOldest = summary.oldest
            end
        end
    end
    if not bestName then
        return
    end
    awaiting = bestName
    transmit("WHISPER", bestName, "ASK", "")
end

local function onSummary(sender, payload)
    if not isMaster() or not onRoster(sender) then
        return
    end
    local fields = decode(payload)
    local count = tonumber(fields[1])
    local oldest = tonumber(fields[2])
    local newest = tonumber(fields[3])
    if not count or not oldest or not newest then
        return
    end
    summaries[sender] = {
        count = count,
        oldest = oldest,
        newest = newest,
    }
    if not awaiting and not decideAt then
        decideAt = mono() + 2
    end
end

local function onAsk(sender)
    if sender ~= MASTER or isMaster() or locked() then
        return
    end
    purgeHeld()
    local lines = db().held
    if #lines == 0 then
        transmit("WHISPER", MASTER, "BATCH", encode({ "empty" }))
        return
    end
    local batchId = "b" .. tostring(serverNow()) .. "x" .. tostring(nextBatchId)
    nextBatchId = nextBatchId + 1
    local chunks = {}
    local ids = {}
    for index = 1, #lines do
        local line = lines[index]
        ids[#ids + 1] = line.id
        chunks[#chunks + 1] = encode({ line.speaker, line.text, line.received })
    end
    db().pendingBatch = {
        id = batchId,
        ids = ids,
    }
    transmit("WHISPER", MASTER, "BATCH", encode({ batchId }) .. "|" .. table.concat(chunks, "^"))
end

local function onBatch(sender, payload)
    if not isMaster() or not onRoster(sender) then
        return
    end
    local batchId, rest = payload:match("^([^|]*)|(.*)$")
    if not batchId then
        return
    end
    batchId = unescape(batchId)
    if rest and rest ~= "" then
        for _, chunk in ipairs(splitSep(rest, "^")) do
            local fields = decode(chunk)
            local speaker = fields[1]
            local text = fields[2]
            local received = tonumber(fields[3])
            if onRoster(speaker) and type(text) == "string" and text ~= "" and received then
                storeRelay(speaker, text, received, sender)
            end
        end
    end
    summaries[sender] = nil
    if awaiting == sender then
        awaiting = nil
    end
    transmit("WHISPER", sender, "ACK", encode({ batchId }))
    askNext()
end

local function onAck(sender, payload)
    if sender ~= MASTER then
        return
    end
    local fields = decode(payload)
    local batchId = fields[1]
    local pending = db().pendingBatch
    if type(pending) ~= "table" or pending.id ~= batchId or type(pending.ids) ~= "table" then
        return
    end
    local drop = {}
    for index = 1, #pending.ids do
        drop[pending.ids[index]] = true
    end
    local kept = {}
    for _, line in ipairs(db().held) do
        if not drop[line.id] then
            kept[#kept + 1] = line
        end
    end
    db().held = kept
    db().pendingBatch = nil
end

-- The Sunday gathering (founder decision, 22 November 2026). Every addon
-- records, on Sunday from 19:00 to 20:00 Swedish time, the guild members who
-- speak in /say near this character and the guild members in this
-- character's group or raid. Nothing is recorded outside that hour, and a
-- speaker or group member who is not on the guild roster is skipped.
-- The master keeps the record in EldgrimGathering. Everyone else holds it and
-- whispers it to her when she is next heard, and she acknowledges each batch.

local GATHERING_HOUR = 19
local GATHERING_HOLD = 14 * 24 * 60 * 60
local GATHERING_BATCH_LINES = 25
local GATHERING_BATCH_BYTES = 6000

local function daysFromCivil(year, month, day)
    if month <= 2 then
        year = year - 1
    end
    local era = math.floor(year / 400)
    local yoe = year - era * 400
    local mp = (month + 9) % 12
    local doy = math.floor((153 * mp + 2) / 5) + day - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
    return era * 146097 + doe - 719468
end

local function civilFromDays(days)
    days = days + 719468
    local era = math.floor(days / 146097)
    local doe = days - era * 146097
    local yoe = math.floor((doe - math.floor(doe / 1460) + math.floor(doe / 36524) - math.floor(doe / 146096)) / 365)
    local year = yoe + era * 400
    local doy = doe - (365 * yoe + math.floor(yoe / 4) - math.floor(yoe / 100))
    local mp = math.floor((5 * doy + 2) / 153)
    local day = doy - math.floor((153 * mp + 2) / 5) + 1
    local month = mp < 10 and mp + 3 or mp - 9
    if month <= 2 then
        year = year + 1
    end
    return year, month, day
end

-- The last Sunday of a month, at 01:00 UTC, when Swedish summer time starts or ends.
local function lastSundayChange(year, month)
    local nextYear, nextMonth = year, month + 1
    if nextMonth > 12 then
        nextYear, nextMonth = year + 1, 1
    end
    local last = daysFromCivil(nextYear, nextMonth, 1) - 1
    local sunday = last - (last + 4) % 7
    return sunday * 86400 + 3600
end

-- Seconds Swedish time is ahead of UTC at this moment: 7200 in summer time, else 3600.
function EldgrimSync.StockholmOffset(utc)
    local year = civilFromDays(math.floor(utc / 86400))
    if utc >= lastSundayChange(year, 3) and utc < lastSundayChange(year, 10) then
        return 7200
    end
    return 3600
end

-- The gathering's date ("2026-11-29") while Sunday 19:00-20:00 Swedish time lasts, else nil.
function EldgrimSync.GatheringDay(utc)
    if type(utc) ~= "number" or utc <= 0 then
        return nil
    end
    local localTime = utc + EldgrimSync.StockholmOffset(utc)
    local days = math.floor(localTime / 86400)
    if (days + 4) % 7 ~= 0 then
        return nil
    end
    local hour = math.floor((localTime - days * 86400) / 3600)
    if hour ~= GATHERING_HOUR then
        return nil
    end
    local year, month, day = civilFromDays(days)
    return string.format("%04d-%02d-%02d", year, month, day)
end

local function gatheringStore()
    if type(EldgrimGathering) ~= "table" then
        EldgrimGathering = {}
    end
    return EldgrimGathering
end

-- Keep one line per speaker and text within MATCH_WINDOW seconds, and one group
-- mark per member and gathering. A mark seen by the master herself, or passed
-- on by two different members, loses its passedBy.
local function storeGathering(day, speaker, kind, text, received, passer)
    local store = gatheringStore()
    local list = store[day]
    if type(list) ~= "table" then
        list = {}
        store[day] = list
    end
    for _, row in ipairs(list) do
        local same = row.speaker == speaker and row.kind == kind
        if same and kind == "say" then
            same = row.text == text and type(row.received) == "number" and math.abs(row.received - received) <= MATCH_WINDOW
        end
        if same then
            if row.passedBy and row.passedBy ~= passer then
                row.passedBy = nil
            end
            return
        end
    end
    local row = {
        speaker = speaker,
        kind = kind,
        received = received,
    }
    if kind == "say" then
        row.text = text
    end
    row.passedBy = passer
    list[#list + 1] = row
end

local function purgeGatheringHeld()
    local now = serverNow()
    local kept = {}
    for _, line in ipairs(db().gathering) do
        if type(line.received) == "number" and now - line.received < GATHERING_HOLD then
            kept[#kept + 1] = line
        end
    end
    db().gathering = kept
end

local function recordGathering(speaker, kind, text)
    local now = serverNow()
    local day = EldgrimSync.GatheringDay(now)
    if not day or not speaker or not onRoster(speaker) then
        return
    end
    if kind == "say" and (type(text) ~= "string" or text == "") then
        return
    end
    if isMaster() then
        storeGathering(day, speaker, kind, text, now, nil)
        return
    end
    local held = db().gathering
    for _, line in ipairs(held) do
        if line.day == day and line.speaker == speaker and line.kind == kind then
            if kind == "group" or (line.text == text and line.received == now) then
                return
            end
        end
    end
    held[#held + 1] = {
        id = "g" .. tostring(now) .. "x" .. tostring(nextGatheringId),
        day = day,
        speaker = speaker,
        kind = kind,
        text = kind == "say" and text or nil,
        received = now,
    }
    nextGatheringId = nextGatheringId + 1
end

-- A group member's full name. Forever may give only the first name for a unit,
-- so a short name is matched to the only roster name that starts with it.
local function rosterNameFor(name)
    name = stripRealm(name)
    if not name then
        return nil
    end
    if name:find(" ", 1, true) then
        return name
    end
    if type(GetNumGuildMembers) ~= "function" or type(GetGuildRosterInfo) ~= "function" then
        return nil
    end
    local countOk, count = pcall(GetNumGuildMembers)
    if not countOk or type(count) ~= "number" then
        return nil
    end
    local prefix = name .. " "
    local match = nil
    local matches = 0
    for index = 1, count do
        local ok, memberName = pcall(GetGuildRosterInfo, index)
        memberName = ok and stripRealm(memberName) or nil
        if memberName and memberName:sub(1, #prefix) == prefix then
            match = memberName
            matches = matches + 1
        end
    end
    if matches == 1 then
        return match
    end
    return nil
end

local function noteGroup()
    if locked() or not EldgrimSync.GatheringDay(serverNow()) then
        return
    end
    if type(GetNumGroupMembers) ~= "function" or type(UnitName) ~= "function" then
        return
    end
    local ok, count = pcall(GetNumGroupMembers)
    if not ok or type(count) ~= "number" or count < 1 then
        return
    end
    local raid = type(IsInRaid) == "function" and IsInRaid() and true or false
    local units = {}
    if raid then
        for index = 1, count do
            units[#units + 1] = "raid" .. index
        end
    else
        units[1] = "player"
        for index = 1, count - 1 do
            units[#units + 1] = "party" .. index
        end
    end
    for _, unit in ipairs(units) do
        local nameOk, name = pcall(UnitName, unit)
        if nameOk and type(name) == "string" then
            local full = unit == "player" and ownName() or rosterNameFor(name)
            if full then
                recordGathering(full, "group", nil)
            end
        end
    end
end

function EldgrimSync.HeardSay(message, sender)
    if locked() or not EldgrimSync.GatheringDay(serverNow()) then
        return
    end
    sender = stripRealm(sender)
    if sender == nil then
        return
    end
    if not sender:find(" ", 1, true) then
        sender = rosterNameFor(sender)
    end
    recordGathering(sender, "say", message)
end

function EldgrimSync.GroupChanged()
    if locked() then
        return
    end
    noteGroup()
end

sendGathering = function()
    if isMaster() or locked() or not masterIsOnline() then
        return
    end
    local saved = db()
    if type(saved.pendingGathering) == "table" then
        return
    end
    purgeGatheringHeld()
    local held = saved.gathering
    if #held == 0 then
        return
    end
    local batchId = "g" .. tostring(serverNow()) .. "x" .. tostring(nextBatchId)
    nextBatchId = nextBatchId + 1
    local chunks = {}
    local ids = {}
    local size = 0
    for index = 1, #held do
        local line = held[index]
        local chunk = encode({ line.day, line.speaker, line.kind, line.text or "", line.received })
        if #ids > 0 and (#ids >= GATHERING_BATCH_LINES or size + #chunk > GATHERING_BATCH_BYTES) then
            break
        end
        chunks[#chunks + 1] = chunk
        ids[#ids + 1] = line.id
        size = size + #chunk + 1
    end
    saved.pendingGathering = {
        id = batchId,
        ids = ids,
        sentAt = mono(),
    }
    transmit("WHISPER", MASTER, "GATH", encode({ batchId }) .. "|" .. table.concat(chunks, "^"))
end

local function onGathering(sender, payload)
    if not isMaster() or not onRoster(sender) then
        return
    end
    local batchId, rest = payload:match("^([^|]*)|(.*)$")
    if not batchId then
        return
    end
    batchId = unescape(batchId)
    if rest and rest ~= "" then
        for _, chunk in ipairs(splitSep(rest, "^")) do
            local fields = decode(chunk)
            local day, speaker, kind, text = fields[1], fields[2], fields[3], fields[4]
            local received = tonumber(fields[5])
            -- A mark counts only for the hour it names, and only for someone on the roster.
            if received and day and EldgrimSync.GatheringDay(received) == day
                and (kind == "say" or kind == "group") and onRoster(speaker)
                and (kind == "group" or (type(text) == "string" and text ~= "")) then
                storeGathering(day, speaker, kind, text, received, sender)
            end
        end
    end
    transmit("WHISPER", sender, "GACK", encode({ batchId }))
end

local function onGatheringAck(sender, payload)
    if sender ~= MASTER then
        return
    end
    local batchId = decode(payload)[1]
    local saved = db()
    local pending = saved.pendingGathering
    if type(pending) ~= "table" or pending.id ~= batchId or type(pending.ids) ~= "table" then
        return
    end
    local drop = {}
    for index = 1, #pending.ids do
        drop[pending.ids[index]] = true
    end
    local kept = {}
    for _, line in ipairs(saved.gathering) do
        if not drop[line.id] then
            kept[#kept + 1] = line
        end
    end
    saved.gathering = kept
    saved.pendingGathering = nil
    sendGathering()
end

-- Once a second: note the group when the hour opens, send what is held when it
-- closes, and give up on a batch that was never acknowledged.
local function gatheringTick()
    local now = mono()
    if now < gatheringCheckAt then
        return
    end
    gatheringCheckAt = now + 1
    local day = EldgrimSync.GatheringDay(serverNow())
    if day and day ~= gatheringOpen then
        gatheringOpen = day
        noteGroup()
    elseif not day and gatheringOpen then
        gatheringOpen = nil
        sendGathering()
    end
    local pending = db().pendingGathering
    if type(pending) == "table" and (type(pending.sentAt) ~= "number" or now - pending.sentAt > 120 or now < pending.sentAt) then
        db().pendingGathering = nil
    end
end

local function dispatch(channel, sender, kind, payload)
    if kind == "HELLO" and channel == "GUILD" then
        onHello(sender, payload)
    elseif kind == "ANSWER" and channel == "GUILD" then
        onAnswer(sender, payload)
    elseif kind == "EMBER" and channel == "GUILD" then
        applyEmber(sender, payload)
    elseif kind == "RECS" and channel == "GUILD" then
        if sender ~= ownName() and sender ~= MASTER and pendingReply then
            pendingReply = nil
        end
        applyRecords(sender, payload)
    elseif kind == "DONE" and channel == "GUILD" then
        onEmberDone(sender, payload)
    elseif kind == "SUM" and channel == "WHISPER" then
        onSummary(sender, payload)
    elseif kind == "ASK" and channel == "WHISPER" then
        onAsk(sender)
    elseif kind == "BATCH" and channel == "WHISPER" then
        onBatch(sender, payload)
    elseif kind == "ACK" and channel == "WHISPER" then
        onAck(sender, payload)
    elseif kind == "GATH" and channel == "WHISPER" then
        onGathering(sender, payload)
    elseif kind == "GACK" and channel == "WHISPER" then
        onGatheringAck(sender, payload)
    end
end

local function collect(channel, sender, messageId, part, total, kind, chunk)
    if part < 1 or total < 1 or part > total or total > 40 then
        return
    end
    local key = sender .. "#" .. tostring(messageId)
    local bag = partials[key]
    if not bag then
        bag = {
            total = total,
            kind = kind,
            channel = channel,
            parts = {},
            started = mono(),
        }
        partials[key] = bag
    end
    if bag.total ~= total or bag.kind ~= kind then
        partials[key] = nil
        return
    end
    bag.parts[part] = chunk
    for index = 1, total do
        if bag.parts[index] == nil then
            return
        end
    end
    partials[key] = nil
    local joined = {}
    for index = 1, total do
        joined[index] = bag.parts[index]
    end
    dispatch(channel, sender, kind, table.concat(joined))
end

function EldgrimSync.Handle(channel, sender, text)
    if locked() or type(text) ~= "string" or type(channel) ~= "string" then
        return
    end
    sender = stripRealm(sender)
    if not sender or (channel ~= "GUILD" and channel ~= "WHISPER") then
        return
    end
    local version, sum, body = text:match("^(%d)#(%x%x%x%x)#(.*)$")
    if version ~= VERSION or not body or checksum(body):lower() ~= sum:lower() then
        return
    end
    local messageId, part, total, kind, chunk = body:match("^M(%d+)#(%d+)#(%d+)#([^|]+)|(.*)$")
    if messageId then
        collect(channel, sender, messageId, tonumber(part), tonumber(total), kind, chunk)
        return
    end
    kind, chunk = body:match("^([^|]+)|(.*)$")
    if kind then
        dispatch(channel, sender, kind, chunk)
    end
end

local function expirePartials()
    local now = mono()
    for key, bag in pairs(partials) do
        if now - bag.started > PART_TIMEOUT then
            partials[key] = nil
        end
    end
end

function EldgrimSync.Pump()
    expirePartials()
    gatheringTick()
    if promote() then
        refreshBoard()
    end
    if pendingReply and mono() >= pendingReply.fireAt then
        fireReply()
    end
    if decideAt and not awaiting and mono() >= decideAt then
        decideAt = nil
        askNext()
    end
    local now = mono()
    while #queue > 0 and (lastSendAt < 0 or now - lastSendAt >= SEND_GAP) do
        local item = table.remove(queue, 1)
        if lastSendAt < 0 then
            lastSendAt = now
        else
            lastSendAt = lastSendAt + SEND_GAP
        end
        EldgrimSync.Sent[#EldgrimSync.Sent + 1] = item
        local api = C_ChatInfo and C_ChatInfo.SendAddonMessage
        if type(api) == "function" and not locked() then
            pcall(api, PREFIX, item.text, item.chatType, item.target)
        end
    end
end

function EldgrimHoldGuildLine(message, sender)
    if type(message) ~= "string" or message == "" then
        return false
    end
    sender = stripRealm(sender)
    if not sender then
        return false
    end
    if isMaster() then
        return false
    end
    if masterIsOnline() then
        return true
    end
    purgeHeld()
    local lines = db().held
    local now = serverNow()
    local previous = lines[#lines]
    if previous and previous.speaker == sender and previous.text == message and previous.received == now then
        return true
    end
    lines[#lines + 1] = {
        id = nextHoldId,
        speaker = sender,
        text = message,
        received = now,
    }
    nextHoldId = nextHoldId + 1
    return true
end

local function broadcastRecord(record)
    if locked() or not inGuild() then
        return
    end
    transmit("GUILD", nil, "RECS", record)
end

local function openCount(creator)
    local count = 0
    for _, quest in pairs(db().quests) do
        if quest.creator == creator and not tombstoned(quest.id) then
            count = count + 1
        end
    end
    return count
end

function EldgrimSync.CreateQuest(title, story, objective)
    local creator = ownName()
    local now = serverNow()
    if not creator then
        return nil, "The character name is missing."
    end
    if type(title) ~= "string" or title == "" or #title > TITLE_MAX then
        return nil, "The title needs 1 to 60 characters."
    end
    if type(story) ~= "string" or #story > STORY_MAX then
        return nil, "The story can be at most 400 characters."
    end
    if type(objective) ~= "string" or objective == "" or #objective > OBJECTIVE_MAX then
        return nil, "The objective needs 1 to 200 characters."
    end
    if openCount(creator) >= OPEN_LIMIT then
        return nil, "Three open quests is the limit."
    end
    local id = creator .. "#" .. tostring(now)
    local suffix = 2
    while db().quests[id] or db().tombstones[id] do
        id = creator .. "#" .. tostring(now) .. "." .. tostring(suffix)
        suffix = suffix + 1
    end
    db().quests[id] = {
        id = id,
        creator = creator,
        title = title,
        story = story,
        objective = objective,
        proof = PROOF,
        created = now,
        confirmed = true,
        accepts = {},
        claims = {},
        completions = {},
    }
    broadcastRecord(encode({
        "Q", creator, id, title, story, objective, PROOF, 0, now,
    }))
    refreshBoard()
    return id
end

function EldgrimSync.AcceptQuest(id)
    local name = ownName()
    local quest = db().quests[id]
    local now = serverNow()
    if not name or type(quest) ~= "table" then
        return nil, "That quest is not here."
    end
    if name == quest.creator then
        return nil, "The creator cannot accept it."
    end
    local existing = quest.accepts and quest.accepts[name]
    if type(existing) == "table" and existing.confirmed then
        return nil, "Already accepted."
    end
    quest.accepts = quest.accepts or {}
    quest.accepts[name] = { at = now, confirmed = true }
    broadcastRecord(encode({ "A", id, name, now }))
    refreshBoard()
    return true
end

-- The one who took the quest marks it complete. It is completed once the
-- creator confirms.
function EldgrimSync.CompleteQuest(id)
    local name = ownName()
    local quest = db().quests[id]
    local now = serverNow()
    if not name or type(quest) ~= "table" then
        return nil, "That quest is not here."
    end
    local accept = quest.accepts and quest.accepts[name]
    if type(accept) ~= "table" or not accept.confirmed then
        return nil, "Accept it first."
    end
    local claim = quest.claims and quest.claims[name]
    if type(claim) == "table" and claim.confirmed then
        return nil, "Already marked complete."
    end
    quest.claims = quest.claims or {}
    quest.claims[name] = { at = now, confirmed = true }
    broadcastRecord(encode({ "C", id, name, now }))
    refreshBoard()
    return true
end

-- The creator confirms that someone who marked it complete has completed it.
function EldgrimSync.ConfirmQuest(id, claimant)
    local name = ownName()
    local quest = db().quests[id]
    local now = serverNow()
    if not name or type(quest) ~= "table" or type(claimant) ~= "string" then
        return nil, "That quest is not here."
    end
    if name ~= quest.creator then
        return nil, "Only the creator confirms it."
    end
    local claim = quest.claims and quest.claims[claimant]
    if type(claim) ~= "table" or not claim.confirmed then
        return nil, "They have not marked it complete."
    end
    local done = quest.completions and quest.completions[claimant]
    if type(done) == "table" and done.confirmed then
        return nil, "Already completed."
    end
    quest.completions = quest.completions or {}
    quest.completions[claimant] = { at = now, confirmed = true }
    broadcastRecord(encode({ "F", id, claimant, now }))
    refreshBoard()
    return true
end

function EldgrimSync.DeleteQuest(id)
    local name = ownName()
    local quest = db().quests[id]
    local now = serverNow()
    if not name or type(quest) ~= "table" then
        return nil, "That quest is not here."
    end
    if name ~= quest.creator and not isOfficer(name) then
        return nil, "Only the creator or an invite rank can delete it."
    end
    db().quests[id] = nil
    db().tombstones[id] = { by = name, at = now }
    broadcastRecord(encode({ "D", id, now }))
    refreshBoard()
    return true
end

local function sortedCompletions(id)
    local list = db().ember.completions[id]
    local copy = {}
    if type(list) == "table" then
        for index = 1, #list do
            copy[#copy + 1] = {
                name = list[index].name,
                at = list[index].at,
            }
        end
    end
    return copy
end

function EldgrimSync.BoardData()
    promote()
    local now = serverNow()
    local ember = db().ember
    local card = ember.current
    local shown = nil
    if type(card) == "table" then
        local ending = EldgrimSync.WeekEnd(card.starts)
        local ended = type(ending) == "number" and now >= ending and type(ember.next) ~= "table"
        shown = {
            id = card.id,
            title = card.title,
            story = card.story,
            hint = card.hint or "",
            ended = ended,
            note = ended and "The next ember has not arrived." or nil,
            completedBy = sortedCompletions(card.id),
        }
    else
        shown = {
            note = "The next ember has not arrived.",
            completedBy = {},
        }
    end
    dropOldQuests()
    -- A quest leaves this character's list once it is completed for them. It
    -- stays for everyone else, and for its creator until they delete it.
    local me = ownName()
    local open = {}
    for _, quest in pairs(db().quests) do
        local mine = quest.completions and me and quest.completions[me]
        if not (type(mine) == "table" and mine.confirmed) then
            open[#open + 1] = {
                id = quest.id,
                title = quest.title,
                creator = quest.creator,
                confirmed = quest.confirmed == true,
            }
        end
    end
    table.sort(open, function(a, b) return a.id < b.id end)
    return {
        ember = shown,
        open = open,
    }
end

function EldgrimSync.QuestDetail(id)
    local quest = db().quests[id]
    if type(quest) ~= "table" then
        return nil
    end
    local accepts = {}
    for name, accept in pairs(quest.accepts or {}) do
        if accept.confirmed then
            accepts[#accepts + 1] = name
        end
    end
    table.sort(accepts)
    local done = {}
    for name, completion in pairs(quest.completions or {}) do
        if completion.confirmed then
            done[name] = true
        end
    end
    -- Marked complete by the one who took it, not yet confirmed by the creator.
    local waiting = {}
    for name, claim in pairs(quest.claims or {}) do
        if claim.confirmed and not done[name] then
            waiting[#waiting + 1] = name
        end
    end
    table.sort(waiting)
    return {
        id = quest.id,
        title = quest.title,
        story = quest.story,
        objective = quest.objective,
        creator = quest.creator,
        waiting = waiting,
        confirmed = quest.confirmed == true,
        accepts = accepts,
        done = done,
    }
end

function EldgrimSync.Button(id)
    local name = ownName()
    local quest = db().quests[id]
    if not name or type(quest) ~= "table" then
        return nil
    end
    if name == quest.creator then
        return { delete = true }
    end
    local completion = quest.completions and quest.completions[name]
    if type(completion) == "table" and completion.confirmed then
        return { label = "Completed", enabled = false }
    end
    local claim = quest.claims and quest.claims[name]
    if type(claim) == "table" and claim.confirmed then
        return { label = "Waiting for " .. quest.creator, enabled = false }
    end
    local accept = quest.accepts and quest.accepts[name]
    if type(accept) ~= "table" or not accept.confirmed then
        return { label = "Accept", enabled = true, action = "accept" }
    end
    return { label = "Mark complete", enabled = true, action = "complete" }
end

local function requestRoster()
    local api = C_GuildInfo and C_GuildInfo.GuildRoster
    if type(api) ~= "function" then
        api = GuildRoster
    end
    if type(api) == "function" then
        pcall(api)
    end
end

-- The master's duties at the start of a session. The full name may only be
-- known once the guild roster has arrived, so this runs again on a roster
-- update until it has run once.
local masterStarted = false

local function startMaster()
    if masterStarted or not isMaster() then
        return
    end
    masterStarted = true
    masterHeard = true
    commitLocalHeld()
    publishFile()
    if applyVerifiedFile() then
        sendVerified()
    end
end

local function onLogin()
    if announced then
        return
    end
    announced = true
    sessionStart = serverNow()
    db()
    purgeHeld()
    purgeGatheringHeld()
    db().pendingGathering = nil
    promote()
    dropOldQuests()
    requestRoster()
    startMaster()
    sendHello()
end

local function onRosterUpdate()
    if not announced or masterStarted then
        return
    end
    local wasKnown = fullOwnName ~= nil
    startMaster()
    -- The first hello went out under the short name; say hello again once.
    if not wasKnown and fullOwnName then
        sendHello()
    end
end

local function onAddon(prefix, text, channel, sender)
    if prefix ~= PREFIX then
        return
    end
    EldgrimSync.Handle(channel, sender, text)
end

if type(CreateFrame) == "function" then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:RegisterEvent("GUILD_ROSTER_UPDATE")
    frame:RegisterEvent("CHAT_MSG_SAY")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LOGIN" then
            onLogin()
            return
        end
        if event == "CHAT_MSG_SAY" then
            -- Read nothing from the event until the chat restriction check passes.
            if locked() then
                return
            end
            local message, sender = ...
            EldgrimSync.HeardSay(message, sender)
            return
        end
        if event == "GROUP_ROSTER_UPDATE" then
            EldgrimSync.GroupChanged()
            return
        end
        if event == "GUILD_ROSTER_UPDATE" then
            onRosterUpdate()
            return
        end
        if event == "CHAT_MSG_ADDON" then
            if locked() then
                return
            end
            onAddon(...)
        end
    end)
    frame:SetScript("OnUpdate", function()
        EldgrimSync.Pump()
    end)
    if frame.Show then
        frame:Show()
    end
end

if type(C_ChatInfo) == "table" and type(C_ChatInfo.RegisterAddonMessagePrefix) == "function" then
    pcall(C_ChatInfo.RegisterAddonMessagePrefix, PREFIX)
end
