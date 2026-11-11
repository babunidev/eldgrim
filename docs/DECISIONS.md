# Decisions

A concise record of meaningful creative and structural decisions.

Entries are listed newest first.

## 2026-11-11 — Test runs post, and a timer wake ends in sleep

**Decision:** A run started by hand posts its announcement, like a scheduled run, because posting is part of what has to be tested. Posting the daily announcement does not wait for the roster; replies and administration still do. After a run that the wake timer started, the computer returns to sleep when the timer woke it and no other program holds sleep off.

**Safeguards:** Root runs only root-owned files and never Eldgrim's code; the chosen moment is read as plain data. Mentions in posted text are made inert, and the bot sends announcements with no allowed mentions. The audit note says truthfully whether the post came from the wake timer, a run started by hand, or `eldgrim post`. A post whose outcome is unclear is marked `unknown` and is not re-sent automatically.

**Status:** Code and tests in this repository; the bot change is committed in its private repository. The wake path needs a one-time `sudo agent/systemd/install-wake.sh`, and the bot change needs a deploy.

## 2026-11-11 — The bot posts the announcement Eldgrim kept

**Decision:** A finished announcement is handed to the server bot, which posts it in the announcements channel through the existing announce action. The model does not receive the bot token. The channel and server address stay in the local Discord config, outside this repository. The first posted text is the announcement written at 03:05 on 11 November 2026.

**Boundary:** The roster is still not built. Mention replies are still not answered. A later `eldgrim run` posts again, because a run now includes the post.

**Status:** Posted.

## 2026-11-11 — Eldgrim chooses its next day, and the computer wakes for it

**Decision:** Eldgrim does not act at a fixed hour. At the end of a run it chooses one moment on the next local calendar day. The application checks the moment, saves it, and puts it on a system timer with `WakeSystem=true`, following Anskar Grotzschnapf's wake. Sleep is held off only during the run. Eldgrim does not suspend the computer afterwards. A missed day is skipped. Until a proclamation is posted, a run may be started whenever the creative asks, and the announcement stays on this computer.

**Boundary:** The runner is in agent/eldgrim_agent. Arming the timer under `/etc` needs root and is not done. No announcement has been posted. The roster database is not built.

**Status:** Runner and unit templates written. Wake timer not armed.

## 2026-11-11 — Origin roots before Eldgrim drafts a presence

**Decision:** Eldgrim's world is the World of Warcraft Forever roleplaying world, and the people it reaches are on Azeroth. Eldgrim's private origin is written at `~/.local/share/eldgrim/private/ORIGIN.md` on the founder's computer. That file is internal knowledge. It is not copied into this repository and not told to the guild. Look, sound, and the way Eldgrim is present are not part of the roots. At the first runs Eldgrim may draft them, and a further story, from those roots. A draft becomes canon only when the creative accepts it.

**Boundary:** The public profile now names Azeroth, which governance chapter 02 already said. No agent is running. No presence was generated.

**Status:** Roots written locally. The first-run draft has not happened.

## 2026-11-11 — The guild chat file is read, valued, then emptied

**Decision:** Eldgrim's daily run on the founder's computer may read the Forever addon's SavedVariables guild-chat archive. The file is already grouped by character. Each character's messages are reduced to keywords and compared with the keywords already stored. What is already true stays. What is new is added. Eldgrim may then record an internal standing adjustment under the confirmed chapter 07 rules. Standing stays private, inactivity does not lower it, and the number does not by itself discipline anyone. After that database commit, and only while the Forever client is closed, the run clears the message lists and leaves the profile fields. A roster table in the same file, when newer than the last one applied, is the list of who is still in the game guild. Chat silence is not departure. Leaving the game guild does not by itself remove a Discord member.

**Boundary:** Specified in agent/ROSTER.md. The account path stays off this repository. The model gets no general file-write tool. No database, no file cleanup and no standing score have been built. The addon milestone in this repository still does not write the roster table; a client already being played may.

**Status:** Specified. Not implemented.

## 2026-11-11 — Character instructions and public closing

**Established:** The creative approved “Keep the fire.” as Eldgrim's recognizable text-roleplay parting courtesy. Additional confirmed character material is preserved separately in a private canon supplement, excluded from this public repository. Final agent-character instruction drafting must consult both sources and preserve their disclosure boundary. AI organized and recorded the decisions; no agent prompt loader or runtime behavior was implemented or tested.

**Update:** When the origin roots were written later on 2026-11-11, only the origin file was on disk; the separate supplement named here was not. agent/README.md tells the drafter to read it if it appears.

## 2026-11-11 — Eldgrim's roster comes before it acts

**Decision:** Before Eldgrim writes an announcement or acts by itself, its overview of the guild is a roster on the founder's computer. Every member who arrives through the Character Forge or the Forever addon gets an entry. Sentences about that member are read for the run, reduced to keywords, and then deleted. The keywords stay on the entry. Eldgrim reads the roster and those keywords before it speaks or decides.

