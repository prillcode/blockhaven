---
spec_id: 01
story_id: 001
epic_id: 004
title: Server Status Polling Hook
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 01: Server Status Polling Hook

## Overview

**User story:** [.storyline/stories/epic-004/story-01-server-status-polling-hook.md](../../stories/epic-004/story-01-server-status-polling-hook.md)

**Goal:** Implement a custom React hook `useServerStatus` that polls the `/api/server-status` endpoint every 30 seconds and provides server status data, loading states, and error handling to consuming components.

**Approach:** Create a custom React hook using `useState` for state management, `useEffect` for side effects (polling + cleanup), and `AbortController` for request cancellation. The hook returns server data, loading state, and error state in a tuple format similar to `useState`.

## Technical Design

### Architecture Decision

**Chosen approach:** Custom React hook with built-in polling logic

**Alternatives considered:**
- **React Query / TanStack Query** - Overkill for a single polling endpoint; adds 40KB+ to bundle
- **SWR** - Good option but adds dependency; custom hook is simpler for this specific use case
- **WebSockets** - Server doesn't support WebSockets yet; polling is sufficient for 30-second refresh rate

**Rationale:** A custom hook provides full control over polling behavior, minimal bundle size impact, and matches the specific requirements (30-second interval, tab visibility detection, AbortController cleanup). It's educational and doesn't introduce unnecessary dependencies.

### System Components

**Frontend:**
- `web/src/hooks/useServerStatus.ts` - Custom React hook (new file)
- `web/src/types/api.ts` - TypeScript types for API responses (new file)
- `web/src/lib/api/minecraft-api.ts` - API client utilities (new file)

**Backend:**
- Uses existing `/api/server-status` endpoint (Epic 003, Story 02)
- No backend changes required

**Database:**
- None (read-only operation)

**External integrations:**
- None (internal API only)

## Implementation Details

### Files to Create

#### `web/src/hooks/useServerStatus.ts`
**Purpose:** Custom React hook that polls server status every 30 seconds
**Exports:**
- `useServerStatus()` hook (default export)
- `ServerStatusResult` type

**Implementation:**
```typescript
import { useState, useEffect, useCallback } from 'react';
import type { ServerStatus } from '@/types/api';

const API_ENDPOINT = '/api/server-status';
const POLLING_INTERVAL = 30000; // 30 seconds

export interface ServerStatusResult {
  data: ServerStatus | null;
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}

export function useServerStatus(): ServerStatusResult {
  const [data, setData] = useState<ServerStatus | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchServerStatus = useCallback(async (signal: AbortSignal) => {
    try {
      const response = await fetch(API_ENDPOINT, { signal });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const json = await response.json();
      setData(json);
      setError(null);
    } catch (err) {
      // Don't set error if request was aborted (component unmounted)
      if (err instanceof Error && err.name !== 'AbortError') {
        setError(err);
      }
    } finally {
      setLoading(false);
    }
  }, []);

  const refetch = useCallback(() => {
    setLoading(true);
    setError(null);
    const controller = new AbortController();
    fetchServerStatus(controller.signal);
  }, [fetchServerStatus]);

  useEffect(() => {
    const controller = new AbortController();

    // Initial fetch
    fetchServerStatus(controller.signal);

    // Set up polling
    const intervalId = setInterval(() => {
      // Only poll if tab is visible (battery optimization)
      if (document.visibilityState === 'visible') {
        fetchServerStatus(controller.signal);
      }
    }, POLLING_INTERVAL);

    // Cleanup function
    return () => {
      controller.abort();
      clearInterval(intervalId);
    };
  }, [fetchServerStatus]);

  return { data, loading, error, refetch };
}
```

#### `web/src/types/api.ts`
**Purpose:** TypeScript types for all API responses
**Exports:** Interface definitions for API contracts

**Implementation:**
```typescript
/**
 * Server status response from /api/server-status
 */
export interface ServerStatus {
  online: boolean;
  playerCount: number;
  maxPlayers: number;
  timestamp: string;
}

/**
 * Contact form submission request to /api/contact
 */
export interface ContactFormData {
  name: string;
  email: string;
  message: string;
}

/**
 * Generic API success response
 */
export interface ApiSuccessResponse {
  success: true;
  message?: string;
}

/**
 * Generic API error response
 */
export interface ApiErrorResponse {
  success: false;
  error: string;
}
```

