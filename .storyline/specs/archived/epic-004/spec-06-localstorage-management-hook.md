---
spec_id: 06
story_id: 006
epic_id: 004
title: LocalStorage Management Hook
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 06: LocalStorage Management Hook

## Overview

**User story:** [.storyline/stories/epic-004/story-06-localstorage-management-hook.md](../../stories/epic-004/story-06-localstorage-management-hook.md)

**Goal:** Implement a custom React hook `useLocalStorage` that provides type-safe, SSR-safe access to browser localStorage with automatic JSON serialization, error handling for disabled localStorage, and cross-tab synchronization via storage events.

**Approach:** Create a custom React hook using TypeScript generics that wraps localStorage operations with try/catch error handling, JSON serialization/deserialization, SSR safety checks, and storage event listeners for cross-tab synchronization. The hook returns a tuple `[value, setValue]` matching the familiar `useState` API.

## Technical Design

### Architecture Decision

**Chosen approach:** Custom React hook with TypeScript generics and comprehensive error handling

**Alternatives considered:**
- **use-local-storage-state library** - External dependency (10KB), but custom implementation is simple and educational
- **Direct localStorage calls** - No abstraction, prone to errors and code duplication
- **Zustand/Redux persist** - Overkill for simple key-value storage, adds complexity
- **SessionStorage wrapper** - Different API, doesn't persist across browser sessions

**Rationale:** A custom hook with TypeScript generics provides full type safety, zero dependencies, minimal bundle impact (~1KB), and complete control over error handling and edge cases. It's educational, reusable, and matches the `useState` API for developer familiarity.

### System Components

**Frontend:**
- `web/src/hooks/useLocalStorage.ts` - Custom React hook with TypeScript generics (new file)
- `web/src/hooks/__tests__/useLocalStorage.test.ts` - Unit tests (new file)

**Backend:**
- None (client-side only)

**Database:**
- None (browser localStorage)

**External integrations:**
- Browser localStorage API
- Browser storage event API (cross-tab sync)

## Implementation Details

### Files to Create

#### `web/src/hooks/useLocalStorage.ts`
**Purpose:** Type-safe React hook for localStorage with error handling and cross-tab sync
**Exports:**
- `useLocalStorage<T>()` hook (default export)

**Implementation:**
```typescript
import { useState, useEffect, useCallback, Dispatch, SetStateAction } from 'react';

/**
 * Custom hook for type-safe localStorage access with SSR safety and cross-tab sync
 *
 * @param key - localStorage key name
 * @param defaultValue - fallback value if key doesn't exist
 * @returns [value, setValue] tuple matching useState API
 *
 * @example
 * const [theme, setTheme] = useLocalStorage<string>('theme', 'light');
 * setTheme('dark'); // Saves to localStorage and updates state
 */
export function useLocalStorage<T>(
  key: string,
  defaultValue: T
): [T, Dispatch<SetStateAction<T>>] {
  // SSR safety check - localStorage only available in browser
  const isClient = typeof window !== 'undefined';

  // Initialize state with value from localStorage or default
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (!isClient) {
      return defaultValue;
    }

    try {
      const item = window.localStorage.getItem(key);
      // Parse stored JSON or return default if null
      return item ? (JSON.parse(item) as T) : defaultValue;
    } catch (error) {
      // Handle JSON parse errors or localStorage disabled
      console.warn(`Error reading localStorage key "${key}":`, error);
      return defaultValue;
    }
  });

  // Update localStorage when value changes
  const setValue: Dispatch<SetStateAction<T>> = useCallback(
    (value) => {
      try {
        // Allow value to be a function (like useState)
        const valueToStore = value instanceof Function ? value(storedValue) : value;

        // Update state
        setStoredValue(valueToStore);

        // Persist to localStorage (SSR safety check)
        if (isClient) {
          window.localStorage.setItem(key, JSON.stringify(valueToStore));
        }
      } catch (error) {
        // Handle quota exceeded or localStorage disabled
        console.warn(`Error writing localStorage key "${key}":`, error);
      }
    },
    [key, storedValue, isClient]
  );

  // Listen for storage events from other tabs (cross-tab sync)
  useEffect(() => {
    if (!isClient) {
      return;
    }

    const handleStorageChange = (e: StorageEvent) => {
      // Only respond to changes to our key from other tabs
      if (e.key === key && e.newValue !== null) {
        try {
          setStoredValue(JSON.parse(e.newValue) as T);
        } catch (error) {
          console.warn(`Error parsing storage event for key "${key}":`, error);
        }
      }
    };

    // Add event listener
    window.addEventListener('storage', handleStorageChange);

    // Cleanup listener on unmount
    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  }, [key, isClient]);

  return [storedValue, setValue];
}
```

