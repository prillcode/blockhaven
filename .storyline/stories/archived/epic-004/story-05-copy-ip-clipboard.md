---
story_id: 005
epic_id: 004
title: Copy IP to Clipboard Button
status: ready_for_spec
created: 2026-01-12
---

# Story 005: Copy IP to Clipboard Button

## User Story

**As a** website visitor ready to join the server,
**I want** to copy the server IP address with one click,
**so that** I can easily paste it into Minecraft without typing errors.

## Acceptance Criteria

### Scenario 1: Successful IP copy (modern browser)
**Given** I am using a modern browser with Clipboard API support
**When** I click the "Copy IP" button next to "5.161.69.191:25565"
**Then** the server IP "5.161.69.191:25565" is copied to my clipboard
**And** a success toast appears: "IP copied to clipboard!"
**And** the button shows a checkmark icon briefly (visual feedback)
**And** I can paste the IP into Minecraft using Ctrl+V/Cmd+V

### Scenario 2: Copy in older browser (fallback)
**Given** I am using an older browser without Clipboard API support
**When** I click the "Copy IP" button
**Then** the fallback method (document.execCommand) is used
**And** the IP is copied successfully
**And** a success toast appears: "IP copied to clipboard!"

### Scenario 3: Copy failure
**Given** the browser blocks clipboard access (rare)
**When** I click the "Copy IP" button
**Then** an error toast appears: "Failed to copy IP. Please copy manually."
**And** the IP text remains visible so I can select and copy manually
**And** the application does not crash

### Scenario 4: Button hover state
**Given** I hover over the "Copy IP" button
**When** my cursor is over the button
**Then** the button shows a visual hover state (color change)
**And** the cursor changes to pointer
**And** a tooltip appears: "Click to copy"

## Business Value

**Why this matters:** Manually typing server IPs leads to typos and frustration. One-click copying reduces friction in the critical "joining the server" workflow.

**Impact:** Removes a major pain point in the player onboarding process. Players can join the server 3-5 seconds faster, improving conversion from visitor to active player.

**Success metric:** Copy button successfully copies IP to clipboard with 99%+ success rate across modern browsers.

## Technical Considerations

**Potential approaches:**
- Use modern `navigator.clipboard.writeText()` API for primary implementation
- Fallback to `document.execCommand('copy')` for older browsers
- Use `useToast` hook (Story 03) for success/error feedback
- Button component with copy icon (clipboard or copy icon from icon library)

**Constraints:**
- Must work on all modern browsers (Chrome, Firefox, Safari, Edge)
- Must have fallback for older browsers
- Must handle permission denial gracefully
- Must integrate with dark mode theme
- Must be keyboard accessible (Enter key works)

**Data requirements:**
- Server IP: `5.161.69.191:25565` (hardcoded constant)
- Icon library: Lucide React or Heroicons for copy/checkmark icons

## Dependencies

**Depends on stories:**
- Story 03: Toast Notification System - provides feedback UI

**Enables stories:**
- No downstream dependencies

## Out of Scope

- QR code generation for mobile users
- "Share server IP" via social media
- Copy button for other information (Discord link, etc.) - can be added later
- Copy history or "recently copied" indicator
- Auto-copy on page load (would be intrusive)

## Notes

- This button will likely appear on the homepage hero section near the ServerStatus widget (Story 02)
- Consider using a dedicated `useCopyToClipboard` hook for reusability
- The IP should be displayed as copyable text, not hidden in the button
- Button should have clear labeling ("Copy IP" or "Copy Server Address")
- Consider brief success animation (button turns green, shows checkmark for 2 seconds)

## Traceability

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

**Related stories:** Story 03 (Toast System), Story 02 (ServerStatus Widget)

---

**Next step:** Run `/spec-story .storyline/stories/epic-004/story-05-copy-ip-clipboard.md`