#### `web/src/lib/api/minecraft-api.ts`
**Purpose:** Centralized API client for Minecraft server endpoints
**Exports:** Typed fetch functions for server endpoints

**Implementation:**
```typescript
import type { ServerStatus } from '@/types/api';

const API_BASE_URL = import.meta.env.VITE_API_URL || '';

/**
 * Fetch current server status
 */
export async function getServerStatus(signal?: AbortSignal): Promise<ServerStatus> {
  const response = await fetch(`${API_BASE_URL}/api/server-status`, {
    signal,
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch server status: ${response.statusText}`);
  }

  return response.json();
}
```

### Files to Modify

None - This is the first frontend implementation, so all files are new.

### API Contracts

#### Endpoint: GET /api/server-status

**Request:**
- No body
- No query parameters
- No authentication required

**Response (Success - 200):**
```json
{
  "online": true,
  "playerCount": 15,
  "maxPlayers": 100,
  "timestamp": "2026-01-12T10:30:00Z"
}
```

**Response (Error - 500):**
```json
{
  "error": "Failed to fetch server status"
}
```

**Headers:**
- `Content-Type: application/json`
- `Cache-Control: public, max-age=30` (30-second cache from Epic 003)

### Database Changes

None - Read-only operation using existing backend endpoint.

### State Management

**State shape:**
```typescript
{
  data: ServerStatus | null,      // Server status data or null if not loaded
  loading: boolean,                 // True during initial load
  error: Error | null,              // Error object if fetch failed
  refetch: () => void               // Manual refetch function
}
```

**Hook behavior:**
1. **Initial mount**: `loading: true`, `data: null`, `error: null`
2. **Successful fetch**: `loading: false`, `data: ServerStatus`, `error: null`
3. **Failed fetch**: `loading: false`, `data: null`, `error: Error`
4. **Polling updates**: `loading: false`, `data` updates, `error: null` (or Error if fails)

**Cleanup:**
- `clearInterval()` on unmount
- `AbortController.abort()` on unmount

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Initial server status fetch
**Verification:**
- Unit test: Mock fetch, verify hook calls `/api/server-status` on mount
- Unit test: Verify hook returns data in correct format
- Manual check: Open app, check browser DevTools Network tab for initial request

**Story criterion 2:** Automatic polling every 30 seconds
**Verification:**
- Unit test: Use Jest fake timers, advance 30 seconds, verify second fetch occurs
- Unit test: Advance 60 seconds, verify 2 additional fetches (total 3)
- Manual check: Open app, watch Network tab, verify requests every 30 seconds

**Story criterion 3:** Error handling
**Verification:**
- Unit test: Mock fetch to throw error, verify hook returns error state
- Unit test: Verify hook retries after 30 seconds despite error
- Unit test: Verify app doesn't crash on fetch failure
- Manual check: Stop backend API, verify error state displays gracefully

**Story criterion 4:** Cleanup on unmount
**Verification:**
- Unit test: Unmount component, verify interval cleared
- Unit test: Verify AbortController.abort() called on unmount
- Unit test: Advance timers after unmount, verify no additional fetches
- Manual check: Navigate away from page, check console for no warnings/errors

## Testing Requirements

### Unit Tests

**File:** `web/src/hooks/__tests__/useServerStatus.test.ts`

```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useServerStatus } from '../useServerStatus';

// Mock fetch
global.fetch = jest.fn();