### Files to Modify

None - This is a standalone utility hook with no dependencies on existing files.

### API Contracts

**Hook signature:**
```typescript
function useLocalStorage<T>(
  key: string,
  defaultValue: T
): [T, Dispatch<SetStateAction<T>>]
```

**TypeScript generics:**
- `T` - Type of the stored value (inferred from defaultValue)
- Supports primitives: `string`, `number`, `boolean`
- Supports complex types: `object`, `array`, custom interfaces
- Enforces type consistency between defaultValue and setValue

**localStorage operations:**
- **Read:** `localStorage.getItem(key)` + `JSON.parse()`
- **Write:** `JSON.stringify(value)` + `localStorage.setItem(key, value)`
- **Sync:** Listen to `storage` event for cross-tab updates

### Database Changes

None - Uses browser localStorage (client-side only).

### State Management

**State shape:**
```typescript
{
  storedValue: T  // Current value (from localStorage or default)
}
```

**Hook behavior:**
1. **Initial mount (SSR)**: Returns `defaultValue`, no localStorage access
2. **Initial mount (browser)**: Reads from localStorage, falls back to `defaultValue` if not found
3. **setValue call**: Updates state and writes to localStorage (with error handling)
4. **Storage event**: Syncs value from other tabs automatically
5. **Unmount**: Removes storage event listener

**Error handling:**
- **localStorage disabled** (private browsing): Falls back to in-memory state, logs warning
- **Quota exceeded**: Catches error, logs warning, state remains unchanged
- **JSON parse error**: Falls back to `defaultValue`, logs warning
- **SSR rendering**: Safely returns `defaultValue` without accessing `window`

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Read existing localStorage value
**Verification:**
- Unit test: Set localStorage manually, mount hook, verify it returns stored value
- Unit test: Verify no errors occur when reading valid JSON
- Manual check: Set theme in localStorage, refresh page, verify hook reads it

**Story criterion 2:** Write to localStorage
**Verification:**
- Unit test: Call setValue, verify localStorage.setItem called with correct JSON
- Unit test: Verify state updates and component re-renders
- Unit test: Refresh simulation (remount hook), verify value persists
- Manual check: Call setTheme('dark'), refresh page, verify persistence

**Story criterion 3:** Use default value when no stored value exists
**Verification:**
- Unit test: Clear localStorage, mount hook, verify returns defaultValue
- Unit test: Verify defaultValue NOT written to localStorage initially
- Unit test: Only write to localStorage on explicit setValue call
- Manual check: Clear localStorage, load app, verify default theme applied

**Story criterion 4:** Handle localStorage errors gracefully
**Verification:**
- Unit test: Mock localStorage.setItem to throw, verify hook catches error
- Unit test: Verify console.warn called with error details
- Unit test: Verify app continues working (state falls back to in-memory)
- Manual check: Private browsing mode, verify no crashes, check console

**Story criterion 5:** Type safety with TypeScript
**Verification:**
- Compile test: Pass wrong type to setValue, verify TypeScript error
- Compile test: Verify generic type inference from defaultValue
- IDE test: Verify autocomplete works for typed values
- Manual check: Intentionally pass wrong type, verify tsc catches it

## Testing Requirements

### Unit Tests

**File:** `web/src/hooks/__tests__/useLocalStorage.test.ts`

