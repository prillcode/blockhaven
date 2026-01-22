---
spec_id: 02
story_id: 002
epic_id: 004
title: Live Server Status Widget
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 02: Live Server Status Widget

## Overview

**User story:** [.storyline/stories/epic-004/story-02-live-server-status-widget.md](../../stories/epic-004/story-02-live-server-status-widget.md)

**Goal:** Create a `ServerStatus` React component that displays real-time server online/offline status and player count using the `useServerStatus` hook, with proper loading and error states.

**Approach:** Build a presentational React component that consumes the `useServerStatus` hook and renders status with Tailwind CSS styling. Include pulsing animation for online indicator, skeleton loading state, and error fallback UI.

## Technical Design

### Architecture Decision

**Chosen approach:** Presentational component with `useServerStatus` hook integration

**Alternatives considered:**
- **Compound component pattern** (ServerStatus.Root, ServerStatus.Indicator, etc.) - Too complex for simple widget
- **Render props pattern** - Less readable than hooks
- **Container/Presenter split** - Unnecessary for this simple component

**Rationale:** Simple component with hook provides clean separation of concerns. Hook handles data fetching, component handles rendering. Easy to test and maintain.

### System Components

**Frontend:**
- `web/src/widgets/ServerStatus.tsx` - Main widget component (new file)
- `web/src/components/ui/LoadingSkeleton.tsx` - Reusable skeleton component (new file)
- Uses `web/src/hooks/useServerStatus.ts` (Spec 01)

**Backend:**
- None (uses existing API via hook)

**Database:**
- None

**External integrations:**
- None

## Implementation Details

### Files to Create

#### `web/src/widgets/ServerStatus.tsx`
**Purpose:** Display live server status with player count
**Exports:** `ServerStatus` component (default export)

**Implementation:**
```typescript
import { useServerStatus } from '@/hooks/useServerStatus';
import { LoadingSkeleton } from '@/components/ui/LoadingSkeleton';

export interface ServerStatusProps {
  className?: string;
  showIP?: boolean;
}

export default function ServerStatus({ className = '', showIP = true }: ServerStatusProps) {
  const { data, loading, error } = useServerStatus();

  if (loading) {
    return (
      <div className={`rounded-lg border border-border bg-card p-6 ${className}`}>
        <LoadingSkeleton className="h-6 w-24 mb-3" />
        <LoadingSkeleton className="h-8 w-32" />
      </div>
    );
  }

  if (error) {
    return (
      <div className={`rounded-lg border border-destructive/50 bg-destructive/10 p-6 ${className}`}>
        <p className="text-destructive text-sm font-medium">
          Unable to fetch server status
        </p>
        <p className="text-destructive/70 text-xs mt-1">
          Please try again later
        </p>
      </div>
    );
  }

  if (!data) return null;

  return (
    <div className={`rounded-lg border border-border bg-card p-6 ${className}`}>
      <div className="flex items-center gap-3 mb-4">
        {/* Status Indicator with Pulse Animation */}
        <div className="relative">
          <div
            className={`w-3 h-3 rounded-full ${
              data.online ? 'bg-green-500' : 'bg-red-500'
            }`}
          />
          {data.online && (
            <div className="absolute inset-0 w-3 h-3 rounded-full bg-green-500 animate-ping opacity-75" />
          )}
        </div>
        <span className="text-sm font-semibold text-foreground">
          {data.online ? 'Online' : 'Offline'}
        </span>
      </div>

      {data.online && (
        <div className="space-y-2">
          <p className="text-2xl font-bold text-foreground">
            {data.playerCount}/{data.maxPlayers}
          </p>
          <p className="text-sm text-muted-foreground">
            {data.playerCount === 1 ? 'player online' : 'players online'}
          </p>
        </div>
      )}

      {!data.online && (
        <p className="text-sm text-muted-foreground">
          Server is currently offline
        </p>
      )}

      {showIP && (
        <div className="mt-4 pt-4 border-t border-border">
          <p className="text-xs text-muted-foreground">Server IP</p>
          <p className="text-sm font-mono text-foreground">5.161.69.191:25565</p>
        </div>
      )}
    </div>
  );
}
```

#### `web/src/components/ui/LoadingSkeleton.tsx`
**Purpose:** Reusable skeleton loading component
**Exports:** `LoadingSkeleton` component (named export)

**Implementation:**
```typescript
import { cn } from '@/lib/utils';

export interface LoadingSkeletonProps {
  className?: string;
}

export function LoadingSkeleton({ className }: LoadingSkeletonProps) {
  return (
    <div
      className={cn(
        'animate-pulse rounded-md bg-muted',
        className
      )}
    />
  );
}
```