describe('useServerStatus', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('should fetch server status on initial mount', async () => {
    const mockData = {
      online: true,
      playerCount: 15,
      maxPlayers: 100,
      timestamp: '2026-01-12T10:00:00Z',
    };

    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => mockData,
    });

    const { result } = renderHook(() => useServerStatus());

    expect(result.current.loading).toBe(true);
    expect(result.current.data).toBeNull();

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(result.current.data).toEqual(mockData);
    expect(result.current.error).toBeNull();
    expect(global.fetch).toHaveBeenCalledWith(
      '/api/server-status',
      expect.objectContaining({ signal: expect.any(AbortSignal) })
    );
  });

  it('should poll server status every 30 seconds', async () => {
    (global.fetch as jest.Mock).mockResolvedValue({
      ok: true,
      json: async () => ({ online: true, playerCount: 10, maxPlayers: 100, timestamp: new Date().toISOString() }),
    });

    renderHook(() => useServerStatus());

    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(1));

    // Advance 30 seconds
    jest.advanceTimersByTime(30000);
    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(2));

    // Advance another 30 seconds
    jest.advanceTimersByTime(30000);
    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(3));
  });

  it('should handle fetch errors gracefully', async () => {
    (global.fetch as jest.Mock).mockRejectedValueOnce(new Error('Network error'));

    const { result } = renderHook(() => useServerStatus());

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(result.current.error).toBeInstanceOf(Error);
    expect(result.current.error?.message).toBe('Network error');
    expect(result.current.data).toBeNull();
  });

  it('should cleanup interval and abort requests on unmount', async () => {
    const abortMock = jest.fn();
    const mockController = { abort: abortMock, signal: {} as AbortSignal };
    jest.spyOn(global, 'AbortController').mockImplementation(() => mockController as any);

    const { unmount } = renderHook(() => useServerStatus());

    unmount();

    expect(abortMock).toHaveBeenCalled();

    // Advance timers after unmount
    jest.advanceTimersByTime(30000);

    // Should not make additional requests after unmount
    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(1)); // Only initial fetch
  });

  it('should respect document visibility state', async () => {
    Object.defineProperty(document, 'visibilityState', {
      writable: true,
      value: 'visible',
    });

    (global.fetch as jest.Mock).mockResolvedValue({
      ok: true,
      json: async () => ({ online: true, playerCount: 5, maxPlayers: 100, timestamp: new Date().toISOString() }),
    });

    renderHook(() => useServerStatus());

    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(1));

    // Hide tab
    Object.defineProperty(document, 'visibilityState', {
      value: 'hidden',
    });

    // Advance 30 seconds (should NOT fetch because tab is hidden)
    jest.advanceTimersByTime(30000);
    expect(global.fetch).toHaveBeenCalledTimes(1);

    // Show tab again
    Object.defineProperty(document, 'visibilityState', {
      value: 'visible',
    });

    // Advance 30 seconds (SHOULD fetch now)
    jest.advanceTimersByTime(30000);
    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(2));
  });

  it('should provide refetch function', async () => {
    (global.fetch as jest.Mock).mockResolvedValue({
      ok: true,
      json: async () => ({ online: true, playerCount: 20, maxPlayers: 100, timestamp: new Date().toISOString() }),
    });

    const { result } = renderHook(() => useServerStatus());

    await waitFor(() => expect(result.current.loading).toBe(false));

    const initialFetchCount = (global.fetch as jest.Mock).mock.calls.length;

    // Call refetch
    result.current.refetch();

    await waitFor(() => expect(global.fetch).toHaveBeenCalledTimes(initialFetchCount + 1));
  });
});
```

**Coverage target:** 100% (all branches, all edge cases)

### Integration Tests

**Scenario 1:** Full polling cycle with real API
- Setup: Start backend API server
- Action: Mount component using the hook
- Assert: Initial fetch succeeds, polling continues every 30 seconds
- Assert: Data updates reflect actual server status

**Scenario 2:** Network failure recovery
- Setup: Start with working API
- Action: Stop backend API mid-polling
- Assert: Hook enters error state
- Action: Restart backend API
- Assert: Next poll succeeds, hook recovers from error state

### Manual Testing

- [ ] Open app in browser, verify initial server status loads
- [ ] Keep browser open for 2 minutes, verify 4 requests occur (0s, 30s, 60s, 90s)
- [ ] Switch to another tab, wait 30 seconds, switch back - verify no request made while tab hidden
- [ ] Open DevTools Network tab, verify requests show `/api/server-status`
- [ ] Stop backend API, verify error state displayed
- [ ] Restart backend API, verify recovery on next poll
- [ ] Navigate away from page, check console for no errors
- [ ] Test in Chrome, Firefox, Safari (cross-browser)

## Dependencies

**Must complete first:**
- Epic 003, Spec 02: Server Status Endpoint - backend API must be running

**Enables:**
- Spec 02: Live Server Status Widget - consumes this hook

## Risks & Mitigations

**Risk 1:** Polling every 30 seconds could drain mobile battery
**Mitigation:** Implement `document.visibilityState` check to pause polling when tab is inactive
**Fallback:** Increase polling interval to 60 seconds if battery drain becomes an issue (user feedback)

**Risk 2:** Memory leaks if interval not cleaned up properly
**Mitigation:** Use `useEffect` cleanup function to clear interval and abort fetch on unmount
**Fallback:** Add React DevTools Profiler checks in testing to verify no memory leaks

**Risk 3:** Race condition if component unmounts during fetch
**Mitigation:** Use `AbortController` to cancel in-flight requests on unmount
**Fallback:** Check `signal.aborted` before calling `setState` (prevents "can't update unmounted component" warning)

**Risk 4:** CORS errors if API not configured properly
**Mitigation:** Backend API already configured with CORS (Epic 003)
**Fallback:** Add proxy configuration in Vite config if running locally

## Performance Considerations

**Expected load:** 1 request every 30 seconds per user (2 requests/minute)
- With 100 concurrent users: 200 requests/minute = 3.3 requests/second (negligible)
- Backend has 30-second Redis cache, so actual Minecraft server queries are cached

**Optimization strategy:**
- Tab visibility detection reduces unnecessary requests by ~70% (average user has multiple tabs open)
- AbortController prevents wasted network resources on unmount
- No expensive computations in hook (simple fetch + setState)

**Benchmarks:**
- Hook initialization: <1ms
- Fetch + parse: <100ms (local network)
- Re-render overhead: <5ms (only consumers re-render)

## Security Considerations

**Authentication:** None required (public endpoint)

**Authorization:** None required (read-only public data)

**Data validation:**
- Validate API response shape matches `ServerStatus` type
- Handle malformed JSON gracefully (try/catch)
- Sanitize any user-displayed values (not applicable here - only numbers/booleans)

**Sensitive data:** None (all data is public server information)

**Additional notes:**
- API endpoint uses HTTPS in production (Epic 005)
- No user credentials or tokens involved
- Rate limiting on backend prevents abuse (Epic 003, Story 04)

## Success Verification

After implementation, verify:
- [ ] All unit tests pass (`pnpm test useServerStatus`)
- [ ] Integration tests pass (backend + frontend running)
- [ ] Manual testing checklist complete (all browsers)
- [ ] Acceptance criteria from story satisfied (all 4 scenarios)
- [ ] No console errors or warnings
- [ ] Performance benchmarks met (hook initializes <1ms)
- [ ] Security review complete (no sensitive data exposed)
- [ ] TypeScript compiles with no errors (`pnpm tsc`)
- [ ] ESLint passes with no warnings (`pnpm lint`)
- [ ] Bundle size impact <2KB (check with `pnpm build && pnpm analyze`)

## Traceability

**Parent story:** [.storyline/stories/epic-004/story-01-server-status-polling-hook.md](../../stories/epic-004/story-01-server-status-polling-hook.md)

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

## Implementation Notes

**Package manager:** Use `pnpm` not `npm`

**Import aliases:** Use `@/` for `src/` directory (configured in tsconfig.json)

**Testing library:** `@testing-library/react` for hook testing, `vitest` as test runner

**TypeScript version:** 5.7+ with strict mode enabled

**React version:** React 19 (ensure hooks work with concurrent features)

**Open questions:**
- Should we add a `useServerStatusWithToast` variant that shows toast on errors? (Decided: No, keep hooks focused, widgets can add toast)
- Should we expose the polling interval as a parameter? (Decided: No, hardcode to 30 seconds to match backend cache)

**Assumptions:**
- Backend API returns consistent response shape (validated in Epic 003)
- Users have modern browsers with `AbortController` support (98%+ browser support)
- `document.visibilityState` API available (97%+ browser support)
- Vite environment variables configured (`VITE_API_URL`)

**Future enhancements:**
- Add exponential backoff for repeated errors (e.g., if 5 consecutive fetches fail, slow down polling)
- Add retry logic with configurable max retries
- Add metrics/telemetry for polling success rate

---

**Next step:** Run `/dev-story .storyline/specs/epic-004/spec-01-server-status-polling-hook.md`