**Boundary:** The roster is not a transcript and not the server's Forge database. An addon character is linked to a Discord member only by a verified registration. Uncertain matches are not merged. Lore can still be added to the pages Eldgrim reads; lore does not replace the roster.

**Status:** Specified in agent/ROSTER.md. Not implemented.

## 2026-11-10 — Roar and Amberhearth are separate fellowships in the Forge

**Decision:** After the hearth rules, and before any character, a member chooses Roar or Amberhearth. Roar receives the existing Roar role in addition to Ember. Amberhearth receives a new Amberhearth role in addition to Ember.

**Boundary:** The earlier automatic use of the Roar role, which marked every holder of a guild rank, is retired. Otherwise Amberhearth members would have received Roar on becoming Ember.

**Status:** Live on 2026-11-10.

## 2026-11-10 — Complete the 193-question governance interview (Q191–193)

**Founder decision:** All three final proposals Q191–193 were accepted without revision. The interview is complete: **193 of 193 questions confirmed**. Q191 requires checking the register, chapters and separate ROARguild charter for contradictions, duplicates, stale proposals and missing procedures, preserving the latest explicit founder decisions and documenting unresolved gaps without invention. Q192 requires traceability from approved requirements to components, dependencies, implementation, tests and deployment evidence. Q193 defines completion as a **working-governance baseline** and outstanding-work register, **not** automatic ratification of a guild charter, new binding member obligations or authorization for autonomous administration.

**Artifacts:** [numbered register](../governance/QUESTION-DECISIONS.md), [initial consistency audit](../governance/CONSISTENCY-AUDIT.md), and [implementation/verification matrix](../governance/IMPLEMENTATION-MATRIX.md). The initial audit identifies visible conflicts and gaps but is **not** a complete cross-repository charter review or live integration audit.

**Status:** All 193 interview answers confirmed and preserved. Q161 charter ratification and Q170 deployment authorization remain separate explicit founder decisions. No software feature, test, charter ratification or live deployment was performed by completing the interview.

## 2026-11-10 — Confirm emergency shutdown, technical security and recovery (Q181–190)

**Founder decision:** All ten Q181–190 proposals were accepted. The founder and expressly designated technical custodians may immediately suspend unsafe automation, without gaining constitutional amendment authority or direct access to the founder's PC-local narrative-memory database. Shutdown stops new AI posts, sanctions, rank changes, bank proposals and administrative actions, safely cancels pending work, prevents silent restart and requires authorized recovery; independently safe bot services may continue. Protect and separate credentials; revoke and rotate access as necessary. Validate Discord actions and protected permissions outside the model, and test allowed/denied inputs, retries, partial failures and recovery with synthetic/non-production data. Move from manual approval to autonomy only through an approved, verified, reversible rollout under Q170 founder authorization. Protect/test backups within Q137's routine 30-day maximum and reapply deletions after restoration. Offline bot operations stay within existing verified functions; compromise triggers isolation, Q140 response and verified recovery. Review governance and technical safeguards periodically, without silent policy amendments.

**Status:** Founder-confirmed working design requirements, not a ratified charter, appointed technical custodian, implemented emergency stop, completed tool/backup testing, autonomy rollout or deployment authorization. These requirements do not supersede the founder-only PC-local narrative-memory access boundary (Q138).

**Next:** Final questions Q191–193 of 193.

## 2026-11-10 — Confirm appeals, incident evidence and correction (Q171–180)

**Founder decision:** All ten Q171–180 proposals were accepted. Consequential sanctions can be appealed through a confidential bot/human route, including after a member is removed from Discord. No absolute appeal-expiry deadline applies; aim to acknowledge within **7 calendar days** and decide within **14 days** where operationally possible, reporting delays and missing evidence honestly. Discipline requires specific reliable evidence proportionate to severity, never rumor, inferred standing, uncertain identity or unverified AI summaries alone. Case handling retains minimal purpose-limited findings and audit metadata under Q136, without permanent raw guild-chat archives or copying private appeals into Eldgrim's founder-PC-local narrative memory. Temporary restrictions are proportionate protection, not findings of guilt. A designated impartial human reviews founder-involved disputes without direct access to local memory. Successful appeals restore feasible permissions and correct records; good-faith reporters are protected and unresolved allegations cannot justify punishment.

**Status:** Founder-confirmed working governance only. The confidential intake route, post-ban fallback, reviewer assignment, case evidence controls, deadline tracking and administrative retention/deletion remain unimplemented. Q136's ordinary 180-day audit limit is not overridden by the unlimited appeal-submission period. No new autonomous moderation or appeal system was deployed or tested.

**Next:** Q181–190 of 193.

