# Development Log

A concise account of meaningful project development, written from the human creative's perspective.

Entries before 14 November 2026 that say only "AI", or name no tool, did not record which tool or model did the work. The [collaboration record](AI_COLLABORATION.md) lists them as earlier AI help, tool and model not recorded.

## 2026-11-22 — Cinder, and who came to the fire

Six of us lit fires along the road from the Valley of Kings to the North Gate pass, and the guild named the second rank Cinder in chat that evening. Faenra Greenleaf and Galandor Levalois were promoted to it. Claude Code (Claude Opus 5.5) gave the five members who were there their point by hand, after backing up the database, and renamed Wayfarer to Cinder in the agent, the bot and the documents. After I approved its preview, the bot renamed the Discord role. The bot was deployed with the new info text at the same time.

Nothing recorded attendance yet, so it built that next. Every copy of the addon now notes guild members who speak in /say, and guild members in the group, on Sunday from 19:00 to 20:00 Swedish time. The other members' addons pass their notes to mine when I log in, and the daily run turns each Sunday into one point per member. It also found why the promotions were missing from the saved roster: the roster was saved at most once a day. It is now saved as soon as a rank changes or someone joins. The addon is developed in this project and installed into the game with `addon/install-local.sh`; the addon README now spells out that workflow.

**Result:** 141 agent tests, 109 bot tests and five addon mock suites passed, including 33 new gathering checks. The bot passed its tests on the server and restarted. The role reads Cinder with its permissions unchanged. The addon was installed into the game folder with `addon/install-local.sh` and is not yet tested in game.

## 2026-11-22 — Quests without the rules in them

Every quest Eldgrim wrote ended with the same out-of-character paragraph about pictures, Discord and the Roar, because the quest instructions required it and a quest without it was refused. The way to finish an Eldgrim quest never changes, so it belongs in one place. Claude Code (Claude Opus 5.5) turned the rule around: the quest is written in character only, and one that mentions screenshots, Discord, emoji or the Roar emoji is refused and the fixed spare text is sent. The bonfire and spare texts lost their proof paragraph. The `info` reply and the Eldgrim channel description now carry the finishing steps as a numbered list, pointing to #roar-screenshots. The description became its own shorter text, because the full info had been cut off partway through the quest paragraph.

**Result:** 136 agent tests and 109 bot tests passed, one new in each. The context check passed. The bot has not been deployed with the new texts, and no live run was made.

## 2026-11-21 — A call to the fire, not a census

Today's announcement listed fourteen level-ups and a quest count, which is the keepers' census and not Eldgrim. Its wish to bring people to the fire, which is its whole role, had not shown in any announcement. Claude Code (Claude Opus 5.5) found the cause in the run itself: the public brief carried every level-up since the last keepers' note, and the instructions told Eldgrim twice to name them all. It took the level-ups out of the public brief, rewrote the instructions to open with what Eldgrim wants, gave each day a random way in such as a dare, a riddle or an empty seat, and added checks that send back a draft listing levels or saying what Sunday lacks. The reason Eldgrim wants the fire full stays in the private roots.

**Result:** 135 agent tests passed, 4 of them new, and the context check passed. Twenty-seven local drafts from today's brief, none posted, were reviewed in five rounds. The reviews led to a check against drafts that echo the rules, a voice-not-body line, and "tomorrow" on Saturdays. No live run was made.

## 2026-11-21 — Which Ollama ran it

The documentation guide asks every agent record to name the Ollama version, and the run logs named only the model. Claude Code (Claude Opus 5.5) explained the difference between Ollama's background server and the command I type, then made each run ask the server for its version when it starts the model and write that beside the model tag.

**Result:** 131 agent tests passed, 2 of them new. Started briefly on my computer without loading a model, the server reported 0.40.6 and stopped again. No live run was made.

## 2026-11-21 — Places by level, and the documentation set straight

The last part of my 20 November plan was world zones by the character's level. Claude Code (Claude Opus 5.5) made a quest see only the places that character's level and side allow, from the world page's own level bands, and made the run refuse a quest that names a place outside them. The world page already said a row with no level is not an errand, so those are never shown either. The two catalog rows the level filter could not fix were mine to correct, and I asked for them: the Night Watchman's Torch now needs its quest's level, 60, and the torches and the fish with no named source wait under Not an errand yet.

Then I asked for the documentation to be set right and checked against the writing rules. Claude Code found the roadmap, the project structure and the root README still describing the agent as a design and the addon as a recorder only, rewrote them from the code and the records, and corrected the bot README, the concept, the documentation guide and AGENTS.md the same way. It also reworded six journal sentences that began with "I" or "My", put two misplaced entries back in date order, noted that older entries did not record their AI tool, and moved a stray research file out of the root. Links were checked and none were broken.

**Result:** 129 agent tests passed, 7 of them new. A level 1 quest now reads about 11,600 tokens, a level 60 quest about 15,600. No live run was made.

## 2026-11-21 — What Eldgrim reads about itself

The last planned step was an audit of the core, the ten pages every task reads whole. Claude Code (Claude Opus 5.5) read them against the current decisions and the code. The capabilities page matched what was checked against the code. Three lines elsewhere did not. Chapter 01 called autonomous administration Eldgrim's authority, as if it were a power it has today; it is an approved goal that waits for my deployment authorization. The same table said several characters per player, which needed my 20 November decision beside it: several characters may stay in the guild, and one is registered with Eldgrim in the Forge. Chapter 15 opened with a priority order I never adopted, before the one I did. Rather than delete the old proposal, I chose to reorder that chapter, so it stays as a record at the end.

Reading the decision log, Claude Code also noticed that I had planned no fire catalog for the announcement at all, while its first change that day had kept four sections of it. The announcement now reads none.

**Result:** 122 agent tests passed. The proclamation's estimate with the largest brief is about 17,200 tokens. No live run was made.

## 2026-11-21 — Fire items by level

Chapter 08 already said a later quest names an item that fits the character's level, but the quest read the whole fire catalog and nothing checked the level. That was the next step I had named. Claude Code (Claude Opus 5.5) made the quest show only the rows the character's level allows, by the level the catalog says an item needs, and made the run refuse an item above it and use a fitting spare. When nothing fits, the model is not asked.

**Result:** 122 agent tests passed, 5 of them new. The quest's reading fell from about 18,300 tokens to 13,100 at level 1 and 15,900 at level 60. At level 1 the catalog still offers the Night Watchman's Torch, whose quest the page tags level 60, and the Smoky Torch, which the page says has no named source; the catalog rows decide that, not the filter. No live run was made.

