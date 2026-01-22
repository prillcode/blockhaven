---
epic_id: 004
title: Interactive Features & Frontend Integration
status: ready_for_stories
source: web/WEB-COMPLETE-PLAN.md
created: 2026-01-10
---

# Epic 004: Interactive Features & Frontend Integration

## Business Goal

Transform the static marketing website into an interactive experience by integrating live server status monitoring, functional contact form, and seamless user interactions that drive engagement and conversions.

**Target outcome:** A fully interactive website where users can see real-time server status, submit contact inquiries, copy the server IP with one click, and receive immediate feedback through toast notifications.

## User Value

**Who benefits:** Potential players evaluating whether to join BlockHaven

**How they benefit:**
- **Real-time Confidence**: See live player count and server status before joining, reducing uncertainty
- **Instant Connection**: One-click copy of server IP removes friction from joining process
- **Direct Support**: Submit questions/issues directly from website with immediate confirmation
- **Smooth Experience**: Toast notifications and loading states provide clear feedback on all actions

**Current pain point:** Static websites don't provide real-time information or interactive features, requiring users to manually type server IPs and search for contact methods.

## Success Criteria

When this epic is complete:

- [ ] ServerStatus widget displays live data from `/api/server-status` endpoint
- [ ] Server status auto-refreshes every 30 seconds without page reload
- [ ] Online/offline indicator shows correct state with pulsing animation
- [ ] Player count displays as "X/100 players online" with accurate numbers
- [ ] ContactForm widget submits to `/api/contact` with validation
- [ ] Contact form shows loading state during submission
- [ ] Success toast appears after successful submission: "Message sent successfully!"
- [ ] Error toast appears on failure: "Failed to send message. Please try again."
- [ ] CopyIPButton copies server IP (5.161.69.191:25565) to clipboard
- [ ] Copy button shows "Copied!" toast notification
- [ ] useServerStatus hook polls API every 30 seconds with error handling
- [ ] useToast hook manages toast notification queue
- [ ] useLocalStorage hook provides type-safe localStorage wrapper
- [ ] All interactive widgets tested on mobile and desktop
- [ ] Performance optimized with React.lazy() for code splitting

**Definition of Done:**
- All user stories completed
- All custom hooks implemented and tested
- All interactive widgets functional and responsive
- Integration with backend API verified (server status, contact form)
- Error handling covers network failures and API errors
- Loading states provide clear feedback during async operations
- Toast notifications queue properly (don't overlap)
- Performance metrics acceptable (no unnecessary re-renders)
- Code splitting implemented for optimal bundle size

## Scope

### In Scope
- Custom React hooks (4): useServerStatus, useToast, useLocalStorage, useTheme
- Interactive widgets (3): ServerStatus, ContactForm, CopyIPButton
- API integration utilities: minecraft-api.ts, discord-webhook.ts (client-side wrappers)
- Toast notification system with queue management
- Loading spinners and skeleton states
- Client-side form validation (in addition to backend validation)
- Clipboard API integration with fallback for older browsers
- Error boundary components for graceful error handling
- Performance optimization: lazy loading, code splitting, image optimization
- Utility functions: utils.ts (className merging, date formatting, etc.)

### Out of Scope
- Backend API endpoints - already in Epic 003
- Static UI components - already in Epic 002
- Base theme system - already in Epic 001
- Docker deployment - handled in Epic 005

### Boundaries
This epic bridges frontend and backend by creating the hooks and widgets that consume API endpoints. It focuses on interactivity and user experience enhancements.

## Dependencies

**Depends on:**
- Epic 001: Website Foundation & Theme System - needs theme context and base layout
- Epic 002: Content Pages & UI Component Library - needs pages to embed widgets into
- Epic 003: Backend API Services - needs API endpoints to integrate with

**Enables:**
- Epic 005: Docker Deployment & Production Release - provides complete app ready for deployment

## Estimated Stories

**Story count:** ~8 user stories

**Complexity:** Medium-High

**Estimated effort:** Medium epic (2 days)

## Technical Considerations

- **Polling Strategy**: useServerStatus uses 30-second interval (matches backend cache TTL) to balance freshness with performance
- **Toast Queue Management**: Multiple toasts should queue and display sequentially, not overlap
- **Clipboard API**: Use modern navigator.clipboard.writeText() with fallback for older browsers (document.execCommand)
- **Error Boundaries**: Wrap interactive components to prevent entire app crash if widget fails
- **Performance**: Use React.memo() for widgets that receive frequent props updates, useMemo/useCallback for expensive computations
- **Code Splitting**: Lazy load Contact page (less frequently visited) to reduce initial bundle
- **AbortController**: Clean up fetch requests in useEffect cleanup to prevent memory leaks

## Risks & Assumptions

**Risks:**
- Polling every 30 seconds could drain mobile battery (mitigation: pause polling when tab is inactive using document.visibilityState)
- Race conditions if user submits form multiple times rapidly (mitigation: disable submit button during submission)
- Clipboard API not supported in older browsers (mitigation: implement fallback with document.execCommand)
- Network failures could leave widgets in error state indefinitely (mitigation: implement retry logic with exponential backoff)

**Assumptions:**
- Backend API endpoints are reliable and return consistent response formats
- Users have modern browsers with JavaScript enabled
- Toast notifications are sufficient for feedback (no need for modal dialogs)
- 30-second polling interval is acceptable for server status freshness

## Related Epics

- Epic 001: Website Foundation & Theme System - uses theme context
- Epic 002: Content Pages & UI Component Library - embeds widgets into pages
- Epic 003: Backend API Services - consumes API endpoints
- Epic 005: Docker Deployment & Production Release - deploys complete interactive app

## Source Reference

**Original PRD/Spec:** web/WEB-COMPLETE-PLAN.md

**Relevant sections:**
- Phase 4: Frontend Integration (lines 803-833)
- Component Architecture - Widget Components (lines 439-495)
- Hooks (lines 107-111)
- Key Features - Live Server Status Widget (lines 47-48)
- Key Features - Discord Contact Form (lines 49)

---

**Next step:** Run `/story-creator .storyline/epics/epic-004-interactive-features-integration.md`