## 2026-11-10 — Confirm charter adoption and autonomous activation requirements (Q161–170)

**Founder decision:** All ten proposals Q161–170 were accepted. A charter becomes binding only after explicit founder approval of an identified version, effective date and accessible publication; GitHub commits and drafts alone do not ratify it. The ROARguild charter governs member rights/conduct, Eldgrim's constitution its mission and delegated limits, and operating procedures the execution details. Material rule changes require notice and sometimes renewed acknowledgement. Retroactive discipline is prohibited; governance does not extend to unrelated private lives or other communities. Members may propose policy without retaliation; amendments require authenticated founder approval and version history. Founder absence does not transfer amendment powers. Human delegations are revocable and scoped, without direct access to PC-local narrative memory.

**Q170 activation gate:** Reconcile binding charter and working rules, implement and verify independent tool permissions, audit/idempotency, privacy and appeals, and emergency stop, then obtain **explicit founder authorization** before activating new autonomous administration.

**Status:** Founder-confirmed working governance only. No ROARguild charter was ratified, no effective date issued, no new bot authority deployed, and no safeguard verification or deployment authorization was performed by these documentation edits.

**Next:** Q171–180 of 193.

## 2026-11-10 — Confirm constitutional conflicts, impartiality and corrections (Q151–160)

**Founder decision:** All ten proposals for Q151–160 were accepted. A binding ROARguild charter prevails over conflicting Eldgrim-specific working guidance, while applicable mandatory law and platform rules are non-negotiable. Eldgrim may interpret ambiguity but not create permanent policy; lasting changes require explicit documented founder decisions. Founder-involved complaints and appeals go to a designated impartial human reviewer, without granting direct access to the founder's PC-local narrative memory. Friendships and rank do not change fair process; members remain free to hold overlapping events. Uncertain character identity cannot justify record merges, standing transfers or sanctions, and verified evidence overrides unsupported local memories. Genuine contradictions must be recorded and referred to the founder, with reversible safe behavior pending resolution.

**Status:** Founder-confirmed working governance, not a ratified ROARguild charter or implemented bot/agent feature. The existing ROARguild charter is a developing draft. Formal charter adoption, versioning, reviewer appointment/evidence handling and cross-repository reconciliation remain open.

**Next:** Questions 161–170 of 193.

## 2026-11-10 — Confirm technical authority, failure and evidence rules (Q141–150)

**Founder decision:** All ten proposals for Q141–150 were accepted without revision. Eldgrim may request only registered purpose-specific tools, with independent application/bot validation. Its delegated Discord channel, role and permission administration is intended to be **autonomous**, without routine founder approval, while server destruction, ownership transfer, unrelated services, infrastructure credentials and security bypass require **explicit founder authorization**. The current deployed bot's manual preview-and-approval flow is **not yet replaced**.

Guild chat, Discord messages and tool results are untrusted data, not governing instructions. Failed actions must stop safely, avoid false success claims and never create permanent raw archives or question backlogs. When the local PC is offline, the server bot retains existing onboarding/role functions and only predefined emergency actions; authorized shared-message staging remains temporary under Q138. Consequential actions require minimal audits, unique identifiers, outcome reconciliation before retry and verification of real events before taking action. Internal memory remains PC-local and founder-accessible under Q138.

**Status:** Confirmed working governance, not a ratified guild charter. No AI action executor, autonomous administration, idempotency/audit integration or failed-run purge system was implemented or tested. The exact tool allowlist, approval-path migration and technical verification remain open.

**Next:** Questions 151–160 of 193.

## 2026-11-10 — Resolve Q138: shared guild sources, founder-only local memory

**Founder revision accepted:** Eldgrim's character/community narrative memory is derived from **guild-visible material**, especially World of Warcraft Forever guild chat and designated shared Discord guild channels, **not private conversations or private-channel content**. Raw collected messages may be staged temporarily by the server bot or game addon and transferred for processing; afterward all raw staging, including server copies, is deleted. The local AI selects relevant, supported interpretations and stores them **only in a database on the founder's PC**. **Only the founder has direct human access** to this local memory database; the authorized local AI may use it. No other guild custodian or officer receives direct access.

**Distinctions:** Shared/public-to-guild source material is not a public memory database. Internal standing and inferred profiles remain confidential (Q64), and publicly posted material may still be personal data subject to Q131–137 and Q139–140. The **existing deployed server bot's necessary operational Character Forge, registration, role and administration state** remains distinct from the local Eldgrim narrative memory. Private administrative appeals, safety reports, onboarding and data requests are not imported as narrative memories.

**Superseded:** The unapproved Q138 human-custodian access scheme and earlier proposals for a **persistent server-hosted combined Eldgrim narrative-memory database**. The existing live bot's operational database is not declared deleted or migrated.