## 2026-11-21 — Reading only what a task needs

The proclamation on 20 November did not fit: it needed about 24,725 tokens in a window of 24,576. The window had already been raised twice to keep up, and a larger window needs more memory while the model runs. Smaller reading for each task was the step I had named, so that is what came next. Claude Code (Claude Opus 5.5) let each task name the sections it reads from a page, while Eldgrim's core self stays whole. It proposed the sections: the confirmed rules each task acts on, without the refinement queues of open questions, and for the proclamation only the fire items anyone can bring to a guild fire, not the gear lists. The choice lives in `agent/context.toml`, where I can change it.

**Result:** 117 agent tests passed, 6 of them new. With the largest allowed brief, the proclamation's estimate fell from about 24,900 to 19,300 tokens, and every task fits. No live run was made.

## 2026-11-20 — A member's whole record

After re-running the ranks step, the note no longer recommended a member it had recommended before; it only said to look at that character. Claude Code (Claude Opus 5.5) found why: the note waited for a positive keyword on that same day, and the second preparation found no new chat. One day should not decide that. Now every day someone has been in Eldgrim's records counts, and only days with a negative keyword lower their positivity. At 75% or more, with enough points, Eldgrim recommends the promotion; the guild still decides. The ranks are further apart too: Wayfarer at 60, Kindler at 90, Hearthkeeper at 150 and Hearthwarden at 200, on a scale up to 200, and my own score is set to 200.

Claude Code wrote the positivity measure and the new recommendation, showed it in `eldgrim roster`, set my score after a backup, and updated chapters 04 and 07, the decision register and the roster page.

**Result:** 111 agent tests passed, 7 of them new. A read-only check of the real database now recommends that member again and names one other to look at. Nothing was posted.

## 2026-11-20 — One step at a time

Eldgrim's run today did only part of its work. The scheduled run stopped before anything, because the announcement's reading was estimated just over its window, and that one overflow stopped quests, replies and the Hearth Keepers note too. When we ran it by hand, the note went out, but both announcement drafts were rejected, and the quest step only set my quest aside, since a cancel was the only request waiting. Claude Code (Claude Opus 5.5) traced that from the run logs, Ollama's log and the quest records. What I asked for was a run in parts, each standing on its own and each able to run alone: `prepare`, `quests`, `replies`, `announce`, `ranks` and `choose`. Ranks stay in one note.

Claude Code made the steps, kept today's brief so a single step does not prepare the guild again, and made a rejected announcement log which check stopped it. Smaller reading for each task, fire items by level and an audit of the core are the next steps, not done yet.

**Result:** 104 agent tests passed, 13 of them new. No live run was made with the new steps.

## 2026-11-20 — One character, and quests that wait

A member brings one character now. Since I am the only one who registered several, I will go through the Forge again and keep Jasmine Amberbrew. Member quests also lost their timer: a quest stays until the one who made it deletes it, and it leaves the list only for someone who has completed it. Claude Code (Claude Opus 5.5) changed the Forge to ask for one character, made the local roster let go of characters the Forge no longer lists, and took the end date out of the addon.

**Result:** 108 bot tests, 91 agent tests and the addon's mock tests passed. Then I asked for it live. The deploy script still archived a repository the bot no longer has, so Claude Code changed it to pack the bot folder itself, checked first that the server held no file the sync would delete, and deployed. Two runs stopped on the service's Python cache before the restart; the third restarted the bot at 02:51 UTC. The Forge panel was updated through the bot's preview and apply. Not tested in game.

## 2026-11-20 — Proof belongs in Discord

Ticking a quest off for oneself was never what I meant. A weekly ember is proved the way every Eldgrim quest is: a screenshot in the Eldgrim channel with @Eldgrim, and another member's Roar. The guild accepts it first, then the record lands on my computer, the daily run brings it together, and my next login passes it on to everyone. Member quests became simpler: the one who took it marks it complete, the one who made it confirms, and nothing about them is kept afterwards. To tell the two kinds of screenshot apart, I chose the word ember; I also chose a private thread to ask which character, and one standing point for a witnessed ember.

Claude Code (Claude Opus 5.5) built it across all three parts: the bot stages ember proofs with their character, the daily run records them and writes `EldgrimVerified.lua` into the installed addon, and the addon takes completions only from Jasmine Amberbrew and drops the old proof choices. One early test run wrote an empty verified file into the installed addon through my real configuration; the file was removed, and the tests now write only to a temporary folder.

**Result:** Mock tests passed in the addon, 107 bot tests and 90 agent tests. The bot is not deployed on the server, so ember screenshots are not yet staged. Not tested in game.

## 2026-11-20 — Why the ember stayed dark

After two reloads the board still had no ember. Claude Code (Claude Opus 5.5) read the saved file: revision 0, and my test quest's creator was "Jasmine". Forever gives a character's own name without the surname, while the roster and guild chat say "Jasmine Amberbrew", so the addon never knew it was the master. It now takes the full name from the character's own roster entry. Beyond that, I wanted the first ember to run now and end on Sunday, with the next one ready behind it, so the file holds two cards, and a third card is to be written each week.

**Result:** A mock where the name arrives short and the roster arrives late, with a second Jasmine in the guild, found the right name, published both cards and handed over at Sunday 00:00 UTC. Not yet seen in game.

## 2026-11-20 — The first ember

With the board looking right, I wanted it to hold something. Claude Code (Claude Opus 5.5) wrote the first weekly ember, "A Fire of Your Own", from Eldgrim's self and voice pages, the fire motifs, the world page and the fire catalogue. It asks each member to light a small fire somewhere new on the road, stay by it, and notice one thing. The hint names only a campfire kit and goods whose source the catalogue gives. The card starts on Sunday 22 November so it runs a full week, and sits in the ember file installed on Jasmine Amberbrew's machine. The text is kept in `narrative/EMBERS.md`.

**Result:** In a mock of two clients, the real sync published the card from Jasmine Amberbrew's file in five messages of at most 255 bytes, and the other client rebuilt the title, story and hint exactly. It has not been published in Forever yet.

## 2026-11-20 — The hearth board gets its frame

The first board opened from the guild panel, but it did not look like Eldgrim. The flame was a flat flask, the buttons were coloured boxes, and the text fields had no edge. The frame instructions had not come through either. What I had asked for was cut corners with triangles in them, and lines from the outside in: one thick line, one thin line broken at random, an even thinner line all the way round, a gap, and one more line.

