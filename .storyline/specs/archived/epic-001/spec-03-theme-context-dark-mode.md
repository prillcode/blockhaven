---
spec_id: 03
story_id: 03
epic_id: 001
title: Theme Context & Dark Mode Implementation
status: ready_for_implementation
created: 2026-01-10
---

# Technical Spec 03: Theme Context & Dark Mode Implementation

## Overview

**User story:** .storyline/stories/epic-001/story-03-theme-context-dark-mode.md

**Goal:** Implement a global theme system using React Context API with localStorage persistence and system preference detection, enabling users to toggle between light and dark modes.

**Approach:** Create ThemeContext provider with theme state management, useTheme custom hook for easy access, ThemeToggle widget component, and logic to detect system preferences and persist user choices to localStorage while preventing FOUC (Flash of Unstyled Content).

## Technical Design

### Architecture Decision

**Chosen approach:** React Context API + localStorage + class-based dark mode

**Alternatives considered:**
- **next-themes library** - Adds unnecessary dependency, overkill for simple theme toggle
- **CSS variables only with media query** - Loses persistence, can't override system preference
- **Redux/Zustand** - Over-engineered for single piece of state

**Rationale:** Context API is built into React, perfect for global state like themes. Class-based dark mode (`<html class="dark">`) integrates seamlessly with Tailwind CSS v4. localStorage provides simple persistence without backend complexity.

### System Components

**Frontend:**
- ThemeContext: React context providing theme state and toggle function
- ThemeProvider: Context provider component wrapping the app
- useTheme hook: Custom hook for accessing theme context
- ThemeToggle widget: Button component for toggling theme
- Theme initialization logic: Prevents FOUC and respects user/system preferences

**Backend:**
- Not applicable

**Database:**
- Not applicable (localStorage only)

**External integrations:**
- None

## Implementation Details

### Files to Create

```
/home/aaronprill/projects/blockhaven/web/src/contexts/ThemeContext.tsx
- Purpose: Theme context provider with state management
- Exports: ThemeProvider component, ThemeContext
```

```
/home/aaronprill/projects/blockhaven/web/src/hooks/useTheme.ts
- Purpose: Custom hook for accessing theme context
- Exports: useTheme hook
```

```
/home/aaronprill/projects/blockhaven/web/src/components/widgets/ThemeToggle.tsx
- Purpose: Theme toggle button component
- Exports: ThemeToggle component
```

### Files to Modify

```
/home/aaronprill/projects/blockhaven/web/src/main.tsx
- Changes: Wrap App with ThemeProvider
- Location: Before <App /> in render
- Reason: Make theme context available to all components
```

```
/home/aaronprill/projects/blockhaven/web/src/App.tsx
- Changes: Add ThemeToggle button for testing
- Location: Temporary - will move to Header in Spec 004
- Reason: Test theme functionality before Header exists
```

```
/home/aaronprill/projects/blockhaven/web/index.html
- Changes: Add inline script to prevent FOUC
- Location: <head> section before any stylesheets
- Reason: Apply theme class to <html> before React hydrates
```

### Detailed File Contents

#### src/contexts/ThemeContext.tsx
```typescript
import { createContext, useEffect, useState, ReactNode } from 'react';

export type Theme = 'light' | 'dark';

interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
}

export const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

const STORAGE_KEY = 'blockhaven-theme';

function getInitialTheme(): Theme {
  // 1. Check localStorage first (user preference)
  if (typeof window !== 'undefined') {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored === 'light' || stored === 'dark') {
      return stored;
    }

    // 2. Fall back to system preference
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
  }

  // 3. Default to light
  return 'light';
}

function applyTheme(theme: Theme) {
  const root = document.documentElement;
  if (theme === 'dark') {
    root.classList.add('dark');
  } else {
    root.classList.remove('dark');
  }
}

interface ThemeProviderProps {
  children: ReactNode;
}

export function ThemeProvider({ children }: ThemeProviderProps) {
  const [theme, setTheme] = useState<Theme>(getInitialTheme);

  useEffect(() => {
    // Apply theme to <html> element
    applyTheme(theme);

    // Persist to localStorage
    localStorage.setItem(STORAGE_KEY, theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme((prev) => (prev === 'light' ? 'dark' : 'light'));
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}
```

