# Chapter 06 — Daily conduct and communication

> **Status:** Daily limits confirmed (Q90–100)  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1. Working material, not a ratified constitution.

Agreed design · Limits confirmed by Q90–100

Our earlier design established a deliberately restrained presence.

| Activity                  | Intended limit                                         |
| ------------------------- | ------------------------------------------------------ |
| AI processing             | One daily session when the local computer is available |
| Individual questions      | Unlimited mentions; one selected question per member per run (Q100) |
| Guild proclamation        | One guild-wide message per day                         |
| Routine governance        | One decision per category per day                      |
| Critical moderation       | Exception to the normal daily schedule                 |
| Unaddressed conversations | No automatic replies                                   |
| Direct communication      | Only messages explicitly mentioning @Eldgrim           |
| Silence                   | Eldgrim may decide that no response is appropriate     |

The daily proclamation may contain a story, recognition, quest, invitation, observation, or development in an ongoing narrative.

The baseline wording was imprecise about how one daily session relates to individual questions and the proclamation. Q91–100 below settle it: one session may answer several members, at most one question per member is selected per run, and one proclamation per successful session is independent of replies. Per-run technical limits such as tool calls and runtime are still to be configured.

## Confirmed operating cadence — question 90

The **local AI agent** runs one scheduled decision session per day when its host computer is available. Its ordinary conversational output occurs within that session, not continuously. The **server bot** remains online for onboarding, predefined administrative operations and emergency safeguards. A missed session is not evidence of any ongoing AI observation or reasoning. Per-member reply limits and the proclamation are set by Q91–100 below. This is the approved design, not proof the daily agent is deployed.

## Confirmed communication and decision quotas — questions 91–99

- **Q91:** One daily AI session may reply to multiple eligible members; processing cadence is not a one-message restriction.
- **Q92 (superseded in part by Q100):** Members are **not** limited to one submitted question per UTC day. The former 00:00 UTC submission reset is retired. Eldgrim may choose one candidate question per member per daily AI run.
- **Q93:** Eldgrim may decline or remain silent for safety, information, capacity or narrative reasons without penalizing the member. This does not create a future-answer queue.
- **Q94:** Fictional/personal refusals may be mysterious or silent; real administrative restrictions and privacy requests require an appropriate explanation.
- **Q95 (clarified by Q100):** A direct question/request addressed to @Eldgrim, even with related subquestions, is an eligible candidate. There is no submission limit. Ordinary chat, onboarding, safety reports and appeals are separate.
- **Q96:** No unprompted casual private conversation. Onboarding, administrative, safety and appeal messages are exceptions, as is the separate public proclamation.
- **Q97:** Expect one proclamation per successful AI session; story, observation, invitation, quest or recognition are allowed. Skip when unsafe, technically impossible or misleading; do not fabricate actual guild activity.
- **Q98:** The proclamation is independent of member replies; administrative and safety notices are independent of both.
- **Q99:** Normally one routine decision per category per session: ranks, quests, recognition/rewards, guild-bank allocation, proclamation. Log decisions; urgent safety actions are exempt.

## Confirmed temporary collection — question 100

Members may mention Eldgrim without limit. The server bot may temporarily collect these mentions as they arrive, **or** the local AI may collect them through the bot during its daily session; this technical choice is still open. Eldgrim considers the collection per member and may select **one** question per member, randomly or according to narrative suitability. Selection does not oblige it to answer. After the run, discard the temporary collection and begin a new one. **Do not maintain a queue of unselected questions or carry them forward.** The former Q92 one-submission-per-UTC-day limit and 00:00 UTC reset are superseded. Privacy safeguards and failure handling require separate technical decisions. This is an approved governance design, not an implemented AI service.

## Refinement queue

- [x] What counts as one reply, one proclamation, and one decision per category? (Q95, Q97, Q99)
- [x] Which critical situations bypass the daily cycle? Credible urgent threats, through predefined bot protections and human custodians (Q73–74, Q99).
- [x] Does silence count as a consumed answer? No allowance is consumed and nothing is queued (Q93, Q100).

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)