Claude Code (Claude Opus 5.5) redrew it. It wrote `addon/tools/hearth_art.py`, which draws the textures: a new flame emblem, the four frame corners with a flame plaque and scrolls in each, and buttons, fields and glyphs. It split the look into `EldgrimSkin.lua` and rebuilt `EldgrimBoard.lua` on it. To see the work without the game, it wrote a small mock of the frame API that runs the real board code on sample data and renders it to PNG. A first corner flame pointed at the window's centre and read as a seed. Mirroring one corner texture would have turned the flames upside down at the bottom, so each corner is drawn on its own.

**Result:** The preview renders, and the new mock test of the window's buttons and form passed, as did the existing mock tests. Nothing has been seen in Forever yet. The client must be restarted to load the new textures.

## 2026-11-20 — The hearth board is in the addon

The hearth board had a plan and no addon. Cursor (Grok 4.7) added the ember file, the guild sync, and the coal-and-fire board in `addon/Eldgrim`. Jasmine Amberbrew is the only character whose addon messages can publish the weekly ember. Other clients hold guild chat until her addon acknowledges a batch, then delete that batch. A quest record counts only when the reported sender is the person acting. A guild line passed on by one member is stored with that member's name, and the daily run does not score it.

**Result:** Mock tests passed on this machine. The two-client checks have not been run in Forever. The project addon was copied into the local AddOns folder. Rank index 0 is the only invite rank on the list. The rest of the guild's invite ranks are not written down yet.

## 2026-11-20 — One project for the bot

The Discord bot had its own folder and its own local git history, with no remote. Eldgrim has one public repository. Cursor (Grok 4.7) moved the working copy into `bot/private` and gitignored that directory. The source contains live Discord identifiers, so it stays on this machine and out of the public record. The earlier local history was kept beside the project and was not imported.

**Result:** `git status` does not list the bot source. The server copy of the bot was not changed.

## 2026-11-20 — The addon stays in the project

The game's AddOns folder and `addon/Eldgrim` had become two copies. The project copy is the 0.1.0 recorder. The installed copy is 0.3.0, with the daily roster and the invite whisper, last written on 19 November 2026. Cursor (Grok 4.7) left both files where they were and added `addon/install-local.sh`, which copies the project addon into the Forever AddOns folder and stops when the installed copy is newer.

**Result:** No file in the game folder was replaced. The install was not run.

## 2026-11-19 — An in-game chat for Amberhearth

The in-game chat needed to belong to the new guild alone. Cursor (Grok 4.7) opened a channel named in-game in the Roar and Amberhearth category. Amberhearth can see it and write there. Roar and the ranks cannot. A Hearthwarden still can, because that role is an administrator and Discord lets administrators through every lock.

**Result:** The channel was created, then removed the same night. The game had offered #chat before it existed, and with the new channel present the list was empty. #chat was left as it was. No one was watched opening the guild window after the removal.

## 2026-11-19 — The clear stays, game open or not

The hearth-board review suggested leaving guild chat in the file while Forever is running. That is not the rule. The run reduces the lines and clears them whether or not the game is open, and the addon fills the lists again. Cursor (Grok 4.7) took the open-client hold back out. The first-hand rule for the hearth board stays: a record counts only when the reported sender is the person acting, and a line relayed by one member does not back a keyword or a standing point.

**Result:** The clear no longer looks for `Wow.exe`. The relay itself is not built.

## 2026-11-19 — Characters, not the players

A keyword had been saved on the Discord member, so a note about conduct belonged to the person rather than the character who spoke. Cursor (Grok 4.7) moved those notes onto the character. Guild chat keeps one keyword for the character who wrote. A reply keeps its short impression on the character that reply was about. The list Eldgrim reads names characters and leaves the player's name out. Standing and rank stay on the shared account.

**Result:** A synthetic greeting is stored on Mira Stone, and a reply's impression is stored on Ada. The guild list no longer says who plays them on Discord. No live run was started.

## 2026-11-19 — The character, the wish, and a fire

A quest had been choosing the highest level, so one character always walked it, and the ask itself was thrown away. Cursor (Grok 4.7) had the ask open a private thread. The member chooses the character, then may add a short wish, such as a place. The wish goes to the quest as a wish, not as an instruction. The quest is posted as a reply to the original message. A mention in the Eldgrim channel gets a fire between three and thirty-seven seconds later. When the quest is done, the quest reply gets a fire and the private thread gets one line that another may be asked for. A new character is stored at level 1 until the guild chat reports a level. The announcement is told not to invent a theme, a region, or a place for Sunday. The Eldgrim channel is placed under talk, in the Roar and Amberhearth category, with that category's permissions.

**Result:** Synthetic tests choose the named character, keep the wish fenced, start a character at level 1 without a census mark, and place the channel under talk. No live run was started.

## 2026-11-19 — One member at a time

A quest came back addressed to another character, because the quest call could see the whole guild. Cursor (Grok 4.7) separated the rounds. A quest and a personal answer now take one member who wrote in the Eldgrim channel, choose that member's character, and see only that character. The proclamation still reads the guild list. Each member who wrote gets one reply, on their newest message. The Eldgrim channel carries the info text as its description.

**Result:** Synthetic tests answer two members from two separate cards, and a quest call no longer receives the guild list. The server bot was restarted with the Eldgrim channel on 19 November 2026.

## 2026-11-18 — The day, and a word when the quest is done

The Wednesday announcement invited the fellowship to light a fire this evening, and called that Sunday's gathering. It also called Pimbleton Mirelight a gnome mage. The stored record says Human mage, and it holds no level. Cursor (Grok 4.7) gave the announcement today's weekday and the date of the coming Sunday, put the recorded race and class on a newcomer's line, and asked for one congratulation after the level-ups.

A Roar had closed a quest and left no word that it was done, so a new quest could be asked for without knowing the last one was finished. Cursor (Grok 4.7) had the bot send one sentence of thanks the moment an Amberhearth Roar lands. The sentence names the quest when the daily run stored that line with it.

**Result:** A Wednesday brief names Sunday 22 November and forbids this evening. A synthetic Roar sends the prepared thanks once. The stored character record was read and not changed. The server bot was restarted with the thanks on 18 November 2026.

## 2026-11-18 — What the lands feel like