#### src/hooks/useTheme.ts
```typescript
import { useContext } from 'react';
import { ThemeContext } from '../contexts/ThemeContext';

export function useTheme() {
  const context = useContext(ThemeContext);

  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }

  return context;
}
```

#### src/components/widgets/ThemeToggle.tsx
```typescript
import { Moon, Sun } from 'lucide-react';
import { useTheme } from '../../hooks/useTheme';

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      onClick={toggleTheme}
      className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
      aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
      title={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
    >
      {theme === 'light' ? (
        <Moon className="w-5 h-5 text-gray-700 dark:text-gray-300" />
      ) : (
        <Sun className="w-5 h-5 text-gray-700 dark:text-gray-300" />
      )}
    </button>
  );
}
```

#### src/main.tsx (update)
```typescript
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './styles/index.css'
import App from './App.tsx'
import { ThemeProvider } from './contexts/ThemeContext'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider>
      <App />
    </ThemeProvider>
  </StrictMode>,
)
```

#### index.html (add FOUC prevention script)
```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>BlockHaven</title>

    <!-- Prevent FOUC: Apply theme before React renders -->
    <script>
      (function() {
        const stored = localStorage.getItem('blockhaven-theme');
        const theme = stored === 'dark' || stored === 'light'
          ? stored
          : (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');

        if (theme === 'dark') {
          document.documentElement.classList.add('dark');
        }
      })();
    </script>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

#### src/App.tsx (demo with ThemeToggle)
```typescript
import { ThemeToggle } from './components/widgets/ThemeToggle'

