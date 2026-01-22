---
epic_id: 001
title: Website Foundation & Theme System
status: ready_for_stories
source: web/WEB-COMPLETE-PLAN.md
created: 2026-01-10
---

# Epic 001: Website Foundation & Theme System

## Business Goal

Establish the technical foundation for the BlockHaven marketing website with a modern, performant stack and professional theming system that supports both dark and light modes.

**Target outcome:** A working development environment with Vite + React 19 + TypeScript + Tailwind CSS v4, featuring a persistent dark/light theme system and responsive base layout components.

## User Value

**Who benefits:** Potential Minecraft server players visiting the BlockHaven website

**How they benefit:** Users experience a fast, modern website with their preferred color scheme (dark/light mode) that persists across visits and respects their system preferences. The Minecraft-themed design creates immediate brand recognition and immersion.

**Current pain point:** Without this foundation, there is no website to showcase the server's unique features and attract players.

## Success Criteria

When this epic is complete:

- [ ] Vite development server runs without errors (`pnpm dev`)
- [ ] Tailwind CSS v4 configured with custom Minecraft-themed color palette
- [ ] Dark/light mode toggle works and persists to localStorage
- [ ] System preference detection works on first visit
- [ ] Base layout components (Header, Footer, Navigation) render correctly
- [ ] Responsive design works on mobile, tablet, and desktop
- [ ] All dependencies installed and project structure created

**Definition of Done:**
- All user stories completed
- Development environment fully functional
- Theme system tested (persistence, system preference, toggle)
- Basic layout renders on all screen sizes
- Documentation updated (README with setup instructions)

## Scope

### In Scope
- Vite + React 19 + TypeScript project initialization
- Tailwind CSS v4 configuration with `@tailwindcss/vite` plugin
- Custom Minecraft-themed color palette (grass, dirt, stone, diamond, etc.)
- Dark/light mode Context API implementation
- localStorage theme persistence
- System preference detection (`prefers-color-scheme`)
- Base layout components: Header, Footer, Navigation
- ThemeToggle widget
- Mobile-responsive navigation (hamburger menu)
- Project directory structure setup

### Out of Scope
- Content pages (Home, Worlds, Rules, Contact) - handled in Epic 002
- Backend API - handled in Epic 003
- Interactive widgets (ServerStatus, ContactForm) - handled in Epic 004
- Production deployment - handled in Epic 005

### Boundaries
This epic provides the technical foundation and theming infrastructure. All content, interactive features, and deployment are separate epics that build on this foundation.

## Dependencies

**Depends on:**
- No dependencies (foundation epic)

**Enables:**
- Epic 002: Content Pages & UI Component Library - needs foundation to build pages
- Epic 004: Interactive Features & Frontend Integration - needs theme system and hooks

**No dependencies:** This is the foundation epic and can start immediately.

## Estimated Stories

**Story count:** ~6 user stories

**Complexity:** Medium

**Estimated effort:** Small to Medium epic (1-2 days)

## Technical Considerations

- **Tailwind v4 Breaking Changes**: Must use `@import "tailwindcss"` instead of `@tailwind` directives, and config must be `.js` not `.ts`
- **React 19**: Latest version with concurrent rendering - ensure compatibility with all dependencies
- **Theme Implementation**: Use class-based dark mode (`<html class="dark">`) for best Tailwind v4 compatibility
- **Performance**: Vite provides fast HMR, but ensure Tailwind JIT mode is properly configured

## Risks & Assumptions

**Risks:**
- Tailwind v4 is relatively new - may encounter edge cases or documentation gaps (mitigation: refer to v4 migration guide)
- React 19 compatibility issues with third-party libraries (mitigation: verify all dependencies support React 19)

**Assumptions:**
- Node.js 20 is available in development environment
- Developers are familiar with React hooks and Context API
- Modern browser support is sufficient (no IE11 requirement)

## Related Epics

- Epic 002: Content Pages & UI Component Library - builds on this foundation
- Epic 004: Interactive Features & Frontend Integration - uses theme context

## Source Reference

**Original PRD/Spec:** web/WEB-COMPLETE-PLAN.md

**Relevant sections:**
- Phase 1: Foundation (lines 710-737)
- Technology Stack (lines 175-199)
- Key Technical Decisions - Dark Mode Strategy (lines 274-293)
- Key Technical Decisions - Tailwind CSS v4 Setup (lines 295-321)
- Component Architecture - Layout Components (lines 326-348)

---

**Next step:** Run `/story-creator .storyline/epics/epic-001-website-foundation-theme.md`
