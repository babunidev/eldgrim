# Eldgrim Addon — First-Milestone Test Plan

**Target:** World of Warcraft Forever only.  
**Baseline:** Version 1.60.1, interface 16001.  
**Build reference:** 1.60.1.70862 (latest public build found on 2026-11-08).  
**Status:** Not run. No addon implementation exists yet.

## 1. Client and loading
- [ ] Confirm the installed client is World of Warcraft Forever.
- [ ] Record the exact version, build, and interface reported by the running client.
- [ ] Confirm the addon loads with its Forever-only manifest.
- [ ] Confirm account-wide SavedVariables initialize correctly.

## 2. Guild message capture
- [ ] Receive a guild message from another character; verify exactly one record is added.
- [ ] Send a guild message as the local character; verify exactly one record is added.
- [ ] Verify the sender name and message text are preserved correctly.
- [ ] Verify timestamps use the community-message epoch only when the associated message is positively matched.
- [ ] Verify the fallback timestamp is recorded as local receipt time and is not described as the sender's exact send time.
- [ ] Verify repeated messages are not lost or duplicated.

## 3. Channel boundaries
- [ ] Verify officer chat is not recorded.
- [ ] Verify say, yell, whisper, party, raid, instance, and custom-channel messages are not recorded.
- [ ] Verify system messages and addon messages are not recorded.

## 4. Character enrichment
- [ ] Verify the community-message record belongs to the same guild message currently being handled.
- [ ] Verify the author name matches the event sender before attaching character information.
- [ ] Verify the message content matches before using the community-message timestamp.
- [ ] Verify class names resolve to the nine Forever classes only.
- [ ] Verify race names resolve to the Forever roster only, including High Order Skyborne and Windshaper Skyborne.
- [ ] Verify level, faction, zone, profession names, profession skill ranks, and achievement points when supplied.
- [ ] Verify missing fields remain absent and no values are guessed.
- [ ] Verify a character's profile is updated without replacing or deleting previous messages.
- [ ] Verify a message is still recorded when profile enrichment is unavailable but event text and sender are accessible.

## 5. Restrictions and failure handling
- [ ] Test while chat-messaging lockdown is active.
- [ ] Verify restricted or secret values are skipped safely without Lua errors.
- [ ] Verify the recorder does not attempt to bypass restrictions.
- [ ] Verify missing community data, nil author records, partial profiles, and unavailable APIs do not break message capture.
- [ ] Verify a community message from a different channel or author is never attached to the current guild event.

## 6. Saved data
- [ ] Use /reload and verify the archive is written.
- [ ] Log out normally and verify the archive is written.
- [ ] Fully exit and restart the client; verify the archive is restored.
- [ ] Verify the file is account-wide under the Forever SavedVariables directory.
- [ ] Inspect the saved file and confirm it contains no GUIDs, account identifiers, club/member/message/chat-line IDs, or numeric race/class IDs.
- [ ] Verify the saved structure contains only character profile fields and timestamped message text.
- [ ] Confirm that a forced client crash can lose unsaved in-memory records; document the normal save boundary.

## 7. Quiet operation
- [ ] Verify there are no visible frames, buttons, menus, or indicators.
- [ ] Verify there are no slash commands, chat messages, notifications, or sounds.
- [ ] Verify there is no addon messaging, network communication, or external service use.
- [ ] Verify the addon does not scan the roster, inspect characters, or poll in the background.

## 8. Automated checks

After source code is created:
- [ ] Run Lua syntax validation.
- [ ] Run static checks against the current Forever API declarations.
- [ ] Add and run tests for profile merging, timestamp conversion, missing fields, and duplicate prevention.
- [ ] Record exact commands and results.

Automated checks and mocked tests do not replace in-game testing. Do not mark any item complete until the corresponding test has actually been performed in the stated Forever build.
