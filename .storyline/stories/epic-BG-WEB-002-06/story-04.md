---
story_id: 04
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Mobile Responsiveness Polish
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-06-polish-security.md
created: 2026-01-25
---

# Story 04: Mobile Responsiveness Polish

## User Story

**As an** admin using a mobile device,
**I want** the dashboard to be fully functional on my phone,
**so that** I can manage the server from anywhere.

## Acceptance Criteria

### Scenario 1: Dashboard layout on 320px width
**Given** I'm on a small mobile device (320px width)
**When** I view the dashboard
**Then** all components are visible
**And** no horizontal scroll on main layout
**And** content doesn't overflow

### Scenario 2: Touch-friendly buttons
**Given** I'm using a touch device
**When** I interact with buttons
**Then** all buttons are at least 44x44px touch target
**And** buttons have adequate spacing

### Scenario 3: Login flow on mobile
**Given** I'm on a mobile device
**When** I complete the GitHub OAuth flow
**Then** login works without popup blockers interfering
**And** redirect flow completes successfully

### Scenario 4: Server controls on mobile
**Given** I'm on a mobile device
**When** I use start/stop buttons
**Then** confirmation dialog is touch-friendly
**And** buttons are large and easy to tap

### Scenario 5: Logs viewer on mobile
**Given** I'm viewing logs on mobile
**When** I scroll through logs
**Then** horizontal scroll works for long lines
**And** vertical scroll works for log history
**And** controls are accessible

### Scenario 6: Forms work with mobile keyboards
**Given** I'm using the quick actions form
**When** the keyboard appears
**Then** input fields are not obscured
**And** form remains usable

### Scenario 7: Tested on real devices
**Given** the dashboard is deployed
**When** I test on iOS Safari (iPhone)
**Then** all features work correctly
**When** I test on Android Chrome
**Then** all features work correctly

## Business Value

**Why this matters:** Mobile management is a key feature. Admins need to start/stop the server from their phones when away from a computer.

**Impact:** Enables true anywhere-access for server management.

**Success metric:** All dashboard features work on 320px+ screen widths.

## Technical Considerations

**Responsive Design Principles:**
```css
/* Mobile-first approach */
.dashboard-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: 1fr;
}

/* Tablet and up */
@media (min-width: 768px) {
  .dashboard-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .dashboard-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

**Touch Target Sizing:**
```css
/* Ensure 44x44px minimum touch targets */
.btn {
  min-height: 44px;
  min-width: 44px;
  padding: 0.75rem 1rem;
}

/* Space buttons for fat finger prevention */
.btn + .btn {
  margin-left: 0.5rem;
}
```

**Mobile Input Handling:**
```tsx
// Prevent zoom on input focus (iOS)
<input
  type="text"
  style={{ fontSize: "16px" }} // Prevents iOS zoom
/>

// Ensure proper keyboard types
<input type="text" inputMode="text" /> // Username
<input type="text" inputMode="numeric" /> // Numbers
```

**Testing Checklist:**
- [ ] iPhone SE (smallest common iPhone)
- [ ] iPhone 14/15 (standard size)
- [ ] iPad (tablet breakpoint)
- [ ] Android phone (various)
- [ ] Android tablet

**Common Issues to Check:**
- Viewport meta tag present
- No fixed widths that cause overflow
- Touch targets adequately sized
- Forms don't break on keyboard appearance
- OAuth redirect works (not popup)
- Modals/dialogs work on mobile

## Dependencies

**Depends on stories:**
- Epic 2-5: All dashboard components exist

**Enables stories:**
- Story 05: Security Audit (includes mobile testing)

## Out of Scope

- Dedicated mobile app
- Offline support / PWA
- Mobile-specific features
- Gesture controls

## Notes

- Use Chrome DevTools mobile emulator for initial testing
- Test on real devices before launch
- iOS Safari has unique quirks (100vh, safe areas, etc.)
- Consider touch-action CSS for scroll/swipe behavior

## Traceability

**Parent epic:** [epic-BG-WEB-002-06-polish-security.md](../../epics/epic-BG-WEB-002-06-polish-security.md)

**Related stories:** All Epic 2-5 component stories

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-06/story-04.md`