The world page could name Loch Modan and the Wetlands, and it could not say what either one was. A level band is not a place. Cursor (Grok 4.7) added one short line of ground and weather to each city and outdoor land already on the page. Riverglades stays the frontier of rivers and grasslands. Gilneas stays seen and not entered. No new place went on the list.

**Result:** A test looks for the loch and the marsh. The proclamation still fits its window. None of the lands were walked.

## 2026-11-18 — Guild news, and a word about Eldgrim

The announcements had begun to name people, and that was the interesting part. They can carry a little guild news as well: a welcome for a new character, a congratulation when someone gains a level, a count of the Eldgrim quests a character has finished, and a fresh reminder of the Sunday evening meeting. A mention that says info now gets a direct message about who Eldgrim is and how to speak to it. Sleep stays with the desktop. The run's own job is to finish, unload, and leave the machine quiet. Cursor (Grok 4.7) put the news into the brief and wrote the info message.

The first info wording was replaced the same night. The creative wrote the message that goes out: Eldgrim watches the fellowship, will not take Jasmine's chair, and explains the mention, the quest, the Roar, and Sunday. Cursor (Grok 4.7) put that text in place.

**Result:** Synthetic tests check the welcome name, the level, the quest count, and that an opted-out name stays off the brief. The server bot was restarted with the info reply on 18 November 2026. A live announcement was not posted from here.

## 2026-11-18 — Amberhearth confirms a quest

A quest screenshot needed a witness, and that witness had been any other registered member, with a Hearthkeeper or a Hearthwarden named as a welcome one. The creative narrowed it. The Roar counts from every member who holds the Amberhearth role, at any rank. Someone without that role does not close the quest. Cursor (Grok 4.7) changed the check and the quest wording, and tested both with synthetic members.

**Result:** A Roar from Amberhearth completes the quest. A Roar from outside it leaves the quest open. The server service was restarted with that check on 18 November 2026. A live Roar was not watched from here.

## 2026-11-17 — One reply, in the channel

Members can write to Eldgrim in the guild channels. The conversation stays there. Once in the daily run, Eldgrim replies to the one mention that matters most to it, on that message, and it does not take the conversation into a direct message. The other letters are dropped. One short impression of the answered letter stays on this computer, and the raw line does not. Cursor (Grok 4.7) wrote the collection, the choice, and the synthetic tests.

**Result:** The local tests cover the one reply, a silence, and the deletion of the raw lines. The server service was restarted on 17 November 2026 so it can hold the letters. The reply itself waits for the daily run, and a live reply was not watched from here.

## 2026-11-16 — The Forge welcome, in Eldgrim's name

The earlier reminder left the Forge under the old bot name, and people could not tell who was asking. The account now speaks as Eldgrim. The new message welcomes them, asks them to finish the Forge so the Discord opens again, and tells them the three small things it needs: the hearth rules, Roar or Amberhearth, and a little about the character they bring. Cursor (Grok 4.7) sent it through the bot to every member who had not finished.

**Result:** 67 direct messages were sent. None were blocked by a closed inbox, and none failed. The messages themselves were not read back from Discord.

## 2026-11-16 — A quest remembered, and a private answer

Asking again while a quest was still unfinished looked like a promise of a new one, and the answer sat in the channel where everyone could see it. The reply now goes directly to the member. An unfinished quest is answered by asking them to complete it. When none is unfinished, Eldgrim says it will prepare one. Every quest given to a member stays in the local database, and the next quest does not repeat that item. When the catalog still has another kind of errand, the next one prefers that kind. The bot keeps only whether a quest is unfinished. A picture that names Eldgrim, with another member's Roar, clears that mark. Cursor (Grok 4.7) wrote the memory check, the direct reply, and the synthetic tests.

**Result:** The local tests cover the unfinished reply, the new-quest reply, and a later quest that is not a repeat. The server service was restarted with that reply on 16 November 2026. A live direct message was not watched from here.

## 2026-11-15 — The lands Eldgrim may name

A quest that sends someone across Azeroth needs the real map, and the daily word does too. ZugZugDB's zone index, read the same night, holds the outdoor lands and the cities. Its dungeon pages name some doors and leave others blank. Blizzard's note supplies the nine Forever dungeons, with their ranges and where the door is. Cursor (Grok 4.7) wrote that gazetteer and pointed the proclamation and the quest at it. Camps, caves, and unused maps stayed off, because a copied dump would teach Eldgrim to name a test island.

**Result:** The keyword call and the wake-time choice still do not carry the map. The level bands were not walked in-game, and the client build was not recorded on this read.

## 2026-11-15 — A word that the ask was heard

Waiting until the daily run left the ask looking unanswered. The channel reply is a fixed line, in Eldgrim's voice: it heard them, it will prepare a quest, and they should be patient. A cancel is answered the same way, with the current quest set aside. Cursor (Grok 4.7) added that reply and tested it with a synthetic channel. The server bot was not restarted.

**Result:** The server service was restarted on 15 November 2026, after a mention in the channel got no reply. The local test checks both the ask and the cancel. A live reply in Discord was not watched from here.

## 2026-11-14 — A quest by mention

A short mention that says quest should come back, on the daily run, as a direct message for one character. The first one is a bonfire. Later ones name a fire-themed thing that fits the character, and the proof is a picture plus someone else's Roar. Doing it adds one private point. Cancelling it does not take a point away, and it is replaced. Epic and legendary things were too hard to ask for, and the low copies from the beta goodbye event are not in the live game, so those left the catalog. A red firework rocket from Fizzlebang Booms in Tinker Town went on, because it is easy to buy. Cursor (Grok 4.7) wrote the staging, the daily message, and the catalog edits, and tested them with synthetic members. The server bot was not restarted.

**Result:** The running bot does not receive quest mentions until that restart. The local tests cover the ask, the cancel, the witness, and the private point.

## 2026-11-14 — Fire-themed things for the bonfire

A torch a person can get without gold, and then carry, raised the question of what else in Forever burns. ZugZugDB, Wowhead Forever, and the Warcraft Wiki supplied the Night Watchman's Torch: a slain Night Watch Guard in Duskwood, the quest An Unfortunate End, no coin, and a light that is carried once lit. Cursor (Grok 4.7) read ZugZugDB's Forever pages, build 1.60.1.70938, and wrote one hundred items whose source the page actually names, plus the quest flames that are given up and should not be treated as keepsakes. A private reason for the interest stays off the public page. The full list is given to the proclamation only, so a keyword call does not carry the table.

**Result:** The catalog is a reference, not an in-game check. The next proclamation can name one of these objects only when the page says where it is found.