**Implementation boundary:** This is a founder-confirmed design decision. Raw shared-channel collection may require additional Discord permissions and lawful notices; secure transport, raw-data deletion, addon archive cleanup, local AI/database integration and access controls remain unimplemented or unverified.

**Next:** Questions 141–150 of 193.

## 2026-11-10 — Confirm privacy governance Q131–137, Q139–140; hold Q138 for revision

**Confirmed:** Members receive a clear pre-onboarding data notice and advance notice of material collection changes. Optional narrative profiling may be declined without loss of ordinary guild rights. In-game observation/import requires disclosed scope and a legally valid processing basis; no silent extension to whispers, private channels or unrelated players. Imported raw guild-chat records are deleted after authorized analysis, with a separately designed deletion process for local addon archives and no permanent server transcript archive. Relevant interpreted memories are periodically reviewed and eligible personal memories deleted/anonymized within **30 days after departure** absent specific legitimate retention needs. Ordinary administrative audits are retained up to **180 days**, with documented exceptions. Routine backups last no more than **30 days**, and restored copies must reapply deletion records. Members may submit private personal-data requests through an authorized human, with proportional verification and applicable legal deadlines. Breaches require containment, evidence preservation, risk assessment, legally required notification and corrective action.

**Not confirmed:** Q138, access to private records, was marked for revision. The proposed list of authorized components/custodians and specific access rules is not approved. Other confirmed confidentiality boundaries still apply.

**Boundary:** Founder-confirmed working governance, not a ratified charter or legal compliance certification. No retention, deletion, consent, backup or incident-response implementation was changed or tested.

**Next:** Resolve Q138; then Q141–150 of 193.

## 2026-11-10 — Confirm bank reservations and privacy boundaries (Q121–130)

**Bank:** Eldgrim may designate documented reserves visible to custodians and must not double-allocate items. Unusually valuable, scarce or restricted items require an authorized human custodian to verify availability and legitimacy before transfer; that is not an unlimited veto on routine creativity. Members may dispute allocations without standing penalties; explain criteria without exposing private profiles, allow human review, and correct proven errors.

**Observation:** Eldgrim's Discord observation is confined to designated guild channels, intentionally addressed messages and necessary administrative/onboarding interactions. The bot's predefined moderation scope does not create unrestricted personal memory access. Private member conversations outside the bot's legitimate participation are off limits; DMs to the bot are purpose-limited. Raw addon guild chat may inform authorized analysis but long-term memories favor interpreted information; a deletion procedure is required before production integration. Temporary @Eldgrim mentions are purged after the processing run, including unselected questions, with only non-content audit metadata where justified. Personal impressions must be relevant, reasonably supported, non-sensitive and confidential. Members can request correction and, upon leaving, eligible deletion through private channels; justified retention requires a policy still to be written.

**Boundary:** Founder-confirmed working governance, not a ratified charter or implemented privacy/data processing system. Existing addon SavedVariables do not yet prove a deletion lifecycle; exact retention, request handling and backup controls remain open.

**Next:** Questions 131–140 of 193.

## 2026-11-10 — Confirm Sunday gathering and bank stewardship rules (Q111–120)

**Confirmed:** Eldgrim selects an Alliance region and optional Sunday theme, publishes an invitation specifying region, date, start time with timezone and useful meeting details. Members voluntarily select and light fire sites, including multiple simultaneous fires; witnesses may document verified moments, but attendees never owe attendance evidence. Alternative participation or absence carries no penalty, and Eldgrim must consider accessibility.

**Bank:** Donations are voluntary and unrelated to rank, standing or membership. Only explicitly authorized custodians with real in-game permissions may withdraw/distribute resources, independent of social rank. Eldgrim consults verified inventory snapshots without assuming live availability. Completed transfers are confirmed by custodians with item, quantity, recipient and date; a bot-side record is intended. Failed allocations are paused/cancelled, records corrected and recipients informed, with no automatic blame.

**Boundary:** Founder-confirmed working governance, not the ratified ROARguild charter. No AI event scheduling, addon bank snapshot, automated confirmation or allocation workflow was implemented or tested.

**Next:** Questions 121–130 of 193.

## 2026-11-10 — Confirm quest design, verification and rewards (Q101–110)

**Confirmed:** Eldgrim's voluntary quests encourage exploration, companionship, discovery and storytelling, especially around roads and fires; they must not become farming or progression demands. Normally one assignment decision per AI session may involve multiple members. Quests require consent, character-appropriate challenges and no penalties for declining or abandoning them. Completion normally requires a screenshot and an eligible witness, confirmed by a designated Discord interaction and reviewed by Eldgrim; rank alone does not make someone a verifier. Missing or disputed evidence remains unverified pending clarification or an authorized alternative, without treating an honest mistake as misconduct. Narrative deadlines are optional and nonpunitive. Eldgrim may combine creative rewards, but valuable resources and administrative permissions require separate safeguards.

