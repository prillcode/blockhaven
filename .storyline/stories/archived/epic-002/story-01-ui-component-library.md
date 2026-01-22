---
story_id: 01
epic_id: 002
title: Reusable UI Component Library
status: ready_for_spec
created: 2026-01-12
---

# Story 01: Reusable UI Component Library

## User Story

**As a** BlockHaven website developer,
**I want** a library of reusable UI components (Button, Card, Badge, Input, Textarea, Toast, LoadingSpinner),
**so that** I can build pages with consistent styling and behavior without duplicating code.

## Acceptance Criteria

### Scenario 1: Button component with variants
**Given** I need a button in my page
**When** I use `<Button variant="primary">Click Me</Button>`
**Then** the button renders with primary styling (bg-primary-500)
**And** hover effects work correctly
**And** loading state is supported
**And** disabled state works

### Scenario 2: Card component wraps content
**Given** I need to group content in a card
**When** I use `<Card>Content</Card>`
**Then** the card renders with white bg (dark mode compatible)
**And** padding and border-radius applied
**And** shadow effects work

### Scenario 3: Badge component shows status
**Given** I need to display a status or label
**When** I use `<Badge variant="success">Easy</Badge>`
**Then** the badge renders with success color styling
**And** different variants work (success, warning, error, default)

### Scenario 4: Form inputs with validation states
**Given** I need form inputs
**When** I use `<Input>` and `<Textarea>`
**Then** they render with consistent styling
**And** error states can be displayed
**And** placeholder and label props work

### Scenario 5: Toast notifications display
**Given** I need to show user feedback
**When** a toast is triggered
**Then** it appears with correct styling and icon
**And** it auto-dismisses after timeout
**And** multiple toasts stack correctly

### Scenario 6: LoadingSpinner shows loading state
**Given** I need to indicate loading
**When** I use `<LoadingSpinner size="md" />`
**Then** animated spinner displays
**And** different sizes work (sm, md, lg)

## Business Value

**Why this matters:** UI component library is the foundation for all visual elements. Consistent components ensure brand cohesion and accelerate development.

**Impact:** Developers can build pages 3-5x faster using pre-built components instead of custom styling each element.

**Success metric:** All components used across at least 3 different pages without modifications.

## Technical Considerations

**Potential approaches:**
- Build custom components with Tailwind (recommended - full control)
- Use headless UI library like Radix (adds dependency, but better accessibility)

**Constraints:**
- Must use Tailwind CSS for styling
- Must support dark mode with dark: variants
- Must be fully typed with TypeScript
- Must work with theme context from Epic 001

**Data requirements:**
- Props interfaces for each component
- Variant types (ButtonVariant, BadgeVariant)
- Size types (Size = 'sm' | 'md' | 'lg')

**Components to create:**
1. **Button** - primary, secondary, outline, ghost variants
2. **Card** - content wrapper with padding and shadow
3. **Badge** - status/label indicator with color variants
4. **Input** - text input with label and error states
5. **Textarea** - multi-line text input
6. **Toast** - notification popup (success, error, info)
7. **LoadingSpinner** - animated loading indicator

## Dependencies

**Depends on stories:**
- Epic 001 complete (needs Tailwind, theme, base layout)

**Enables stories:**
- Story 03: WorldCard (uses Button, Card, Badge)
- Story 04: Hero (uses Button)
- Story 05-07: All section components (use UI components)
- Story 08-10: All pages (use UI components)

**No dependencies:** Can start immediately after Epic 001.

## Out of Scope

- Complex form validation logic (just UI components)
- Toast queue management system (simple implementation)
- Accessibility testing (should be done, but not blocking)
- Storybook or component documentation (nice to have)

## Notes

- Use Tailwind's `clsx` and `tailwind-merge` for className composition
- Follow naming convention: PascalCase for components
- Export from `src/components/ui/index.ts` for clean imports
- Add TODO comments for future accessibility improvements

## Traceability

**Parent epic:** .storyline/epics/epic-002-content-pages-ui-library.md

**Related stories:** All other stories in Epic 002 use these components

---

**Next step:** Run `/spec-story .storyline/stories/epic-002/story-01-ui-component-library.md`
