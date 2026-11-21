# Chapter 08 — Quests, recognition, and rewards

> **Status:** Founder-confirmed quest principles and verification rules (Q101–110); implementation and resource safeguards developing  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1; founder decisions Q101–110. Working material, not a ratified constitution.

## Purpose and creative direction

Eldgrim creates quests to encourage exploration, discovery, companionship, creativity and character storytelling, especially around Azeroth's roads, hearths, torches and fires (Q101). Examples include finding a torch, visiting a forgotten fire, meeting travelers, or carrying a symbolic flame. Quests must not become compulsory farming, wealth accumulation or progression requirements.

## Assignment and participation (Q102–104)

- **Q102 — Frequency:** Normally one quest-assignment **decision** per daily AI session. A decision may involve one member, several members or the fellowship as a whole. Existing quests may continue across days.
- **Q103 — Consent:** Quests are invitations. Members may accept, decline or abandon them freely, without punishment, pressure to explain, or loss of rank or standing.
- **Q104 — Suitability:** Consider known character interests, story, capabilities, location and level where relevant. Never demand unsafe travel, inaccessible areas, unwanted roleplay or unreasonable activities. Offer creative alternatives where appropriate.

## Evidence and verification (Q105–108)

1. **Q105 — Evidence:** The participant submits a screenshot showing the objective and names a witness. Eldgrim evaluates the evidence; a screenshot by itself is not automatic proof.
2. **Q106 — Witness eligibility:** A different registered member who genuinely observed the action, or a **specifically authorized verifier**, may confirm it. Rank alone does **not** grant verification authority. The participant cannot be their own sole witness.
3. **Q107 — Confirmation:** The named witness uses a designated Discord reaction or verification command associated with the evidence. The bot is intended to record the confirmation for Eldgrim's subsequent review. Witnesses must not claim to have observed something they did not see.
4. **Q108 — Incomplete or disputed evidence:** Leave the quest unverified while seeking clarification or allowing an equivalent **authorized** verification method. An unclear screenshot or unavailable witness is not misconduct. Deliberately dishonest evidence is addressed under the conduct rules.

Automated image recognition is not part of the currently approved verification design. The designated witness mark is the Roar emoji on a Discord message that names Eldgrim and has an image. The bot records that fact for the next daily run and does not read the picture. On 18 November 2026 the creative decided who may make that mark: every member who holds the Amberhearth role, at any rank. A member without that role does not confirm the quest, whatever rank they hold. The participant's own Roar does not count. Correction and fraud review of a witness claim are not built.

## The daily quest

A member names Eldgrim in the Eldgrim channel and writes a short line that asks for a quest, or writes `quest cancel`. The ask is not answered with text. A fire shows it was seen. A private thread asks whether to add a short wish. Each member brings one character (2026-11-20), so the thread asks which character only of a member who still has several from before. If a quest is unfinished, the thread says to complete it first, and no new ask is kept. The wish is data for that one quest, not an instruction. On the next daily run the quest is posted as a reply to the ask, for the character the member chose. If the name does not match a character on record, the highest level is used, or a random one when the levels tie. A new character is stored at level 1 until the guild chat reports a level. That starting level is not announced as a level-up. The first quest is to light a bonfire. A later quest names one item from the fire catalog that fits the character's level and faction, and it does not repeat an item already given to that member. A place in that message comes from the world page, and from a wish only when the world page and the catalog allow it. The proof is the screenshot mention and the Roar. A completed proof adds one private standing point and does not print the score. When the Roar lands, a fire is set on the posted quest and one line in the private thread says another may be asked for. Cancelling, or leaving the quest unfinished, changes the score by nothing. A cancel sets the quest aside and does not offer another until the member asks again. The words are grateful, and no item is handed out. This is tested with synthetic members.

## Deadlines and rewards (Q109–110)

- **Q109 — Unfinished quests:** Eldgrim may set narrative deadlines or close quests when circumstances change. Failure to complete a quest never reduces standing, rank or ordinary membership privileges. A member may leave a quest unfinished without punishment.
- **Q110 — Reward discretion:** Eldgrim may combine recognition, titles, stories, special opportunities, rank consideration and available bank items. Match the gift to the member, character or shared moment as it unfolds. Someone who danced around the bonfire might receive a fire elemental or a burning sword if the gift fits and can be delivered. Market value, rarity and scarcity do not enter the choice. Participation creates no entitlement. Rank and permission changes follow their separate rules.

## Refinement queue

- [x] Define witness eligibility and missing-evidence treatment (Q105–108).
- [x] Establish voluntary participation, unfinished quests and reward discretion (Q103, Q109–110).
- [x] The witness mark is the Roar emoji from a different member who holds the Amberhearth role, at any rank. The picture itself is not read (Q107).
- [ ] Correction and fraud review of a witness claim.
- [x] Establish roleplay-led reward selection and separate bank transfer and permission rules (Q110, Q117–123).
- [x] Stage a quest ask, a cancel, and a witnessed screenshot for the daily run. Synthetic tests cover the direct message, the private point, the unfinished reply, and the replacement. The server service was restarted with the direct reply on 16 November 2026.

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)

The [operating procedures](OPERATING-PROCEDURES.md) give the current practical defaults. Configuration, appointments, implementation and verification are tracked separately.