### Files to Modify

None - All new files for this feature.

### API Contracts

None - Component consumes data from `useServerStatus` hook (Spec 01).

### Database Changes

None

### State Management

**Component state:** None (stateless, uses hook data)

**Hook state (from Spec 01):**
```typescript
{
  data: ServerStatus | null,
  loading: boolean,
  error: Error | null
}
```

**Derived UI states:**
- `loading === true` → Show skeleton
- `error !== null` → Show error UI
- `data && data.online` → Show online status + player count
- `data && !data.online` → Show offline message

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Server online with players
**Verification:**
- Unit test: Mock hook to return online data, verify renders player count "15/100 players online"
- Unit test: Verify green indicator rendered
- Unit test: Verify pulsing animation class applied
- Manual check: View widget with server online, see green pulsing dot

**Story criterion 2:** Server offline
**Verification:**
- Unit test: Mock hook to return offline data, verify renders "Server is currently offline"
- Unit test: Verify red indicator rendered (no pulse)
- Unit test: Verify no player count displayed
- Manual check: Stop server, verify red indicator and offline message

**Story criterion 3:** Loading state
**Verification:**
- Unit test: Mock hook with loading: true, verify LoadingSkeleton rendered
- Manual check: Hard refresh page, briefly see skeleton before data loads
- Verify skeleton matches card dimensions

**Story criterion 4:** Error state
**Verification:**
- Unit test: Mock hook with error, verify error message rendered
- Unit test: Verify destructive color scheme used
- Manual check: Stop backend API, verify error state displays

## Testing Requirements

### Unit Tests

**File:** `web/src/widgets/__tests__/ServerStatus.test.tsx`

```typescript
import { render, screen } from '@testing-library/react';
import { vi } from 'vitest';
import ServerStatus from '../ServerStatus';
import * as useServerStatusModule from '@/hooks/useServerStatus';

vi.mock('@/hooks/useServerStatus');

const mockUseServerStatus = vi.mocked(useServerStatusModule.useServerStatus);

describe('ServerStatus', () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  it('should render loading skeleton when loading', () => {
    mockUseServerStatus.mockReturnValue({
      data: null,
      loading: true,
      error: null,
      refetch: vi.fn(),
    });

    render(<ServerStatus />);

    expect(screen.getByTestId('loading-skeleton')).toBeInTheDocument();
  });

  it('should render online status with player count', () => {
    mockUseServerStatus.mockReturnValue({
      data: {
        online: true,
        playerCount: 15,
        maxPlayers: 100,
        timestamp: '2026-01-12T10:00:00Z',
      },
      loading: false,
      error: null,
      refetch: vi.fn(),
    });

    render(<ServerStatus />);

    expect(screen.getByText('Online')).toBeInTheDocument();
    expect(screen.getByText('15/100')).toBeInTheDocument();
    expect(screen.getByText('players online')).toBeInTheDocument();
  });

  it('should render singular "player" when count is 1', () => {
    mockUseServerStatus.mockReturnValue({
      data: {
        online: true,
        playerCount: 1,
        maxPlayers: 100,
        timestamp: '2026-01-12T10:00:00Z',
      },
      loading: false,
      error: null,
      refetch: vi.fn(),
    });

    render(<ServerStatus />);

    expect(screen.getByText('player online')).toBeInTheDocument();
  });

  it('should render offline status', () => {
    mockUseServerStatus.mockReturnValue({
      data: {
        online: false,
        playerCount: 0,
        maxPlayers: 100,
        timestamp: '2026-01-12T10:00:00Z',
      },
      loading: false,
      error: null,
      refetch: vi.fn(),
    });

    render(<ServerStatus />);

    expect(screen.getByText('Offline')).toBeInTheDocument();
    expect(screen.getByText('Server is currently offline')).toBeInTheDocument();
    expect(screen.queryByText(/players online/)).not.toBeInTheDocument();
  });

  it('should render error state', () => {
    mockUseServerStatus.mockReturnValue({
      data: null,
      loading: false,
      error: new Error('Network error'),
      refetch: vi.fn(),
    });

    render(<ServerStatus />);

    expect(screen.getByText('Unable to fetch server status')).toBeInTheDocument();
    expect(screen.getByText('Please try again later')).toBeInTheDocument();
  });

  it('should show IP when showIP prop is true', () => {
    mockUseServerStatus.mockReturnValue({
      data: {
        online: true,
        playerCount: 10,
        maxPlayers: 100,
        timestamp: '2026-01-12T10:00:00Z',
      },
      loading: false,
      error: null,
      refetch: vi.fn(),
    });

    render(<ServerStatus showIP={true} />);

    expect(screen.getByText('5.161.69.191:25565')).toBeInTheDocument();
  });

  it('should hide IP when showIP prop is false', () => {
    mockUseServerStatus.mockReturnValue({
      data: {
        online: true,
        playerCount: 10,
        maxPlayers: 100,
        timestamp: '2026-01-12T10:00:00Z',
      },
      loading: false,
      error: null,
      refetch: vi.fn(),
    });

    render(<ServerStatus showIP={false} />);

    expect(screen.queryByText('5.161.69.191:25565')).not.toBeInTheDocument();
  });

  it('should apply custom className', () => {
    mockUseServerStatus.mockReturnValue({
      data: {
        online: true,
        playerCount: 5,
        maxPlayers: 100,
        timestamp: '2026-01-12T10:00:00Z',
      },
      loading: false,
      error: null,
      refetch: vi.fn(),
    });

    const { container } = render(<ServerStatus className="custom-class" />);

    expect(container.firstChild).toHaveClass('custom-class');
  });
});
```

