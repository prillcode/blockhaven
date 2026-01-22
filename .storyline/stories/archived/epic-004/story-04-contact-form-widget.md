---
story_id: 004
epic_id: 004
title: Contact Form Widget
status: ready_for_spec
created: 2026-01-12
---

# Story 004: Contact Form Widget

## User Story

**As a** potential player or current player,
**I want** to submit questions or feedback through a contact form,
**so that** I can get help or share feedback without needing to have Discord.

## Acceptance Criteria

### Scenario 1: Successful form submission
**Given** I am on the Contact page
**When** I fill in name "John Doe", email "john@example.com", and message "How do I join?"
**And** I click the "Send Message" button
**Then** the form shows a loading state (disabled button with spinner)
**And** the form submits to `/api/contact` endpoint
**And** a success toast appears: "Message sent successfully!"
**And** the form fields are cleared
**And** the submit button becomes enabled again

### Scenario 2: Client-side validation errors
**Given** I am on the Contact page
**When** I leave the name field empty and click "Send Message"
**Then** an error message appears below the name field: "Name is required"
**And** the form does NOT submit to the API
**And** the name field is highlighted in red
**And** the submit button remains enabled

### Scenario 3: API submission error
**Given** I fill in valid form data
**When** the API request fails (network error or 500 response)
**Then** an error toast appears: "Failed to send message. Please try again."
**And** the form fields retain my entered data (not cleared)
**And** the submit button becomes enabled again
**And** I can retry the submission

### Scenario 4: Loading state prevents double submission
**Given** I have submitted the form and it's currently processing
**When** I try to click the "Send Message" button again
**Then** the button is disabled and shows a spinner
**And** no duplicate API request is sent
**And** the button remains disabled until the request completes

## Business Value

**Why this matters:** Not all players use Discord. A contact form provides an accessible way for anyone to reach out, lowering the barrier to communication and support.

**Impact:** Increases player engagement and reduces friction for support requests. Captures feedback from non-Discord users who would otherwise have no way to contact server staff.

**Success metric:** Contact form successfully submits to API, sends Discord webhook, and provides clear feedback to users.

## Technical Considerations

**Potential approaches:**
- React component with controlled form inputs (useState)
- Client-side validation using HTML5 validation or custom validation logic
- Integration with `/api/contact` endpoint (Epic 003, Story 03)
- Use `useToast` hook (Story 03) for success/error feedback
- Form state management: idle → loading → success/error

**Constraints:**
- Must validate: name (required, min 2 chars), email (required, valid format), message (required, min 10 chars)
- Must show loading state during submission
- Must prevent double submission
- Must integrate with dark mode theme
- Must be mobile-responsive (form fields stack on mobile)

**Data requirements:**
- Form fields: name (string), email (string), message (string)
- API endpoint: POST `/api/contact` (from Epic 003, Story 03)
- API response: `{ success: boolean, message?: string }`

## Dependencies

**Depends on stories:**
- Epic 003, Story 03: Contact Form Endpoint - provides the API to submit to
- Story 03: Toast Notification System - provides feedback UI

**Enables stories:**
- No downstream dependencies

## Out of Scope

- File upload attachments
- CAPTCHA/bot protection (rate limiting handled in Epic 003)
- Auto-save form drafts to localStorage
- Email confirmation to user after submission
- Form field character counters
- "Send a copy to my email" checkbox

## Notes

- This widget will be embedded on the Contact page (from Epic 002)
- Consider using a form library like `react-hook-form` for validation, or implement custom validation for simplicity
- Email validation regex should be reasonable (not overly strict)
- Textarea for message should have rows="5" for comfortable typing
- Form should be accessible (proper labels, ARIA attributes, keyboard navigation)

## Traceability

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

**Related stories:** Story 03 (Toast System), Epic 003 Story 03 (Contact API)

---

**Next step:** Run `/spec-story .storyline/stories/epic-004/story-04-contact-form-widget.md`