```typescript
import { renderHook, act } from '@testing-library/react';
import { useLocalStorage } from '../useLocalStorage';

// Mock console.warn to avoid test noise
const originalWarn = console.warn;
beforeAll(() => {
  console.warn = jest.fn();
});
afterAll(() => {
  console.warn = originalWarn;
});

describe('useLocalStorage', () => {
  beforeEach(() => {
    // Clear localStorage before each test
    localStorage.clear();
    jest.clearAllMocks();
  });

  describe('Initialization', () => {
    it('should return default value when localStorage is empty', () => {
      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      expect(result.current[0]).toBe('light');
    });

    it('should return stored value when localStorage has data', () => {
      localStorage.setItem('theme', JSON.stringify('dark'));

      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      expect(result.current[0]).toBe('dark');
    });

    it('should handle complex objects', () => {
      const defaultUser = { name: 'Guest', admin: false };
      const storedUser = { name: 'Alice', admin: true };
      localStorage.setItem('user', JSON.stringify(storedUser));

      const { result } = renderHook(() => useLocalStorage('user', defaultUser));

      expect(result.current[0]).toEqual(storedUser);
    });

    it('should handle arrays', () => {
      const storedArray = [1, 2, 3, 4, 5];
      localStorage.setItem('numbers', JSON.stringify(storedArray));

      const { result } = renderHook(() => useLocalStorage('numbers', []));

      expect(result.current[0]).toEqual(storedArray);
    });

    it('should not write default value to localStorage on init', () => {
      renderHook(() => useLocalStorage('theme', 'light'));

      expect(localStorage.getItem('theme')).toBeNull();
    });
  });

  describe('setValue', () => {
    it('should update state and localStorage', () => {
      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      act(() => {
        result.current[1]('dark');
      });

      expect(result.current[0]).toBe('dark');
      expect(localStorage.getItem('theme')).toBe(JSON.stringify('dark'));
    });

    it('should support functional updates', () => {
      const { result } = renderHook(() => useLocalStorage('count', 0));

      act(() => {
        result.current[1]((prev) => prev + 1);
      });

      expect(result.current[0]).toBe(1);
      expect(localStorage.getItem('count')).toBe('1');

      act(() => {
        result.current[1]((prev) => prev + 1);
      });

      expect(result.current[0]).toBe(2);
      expect(localStorage.getItem('count')).toBe('2');
    });

    it('should persist complex objects', () => {
      const { result } = renderHook(() =>
        useLocalStorage('settings', { theme: 'light', lang: 'en' })
      );

      const newSettings = { theme: 'dark', lang: 'es' };

      act(() => {
        result.current[1](newSettings);
      });

      expect(result.current[0]).toEqual(newSettings);
      expect(JSON.parse(localStorage.getItem('settings')!)).toEqual(newSettings);
    });
  });

  describe('Error Handling', () => {
    it('should handle JSON parse errors gracefully', () => {
      // Set invalid JSON
      localStorage.setItem('theme', 'invalid-json-{');

      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      expect(result.current[0]).toBe('light');
      expect(console.warn).toHaveBeenCalledWith(
        expect.stringContaining('Error reading localStorage'),
        expect.any(Error)
      );
    });

    it('should handle localStorage.setItem errors', () => {
      // Mock localStorage.setItem to throw
      const setItemSpy = jest.spyOn(Storage.prototype, 'setItem');
      setItemSpy.mockImplementation(() => {
        throw new Error('QuotaExceededError');
      });

      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      act(() => {
        result.current[1]('dark');
      });

      // State should update even if localStorage fails
      expect(result.current[0]).toBe('dark');
      expect(console.warn).toHaveBeenCalledWith(
        expect.stringContaining('Error writing localStorage'),
        expect.any(Error)
      );

      setItemSpy.mockRestore();
    });

    it('should handle localStorage.getItem errors', () => {
      // Mock localStorage.getItem to throw
      const getItemSpy = jest.spyOn(Storage.prototype, 'getItem');
      getItemSpy.mockImplementation(() => {
        throw new Error('SecurityError');
      });

      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      expect(result.current[0]).toBe('light');
      expect(console.warn).toHaveBeenCalledWith(
        expect.stringContaining('Error reading localStorage'),
        expect.any(Error)
      );

      getItemSpy.mockRestore();
    });
  });

  describe('Cross-tab Synchronization', () => {
    it('should sync value when storage event fires', () => {
      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      // Initial value
      expect(result.current[0]).toBe('light');

      // Simulate storage event from another tab
      act(() => {
        const event = new StorageEvent('storage', {
          key: 'theme',
          newValue: JSON.stringify('dark'),
          oldValue: JSON.stringify('light'),
        });
        window.dispatchEvent(event);
      });

      expect(result.current[0]).toBe('dark');
    });

    it('should ignore storage events for different keys', () => {
      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      act(() => {
        result.current[1]('dark');
      });

      // Simulate storage event for different key
      act(() => {
        const event = new StorageEvent('storage', {
          key: 'other-key',
          newValue: JSON.stringify('some-value'),
        });
        window.dispatchEvent(event);
      });

      // Value should remain unchanged
      expect(result.current[0]).toBe('dark');
    });

    it('should handle storage event with invalid JSON', () => {
      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      act(() => {
        const event = new StorageEvent('storage', {
          key: 'theme',
          newValue: 'invalid-json-{',
        });
        window.dispatchEvent(event);
      });

      // Value should remain unchanged
      expect(result.current[0]).toBe('light');
      expect(console.warn).toHaveBeenCalled();
    });

    it('should remove event listener on unmount', () => {
      const removeEventListenerSpy = jest.spyOn(window, 'removeEventListener');

      const { unmount } = renderHook(() => useLocalStorage('theme', 'light'));

      unmount();

      expect(removeEventListenerSpy).toHaveBeenCalledWith(
        'storage',
        expect.any(Function)
      );

      removeEventListenerSpy.mockRestore();
    });
  });

  describe('SSR Safety', () => {
    it('should return default value during SSR', () => {
      // Mock SSR environment (no window)
      const originalWindow = global.window;
      // @ts-ignore
      delete global.window;

      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      expect(result.current[0]).toBe('light');

      // Restore window
      global.window = originalWindow;
    });

    it('should not crash when calling setValue during SSR', () => {
      // Mock SSR environment
      const originalWindow = global.window;
      // @ts-ignore
      delete global.window;

      const { result } = renderHook(() => useLocalStorage('theme', 'light'));

      expect(() => {
        act(() => {
          result.current[1]('dark');
        });
      }).not.toThrow();

      // State should update even without localStorage
      expect(result.current[0]).toBe('dark');

      // Restore window
      global.window = originalWindow;
    });
  });

  describe('Type Safety', () => {
    it('should enforce string type', () => {
      const { result } = renderHook(() => useLocalStorage<string>('theme', 'light'));

      act(() => {
        result.current[1]('dark');
      });

      expect(result.current[0]).toBe('dark');
    });

    it('should enforce number type', () => {
      const { result } = renderHook(() => useLocalStorage<number>('count', 0));

      act(() => {
        result.current[1](42);
      });

      expect(result.current[0]).toBe(42);
    });

    it('should enforce boolean type', () => {
      const { result } = renderHook(() => useLocalStorage<boolean>('enabled', false));

      act(() => {
        result.current[1](true);
      });

      expect(result.current[0]).toBe(true);
    });

    it('should enforce custom interface type', () => {
      interface User {
        name: string;
        age: number;
      }

      const { result } = renderHook(() =>
        useLocalStorage<User>('user', { name: 'Guest', age: 0 })
      );

      act(() => {
        result.current[1]({ name: 'Alice', age: 30 });
      });

      expect(result.current[0]).toEqual({ name: 'Alice', age: 30 });
    });
  });
});
```