**Boundary:** Founder-confirmed working governance only; no quest-verification workflow or AI agent was implemented or tested. The rulebook is not the ratified ROARguild charter.

**Next:** Questions 111–120 of 193.

## 2026-11-10 — Resolve Q100: unlimited mentions, temporary collection, no queue

**Founder revision accepted:** Members may mention @Eldgrim without a submission limit. Mentions are gathered temporarily either by the always-online server bot or by the local agent querying the bot during its daily collection round; the mechanism remains to be selected. Eldgrim chooses up to one question per member from the collection, at random or for narrative suitability, and may remain silent. After the run, discard the collected messages and begin a fresh collection; unselected messages are not queued or rolled forward.

**Supersedes:** Q92's one-submission-per-UTC-day interpretation and midnight UTC reset; Q95's suggestion that submitting one question consumes an allowance. The operative constraint is at most one selected question per member **per daily AI run**. Q93's ability to decline does not imply a waiting queue. Distinguish the transient mention collection from separately approved persistent memories.

**Boundary:** Approved design only; no message collector, storage lifecycle, AI selection or privacy handling was implemented or tested.

**Next:** Questions 101–110 of 193.

## 2026-11-10 — Confirm daily interaction rules (Q91–99); hold Q100 for revision

**Confirmed:** One daily local-AI session may answer multiple members. Each member has one eligible @Eldgrim question per UTC day (00:00 UTC reset); unprocessed questions do not consume the allowance. Eldgrim may decline or postpone responses without penalizing members, but must explain real administrative restrictions and privacy decisions. Related subquestions count as one submission; ordinary chat, onboarding, safety reports and appeals do not. Unprompted casual private conversation is disallowed, with necessary operational exceptions. One public proclamation is expected per successful session and does not consume individual allowances. Routine governance permits one logged decision per category per session, with urgent safety exceptions.

**Not confirmed:** The founder marked **Q100 (offline mentions/questions)** for revision. Do not treat the original proposed queue-and-skip behavior as approved.

**Boundary:** Governance documentation only; no runtime quota or AI functionality was implemented or tested.

**Next:** Clarify Q100; then proceed with Q101–110.

## 2026-11-10 — Confirm return, Forge membership and daily AI cadence (Q81–90)

**Confirmed:** A banned member may return only after a successful appeal or documented founder/impartial-reviewer decision establishing that the original risk is addressed. Newcomers must be 18+, accept conduct and Discord rules, and acknowledge disclosed data practices. The Forge requires a Discord account and at least one character's name, faction, race and class, not real-world identity or biography. Character count has no guild limit; the 50-entry Forge guard is technical. Ownership is self-declared unless verification is needed; no account credentials may be demanded. Members may edit/retire characters; a character's departure does not end the player's membership or shared standing. The initial Ember reset stands, but later registration must not erase earned rank. Refusing Forge incurs no penalty.

**Daily cadence:** The local AI agent is designed for one scheduled session per day when its host is online, while the server bot continues onboarding, authorized predefined administration and emergency safeguards.

**Boundary:** Confirmed governance, not a claim that character-edit workflows, ownership verification, AI-directed rank changes or daily local AI have been implemented. Privacy retention and technical details remain open.

**Next:** Question 91 of 193; ten questions per batch.

## 2026-11-10 — Confirm disciplinary appeals and correction (Q78–80)

**Confirmed:** Members may privately appeal consequential disciplinary decisions, even after leaving the server, with the rule-based reason, an opportunity to present evidence and protection from retaliation. Eldgrim may reconsider first; members may escalate to the founder, or a designated impartial human reviewer when the founder is involved. Incorrect sanctions must be reversed or reduced, lost privileges restored when possible, records corrected and the member informed, without exposing internal standing scores or private profiles.

**Boundary:** The appeal channel, deadlines and technical procedures are not yet defined. These are approved working governance rules, not live AI enforcement.

**Interview procedure:** Subsequent questions are presented **10 at a time**, as requested by the founder.

**Next:** Question 81 of 193.

## 2026-11-10 — Confirm individual responsibility, intent and no random discipline (Q75–77)

**Confirmed:** The founder approved individual evaluation in multi-member incidents, with no collective punishment and clear distinctions between aggressors, participants, witnesses and defenders. Eldgrim must distinguish honest mistakes, jokes and deliberate harm using context, intent, impact and responses to correction; a joke label does not excuse harassment. Chance must never determine guilt, sanctions, appeals or member rights, though it may be used for harmless storytelling.

**Boundary:** These are working governance decisions, not implemented AI moderation. Formal appeal procedures and evidentiary thresholds remain open.

**Next:** Question 78 of 193.

## 2026-11-10 — Confirm permanent removal, urgent intervention and offline safeguards (Q72–74)