A second list of one hundred arrived the same evening, closer to what a person can carry to a fire: campfire kits, flint, wood, and named wands. Cursor (Grok 4.7) checked those rows against ZugZugDB and added the ones the Forever page actually describes. Fiery Cloak was left out because that item number has no page. Rows with no item number stayed out.

## 2026-11-13 — Level-ups in the census

The keepers should see the guild grow, so the census now counts level-ups since the last note. Claude Code (Claude Opus 5.5) added a remembered level per character that moves forward only after the note is posted, so a failed post does not lose a level, and tested it with a synthetic guild.

**Result:** 60 agent tests pass. The first posted note sets the baseline; the one after shows the gains.

## 2026-11-13 — It knows the people of Amberhearth

Eldgrim should know itself and the people of the fellowship. Every call now reads the guild's characters with their class, rank and professions, right after its self. The choices I made were that it may name anyone kindly, that opted-out members stay listed, and that declared characters sit under the member's Discord name. Claude Code (Claude Opus 5.5) built the block and tested drafts without posting. The first drafts named the first person on the list twice and invented her deeds, so Claude Code shuffled the order each run and limited what may be said about a named member to the list itself.

**Result:** 58 agent tests pass. With the narrower rule, five drafts named no one and invented nothing about a member.

## 2026-11-13 — The new reading goes live

Two blind rounds of ten proclamations each settled it. The full rulebook wrote the same sentence again and again, while the narrower reading varied and sounded more like the character. The first round also invented a traveler's find, so the closing instruction now forbids news that is not in the brief or the pages, while a story may still imagine. After reading both rounds, the switch had my approval. Claude Code (Claude Opus 5.5) ran the comparisons, pointed the three live calls at the loader, removed the old reading, recorded which pages each call reads in the run log, and tested a real call of each kind without posting.

**Result:** 54 agent tests pass. The proclamation prompt is about 8,700 tokens instead of 38,000. The comparison command now compares two local models on the same reading.

## 2026-11-13 — A self it carries into every call

The full rulebook was crowding the personality out of a small model. The approved core, a short account of what Eldgrim can do today, and a page list for each task are now written down. The live run still reads the whole rulebook. A blind comparison has to be accepted before that changes. The guild brief is kept in one file that the next run replaces, and a check that does not fit still names a next morning so the computer keeps waking.

**Result:** The loader and the comparison command are in place. The Saturday run is unchanged.

## 2026-11-13 — The last pages come in

The lines still marked open were the policy questions, and those questions are answered. Eldgrim now reads the remaining chapters, the consistency audit, and the implementation matrix with the rest. The confirmed order of what matters stays above the older proposed order. A power the pages say is not yet in force stays out of reach.

**Result:** The announcement runner reads the whole rulebook.

## 2026-11-13 — The whole character, before it speaks

The first announcements read four pages, because the rest of the rules were still being written. The questions are answered now. A run that speaks for the guild reads the character, the lore, the interaction principles, the governance chapters through the known conflicts, and every confirmed answer. The private roots stay on this computer. They are known, and they are not said.

**Result:** The announcement runner reads that set. Chapter 15 stays out until it is ratified.

## 2026-11-13 — The guild comes first

The people in the game are the guild. Waiting until they open Discord left most of them out, including members who will never use it. A character in the guild is now a member from the start. Discord connects a name to that member when they use the Forge. The notes stay. The raw lines do not.

**Result:** In-game characters are registered. A later Forge registration attaches to the member who is already there.

## 2026-11-13 — Governance reconciliation

AI assistance compared the public working rulebook and ROARguild charter, wrote operating defaults, and identified the deployment evidence still required.

## 2026-11-13 — Giving the repository clear permissions

Public source alone did not explain what others could reuse, so I approved MIT for the agent, bot and addon code while reserving the Eldgrim character identity. AI assistance added the license and brought the project notes into agreement, without changing how the application runs. Other people's content retains its own terms.

## 2026-11-12 — A roster of its own

The guild needed a memory that lives on this computer. A run now opens that database first, copies the Forge, and reads the guild-chat file as it sits. Someone who spoke gets one keyword for the whole day and a private point: one for being there, one more when the keyword is positive, and two off when it is negative. Keepers and wardens get one short note about the ranks. The note recommends. It does not move anyone.

**Result:** The database, the Forge export, and the daily note are in place. Tests cover an empty file, a second pass over the same lines, an unlinked character, and a note that does not print the score.

## 2026-11-11 — Testing for real, and sleeping again

Test runs have to post; otherwise there is nothing to test. A review then found weak spots around posting and waking. The model's text could have pinged everyone, the wake script that root ran was a file my own account could change, and the audit note claimed my approval even for runs I never saw. AI made mentions inert on both sides, gave each post an honest note, and recorded when a post's outcome is unclear so it is never sent twice. It also rebuilt the wake path on what worked for Anskar: root holds sleep off and starts the run as me, a small root-owned helper sets the next timer, and after a timer wake the computer goes back to sleep unless something else is keeping it up.

**Result:** 13 agent tests and 68 bot tests pass. The wake path waits for one sudo install, and the bot change waits for a deploy.

## 2026-11-11 — The announcement reaches the guild

The line Eldgrim kept deserved to be said in the guild, not only saved on this computer. The bot places the finished words in the announcements channel. The writing still happens here.

**Result:** Posted the 03:05 announcement. Later runs post the one they keep.

## 2026-11-11 — A time Eldgrim chooses

Eldgrim should not speak at the same hour every day. At the end of a run it picks one moment on the next day, and the computer wakes for that moment the way Anskar's noon run wakes it, then goes back to sleep on its own. For now a run can be asked for whenever it is needed. The announcement is written here and is not posted.

**Result:** The runner is in place. qwen3:8b chose a real moment on the next day. The first tries only repeated the motto and were rejected after that; a later run wrote a short hearth line and did not post it. The wake timer still needs root once before it can wake the machine.

## 2026-11-11 — Roots before a face

Eldgrim has to know where it stands before it tells any further story. The world is World of Warcraft Forever, and the people are on Azeroth. The rest of its roots is written on this computer and kept out of the public pages. Look, sound, and presence are not decided. Those are for Eldgrim to draft from the roots when the first runs begin, and they wait for acceptance before they count.

**Result:** The origin is in ~/.local/share/eldgrim/private/ORIGIN.md. Nothing was posted. No face was invented.

## 2026-11-11 — The guild chat file, then a clean slate