**Coverage target:** 100% (all branches, all edge cases)

### Integration Tests

**Scenario 1:** Theme persistence across page refresh
- Setup: Mount app with useLocalStorage for theme
- Action: Set theme to 'dark', unmount and remount component
- Assert: Theme remains 'dark' after remount
- Assert: localStorage contains correct JSON value

**Scenario 2:** Cross-tab synchronization
- Setup: Open app in two browser tabs
- Action: Change theme in Tab 1
- Assert: Theme updates automatically in Tab 2
- Assert: No page refresh required

**Scenario 3:** Private browsing mode
- Setup: Open app in private browsing mode (localStorage disabled)
- Action: Change theme
- Assert: Theme changes in current session (in-memory state)
- Assert: Warning logged to console
- Assert: App continues working (no crash)

### Manual Testing

- [ ] Set theme to 'dark', refresh page, verify theme persists
- [ ] Clear localStorage, load app, verify default theme applied
- [ ] Open app in two tabs, change theme in one, verify other updates automatically
- [ ] Open app in private browsing mode, change theme, verify no crash
- [ ] Check console for warnings in private browsing mode
- [ ] Test with different data types (string, number, boolean, object, array)
- [ ] Test in Chrome, Firefox, Safari (cross-browser)
- [ ] Test on mobile browsers (iOS Safari, Android Chrome)

## Dependencies

**Must complete first:**
- None - Standalone utility hook

**Enables:**
- Epic 001: Theme System - will use this hook for theme persistence
- Any feature requiring localStorage (future enhancements)

## Risks & Mitigations

**Risk 1:** localStorage disabled in private browsing mode
**Mitigation:** Wrap all localStorage operations in try/catch, fall back to in-memory state
**Fallback:** App continues working with in-memory state, preferences lost on refresh

**Risk 2:** localStorage quota exceeded (5-10MB limit)
**Mitigation:** Catch QuotaExceededError, log warning, prevent app crash
**Fallback:** Use sessionStorage for larger data (future enhancement)

**Risk 3:** JSON serialization fails for circular references
**Mitigation:** Document that hook only supports JSON-serializable values
**Fallback:** Add custom serializer parameter (future enhancement)

