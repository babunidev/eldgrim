-- Mock checks for the hearth board. These do not replace the two-client game test.

local root = arg and arg[1] or "addon/Eldgrim"
local frames = {}
local player = "Bob"
local now = 1700000000
local clock = 1000
local roster = {}

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

function UnitName()
    return player
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
    return member.name, member.rank or "", member.rankIndex or 4, 60, "Mage", "Ironforge", "", "", member.online and 1 or nil
end

C_ChatInfo = {
    InChatMessagingLockdown = function()
        return false
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
    EldgrimDB = {}
    EldgrimRoster = { members = {} }
    EldgrimSync = nil
    dofile(root .. "/EldgrimEmbers.lua")
    dofile(root .. "/EldgrimSync.lua")
end

local function pump()
    for _ = 1, 16 do
        clock = clock + 0.25
        EldgrimSync.Pump()
    end
end

local function advance(seconds)
    now = now + seconds
    clock = clock + seconds
    pump()
end

local function kinds()
    local found = {}
    for index = 1, #EldgrimSync.Sent do
        local text = EldgrimSync.Sent[index].text
        local kind = text:match("#%x%x%x%x#M%d+#%d+#%d+#([^|]+)|") or text:match("#%x%x%x%x#([^|]+)|")
        found[#found + 1] = kind
    end
    return found
end

local function hasKind(kind)
    for index = 1, #kinds() do
        if kinds()[index] == kind then
            return true
        end
    end
    return false
end

local function deliver(channel, sender, item)
    EldgrimSync.Handle(channel, sender, item.text)
end

local function assertTrue(condition, message)
    if not condition then
        error(message or "assertion failed", 2)
    end
end

boot()
assertTrue(EldgrimSync.WeekEnd(259200) == 864000, "a Sunday publish ends the next Sunday")
assertTrue(EldgrimSync.WeekEnd(172800) == 259200, "a Saturday publish ends on Sunday")
assertTrue(EldgrimSync.WeekEnd(518400) == 864000, "a Wednesday publish ends on Sunday")

EldgrimQuests = {
    ember = {
        revision = 1,
        current = { id = "wed", starts = 518400, title = "Coal", story = "A short fire.", hint = "Look west." },
        next = { id = "after", starts = 99999999, title = "Next", story = "Later.", hint = "" },
        history = {},
        completions = {},
    },
    quests = {},
    tombstones = {},
    held = {},
    inbox = {},
}
now = 518400 + 10
local shown = EldgrimSync.BoardData()
assertTrue(shown.ember.id == "wed" and not shown.ember.ended, "the Wednesday ember is still current")
now = 864000
shown = EldgrimSync.BoardData()
assertTrue(shown.ember.id == "after", "the week boundary promotes next even when its starts disagrees")
EldgrimQuests.ember.next = nil
EldgrimQuests.ember.current.starts = 518400
now = 864000
shown = EldgrimSync.BoardData()
assertTrue(shown.ember.ended and shown.ember.note == "The next ember has not arrived.", "an ended ember stays up")

-- A forged sender cannot publish an ember.
boot()
EldgrimQuests = nil
player = "Bob"
EldgrimSync.Handle("GUILD", "Bob", "1#0000#EMBER|9|fake|1|Forged|no|")
assertTrue(EldgrimQuests == nil or EldgrimQuests.ember == nil or EldgrimQuests.ember.revision == 0, "a bad checksum is ignored")

local function wire(body)
    local sum = 0
    for index = 1, #body do
        sum = (sum + body:byte(index)) % 65536
    end
    return string.format("1#%04X#%s", sum, body)
end

boot()
player = "Bob"
EldgrimSync.Handle("GUILD", "Bob", wire("EMBER|9|fake|1|Forged|Story|Hint|"))
assertTrue(EldgrimQuests == nil or (EldgrimQuests.ember.revision or 0) == 0, "a forged master name does not publish an ember")

player = "Jasmine Amberbrew"
EldgrimEmberFile.revision = 2
EldgrimEmberFile.current = { id = "ember-1", starts = 1700000000, title = "First", story = "The fire is lit.", hint = "South." }
EldgrimEmberFile.next = nil
frames[1].scripts.OnEvent(frames[1], "PLAYER_LOGIN")
pump()
assertTrue(hasKind("EMBER"), "the master publishes a newer file")
assertTrue(hasKind("HELLO"), "login sends a hello")
local emberText
for index = 1, #EldgrimSync.Sent do
    if kinds()[index] == "EMBER" then
        emberText = EldgrimSync.Sent[index].text
    end
end
player = "Bob"
EldgrimQuests.ember.revision = 0
EldgrimQuests.ember.current = nil
EldgrimSync.Handle("GUILD", "Bob", emberText)
assertTrue(EldgrimQuests.ember.revision == 0, "a forged ember revision does not replace the saved quest")
EldgrimSync.Handle("GUILD", "Jasmine Amberbrew", emberText)
assertTrue(EldgrimQuests.ember.revision == 2 and EldgrimQuests.ember.current.title == "First", "the master's ember is kept")

-- A late hello is answered with the card, the revision, and online since.
EldgrimSync.Sent = {}
player = "Jasmine Amberbrew"
EldgrimSync.Handle("GUILD", "Ned", wire("HELLO|0|0|00000000||"))
pump()
assertTrue(hasKind("ANSWER") and hasKind("EMBER"), "the master answers a late hello with the ember")
local answer
for index = 1, #EldgrimSync.Sent do
    if kinds()[index] == "ANSWER" then
        answer = EldgrimSync.Sent[index]
    end
end
assertTrue(answer and answer.chatType == "GUILD", "the answer is a guild message")

-- A peer answers with records outside the asker's ids, never the ember, after the wait.
boot()
player = "Bob"
roster = {
    { name = "Jasmine Amberbrew", rankIndex = 0, online = false },
    { name = "Bob", rankIndex = 4, online = true },
    { name = "Ned", rankIndex = 4, online = true },
}
now = 1700001000
local first = EldgrimSync.CreateQuest("One", "Story", "Do the thing")
local second = EldgrimSync.CreateQuest("Two", "Story", "Do the other")
assertTrue(first and second, "two quests can be made")
pump()
EldgrimSync.Sent = {}
EldgrimSync.Handle("GUILD", "Ned", wire("HELLO|0|1|AAAAAAAA||" .. first:gsub("#", "\\#")))
advance(4)
assertTrue(not hasKind("RECS"), "the peer waits")
advance(16)
assertTrue(hasKind("RECS"), "the peer answers after the wait")
assertTrue(not hasKind("EMBER"), "a peer never sends the ember")
local recs
for index = 1, #EldgrimSync.Sent do
    if kinds()[index] == "RECS" then
        recs = EldgrimSync.Sent[index].text
    end
end
assertTrue(recs:find("|Two|", 1, true) ~= nil, "the answer includes the missing quest")
assertTrue(recs:find("|One|", 1, true) == nil, "the answer leaves out the quest the asker has")

-- Another peer's records cancel the wait. The master's answer does not stop her own reply.
boot()
player = "Bob"
roster = { { name = "Jasmine Amberbrew", rankIndex = 0, online = false } }
now = 1700002000
EldgrimSync.CreateQuest("Held", "Story", "Wait")
pump()
EldgrimSync.Sent = {}
EldgrimSync.Handle("GUILD", "Ned", wire("HELLO|0|0|00000000||"))
EldgrimSync.Handle("GUILD", "Ann", wire("RECS|Q|Ann|Ann#1|T|S|O|creator|" .. tostring(now + 86400) .. "|" .. tostring(now)))
advance(20)
assertTrue(not hasKind("RECS"), "another peer's answer cancels the wait")

boot()
player = "Jasmine Amberbrew"
EldgrimEmberFile.revision = 3
EldgrimEmberFile.current = { id = "ember-3", starts = 1700002000, title = "Third", story = "Still here.", hint = "" }
EldgrimEmberFile.next = nil
frames[1].scripts.OnEvent(frames[1], "PLAYER_LOGIN")
pump()
EldgrimSync.Sent = {}
EldgrimSync.Handle("GUILD", "Ann", wire("RECS|Q|Ann|Ann#9|T|S|O|creator|1700086400|1700002000"))
EldgrimSync.Handle("GUILD", "Ned", wire("HELLO|0|0|00000000||"))
pump()
assertTrue(hasKind("ANSWER") and hasKind("EMBER"), "a peer's records do not cancel the master's answer")

-- Split parts that never finish are not applied.
boot()
player = "Bob"
now = 1700003000
local questId = EldgrimSync.CreateQuest("Split", "Story", "Mark it")
player = "Cara"
EldgrimSync.AcceptQuest(questId)
EldgrimSync.Handle("GUILD", "Cara", wire("M4#1#2#RECS|C|" .. questId .. "|Cara"))
advance(61)
EldgrimSync.Handle("GUILD", "Cara", wire("M4#2#2#RECS||" .. tostring(now) .. "|Cara"))
local detail = EldgrimSync.QuestDetail(questId)
assertTrue(detail and #detail.waiting == 0, "a split that stops halfway is discarded")

-- The one who took it marks it complete; only the creator's confirmation completes it.
boot()
player = "Maker"
now = 1700004000
local made = EldgrimSync.CreateQuest("Mine", "Story", "Show it")
assertTrue(EldgrimSync.AcceptQuest(made) == nil, "the creator cannot accept it")
player = "Cara"
assertTrue(EldgrimSync.CompleteQuest(made) == nil, "it cannot be marked complete before it is accepted")
assertTrue(EldgrimSync.AcceptQuest(made), "someone else can accept")
assertTrue(EldgrimSync.ConfirmQuest(made, "Cara") == nil, "the one who took it cannot confirm it")
assertTrue(EldgrimSync.CompleteQuest(made), "the one who took it marks it complete")
local detail = EldgrimSync.QuestDetail(made)
assertTrue(not detail.done.Cara and detail.waiting[1] == "Cara", "marked complete is not yet completed")
assertTrue(EldgrimSync.Button(made).label == "Waiting for Maker", "the one who took it waits for the creator")
player = "Ned"
assertTrue(EldgrimSync.ConfirmQuest(made, "Cara") == nil, "a third member cannot confirm it")
player = "Maker"
assertTrue(EldgrimSync.ConfirmQuest(made, "Ned") == nil, "the creator cannot confirm someone who did not mark it")
assertTrue(EldgrimSync.ConfirmQuest(made, "Cara"), "the creator confirms it")
detail = EldgrimSync.QuestDetail(made)
assertTrue(detail.done.Cara and #detail.waiting == 0, "the creator's confirmation completes it")
player = "Cara"
assertTrue(EldgrimSync.Button(made).label == "Completed", "the one who took it sees Completed")

-- A confirmation passed on by someone else stays unconfirmed.
boot()
player = "Cara"
now = 1700005000
EldgrimSync.Handle("GUILD", "Maker", wire("RECS|Q|Maker|Maker#1|T|S|O|creator|" .. tostring(now + 86400) .. "|" .. tostring(now)))
EldgrimSync.AcceptQuest("Maker#1")
EldgrimSync.CompleteQuest("Maker#1")
EldgrimSync.Handle("GUILD", "Peer", wire("RECS|F|Maker#1|Cara|" .. tostring(now)))
detail = EldgrimSync.QuestDetail("Maker#1")
assertTrue(detail and not detail.done.Cara, "a peer's confirmation does not complete it")
EldgrimSync.Handle("GUILD", "Maker", wire("RECS|F|Maker#1|Cara|" .. tostring(now)))
detail = EldgrimSync.QuestDetail("Maker#1")
assertTrue(detail.done.Cara, "the creator's own confirmation completes it")
EldgrimSync.Handle("GUILD", "Old", wire("RECS|Q|Old|Old#1|T|S|O|witness|" .. tostring(now + 86400) .. "|" .. tostring(now)))
assertTrue(EldgrimSync.QuestDetail("Old#1") == nil, "a quest in the old proof format is refused")

-- No end date: a quest stays until its creator deletes it. It leaves the list
-- of whoever has completed it, and stays for everyone else.
boot()
player = "Maker"
now = 1700006000
assertTrue(EldgrimSync.CreateQuest("", "Story", "No") == nil, "a missing title is refused")
local oneQuest = EldgrimSync.CreateQuest("One", "Story", "Go")
local twoQuest = EldgrimSync.CreateQuest("Two", "Story", "Go")
local threeQuest = EldgrimSync.CreateQuest("Three", "Story", "Go")
assertTrue(oneQuest and twoQuest and threeQuest, "three open quests fit")
assertTrue(EldgrimSync.CreateQuest("Four", "Story", "Go") == nil, "a fourth open quest is refused")
now = now + 400 * 86400
local board = EldgrimSync.BoardData()
assertTrue(#board.open == 3, "a quest has no end date")
assertTrue(board.history == nil, "there is no history of member quests")
player = "Cara"
EldgrimSync.AcceptQuest(oneQuest)
EldgrimSync.CompleteQuest(oneQuest)
player = "Maker"
EldgrimSync.ConfirmQuest(oneQuest, "Cara")
player = "Cara"
board = EldgrimSync.BoardData()
local listed = {}
for index = 1, #board.open do
    listed[board.open[index].id] = true
end
assertTrue(not listed[oneQuest] and listed[twoQuest], "a completed quest leaves the list of the one who completed it")
player = "Ned"
assertTrue(#EldgrimSync.BoardData().open == 3, "it stays for everyone else")
player = "Maker"
assertTrue(#EldgrimSync.BoardData().open == 3, "it stays for its creator")
assertTrue(EldgrimSync.DeleteQuest(oneQuest), "the creator deletes it when they want")
assertTrue(#EldgrimSync.BoardData().open == 2 and EldgrimSync.QuestDetail(oneQuest) == nil, "a deleted quest is gone")
assertTrue(EldgrimSync.CreateQuest("Four", "Story", "Go"), "deleting makes room for another")

-- Log in as another character, keeping what is saved. The sync caches a
-- two-part name, so changing characters means loading it again.
local function as(name)
    player = name
    local saved = EldgrimQuests
    frames = {}
    EldgrimSync = nil
    dofile(root .. "/EldgrimSync.lua")
    EldgrimQuests = saved
end
-- Who can complete it: for everyone, or for the first member to accept.
local function sentText()
    local all = {}
    for index = 1, #EldgrimSync.Sent do
        all[#all + 1] = EldgrimSync.Sent[index].text
    end
    return table.concat(all, "\n")
end
local function listedFor(name, id)
    if player ~= name then
        as(name)
    end
    for _, row in ipairs(EldgrimSync.BoardData().open) do
        if row.id == id then
            return true
        end
    end
    return false
end
boot()
EldgrimTestQuestFile = nil
player = "Maker Moss"
now = 1700007000
local solo = EldgrimSync.CreateQuest("Solo", "Story", "Go", "one")
local open = EldgrimSync.CreateQuest("Open", "Story", "Go")
pump()
assertTrue(sentText():find("|one", 1, true) ~= nil, "a one-member quest is sent with its mode")
assertTrue(EldgrimSync.QuestDetail(open).mode == "all", "a quest is for everyone unless set otherwise")
as("Cara Vell")
assertTrue(EldgrimSync.AcceptQuest(solo), "the first member accepts the one-member quest")
assertTrue(EldgrimSync.CurrentQuest() == solo, "the one who accepted is on it")
assertTrue(not listedFor("Ned Ash", solo), "a taken one-member quest leaves the board for others")
assertTrue(listedFor("Maker Moss", solo), "it stays on its creator's board")
as("Ned Ash")
assertTrue(EldgrimSync.AcceptQuest(solo) == nil, "a second member cannot take a one-member quest")
assertTrue(EldgrimSync.Button(solo).label == "Taken by Cara Vell", "others see who took it")

-- One quest at a time.
as("Cara Vell")
assertTrue(EldgrimSync.AcceptQuest(open) == nil, "a member on a quest cannot accept another")
assertTrue(EldgrimSync.Button(open).label == "On another quest", "the button says why")
assertTrue(EldgrimSync.Button(solo).abandon == true, "the quest on offers Abandon")

-- The notebook belongs to the quest this character is on.
assertTrue(EldgrimSync.AddNote("  Ask the innkeeper  "), "a note is added")
EldgrimSync.AddNote("Find the lamplighter")
assertTrue(EldgrimSync.AddNote("   ") == nil, "an empty note is refused")
local written = EldgrimSync.Notes()
assertTrue(#written == 2 and written[1].text == "Ask the innkeeper", "notes are listed in order, trimmed")
assertTrue(EldgrimSync.CheckNote(1) and EldgrimSync.Notes()[1].text == "Find the lamplighter", "a checked note is removed")
pump()
assertTrue(sentText():find("lamplighter", 1, true) == nil, "notes are never sent")
as("Ned Ash")
assertTrue(#EldgrimSync.Notes() == 0 and EldgrimSync.AddNote("x") == nil, "another character has no notebook without a quest")

-- Abandon puts a one-member quest back on the board and frees the member.
as("Cara Vell")
assertTrue(EldgrimSync.AbandonQuest(solo), "the member abandons the quest")
assertTrue(EldgrimSync.CurrentQuest() == nil, "after abandoning, the member is on no quest")
assertTrue(#EldgrimSync.Notes() == 0, "the notes go with the quest")
assertTrue(listedFor("Ned Ash", solo), "an abandoned one-member quest is back on the board")
as("Ned Ash")
assertTrue(EldgrimSync.AcceptQuest(solo), "another member can take it now")
as("Cara Vell")
assertTrue(EldgrimSync.AcceptQuest(open), "the member who abandoned can take another quest")

-- A forged abandon is ignored; the member's own counts.
boot()
EldgrimTestQuestFile = nil
player = "Cara Vell"
now = 1700008000
EldgrimSync.Handle("GUILD", "Maker Moss", wire("RECS|Q|Maker Moss|Maker Moss#1|T|S|O|creator|0|" .. tostring(now) .. "|one"))
EldgrimSync.Handle("GUILD", "Ned Ash", wire("RECS|A|Maker Moss#1|Ned Ash|" .. tostring(now)))
assertTrue(EldgrimSync.Button("Maker Moss#1").label == "Taken by Ned Ash", "a one-member quest taken elsewhere shows who holds it")
EldgrimSync.Handle("GUILD", "Peer Bly", wire("RECS|W|Maker Moss#1|Ned Ash|" .. tostring(now + 5)))
assertTrue(EldgrimSync.QuestDetail("Maker Moss#1").holder == "Ned Ash", "an abandon passed on by someone else does not count")
EldgrimSync.Handle("GUILD", "Ned Ash", wire("RECS|W|Maker Moss#1|Ned Ash|" .. tostring(now + 6)))
assertTrue(EldgrimSync.QuestDetail("Maker Moss#1").holder == nil, "the member's own abandon frees it")
EldgrimSync.Handle("GUILD", "Old Fen", wire("RECS|Q|Old Fen|Old Fen#1|T|S|O|creator|0|" .. tostring(now)))
assertTrue(EldgrimSync.QuestDetail("Old Fen#1").mode == "all", "a quest from an older client is for everyone")
-- Two accepts of a one-member quest: the earlier one holds it on every client.
EldgrimSync.Handle("GUILD", "Pia Rook", wire("RECS|A|Maker Moss#1|Pia Rook|" .. tostring(now + 20)))
EldgrimSync.Handle("GUILD", "Ned Ash", wire("RECS|A|Maker Moss#1|Ned Ash|" .. tostring(now + 19)))
assertTrue(EldgrimSync.QuestDetail("Maker Moss#1").holder == "Ned Ash", "the earlier accept holds a one-member quest")

-- The test quest: only on the master's client, never sent, confirmed by Eldgrim.
boot()
dofile(root .. "/EldgrimTestQuest.lua")
local testId = EldgrimTestQuestFile.quest.id
as("Cara Vell")
assertTrue(not listedFor("Cara Vell", testId), "the test quest is not on a member's board")
as("Jasmine Amberbrew")
roster = { { name = "Jasmine Amberbrew", rankIndex = 0, online = true } }
assertTrue(listedFor("Jasmine Amberbrew", testId), "the test quest is on the master's board")
local test = EldgrimSync.QuestDetail(testId)
assertTrue(test.creator == "Eldgrim" and test.test and test.mode == "one", "the test quest is Eldgrim's, for one member")
assertTrue(EldgrimSync.AcceptQuest(testId), "the master can accept the test quest")
assertTrue(EldgrimSync.CurrentQuest() == testId and EldgrimSync.AddNote("Try the Kharanos lamp"), "the master is on it and can write notes")
assertTrue(EldgrimSync.CompleteQuest(testId), "the test quest is marked complete")
assertTrue(EldgrimSync.QuestDetail(testId).done["Jasmine Amberbrew"], "Eldgrim confirms its test quest at once")
assertTrue(not listedFor("Jasmine Amberbrew", testId), "a completed test quest leaves the board")
pump()
assertTrue(sentText():find(testId, 1, true) == nil, "nothing about the test quest is sent")
EldgrimTestQuestFile = nil

-- Ember completions come only from the master, from the verified file.
boot()
player = "Jasmine Amberbrew"
roster = { { name = "Jasmine Amberbrew", rankIndex = 0, online = true } }
now = 1795132800 + 3600
EldgrimEmberFile.revision = 5
EldgrimEmberFile.current = { id = "e-now", starts = 1795132800, title = "Now", story = "Now.", hint = "" }
EldgrimEmberFile.next = { id = "e-next", starts = 1795305600, title = "Next", story = "Next.", hint = "" }
EldgrimVerifiedFile = {
    revision = 3,
    embers = {
        { week = 1795305600, name = "Garran Veyne" },
        { week = 1795305600, name = "Teanie Tinkertop" },
        { week = 1795305600, name = "Garran Veyne" },
        { week = 1795910400, name = "Not Yet" },
        { week = 1700000000, name = "Unknown Week" },
    },
}
frames[1].scripts.OnEvent(frames[1], "PLAYER_LOGIN")
pump()
local shownEmber = EldgrimSync.BoardData().ember
assertTrue(#shownEmber.completedBy == 2 and shownEmber.completedBy[1].name == "Garran Veyne", "the master shows each verified character once")
assertTrue(hasKind("DONE"), "the master sends the verified list")
local doneText
for index = 1, #EldgrimSync.Sent do
    if kinds()[index] == "DONE" then
        doneText = EldgrimSync.Sent[index].text
    end
end
assertTrue(EldgrimSync.FinishEmber == nil, "nobody can mark the ember complete on the board")

boot()
player = "Bob"
EldgrimSync.BoardData()
EldgrimQuests.ember.revision = 5
EldgrimQuests.ember.current = { id = "e-now", starts = 1795132800, title = "Now", story = "Now.", hint = "" }
EldgrimSync.Handle("GUILD", "Bob", doneText)
assertTrue(#EldgrimSync.BoardData().ember.completedBy == 0, "a list from anyone else is ignored")
EldgrimSync.Handle("GUILD", "Bob", wire("DONE|9|e-now|Bob"))
assertTrue(#EldgrimSync.BoardData().ember.completedBy == 0, "a member cannot mark themselves complete")
EldgrimSync.Handle("GUILD", "Jasmine Amberbrew", doneText)
assertTrue(#EldgrimSync.BoardData().ember.completedBy == 2, "the master's list is taken")
EldgrimSync.Handle("GUILD", "Jasmine Amberbrew", wire("DONE|2|e-now|Older"))
assertTrue(#EldgrimSync.BoardData().ember.completedBy == 2, "an older list does not replace a newer one")

-- A member who logs in later gets the list with the master's answer.
boot()
player = "Jasmine Amberbrew"
frames[1].scripts.OnEvent(frames[1], "PLAYER_LOGIN")
pump()
EldgrimSync.Sent = {}
EldgrimSync.Handle("GUILD", "Ned", wire("HELLO|5|0|00000000||"))
pump()
assertTrue(hasKind("ANSWER") and hasKind("DONE"), "a late hello is answered with the verified list")
EldgrimVerifiedFile = nil

-- Held guild lines, the summary, one holder at a time, and the ack.
boot()
player = "Bob"
roster = {
    { name = "Jasmine Amberbrew", rankIndex = 0, online = false },
    { name = "Bob", rankIndex = 4, online = true },
    { name = "Ann", rankIndex = 4, online = true },
    { name = "Cara", rankIndex = 3, online = false },
}
now = 100
EldgrimHoldGuildLine("older", "Speaker")
now = 200
EldgrimHoldGuildLine("newer", "Speaker")
EldgrimSync.Handle("GUILD", "Jasmine Amberbrew", wire("HELLO|1|0|00000000|150|"))
pump()
assertTrue(#EldgrimQuests.held == 1 and EldgrimQuests.held[1].text == "older", "lines newer than online since are dropped")
assertTrue(EldgrimSync.Sent[1].chatType == "WHISPER" and kinds()[1] == "SUM", "the summary comes before the lines")
EldgrimSync.Handle("WHISPER", "Jasmine Amberbrew", wire("ASK|"))
pump()
assertTrue(hasKind("BATCH"), "the lines follow the master's ask")
local beforeAck = #EldgrimQuests.held
EldgrimSync.Handle("WHISPER", "Jasmine Amberbrew", wire("ACK|" .. EldgrimQuests.pendingBatch.id))
assertTrue(beforeAck == 1 and #EldgrimQuests.held == 0, "the ack deletes that batch")

boot()
player = "Bob"
now = 300
EldgrimHoldGuildLine("keep", "Speaker")
now = 400
EldgrimHoldGuildLine("also", "Speaker")
EldgrimSync.Handle("WHISPER", "Jasmine Amberbrew", wire("ASK|"))
pump()
local batchId = EldgrimQuests.pendingBatch.id
local kept = EldgrimQuests.held[2].id
EldgrimQuests.pendingBatch.ids = { EldgrimQuests.held[1].id }
EldgrimSync.Handle("WHISPER", "Jasmine Amberbrew", wire("ACK|" .. batchId))
assertTrue(#EldgrimQuests.held == 1 and EldgrimQuests.held[1].id == kept, "the ack deletes only that batch")

now = 400 + 7 * 86400 + 5
EldgrimHoldGuildLine("fresh", "Speaker")
local sawOld = false
for index = 1, #EldgrimQuests.held do
    if EldgrimQuests.held[index].text == "also" then
        sawOld = true
    end
end
assertTrue(not sawOld, "held lines older than 7 days are deleted")

-- The master takes the oldest online holder, and drops speakers who are not on the roster.
boot()
player = "Jasmine Amberbrew"
roster = {
    { name = "Jasmine Amberbrew", rankIndex = 0, online = true },
    { name = "Ann", rankIndex = 4, online = true },
    { name = "Bob", rankIndex = 4, online = true },
    { name = "Cara", rankIndex = 3, online = false },
    { name = "Speaker", rankIndex = 4, online = true },
}
EldgrimDB = {}
EldgrimSync.Handle("WHISPER", "Cara", wire("SUM|1|1|1"))
EldgrimSync.Handle("WHISPER", "Bob", wire("SUM|1|50|50"))
EldgrimSync.Handle("WHISPER", "Ann", wire("SUM|1|10|10"))
pump()
assertTrue(EldgrimSync.Sent[1].target == "Ann" and kinds()[1] == "ASK", "the oldest online holder is asked first")
EldgrimSync.Handle("WHISPER", "Stranger", wire("BATCH|x|Speaker|no|10"))
assertTrue(EldgrimDB.Speaker == nil, "a passer who is not on the roster is dropped")
EldgrimSync.Handle("WHISPER", "Ann", wire("BATCH|a1|Missing|ghost|10"))
assertTrue(EldgrimDB.Missing == nil, "a speaker who is not on the roster is dropped")
EldgrimSync.Handle("WHISPER", "Ann", wire("BATCH|a2|Speaker|same line|100"))
assertTrue(EldgrimDB.Speaker.messages[1].passedBy == "Ann", "one member's line keeps that passer")
EldgrimSync.Handle("WHISPER", "Bob", wire("BATCH|b2|Speaker|same line|106"))
assertTrue(EldgrimDB.Speaker.messages[1].passedBy == nil, "the same line from a second member may stand as guild chat")
assertTrue(#EldgrimDB.Speaker.messages == 1, "the two copies are one line")
pump()
local askedBob = false
for index = 1, #EldgrimSync.Sent do
    if EldgrimSync.Sent[index].target == "Bob" and kinds()[index] == "ASK" then
        askedBob = true
    end
end
assertTrue(askedBob, "the next online holder is asked after the batch")

-- /eldgrim log opens the board. Any other text stays the invite whisper.
local opened = false
function EldgrimOpenHearth()
    opened = true
end
local printed = {}
function print(text)
    printed[#printed + 1] = text
end
function UnitExists()
    return false
end
SlashCmdList = {}
dofile(root .. "/Eldgrim.lua")
SlashCmdList.ELDGRIM("log")
assertTrue(opened, "/eldgrim log opens the hearth")
opened = false
SlashCmdList.ELDGRIM("log ")
assertTrue(not opened, "only the exact word log opens the hearth")
local whispers = 0
C_ChatInfo.SendChatMessage = function()
    whispers = whispers + 1
    return true
end
function UnitExists()
    return true
end
function UnitIsPlayer()
    return true
end
function UnitIsUnit()
    return false
end
function UnitIsInMyGuild()
    return false
end
function UnitName(unit)
    if unit == "target" then
        return "Target"
    end
    return player
end
SlashCmdList.ELDGRIM("")
assertTrue(whispers == 1, "bare /eldgrim stays the invite whisper")

print("Eldgrim hearth mock tests passed. These are not in-game tests.")