The guild chat archive on this computer is the record Eldgrim should read. It is already grouped by the character who spoke. Eldgrim turns those messages into keywords, checks them against what it already keeps, and notices whether the person is the same or whether something new was actually said. A plus or a minus has to follow the standing rules already written down, and it stays private. Afterwards the messages are cleared, so the addon can fill the file again the next time the game is played. The clear waits until the game is closed, because the client would otherwise write the old lines back. The same save can also carry a roster snapshot. That snapshot, not the chat, is how Eldgrim tells who is still in the guild.

**Result:** Specified in agent/ROSTER.md. The file was not emptied, and no database was built.

## 2026-11-11 — Connect character decisions to the final agent draft

Eldgrim now has a recognizable text-roleplay closing, and the character decisions should reach whoever prepares the final agent instructions. AI updated the voice guide and drafting references, keeping concealed material out of the public pages.

**Result:** Documentation only; no runtime prompt loading or deployment was performed.

## 2026-11-11 — The roster before Eldgrim acts

Before Eldgrim writes to the guild or acts on its own, I want the way it knows the guild written down. It lives on my computer. Anyone who comes through the Forge or the addon gets an entry. When sentences come back about that person, Eldgrim turns them into keywords and keeps the keywords, not the sentences. That roster is the overview it uses to be itself. A little lore can still be added. The announcement waits until the roster is real.

**Result:** Specified in agent/ROSTER.md. No database and no announcement have been built.

## 2026-11-10 — Roar and Amberhearth in the Forge

Some people on the Discord belong to Roar, and some belong to Amberhearth. At my request, the Forge now asks for that choice after the rules and before the characters. Roar members keep the Roar role as well as Ember. Amberhearth members receive a new Amberhearth role and Ember. AI found that the Roar role had been given automatically to anyone with a guild rank, which would have erased the difference, and retired that automatic assignment.

**Result:** The choice is live. The Amberhearth role exists. Members who already finished are unchanged until they run the Forge again.

## 2026-11-10 — Finish the rulebook interview (Q191–193)

With the last three answers accepted, all 193 governance questions are complete. The final decisions require us to compare the answers with the sixteen chapters and the separate guild charter, preserve corrections instead of resurrecting old proposals, and track which rules are only written versus actually built and tested. The result is a working baseline, not a ratified guild charter or permission to switch on autonomous administration. AI recorded the final answers, created a consistency audit and implementation matrix, and updated the chapter index, documentation guide and contributor instructions.

**Result:** Interview complete and documentation committed. The audit is an initial documentation comparison, not a full cross-repository charter or runtime audit. No new feature was implemented, tested, deployed or ratified.

## 2026-11-10 — Define how Eldgrim can be stopped and safely recovered (Q181–190)

The latest ten decisions specify an emergency stop I can use, or delegate to an explicitly authorized technical custodian, without exposing the local memory database. It must halt new automated actions and stay off until authorized recovery. Server credentials remain separate from my PC-local memories, and tool permissions must be enforced by code rather than model instructions. Every administrative tool needs negative tests and failure/retry checks before a reversible rollout. Backup recovery must respect the approved retention and deletion rules. When my PC or AI is offline, the server bot continues only its verified functions; compromise triggers containment and review. Periodic technical and governance checks cannot change the charter by themselves. AI synchronized the question register, technical governance chapter, conflict inventory, agent security/memory guidance, bot documentation and development records.

**Result:** Q181–190 documented as founder-confirmed working requirements. No emergency stop, tool executor, autonomous administration, verified restore, custodian appointment, security test or deployment approval was performed.

## 2026-11-10 — Complete the appeal and evidence rules (Q171–180)

The next ten decisions give members a private way to challenge sanctions, even after leaving the Discord server, without an absolute expiry. Seven days to acknowledge and fourteen to decide are operational targets, not invented guarantees. Discipline needs reliable evidence; uncertain character identity, standing and rumors are not proof. Temporary restrictions protect against present risk rather than pronounce guilt, and unresolved accusations remain unproven. Founder-related appeals require an impartial human reviewer without exposing the local narrative-memory database. Case records remain purpose-limited, subject to existing audit retention, and never become a permanent guild-chat archive. AI synchronized the question register, moderation, privacy, conflicts, agent and bot design, and development documentation.

**Result:** Q171–180 documented as founder-confirmed working policy. No appeal system, reviewer appointment, evidence vault, retention job or automated sanction was implemented or tested.

## 2026-11-10 — Define the adoption and activation gate (Q161–170)

The next ten answers distinguish the act of documenting rules from making them binding. A charter needs an identified approved version, effective date and member access; future amendments must be traceable and announced. No retroactive discipline or policing of unrelated private lives is allowed, and members remain free to suggest changes. Human duties can be delegated without turning recognition ranks into command positions or exposing the local memory database. Before Eldgrim can administer Discord autonomously, its tools, safeguards, appeals and emergency stop must be verified and deployment explicitly authorized. AI synchronized the question register, governance chapters, agent/bot guidance and development records.

**Result:** Q161–170 recorded as working governance. No charter ratification, new deployment approval, autonomous administration, safeguard test or bot integration was performed.

## 2026-11-10 — Clarify conflicts and correction (Q151–160)

The latest ten answers establish how Eldgrim handles rules that disagree, especially the separate guild charter, mandatory platform requirements and my own informal instructions. The written rules remain authoritative unless an explicit founder decision amends them. A complaint involving me needs an impartial human reviewer, without giving that reviewer direct access to the local memory database. Members may hold their own events; friendships and ranks cannot alter disciplinary fairness. Eldgrim must verify uncertain character identities and correct memories when better evidence appears. AI recorded the decisions across the governance register, chapters on authority, conflicts, hierarchy, documents, membership, Sunday gatherings, moderation, memory and contributor guidance.

**Result:** Q151–160 documented as working governance. No charter ratification, reviewer system, identity matching or local memory correction feature was implemented or tested.

## 2026-11-10 — Bound Eldgrim's technical authority (Q141–150)

The next ten decisions establish how Eldgrim may act without receiving unrestricted control of my computer or Discord. Authorized channel, role and permission changes should eventually be autonomous through independently checked tools, while exceptional infrastructure actions still require my explicit approval. Failed or ambiguous actions must not duplicate sanctions or rewards, and guild messages cannot command the system. The bot's present approval workflow remains until a validated replacement is built. AI synchronized the governance register, technical chapter, agent security, architecture, operations and bot instructions.

