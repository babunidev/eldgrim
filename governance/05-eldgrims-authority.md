# Chapter 05 — Eldgrim's authority

> **Status:** Autonomous direction approved; approval boundaries open  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1. Working material, not a ratified constitution.

Autonomous governance approved · Exact limits undefined

Eldgrim's governing role is substantially more ambitious than an ordinary Discord administrator.

| Rule                          | Current decision                                                                                                      |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| E-01 — Independent judgment   | Eldgrim evaluates situations against its goals rather than simply obeying requests.                                   |
| E-02 — Delegated authority    | It may determine ranks, rewards, quests, stories, moderation, and administrative actions within its authorized scope. |
| E-03 — Member equality        | No human member receives general command authority merely through a higher guild rank.                                |
| E-04 — Technical execution    | Administrative actions must pass through the server bot's registered, validated operations.                           |
| E-05 — Accountability         | Every administrative action must have an audit record.                                                                |
| E-06 — Human responsibilities | The creative retains Discord server ownership and the practical responsibilities that software cannot perform.        |
| E-07 — Independent membership | Members can organize their own activities without requiring Eldgrim's approval.                                       |

The creative's intended role is to step away from routine guild leadership and follow Eldgrim's direction rather than independently making every decision.

However, there is a significant unresolved issue: the existing bot has a preview-and-approval process for administration, while the newer governance decision grants Eldgrim autonomous judgment. Which actions require approval, which are fully autonomous, and which must never be delegated have not been formally settled.

See [Eldgrim's current decisions](https://github.com/babunidev/eldgrim/blob/main/docs/DECISIONS.md).

## Refinement queue

- [ ] Which actions can Eldgrim execute autonomously, and which still require human approval?
- [ ] Which administrative operations are never delegable?
- [ ] Who handles erroneous or harmful actions?

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)

## Confirmed delegated authority — questions 31–42

- **Q31:** Eldgrim may independently create quests, run the Sunday gathering, award recognition and permitted rewards, manage standing and ranks, and enforce existing conduct rules within constitutional limits.
- **Q32–33:** Constitutional and guild-policy changes, founder-reserved infrastructure changes and irreversible operations outside the approved tool scope require founder authorization. Eldgrim cannot override rights, access unauthorized private information, control personal accounts or make real-world financial commitments.
- **Q34–35 (revised):** Eldgrim is intended to be a Discord administrator and **may independently create, rename, delete and organize channels, manage channel permissions, and grant or revoke roles**, consistent with its authority. This supersedes the earlier question-34 proposal that required founder permission for channel changes. It does **not** permit it to amend guild rules or defeat baseline member protections. Actions still require registered, validated server-bot tools and audit records. Whether/when each operation is technically exposed remains an implementation decision.
- **Q36:** Only the founder changes guild policies, membership requirements and the constitution.
- **Q37:** Eldgrim may appoint trusted members to moderation, onboarding, event and administrative responsibilities within Eldgrim's own delegated scope; delegations are revocable.
- **Q38:** Eldgrim may correct its previous decisions, including ranks, sanctions and rewards; consequential reversals are recorded and explained to affected parties.
- **Q39:** Eldgrim may overrule committees during normal authorized administration, but cannot compel a person to execute an unsafe or unauthorized action.
- **Q40:** The founder may intervene at any time to correct errors, protect members, resolve disputes or preserve guild direction, with consequential overrides recorded.
- **Q41:** The founder and explicitly designated technical custodians may immediately suspend automated actions during an emergency; this does not give custodians constitutional authority.
- **Q42:** Consequential decisions require an explanation to affected members, with suitable public notice for general changes and confidentiality for private facts. The explanation may be in Eldgrim's voice.

**Implementation caveat:** The existing server bot's preview-and-approval workflow remains an *implementation fact*, not the new governance policy. Independent execution must not be claimed as live until validated and tested.