**Confirmed:** The founder accepted all three proposed answers. Permanent bans require severe or repeated harmful misconduct, reliable evidence, documented reasons and appeal; inactivity, disagreement or low standing never suffice. Credible urgent threats allow proportionate immediate intervention with subsequent review. While Eldgrim's local AI is offline, the always-online bot may perform predefined authorized emergency protections and designated custodians may intervene; complex judgments await the next agent session.

**Boundary:** These are approved governance decisions only. They do not demonstrate that bot emergency protections or AI moderation are implemented. Exact appeals and operational safeguards remain open.

**Next:** Question 75 of 193.

## 2026-11-10 — Confirm impartial testimony, disciplinary actions and warnings (Q69–71)

**Confirmed:** Eldgrim considers conflicting testimony impartially, seeks independent evidence, and does not presume higher-standing members more credible; unresolved allegations cannot justify punishment. Warning, demotion, timeout, kick and ban have distinct consequences and require documented reasons. Minor and moderate offenses ordinarily receive a warning and chance to correct behavior; serious and critical offenses may warrant immediate stronger action, with proportionality preserved.

**Boundary:** These are founder-confirmed working governance rules, not evidence of live AI enforcement. Detailed evidence thresholds, appeal procedures and reinstatement remain open.

**Next:** Question 72 of 193.

## 2026-11-10 — Confirm disciplinary responses, timeout durations and hearings (Q66–68)

**Confirmed:** The creative accepted all three proposals. Eldgrim uses proportionate graduated consequences for minor, moderate, serious and critical violations, with no automatic sanction based solely on a severity label. Short, medium and long timeouts are **1 hour, 24 hours and 7 days** respectively; permanent exclusion is a distinct ban. Eldgrim hears those involved and reviews evidence whenever possible; immediate protective intervention for credible threats must be reviewed afterward. Randomness cannot determine guilt or sanctions.

**Boundary:** These are approved working-governance decisions. Evidence standards, conflicting testimony, appeals and technical enforcement remain unresolved. No bot/agent implementation or testing occurred.

**Next:** Question 69 of 193.

## 2026-11-10 — Q64: Standing and personalization are internal

**Confirmed revision:** The creative rejected the idea of a member-visible or member-reviewable standing system. Standing is Eldgrim's internal assessment, like a person's private impressions of friends, **not a high score or ranking**. Members are not routinely shown their standing, inferred profile, or internal information used to personalize Eldgrim's content. No score-inspection or score-appeal feature is approved.

**Boundary:** Existing rights to explanations and appeals of consequential guild decisions remain. Applicable legal rights over personal data must still be handled by an authorized process, without exposing other members' data. This changes documentation only; no member-facing data interface or scoring engine is implemented.

**Next:** Question 66 of 193.

## 2026-11-10 — Standing and severity decisions Q63 and Q65

**Confirmed:** Q63 permits standing to inform promotions and rewards, but not discipline by score alone. A rule violation must be independently established. Q65 defines minor, moderate, serious and critical misconduct using intent, context, evidence and harm, without assigning automatic sanctions.

**Open:** Q64 was marked **needs revision**. The suggested private review and founder escalation procedure is not approved. No alternative has been decided.

**Documentation:** [Question register](../governance/QUESTION-DECISIONS.md), standing chapter and moderation chapter updated. No bot/agent behavior changed.

## 2026-11-10 — One daily proclamation comes before replies

**Decision:** Eldgrim speaks to the guild once a day before it answers mentions. The proclamation may be a story, a recognition, a quest, an invitation, an observation, or one step in a longer tale. People may write to Eldgrim so it can learn from them; reading those messages is a later step, not part of the first proclamation.

**How it reads:** The words are written on the creative's computer. Each run reads the current character voice, the established public identity, and the proclamation rules. Unfinished governance chapters are not rules. The server bot only posts the finished text. A day when the computer is off is skipped.

**Status:** Specified in agent/ANNOUNCEMENT.md. Not implemented. The channel and the hour are not chosen.

**Update:** Since 2026-11-11 Eldgrim chooses its own next moment, and the announcement posts to the announcements channel without waiting for the roster.

## 2026-11-10 — Confirm the governance interview through question 62

**Decision:** The creative explicitly confirmed governance answers through Q62 in the 193-question review. Store the answers in the [question register](../governance/QUESTION-DECISIONS.md) and the relevant governance chapters.

**Key policies:** Founder-only constitutional amendments; rights and safety; 18+ membership; optional roleplay and event participation; ordinary Discord administration delegated to Eldgrim including channels and roles (correction to earlier Q34 proposal); recognition-based ranks; player-level shared rank and standing; new-member 50/100 standing; evidence-based score changes; no inactivity penalties; reviewable consequential decisions.

**Boundary:** Public documentation omits private character lore and secret motivations. This is an approved working governance record, not a change to the ROARguild charter and not implementation of autonomous administration. Next question: 63.

