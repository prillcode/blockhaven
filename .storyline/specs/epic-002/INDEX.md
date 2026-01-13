# Epic 002: Technical Specifications Index

**Epic:** Content Pages & UI Component Library
**Generated:** 2026-01-12
**Total Specs:** 8 (from 11 stories)

---

## Spec Organization

### Story Combination Strategy
- **spec-01**: Story 01 (UI Library - 7 components)
- **spec-02**: Story 02 (Data & Types)
- **spec-03**: Story 03 (WorldCard)
- **spec-04-05-06-07**: Stories 04-07 (Homepage sections - Hero, WorldsShowcase, FeaturesGrid, ServerRules, CTA)
- **spec-08**: Story 08 (Home Page)
- **spec-09**: Story 09 (Worlds Page)
- **spec-10**: Story 10 (Rules & Contact Pages)
- **spec-11**: Story 11 (React Router)

---

## Specs Summary

### Spec 01: UI Component Library
**Stories covered:** 01
**Files to create:** 7 component files + 1 index
- Button.tsx, Card.tsx, Badge.tsx, Input.tsx, Textarea.tsx, Toast.tsx, LoadingSpinner.tsx
- ui/index.ts (barrel export)
**Estimated time:** 1 day

### Spec 02: Data Structures & TypeScript Types
**Stories covered:** 02
**Files to create:** 6 files
- types/world.ts, types/rank.ts
- data/worlds.ts, data/features.ts, data/rules.ts
- lib/utils.ts
**Estimated time:** 4-6 hours

### Spec 03: WorldCard Component
**Stories covered:** 03
**Files to create:** 1 file
- components/WorldCard.tsx
**Estimated time:** 3-4 hours

### Spec 04-05-06-07: Homepage Section Components
**Stories covered:** 04, 05, 06, 07
**Files to create:** 5 files
- sections/Hero.tsx
- sections/WorldsShowcase.tsx
- sections/FeaturesGrid.tsx
- sections/ServerRules.tsx
- sections/CallToAction.tsx
**Estimated time:** 1 day

### Spec 08: Home Page Assembly
**Stories covered:** 08
**Files to create:** 1 file
- pages/Home.tsx
**Estimated time:** 3-4 hours

### Spec 09: Worlds Detail Page
**Stories covered:** 09
**Files to create:** 1 file
- pages/Worlds.tsx
**Estimated time:** 5-6 hours

### Spec 10: Rules & Contact Pages
**Stories covered:** 10
**Files to create:** 2 files
- pages/Rules.tsx
- pages/Contact.tsx
**Estimated time:** 4-5 hours

### Spec 11: React Router Integration
**Stories covered:** 11
**Files to create/modify:** 2 files
- App.tsx (modify to add Router)
- main.tsx (wrap with BrowserRouter)
**Estimated time:** 3-4 hours

---

## Total Implementation Effort

**Estimated:** 3.5-4 days for complete Epic 002 implementation

---

## Detailed Spec Files

All detailed specs are in individual files:
- [spec-01-ui-component-library.md](./spec-01-ui-component-library.md)
- [spec-02-data-structures-types.md](./spec-02-data-structures-types.md)
- [spec-03-worldcard-component.md](./spec-03-worldcard-component.md)
- [spec-04-05-06-07-homepage-sections.md](./spec-04-05-06-07-homepage-sections.md)
- [spec-08-home-page-assembly.md](./spec-08-home-page-assembly.md)
- [spec-09-worlds-detail-page.md](./spec-09-worlds-detail-page.md)
- [spec-10-rules-contact-pages.md](./spec-10-rules-contact-pages.md)
- [spec-11-react-router-integration.md](./spec-11-react-router-integration.md)

---

**Status:** ✅ All specs ready for implementation
**Next Step:** Begin with spec-01 or spec-02 (no dependencies between them)