**Result:** Q141–150 recorded as founder-confirmed working policy. Documentation only; no live agent, new autonomous bot actions, audit executor or purge mechanism was implemented or tested.

## 2026-11-10 — Keep Eldgrim's lasting memories on my PC

This answer settles where Eldgrim's character observations come from: conversations already shared in guild chat or designated Discord guild channels, not private exchanges. The server bot and the game addon may collect raw material temporarily, but after my local AI selects what is worth remembering, the raw messages are discarded. The selected interpretations belong in a database on my PC, accessible directly only to me and the local AI, not other guild custodians. The server bot's existing registration and administrative state is a separate operational necessity, not Eldgrim's narrative-memory archive. AI updated the governance and architecture documents to retire the old combined server-memory proposal.

**Result:** Q138 confirmed and documented. No new Discord observation permissions, synchronization, deletion, local database or AI processing feature was implemented or tested.

## 2026-11-10 — Define privacy lifecycle, hold record access for revision

Nine privacy decisions were approved, covering clear member notices, optional personalization, in-game data processing, temporary raw-chat handling, interpreted-memory retention, audit records, backups, private data requests and breach response. Q138, about who can inspect private records, was marked for revision rather than accepted. AI synchronized the governance register and privacy chapter without assuming the disputed access model.

**Result:** Governance documentation committed. No bot, agent, addon, database, deletion job, consent flow or security incident process was implemented or tested.

## 2026-11-10 — Bank reserves and member-data boundaries (Q121–130)

Ten more governance decisions are approved. Bank reservations and valuable transfers now require documented limits and human verification; disputed allocations have a review path. Eldgrim's observation scope excludes unrelated private conversations and restricts memory to relevant, supported impressions. Raw chat and temporary mention collections must not become hidden permanent archives, and members have private correction and departure-related deletion processes to be developed. AI synchronized the relevant governance chapters and decision register.

**Result:** Documentation committed to GitHub. No bot, agent, addon, data purge or legal-compliance procedure was implemented or tested.

## 2026-11-10 — Confirm Sunday gathering and bank custody principles (Q111–120)

Ten decisions now describe Eldgrim's Sunday invitations and regional themes, voluntary bonfires, simultaneous gatherings, accessibility and attendance neutrality. Guild-bank rules now distinguish freely offered contributions, authorized human custodians, verified inventory snapshots and confirmed deliveries from merely announced allocations. AI revised the corresponding governance chapters and decision register.

**Result:** Documentation committed to GitHub. No agent, bot, addon or in-game bank operation was changed or tested.

## 2026-11-10 — Establish the quest rules (Q101–110)

Ten governance answers now set the purpose, frequency, consent, suitability, evidence, witness eligibility, completion handling, deadlines and reward boundaries for Eldgrim's quests. AI integrated them into the governance register and rewrote the quest chapter to remove the outdated assumption that higher rank alone authorizes verification.

**Result:** Documentation committed to GitHub. No Discord quest workflow, local AI behavior or addon integration was implemented or tested.

## 2026-11-10 — Replace the offline-question queue with a temporary collection

The proposed waiting queue for questions addressed to Eldgrim is not what I want. Members should be able to mention it freely. The bot or the local AI's collection round gathers these messages temporarily; Eldgrim then chooses up to one question per person, by chance or according to what suits the character's story. The collection is discarded after the run. AI reconciled this with the previously recorded daily question limit and revised the governance, agent and bot design documents.

**Result:** Approved Q100 and synchronized public documentation. No collection system, local AI or retention behavior was implemented or tested.

## 2026-11-10 — Preserve confirmed questions 81–90

Ten more governance decisions now have my approval, covering reinstatement, Forge requirements, member-owned character records, the initial rank migration and the once-daily local AI session. AI updated the numbered question register, relevant governance chapters and decision history, preserving the distinction between existing Forge features and intended future workflows.

**Result:** Governance documentation committed to GitHub. No bot, agent or addon source was changed or tested.

## 2026-11-10 — Clarify Q64 internal standing confidentiality

On Q64, my answer is that Eldgrim's standing and member-personalization context are internal, not a high score, ranking or member-facing profile. AI recorded the confirmed revision in the question register and relevant governance chapters, distinguishing confidential creative context from appeals of consequential decisions and applicable data rights.

**Result:** Documentation only. No bot, agent or addon implementation or tests.

## 2026-11-10 — A daily word from Eldgrim

Replies to mentions can wait. What I want first is Eldgrim speaking to the guild once a day, a story or a small announcement, in its own voice. The governance chapters are still being written, so the first version reads only the pages that are already solid, and it reads them again each day so a later edit is picked up. The writing happens on my computer, because that is where the model runs. The bot on the server only posts the finished words.

**Result:** Specified, not scheduled, and not posting. The announcements channel is already visible to the ranks and hidden from members who have not finished the Forge.

## 2026-11-10 — Preserving confirmed governance answers

To protect the question-by-question rule review from conversation limits, I asked AI to document every approved answer through question 62 in GitHub. AI updated the affected governance chapters and introduced a numbered decision register, including the correction allowing Eldgrim to manage Discord channels independently. Private character details were deliberately kept out of the public repository.

**Result:** Governance documentation committed. No bot, agent or game addon source changed or tested.

## 2026-11-10 — Preparing Eldgrim's governance chapters

To work through Eldgrim's constitution chapter by chapter, I asked AI to put the consolidated guild rules and governance framework into the Eldgrim repository as separate Markdown documents. AI organized the sixteen chapters into governance/, added individual refinement queues, linked the rulebook from project documentation, and kept private character canon out of the public files. It also aligned the Forge status with the confirmed live deployment instead of preserving the earlier offline-only description.

**Result:** The working rulebook is in GitHub as documentation; no new governance rules were ratified and no autonomous administration was implemented or tested.

## 2026-11-10 — Approving the Forge and the rank reset

Reviewing AI's drafts, I corrected three things: Eldgrim is an entity and must never be called "he"; the notice covers all guild activity recorded in the game, including emotes and presence at events; and the Forge must make clear that race and class are being asked. Beyond that, I decided that everyone except me restarts at Ember, with Eldgrim deciding promotions afterwards.

AI made the corrections and built the reset into the switch that holds back ranks. It removes ranks only from members who never completed the Forge, so a later promotion cannot be undone by accident, and records former ranks first. Deploying, AI found that its own copy step had left the files unreadable for the service account; the bot was offline for about seven minutes until AI fixed the permissions and wrote a safer update script.

