# Operating procedures for Amberhearth

These are design defaults for the working rulebook. Amberhearth is a place to share roads, fires and stories. Participation stays voluntary, members can organize their own gatherings, and the same conduct standards apply to every rank. Use the [decision register](QUESTION-DECISIONS.md) for policy and the [implementation matrix](IMPLEMENTATION-MATRIX.md) for verification. The procedures require real appointments and configured routes before use.

## Conduct, reports and appeals

- Publish a private reporting and appeals contact in the guild rules and in any consequential sanction notice. Use a private bot form for current members and a founder-designated contact reachable outside the server for former members. The founder owns ordinary escalations. Appoint an impartial reviewer and alternate before delegating moderation. Anyone personally involved recuses. If neither reviewer is available for a founder conflict, acknowledge the case, explain the delay and arrange an impartial substitute.
- Log the case ID, applicable rule, action, reason, review owner and dates. Acknowledge appeals within seven calendar days where possible and aim for a substantive decision within fourteen calendar days. Explain delays and accept later appeals even after ordinary records expire. Give the member the relevant rule and a fair opportunity to provide context privately.
- Verify the actor, source, timing and surrounding context. Check contrary accounts and use corroboration where available. An authenticated, clear firsthand record may suffice. Severe or permanent sanctions require high confidence supported by a clear primary record or independent corroboration. If reliable evidence does not establish the violation, record the uncertainty and close without a punitive finding.
- For credible immediate risk, use the least restrictive effective protection. The off-cycle bot may execute only explicitly authorized temporary protections. A human reviews the restriction by the next day where possible and lifts it when the risk no longer justifies it. For urgent action beyond the predefined protections, alert the authorized human operator.
- On a successful appeal, reverse or reduce the sanction, restore feasible roles and access, correct the case and dependent decisions, and notify the member privately. Keep confidential records in the administrative case workflow. Reviewers receive only the necessary case material and have no direct access to the founder's narrative database.

## Standing and identity corrections

Use the confirmed neutral starting value of 50 when an existing member has no stored score. Keep valid existing scores. When evidence or a character link is disputed, pause dependent consequential decisions, verify ownership and provenance, then remove or amend unsupported inputs. Recalculate from the last reliable state by replaying valid adjustments in order, applying the existing bounds. If the earlier state cannot be reconstructed, send the case for human review and withhold the disputed signal from consequential decisions. Review and remedy affected outcomes through the applicable process. Keep standing and private profiles internal and route personal-data requests through the authorized human.

## Privacy, evidence and recovery

- Publish the designated shared sources, purposes, retention and privacy contact before collection starts. Use a private data-request route staffed by an authorized human. Verify identity proportionately and disclose only the requester's eligible data with other people's information protected.
- Stage eligible mentions through the server bot, using authenticated transfer and a unique batch ID. Stage only approved shared sources for narrative processing. For mentions, allow unlimited submissions, select at most one per member per run, and drop the rest after the run. Expire temporary Discord batches within 24 hours, including missed or failed runs. Purge temporary copies on completion or expiry and audit only batch state and counts. Keep Forge and moderation records separate from narrative storage.
- Use the [roster specification](../agent/ROSTER.md) for game-side files. Clear messages only after a successful reduction and while the client is closed. Use the specified deduplication for interrupted cleanup. Before production, verify bounded expiry for unprocessed addon messages and recovery after a failed save.
- Retain eligible narrative memory during membership and delete or anonymize it within 30 days of departure subject to a specific legitimate exception. Ordinary administrative audits expire within 180 days. Record the reason and next review date for justified extensions and remove extended records when the reason ends. Keep routine backups for at most 30 days. Replay deletions and check access before restoring service. Keep private case material out of narrative memory.

## Quests, fires and bank stewardship

Use a bot quest submission with a quest ID, a screenshot and the named witness. The witness confirms from their own registered identity via the designated reaction or equivalent bot action. Reject self-confirmation and duplicate completions. When evidence conflicts, pause completion and ask for clarification privately. Suspected fabrication follows the normal evidence procedure. Request explicit consent before capturing identifiable witness material. Declining a quest, witness role or Sunday gathering carries no penalty.

Use Sunday 19:00 Europe/Stockholm as the planning default, publish each route and time ahead of the gathering, and allow members to run overlapping activities. Keep event recording to the fire, location, time and consenting witnesses. Use the minimum evidence needed and delete temporary material under the applicable workflow. The start time is a planning default until announced for a particular gathering.

Treat an item as restricted if it is reserved, on the custodian's scarce-item list, or a withdrawal would take stock below its published reserve. Until the custodians set item-specific reserves and valuation thresholds, treat uncertain scarcity or value as restricted. An authorized custodian confirms availability and legitimacy before transfer. Record the allocation, reserve change and transfer once, with a unique reference. A different designated reviewer handles disputes. Use a story reward or ordinary supplies when verification is pending.

## Tool and deployment boundaries

| Operation | Allowed target and authority |
| --- | --- |
| Post proclamation | Existing announcement route, one scheduled proclamation per daily cycle, with separately authorized test runs under the announcement specification. |
| Reply to mention | Eligible source message in a configured guild channel, at most one selected question per member per run, after reply integration is verified. |
| Channel and role administration | Individually registered actions on configured targets, with independent authorization and before/after verification. Protected roles, permissions and infrastructure remain outside the model's delegated tools. |
| Moderation and bank | Registered actions only after workflow verification. Keep current manual approval until Q170 activation. Human custodians execute in-game transfers. |

For future tools, use a unique action ID and typed arguments with configured guild and target IDs. Reject unknown fields, wrong scope, protected targets and stale state. Check the outcome before retrying an uncertain action. Never expose credentials, raw Discord API access, arbitrary code or general filesystem/network access to the model. Server ownership, security bypasses and infrastructure credentials stay outside model tools.

For the first mention integration, budget 120 seconds of elapsed model time, four tool-call rounds and 512 generated tokens per reply. Stop safely when a budget is exhausted and discard unselected or unfinished questions at the end of the run. The existing proclamation is the only routine proactive post. Verify the configured Ollama version, model tag and tool behavior locally before enabling replies.

The founder appoints emergency-stop operators with no direct narrative database access. Verify that stopping blocks new AI and administrative actions, handles work in flight, logs shutdown and requires an authorized restart. The existing bot's manual preview and approval applies until the founder reconciles the charter, verifies Q170 safeguards and explicitly authorizes each new class of autonomous action. Keep the test evidence and rollback steps with the activation record.
