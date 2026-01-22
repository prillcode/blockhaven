---
story_id: 003
epic_id: 004
title: Toast Notification System
status: ready_for_spec
created: 2026-01-12
---

# Story 003: Toast Notification System

## User Story

**As a** website user,
**I want** to receive toast notifications for important actions (form submissions, copy success, errors),
**so that** I get immediate visual feedback that my actions succeeded or failed.

## Acceptance Criteria

### Scenario 1: Show success toast
**Given** I perform an action that succeeds (e.g., submit contact form)
**When** the action completes successfully
**Then** a toast notification appears at the top-right of the screen
**And** the toast shows a success icon (green checkmark) and message: "Message sent successfully!"
**And** the toast auto-dismisses after 5 seconds
**And** I can manually dismiss it by clicking the X button

### Scenario 2: Show error toast
**Given** I perform an action that fails (e.g., contact form submission error)
**When** the error occurs
**Then** a toast notification appears with error styling (red)
**And** the toast shows an error icon (red X) and message: "Failed to send message. Please try again."
**And** the toast auto-dismisses after 5 seconds

### Scenario 3: Toast queue management
**Given** multiple toasts are triggered rapidly (3 toasts within 1 second)
**When** the toasts are added
**Then** they appear stacked vertically, not overlapping
**And** each toast displays for its full duration
**And** toasts exit in the order they were created (FIFO)
**And** maximum of 3 toasts are visible at once

### Scenario 4: Manual dismissal
**Given** a toast is displayed
**When** I click the X button
**Then** the toast immediately slides out and disappears
**And** the auto-dismiss timer is cancelled
**And** other toasts shift position smoothly

## Business Value

**Why this matters:** Toast notifications provide essential feedback for user actions, especially for async operations like form submissions. Without feedback, users don't know if their action succeeded or failed.

**Impact:** Improves user experience by providing immediate, non-intrusive feedback. Reduces user confusion and support requests ("did my form submit?").

**Success metric:** All interactive actions (form submit, IP copy) trigger appropriate toast notifications with 100% reliability.

## Technical Considerations

**Potential approaches:**
- Create `useToast` custom hook to manage toast state and queue
- Create `Toast` component for individual toast rendering
- Create `ToastContainer` component to manage positioning and stacking
- Use React Context or simple state management for global toast access
- Use CSS transitions for smooth enter/exit animations

**Constraints:**
- Must be accessible (ARIA roles, keyboard dismissal)
- Must support dark mode (from Epic 001)
- Must not block UI interactions (non-modal)
- Must be responsive (mobile and desktop positioning)
- Maximum 3 toasts visible simultaneously

**Data requirements:**
- Toast types: success, error, info, warning
- Toast message (string)
- Auto-dismiss duration (default 5 seconds, configurable)
- Optional action button

## Dependencies

**Depends on stories:**
- Epic 001 (Theme System) - must integrate with dark mode

**Enables stories:**
- Story 04: Contact Form Widget - uses toasts for success/error feedback
- Story 05: Copy IP Button - uses toasts for "Copied!" feedback

## Out of Scope

- Complex notification center with history
- Persistent notifications that survive page refresh
- Sound effects for notifications
- Browser push notifications (different from in-app toasts)
- Toast positioning preferences (always top-right for consistency)

## Notes

- Consider using libraries like `react-hot-toast` or `sonner` for faster implementation, or build custom for learning/control
- Toast animations should be smooth (use CSS transforms, not position changes)
- Ensure toasts don't cover important UI elements (positioned with safe margins)
- Toast component should be added to root layout (from Epic 001) so it's available app-wide

## Traceability

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

**Related stories:** Story 04 (ContactForm), Story 05 (CopyIPButton)

---

**Next step:** Run `/spec-story .storyline/stories/epic-004/story-03-toast-notification-system.md`