Some members bring characters from other versions of World of Warcraft, so a single name has to be allowed as well as a first name and a surname. Everyone who has not registered should also hear from Eldgrim. AI posted that call in the Forge, then sent the same call as a direct message to each of them.

Testing the Forge myself, I found it rejected a full character name: WoW Forever gives every character a first name and a surname, and AI had built the check for a single name. AI verified the naming rules from Blizzard's announcement and a rules guide, then split the question into first name and surname with the same limits the game uses.

After testing the Forge, I approved both switches. AI hid the five public channels behind the ranks, then removed every rank except mine. A dice bot kept its ranks, since a bot cannot complete the Forge.

**Result:** The Forge is live. A character may have one name or two, and Eldgrim has called the 73 members who have not registered. They see only the Forge until they finish, and finishing grants Ember.

## 2026-11-10 — Building the multi-character Forge

With the bot renamed to Eldgrim and given its new image, I asked AI to build the multi-character onboarding. Every newcomer should see only the Forge, accept the hearth rules, name every character they bring, and become an Ember on completion. Existing members pass through it too; only I as server owner am exempt.

AI checked the live permission layout and found that Discord cannot hide channels a role grants explicitly, so Ember now follows completion instead of arrival, and the five public channels will move to the ranks. A test also showed that hiding a channel from everyone would hide it from ranks relying on server-wide access, so every rank receives the former public access explicitly. AI rewrote the Forge, drafted the hearth rules and Eldgrim's texts, and replaced the old rank names in the bot.

**Result:** Built and tested offline (61 tests). Not deployed; the texts await my approval, and the switches that hold back Ember and hide the public channels stay off until I approve them.

## 2026-11-10 — Moving the bot to the server

To keep the bot online at all times, I approved moving it to my existing server under its own account. AI wrote the setup script, staged the code and configuration, stopped the desktop service, and transferred the bot's database; I ran the script with my server password. Two problems surfaced and AI fixed both: the service account could not read the Python environment, and the bot's token check rejected the file permissions systemd uses for system services.

When publishing these notes, AI found the local-agent documentation from 2026-11-09 on GitHub and merged it. Both designs agree that Eldgrim answers once a day and only to @Eldgrim. Afterwards, I decided how they fit together: the server bot stays always online for onboarding, administration, and data, while the agent on my PC becomes Eldgrim's daily voice. The agent may also trigger administration through the bot and use the addon's archive.

**Result:** The bot runs on the server and its Discord connection was confirmed. Behavior is unchanged; it is not yet renamed.

## 2026-11-10 — Bringing Eldgrim to Discord

Eldgrim should be present where the guild gathers outside the game. Rather than starting a new bot, I decided to rename and expand the existing guild Discord bot, which already runs the Character Forge, and to move it to a server so it is always online. Its first new task is to ask newcomers which characters they play in the guild before opening the server to them. Eldgrim will speak only once a day, and only to those who call on it with @Eldgrim.

AI inspected the existing bot and the installed addon. The addon's saved archive held 79 guild messages from 8 characters but no character details, so profile enrichment does not yet work in-game. AI recorded the direction, data flow, and open questions under bot/, copied the existing bot's source into its own local git repository, backed up its configuration, state, and service file, and confirmed that the 51 existing unit tests pass on the copy.

**Result:** Direction documented and bot source under version control.

## 2026-11-09 — Documenting the local agent architecture

With Eldgrim's technical direction expanding beyond the passive addon, I asked AI to research and document a local agent that would act once per day while remaining autonomous within clear boundaries. The design separates Discord communication from local model inference: a systemd user timer starts a one-shot Python process, the process polls configured Discord channels through the HTTP API, local Ollama performs bounded reasoning and tool calls, and SQLite holds private runtime memory outside the repository.

AI checked the design against the current official Discord, Ollama, Python, and systemd documentation. The initial communication scope is limited to explicit mentions, without requesting Discord's privileged Message Content Intent. The documentation also records that REST polling still exposes message metadata for the selected channels, so unrelated messages must not be archived or sent to the model.

The agent remains independent of the Forever addon and of Eldgrim's public character canon. Proactive channel posts are documented as an opt-in capability rather than a default behavior.

**Result:** Added the agent architecture, specification, security, memory, and operations documentation; updated the repository map, instructions, concept, roadmap, decisions, and changelog. This was a documentation change only. No Python agent, Discord integration, SQLite runtime database, systemd unit, or deployment was created or tested.

## 2026-11-08 — First recorder implementation

With the first milestone settled, I asked AI to implement the Forever-only event recorder and its TOC manifest inside the existing addon/ area. The code registers only CHAT_MSG_GUILD, checks chat-messaging lockdown before reading the event payload, and accepts community author data only when the returned record is a guild message whose content and author exactly match the current event.

The archive stores character-facing names and values only, alongside timestamped message text. Community identifiers are kept transiently for correlation and are never written to SavedVariables. When a community record cannot be matched, the message uses local receipt time and is saved without unverified profile enrichment.

AI added a repeatable mocked test harness. Lua syntax validation and the mock behavior suite passed with texlua. These checks exercise local logic only; live Forever event correlation, profile data, SavedVariables persistence, and in-game behavior have not been verified.

**Result:** Initial addon source, TOC manifest, and mock tests committed. No public release was created.

## 2026-11-08 — Defining the first addon milestone

After narrowing the addon's first responsibility to passive local guild-chat recording, I approved a dedicated technical area inside this repository while keeping it separate from Eldgrim's in-world character material and Amberhearth's guild operations. The initial archive is limited to character names, available human-readable character details, message text, and timestamps. It has no in-game interface or interaction.

AI reviewed the repository instructions and documentation, researched the Forever-specific chat and character APIs, and recorded both the available data and the unresolved runtime questions. The current research baseline is Forever 1.60.1, interface 16001, with build 1.60.1.70862 as the latest public build found during this work.

**Result:** Addon specification, API research, data model, and test plan added. No addon source code was implemented; no syntax checks or in-game tests were run.

## 2026-11-08 — Establishing the repository foundation

With Eldgrim becoming a distinct character and narrative project, I asked AI to establish a documentation structure that could hold the character's identity, voice, lore, and developing stories without confusing them with Amberhearth's guild administration or a possible future software implementation. The existing README provided the initial direction; AI organized the supporting documents and folder structure, preserving unresolved details as open rather than inventing canon.

**Result:** Documentation structure committed to the repository. No addon, bot, or other software was implemented or verified.