function App() {
  return (
    <div className="min-h-screen bg-white dark:bg-gray-900 text-gray-900 dark:text-white transition-colors">
      <div className="container mx-auto px-4 py-16">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold text-minecraft-grass">
            BlockHaven
          </h1>
          <ThemeToggle />
        </div>

        <p className="text-lg mb-4">
          Theme system is working! Toggle the theme with the button above.
        </p>

        <div className="grid md:grid-cols-2 gap-4">
          <div className="p-6 bg-gray-100 dark:bg-gray-800 rounded-lg">
            <h2 className="font-bold mb-2">Light Mode</h2>
            <p className="text-sm">Clean and bright for daytime browsing</p>
          </div>

          <div className="p-6 bg-gray-100 dark:bg-gray-800 rounded-lg">
            <h2 className="font-bold mb-2">Dark Mode</h2>
            <p className="text-sm">Easy on the eyes for night gaming</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
```

## Acceptance Criteria Mapping

### Story Criterion 1: ThemeContext provides theme state
**Verification:**
- Unit test: Import useTheme in test component, verify theme and toggleTheme exist
- Manual: Add console.log in App.tsx, verify theme value logs correctly

### Story Criterion 2: System preference detected on first visit
**Verification:**
- Manual: Clear localStorage, set OS to dark mode, reload page → should be dark
- Manual: Clear localStorage, set OS to light mode, reload page → should be light
- Test in Chrome DevTools: Rendering → prefers-color-scheme override

### Story Criterion 3: Theme persists to localStorage
**Verification:**
- Manual: Toggle theme, check localStorage in DevTools (Application tab)
- Manual: Verify key is 'blockhaven-theme' with value 'light' or 'dark'
- Manual: Inspect <html> element, verify class="dark" added/removed

### Story Criterion 4: Theme loads from localStorage on return visit
**Verification:**
- Manual: Set theme to dark, reload page → should stay dark
- Manual: Set localStorage manually to 'light', reload → should be light
- Manual: Verify system preference ignored when localStorage exists

### Story Criterion 5: ThemeToggle widget works
**Verification:**
- Manual: Click toggle button, verify theme switches instantly
- Manual: Verify icon changes from Sun to Moon (and vice versa)
- Manual: Verify no flash/flicker during transition
- Manual: Verify hover effect works

### Story Criterion 6: Dark mode styles apply correctly
**Verification:**
- Manual: Toggle to dark mode, verify background changes to dark
- Manual: Verify all dark: classes apply throughout page
- Accessibility: Check contrast ratios meet WCAG AA (4.5:1 for text)

## Testing Requirements

### Unit Tests

Create `src/contexts/__tests__/ThemeContext.test.tsx`:
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { ThemeProvider } from '../ThemeContext';
import { useTheme } from '../../hooks/useTheme';

function TestComponent() {
  const { theme, toggleTheme } = useTheme();
  return (
    <div>
      <div>Current theme: {theme}</div>
      <button onClick={toggleTheme}>Toggle</button>
    </div>
  );
}

describe('ThemeContext', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('provides theme and toggleTheme', () => {
    render(
      <ThemeProvider>
        <TestComponent />
      </ThemeProvider>
    );
    expect(screen.getByText(/Current theme:/)).toBeInTheDocument();
  });

  it('toggles theme', () => {
    render(
      <ThemeProvider>
        <TestComponent />
      </ThemeProvider>
    );
    const button = screen.getByText('Toggle');
    fireEvent.click(button);
    // Verify theme changed
  });

  it('persists to localStorage', () => {
    render(
      <ThemeProvider>
        <TestComponent />
      </ThemeProvider>
    );
    const button = screen.getByText('Toggle');
    fireEvent.click(button);
    expect(localStorage.getItem('blockhaven-theme')).toBeTruthy();
  });
});
```

### Manual Testing Checklist

- [ ] Run `pnpm dev` successfully
- [ ] See ThemeToggle button in top right
- [ ] Click toggle, verify background changes light ↔ dark
- [ ] Verify icon changes Sun ↔ Moon
- [ ] Open DevTools → Application → Local Storage, verify 'blockhaven-theme' key
- [ ] Inspect <html> element, verify class="dark" toggles
- [ ] Reload page, verify theme persists
- [ ] Clear localStorage, set OS to dark mode, reload → should be dark
- [ ] Clear localStorage, set OS to light mode, reload → should be light
- [ ] Toggle theme, reload multiple times → should stay consistent
- [ ] Verify no flash of wrong theme on page load (FOUC)
- [ ] Test in Chrome, Firefox, Safari
- [ ] Test keyboard navigation (Tab to button, Enter to toggle)

## Dependencies

**Must complete first:**
- Spec 01: Vite + React Project Initialization
- Spec 02: Tailwind CSS Configuration (needs darkMode: 'class' config)

**Enables:**
- Spec 004: Header Component (Header will include ThemeToggle)
- All future components (can use useTheme hook and dark: variants)

## Risks & Mitigations

**Risk 1:** Flash of Unstyled Content (FOUC) on page load
**Mitigation:** Inline script in index.html applies theme before React hydration
**Fallback:** If FOUC persists, use CSS-only approach with `color-scheme` property

**Risk 2:** localStorage not available (private browsing, old browsers)
**Mitigation:** Wrap localStorage calls in try-catch, fall back to memory-only state
**Fallback:** Theme resets on page reload, but app remains functional

**Risk 3:** System preference detection fails
**Mitigation:** Default to light mode if matchMedia not supported
**Fallback:** Always start with light mode, let user manually toggle

## Success Verification

After implementation, verify:
- [ ] `pnpm dev` starts without errors
- [ ] ThemeToggle button renders and is clickable
- [ ] Theme switches between light and dark instantly
- [ ] localStorage stores 'blockhaven-theme' correctly
- [ ] System preference detected on first visit (when no localStorage)
- [ ] Theme persists across page reloads
- [ ] No FOUC (flash) when page loads
- [ ] Dark mode styles (dark: variants) work throughout app
- [ ] Icons change correctly (Sun ↔ Moon)
- [ ] Smooth transition animations work

## Traceability

**Parent story:** .storyline/stories/epic-001/story-03-theme-context-dark-mode.md
**Parent epic:** .storyline/epics/epic-001-website-foundation-theme.md

## Implementation Notes

**Working directory:** `/home/aaronprill/projects/blockhaven/web/`

**Order of operations:**
1. Create src/contexts/ThemeContext.tsx
2. Create src/hooks/useTheme.ts
3. Create src/components/widgets/ThemeToggle.tsx
4. Update src/main.tsx to wrap App with ThemeProvider
5. Add FOUC prevention script to index.html
6. Update App.tsx to test ThemeToggle
7. Test manually in browser
8. Verify localStorage persistence
9. Test system preference detection

**Icons from lucide-react:**
- Sun: Indicates light mode is active (clicking switches to dark)
- Moon: Indicates dark mode is active (clicking switches to light)

**localStorage key:** 'blockhaven-theme' (consistent with plan)

**Time estimate:** 2-3 hours

---

**Next step:** Run `/dev-story .storyline/specs/epic-001/spec-003-theme-context-dark-mode.md`