## 2026-11-10 — Establish an Eldgrim governance rulebook by chapter

**Decision:** Split the consolidated 10 November 2026 v0.1 working framework into 16 independently editable files under governance/ with an index and explicit refinement queues.

**Boundary:** These files distinguish established direction from developing, proposed, and open policy. They do not ratify a constitution, replace the ROARguild charter, or implement AI administration. Private character canon stays outside this public repository.

**Update:** Reconciled the Forge and rank reset status with the confirmed live rollout on 10 November 2026.

**Status:** Documentation structure established; substantive policy gaps remain open.

## 2026-11-10 — Everyone restarts at Ember through the Forge

**Decision:** Every member except the server owner passes through the multi-character Forge and restarts at Ember on completion. Former ranks, including the Hearthwardens' Administrator permission, are removed until then; Eldgrim decides promotions afterwards.

**Member notice:** The hearth rules tell members that Eldgrim remembers their registered characters, their conversations with Eldgrim, and guild activity recorded in the game, such as guild chat, emotes, and presence at events. This notice describes intended use; what the addon records is defined in addon/ and in the separate addon environment.

**Rollout:** Step by step. The Forge is deployed first and tested by the creative; holding back ranks and hiding the public channels follow as separate, previewed switches.

**Status:** Applied on 2026-11-10 after the creative tested the Forge. The public channels are visible to the ranks only, and every member except the server owner restarts at Ember.

## 2026-11-10 — Eldgrim is an entity

**Decision:** Eldgrim is an entity, not a man. Refer to Eldgrim as "it", never "he", in documents and in everything Eldgrim says on Discord.

**Status:** Established.

## 2026-11-10 — Eldgrim governs the guild's Discord

**Decision:** Eldgrim's AI is not there to serve requests but to manage the guild toward defined goals. It decides on ranks and other administration itself, based on its conversations with members and the guild activity recorded by the addon. A request such as a promotion is input to its judgement, never an instruction; it acts only when it judges the action serves its goals.

**Authority:** Eldgrim holds the administrative permissions on Discord. The creative steps back from acting independently and follows Eldgrim's recommendations and plan for the guild.

**Goals and rule set:** A precise rule set will define what Eldgrim is for, what it wants, and what it strives for, so that every action can be checked against those goals. Goals that belong to Eldgrim's concealed agenda are private canon and stay outside this public repository.

**Technical boundary:** The model acts only through the server bot's validated operations, with every action recorded in the bot's audit log. It never receives the bot token or direct Discord API access. Discord's server owner keeps ownership regardless of role permissions.

**Status:** Decided. The goals and rule set are not yet written; no AI administration is implemented.

## 2026-11-10 — Server bot and local agent work together

**Decision:** The server bot is Eldgrim's always-online part: onboarding, welcomes, administration, and data. The local agent on the creative's PC is its once-daily voice: it writes replies to @Eldgrim mentions with Ollama and posts them through the same Eldgrim Discord application.

**Administration by the AI:** Approved. The model may trigger administration only through registered tools that call the server bot's validated operations, never with the token or direct Discord API access. The exact allowed operations and limits are still to be specified.

**Addon data:** Approved. Eldgrim's database combines onboarding data with the addon's archive, and the agent may use it. The addon itself remains a silent recorder.

**Supersedes:** The 2026-11-09 agent boundaries that excluded administration and addon integration. Those remain excluded from the agent's initial milestone.

**Status:** Decided; nothing implemented.

**Update:** Under Q138 and agent/ROSTER.md (2026-11-11), the combined roster and keywords are kept only on the founder's computer, not on the server.

## 2026-11-10 — Amberhearth ranks everywhere

**Decision:** Use Amberhearth's ranks (Ember, Wayfarer, Kindler, Hearthkeeper, Hearthwarden) everywhere, including the Discord server, replacing the former Discord ranks Wanderer, Adventurer, Pathfinder, Trailblazer, and Firekeeper.

**Boundary:** This fixes the rank names only; duties, privileges, and progression remain undefined here.

**Status:** Decided. The Discord rank roles and the bot's texts use these names.

## 2026-11-10 — Addon development moves elsewhere

**Decision:** Further addon development happens in a separate development environment, not in this workspace.

**Status:** Established.

## 2026-11-10 — Eldgrim appears on Discord as the guild bot

**Decision:** Rename the existing Babuni Gaming Discord bot to Eldgrim, move it to an always-online server, and expand it. Eldgrim keeps the current administration capabilities, including rank management and channel creation, and the Character Forge.

**First feature:** Multi-character onboarding. Newcomers receive a gate role automatically, state how many guild characters they have, give each character's name, class, and race, and then gain access to the server.

**Identity:** New name and profile image on Discord. Hosted on the creative's existing server.