**Risk 4:** Storage event not supported in older browsers
**Mitigation:** Feature is progressive enhancement, core functionality works without it
**Fallback:** Cross-tab sync gracefully degrades (each tab maintains own state)

**Risk 5:** SSR hydration mismatch (server vs client default value)
**Mitigation:** Check `typeof window !== 'undefined'` before localStorage access
**Fallback:** Use `useEffect` to update state after hydration (if needed)

## Performance Considerations

**Expected load:** Minimal - localStorage operations are synchronous and fast
- Read: <1ms (synchronous localStorage.getItem + JSON.parse)
- Write: <1ms (synchronous JSON.stringify + localStorage.setItem)
- Storage event listener: Negligible overhead (only fires on other tab changes)

**Optimization strategy:**
- Use `useCallback` for setValue to prevent unnecessary re-renders
- Storage event listener only updates state when key matches
- No expensive computations or async operations

**Benchmarks:**
- Hook initialization: <1ms
- setValue call: <1ms
- Cross-tab sync: <10ms (event propagation)
- Memory footprint: <1KB per hook instance

**Bundle size:**
- Hook implementation: ~1.5KB uncompressed
- Zero dependencies (uses only React and browser APIs)

## Security Considerations

**Authentication:** Not applicable (client-side storage only)

**Authorization:** Not applicable (user controls their own localStorage)

**Data validation:**
- Validate JSON.parse output matches expected type (TypeScript provides compile-time checking)
- Sanitize values before display (responsibility of consuming components)
- No server-side validation needed (client-side only)

**Sensitive data:**
- Do NOT store sensitive data (passwords, tokens, PII) in localStorage
- localStorage is NOT encrypted and accessible via JavaScript
- Document security best practices in hook JSDoc comments

**Additional notes:**
- localStorage is vulnerable to XSS attacks (inject script can read localStorage)
- Use httpOnly cookies for sensitive authentication tokens (not localStorage)
- localStorage persists across browser sessions (unlike sessionStorage)
- Consider encryption for sensitive preferences (future enhancement)

## Success Verification

After implementation, verify:
- [ ] All unit tests pass (`pnpm test useLocalStorage`)
- [ ] 100% code coverage achieved
- [ ] Manual testing checklist complete (all browsers)
- [ ] Acceptance criteria from story satisfied (all 5 scenarios)
- [ ] No console errors or warnings (except expected warnings in error scenarios)
- [ ] TypeScript compiles with no errors (`pnpm tsc`)
- [ ] ESLint passes with no warnings (`pnpm lint`)
- [ ] Bundle size impact <2KB (`pnpm build && pnpm analyze`)
- [ ] Works in SSR environment (no window access errors)
- [ ] Works in private browsing mode (graceful degradation)
- [ ] Cross-tab sync works in all modern browsers

## Traceability

**Parent story:** [.storyline/stories/epic-004/story-06-localstorage-management-hook.md](../../stories/epic-004/story-06-localstorage-management-hook.md)

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

## Implementation Notes

**Package manager:** Use `pnpm` not `npm`

**Import aliases:** Use `@/` for `src/` directory (configured in tsconfig.json)

**Testing library:** `@testing-library/react` for hook testing, `vitest` as test runner

**TypeScript version:** 5.7+ with strict mode enabled

**React version:** React 19 (ensure hooks work with concurrent features)

**Browser support:**
- localStorage API: 98%+ browser support (IE8+)
- Storage event API: 97%+ browser support (IE9+, mobile Safari 8+)
- TypeScript `typeof` check: 100% support (compile-time only)

**Open questions:**
- Should we add TTL (time-to-live) for auto-expiring values? (Decided: No, keep simple, add in future if needed)
- Should we support custom serializers (beyond JSON)? (Decided: No, JSON covers 99% of use cases)
- Should we add a `removeItem` helper? (Decided: No, users can call `setValue(defaultValue)`)

**Assumptions:**
- localStorage available in all target browsers (no IE11 required)
- JSON.stringify/parse sufficient for all stored values
- Storage events work consistently across modern browsers
- Users accept ~1-2 second delay for cross-tab sync

**Future enhancements:**
- Add TTL support for auto-expiring values (e.g., cache invalidation)
- Add compression for large values (LZ-string library)
- Add encryption for sensitive values (Web Crypto API)
- Add storage quota monitoring and warnings
- Add batch operations (setMultiple, getMultiple)
- Add storage namespace/prefix support (avoid key collisions)

---

**Next step:** Run `/dev-story .storyline/specs/epic-004/spec-06-localstorage-management-hook.md`