**Coverage target:** 100%

### Integration Tests

**Scenario 1:** Real-time status updates
- Setup: Start backend API with server online
- Action: Render ServerStatus widget, wait 30 seconds
- Assert: Widget updates to show current player count
- Action: Stop Minecraft server
- Assert: Widget updates to offline status

### Manual Testing

- [ ] View widget on homepage - verify renders correctly
- [ ] Server online - verify green pulsing indicator
- [ ] Server online - verify player count displays (e.g., "5/100 players online")
- [ ] Server offline - verify red indicator (no pulse)
- [ ] Server offline - verify "Server is currently offline" message
- [ ] Hard refresh - briefly see skeleton loading state
- [ ] Stop backend API - verify error state with red border
- [ ] Test in light mode - verify colors readable
- [ ] Test in dark mode - verify colors readable
- [ ] Test on mobile (375px width) - verify responsive layout
- [ ] Test on desktop (1920px width) - verify looks good

## Dependencies

**Must complete first:**
- Spec 01: Server Status Polling Hook - provides data source
- Epic 001: Theme System - provides Tailwind theme tokens

**Enables:**
- Homepage can display live server status
- Epic 005: Production deployment includes working server status

## Risks & Mitigations

**Risk 1:** Pulsing animation may be distracting or performance-heavy
**Mitigation:** Use CSS `animate-ping` (hardware-accelerated), set to subtle opacity
**Fallback:** Remove pulse, use solid green dot only

**Risk 2:** Layout shift if player count digits change (1 → 10 → 100)
**Mitigation:** Use monospace font for numbers or fixed width container
**Fallback:** Accept minor layout shift (not critical for UX)

**Risk 3:** Theme colors may not have sufficient contrast
**Mitigation:** Use semantic color tokens from theme system (already WCAG AA compliant)
**Fallback:** Add explicit border to indicators for better visibility

## Performance Considerations

**Expected load:** Widget renders every 30 seconds when data updates
- Use `React.memo()` to prevent unnecessary re-renders
- Pulsing animation uses CSS (GPU-accelerated), not JavaScript

**Optimization strategy:**
- Component is small (<1KB)
- No expensive computations
- Pure functional component (easy to optimize)

**Benchmarks:**
- Initial render: <5ms
- Re-render on data update: <2ms

## Security Considerations

**Data sanitization:** All data is numbers/booleans from typed API - no XSS risk

**No sensitive data displayed**

## Success Verification

After implementation, verify:
- [ ] All unit tests pass
- [ ] Manual testing checklist complete
- [ ] Acceptance criteria from story satisfied
- [ ] No console errors
- [ ] Performance benchmarks met
- [ ] Works in light and dark mode
- [ ] Responsive on mobile and desktop
- [ ] Accessibility check (screen reader, keyboard navigation)

## Traceability

**Parent story:** [.storyline/stories/epic-004/story-02-live-server-status-widget.md](../../stories/epic-004/story-02-live-server-status-widget.md)

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

## Implementation Notes

**Tailwind classes:**
- Use semantic tokens: `bg-card`, `text-foreground`, `border-border`, etc.
- Don't hardcode colors like `bg-gray-100` (breaks theme system)

**Accessibility:**
- Indicator should have `aria-label` for screen readers
- Consider adding `role="status"` for live region announcements

**Future enhancements:**
- Add "Last updated X seconds ago" timestamp
- Add manual refresh button
- Show historical player count graph (sparkline)

---

**Next step:** Run `/dev-story .storyline/specs/epic-004/spec-02-live-server-status-widget.md`