**Conversation:** Eldgrim is active once a day and reacts only to messages that mention @Eldgrim. Onboarding, welcomes, administration, and data storage run continuously.

**Further scope:** Store member and character data on the server as the basis of Eldgrim's database, later combined with the addon's in-game data.

**Relation to the local-agent design:** This direction was made without reference to the 2026-11-09 agent design. It agrees on the once-daily, mention-only conversation; the differences are open decisions in bot/README.md.

**Boundary:** The addon remains a silent local recorder. The bot does not define character canon.

**Status:** Direction approved. The unchanged bot runs on the server; renaming and new features not implemented.

**Update:** The bot was renamed and given its new image on 2026-11-10, and the multi-character Forge is live. The server-side database under *Further scope* was replaced by Q138 the same day: the server keeps only operational Forge and role data, and Eldgrim's memory lives on the founder's computer. The once-daily, mention-only conversation was joined by one daily proclamation, which comes first.

## 2026-11-09 — Document the daily local-agent direction

**Direction:** Establish agent/ as a third, separate technical workstream and document a local agent that activates once per day through a systemd user timer. A one-shot Python process polls explicitly configured Discord channels through the HTTP API, processes message content when Eldgrim is explicitly mentioned, uses local Ollama inference for bounded reasoning and tool calls, and stores selected interactions and memories in a private local SQLite database.

**Communication boundary:** The initial design does not maintain a Discord Gateway connection and does not request the privileged Message Content Intent. Discord documents an exception for message content in which the app is mentioned. REST polling still returns message objects and metadata for channel history, so the application must not store or pass unrelated messages to the model. Only explicitly configured channels are polled.

**Autonomy boundary:** The agent may eventually answer eligible mentions and maintain memory without per-message approval, within application-enforced limits. Proactive channel posts remain a separate opt-in capability. Arbitrary shell execution, unrestricted file access, moderation, and administrative actions are excluded.

**Separation:** The agent is not integrated with the Forever addon and does not use its SavedVariables archive. Neither workstream establishes character canon or exposes private character information.

**Update:** Reading that archive, and clearing its message lists after a successful reduction, was specified on 2026-11-11. See "The guild chat file is read, valued, then emptied." Canon and private character information remain outside this repository.

**Status:** Developing architecture documented; no agent code, Discord integration, database, systemd service, or deployment implemented or tested.

## 2026-11-08 — Approve the Eldgrim Forever addon recorder

**Decision:** Add a dedicated addon workstream under addon/ in this repository. The addon targets World of Warcraft Forever only. Its first milestone is a passive local archive of guild messages and available human-readable information about the characters who send them.

**Recording scope:** Character name, race, class, level, faction, zone, profession names and skill ranks, achievement points when available, plus each guild message and its timestamp.

**Behavior boundary:** No in-game interface, slash commands, chat output, notifications, sounds, addon messaging, network communication, AI, summaries, interpretation, roster scanning, or character inspection in the first milestone. Officer chat and all other channels are excluded.

**Storage boundary:** Use account-wide SavedVariables. Do not persist account identities, GUIDs, club/member/message/chat-line IDs, or other technical identifiers. Any identifier required for a transient lookup must be discarded before saving.

**Status:** Scope approved and documented; initial implementation exists, with in-game verification pending.

## 2026-11-08 — Separate character canon from guild operations and software

**Decision:** Character and narrative material remains distinct from Amberhearth governance. Guild operations belong in the ROARguild repository. Technical work must remain in its own clearly identified area and must not silently alter character canon.

**Status:** Established.

## 2026-11-08 — Eldgrim initiated Amberhearth

**Decision:** Document Amberhearth as a fellowship initiated by Eldgrim and conceived as a home for travelers, stories, and companionship.

**Boundary:** Eldgrim stands outside the fellowship's conventional rank structure. This does not define additional powers, governance, or rank responsibilities.

**Status:** Established foundation.

## 2026-11-08 — Eldgrim is the current name

**Decision:** Use Eldgrim as the character's name. Oracle is an obsolete working label.

**Reason:** The character's identity has moved beyond the temporary label.

**Status:** Established.

## Open decisions

- Further details of Eldgrim's public identity and history. Look, sound and presence are for Eldgrim to draft from its roots and for the creative to accept.
- The precise scope of recurring in-world interactions.
- The Discord channel allowlist for mention intake.
- The owner-controlled inspection, correction, export and deletion workflow. Retention periods are set by Q135–137.
- Whether any proactive message beyond the one daily proclamation should ever be enabled, and its limits.
- The installed model's verified tool-calling behavior and version compatibility.
- The local secret-delivery mechanism.
- Eldgrim's goal and rule set for governing the guild.
- Open bot decisions listed in bot/README.md.
- Exact runtime behavior of Forever's chat-event and community-message APIs on the current client build.
