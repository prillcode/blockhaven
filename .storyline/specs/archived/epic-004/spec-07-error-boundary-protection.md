---
spec_id: 07
story_id: 007
epic_id: 004
title: Error Boundary Protection for Interactive Widgets
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 07: Error Boundary Protection for Interactive Widgets

## Overview

**User story:** [.storyline/stories/epic-004/story-07-error-boundary-protection.md](../../stories/epic-004/story-07-error-boundary-protection.md)

**Goal:** Implement reusable React Error Boundary components that catch rendering errors in widgets, display helpful fallback UI with reload functionality, and prevent widget crashes from breaking the entire page. Support dark mode in fallback UI and provide error logging for debugging.

**Approach:** Create two error boundary components: (1) a generic `ErrorBoundary` base class component using React's `componentDidCatch` and `getDerivedStateFromError`, and (2) a specialized `WidgetErrorBoundary` wrapper with themed fallback UI, reload button, and widget-specific error handling. Use class components (required by React) with TypeScript.

## Technical Design

### Architecture Decision

**Chosen approach:** Two-tier error boundary system (base + widget-specific)

**Alternatives considered:**
- **react-error-boundary library** - External dependency (5KB), but custom implementation provides more control
- **Single universal error boundary** - Less flexible, same fallback UI for all components
- **Try/catch in components** - Doesn't catch rendering errors, only works in event handlers
- **Global window.onerror handler** - Catches unhandled errors but can't recover React component tree

**Rationale:** A two-tier approach provides flexibility: the base `ErrorBoundary` is reusable for any component, while `WidgetErrorBoundary` provides widget-specific UI and behavior. Custom implementation gives full control over error logging, fallback UI, and reset logic without adding dependencies.

### System Components

**Frontend:**
- `web/src/components/ErrorBoundary.tsx` - Base error boundary class component (new file)
- `web/src/components/WidgetErrorBoundary.tsx` - Widget-specific error boundary wrapper (new file)
- `web/src/components/__tests__/ErrorBoundary.test.tsx` - Unit tests (new file)
- `web/src/components/__tests__/WidgetErrorBoundary.test.tsx` - Unit tests (new file)

**Backend:**
- None (frontend error handling only)

**Database:**
- None (optional error tracking service integration in future)

**External integrations:**
- Console API for error logging (development)
- Optional error tracking service (Sentry, Rollbar) in production (future enhancement)

## Implementation Details

### Files to Create

#### `web/src/components/ErrorBoundary.tsx`
**Purpose:** Generic reusable error boundary for catching React rendering errors
**Exports:**
- `ErrorBoundary` class component (default export)
- `ErrorBoundaryProps` interface
- `ErrorBoundaryState` interface

**Implementation:**
```typescript
import React, { Component, ErrorInfo, ReactNode } from 'react';

export interface ErrorBoundaryProps {
  children: ReactNode;
  fallback?: ReactNode | ((error: Error, errorInfo: ErrorInfo, reset: () => void) => ReactNode);
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
  resetKeys?: Array<string | number>;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
  errorInfo: ErrorInfo | null;
}

/**
 * Generic error boundary component for catching React rendering errors
 *
 * @example
 * <ErrorBoundary fallback={<div>Something went wrong</div>}>
 *   <MyComponent />
 * </ErrorBoundary>
 */
export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
    };
  }

  static getDerivedStateFromError(error: Error): Partial<ErrorBoundaryState> {
    // Update state so next render shows fallback UI
    return {
      hasError: true,
      error,
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    // Log error details to console
    console.error('ErrorBoundary caught an error:', error, errorInfo);

    // Store error info in state
    this.setState({
      errorInfo,
    });

    // Call optional error handler
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }
  }

  componentDidUpdate(prevProps: ErrorBoundaryProps): void {
    // Reset error boundary if resetKeys change
    if (
      this.state.hasError &&
      this.props.resetKeys &&
      prevProps.resetKeys &&
      this.props.resetKeys.some((key, index) => key !== prevProps.resetKeys?.[index])
    ) {
      this.reset();
    }
  }

  reset = (): void => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
    });
  };

  render(): ReactNode {
    if (this.state.hasError && this.state.error) {
      // Render custom fallback UI
      if (this.props.fallback) {
        if (typeof this.props.fallback === 'function') {
          return this.props.fallback(
            this.state.error,
            this.state.errorInfo!,
            this.reset
          );
        }
        return this.props.fallback;
      }

      // Default fallback UI
      return (
        <div role="alert" className="error-boundary-fallback">
          <h2>Something went wrong</h2>
          <details style={{ whiteSpace: 'pre-wrap' }}>
            <summary>Error details</summary>
            <p>{this.state.error.toString()}</p>
            <p>{this.state.errorInfo?.componentStack}</p>
          </details>
          <button onClick={this.reset}>Try again</button>
        </div>
      );
    }

    // No error, render children normally
    return this.props.children;
  }
}
```

#### `web/src/components/WidgetErrorBoundary.tsx`
**Purpose:** Widget-specific error boundary with themed fallback UI and reload button
**Exports:**
- `WidgetErrorBoundary` component (default export)
- `WidgetErrorBoundaryProps` interface

**Implementation:**
```typescript
import React from 'react';
import { ErrorBoundary } from './ErrorBoundary';

export interface WidgetErrorBoundaryProps {
  children: React.ReactNode;
  widgetName: string;
}

/**
 * Error boundary specifically for widget components with themed fallback UI
 *
 * @example
 * <WidgetErrorBoundary widgetName="Server Status">
 *   <ServerStatusWidget />
 * </WidgetErrorBoundary>
 */
export function WidgetErrorBoundary({
  children,
  widgetName,
}: WidgetErrorBoundaryProps): React.ReactElement {
  return (
    <ErrorBoundary
      fallback={(error, errorInfo, reset) => (
        <div
          role="alert"
          className="widget-error-fallback rounded-lg border-2 border-red-500 bg-red-50 p-6 text-center dark:border-red-700 dark:bg-red-950"
        >
          <div className="mb-4">
            <svg
              className="mx-auto h-12 w-12 text-red-500 dark:text-red-400"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              aria-hidden="true"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
          </div>

          <h3 className="mb-2 text-lg font-semibold text-red-900 dark:text-red-100">
            Unable to load {widgetName}
          </h3>

          <p className="mb-4 text-sm text-red-700 dark:text-red-300">
            Something went wrong with this widget. The rest of the page should continue to work normally.
          </p>

          {import.meta.env.DEV && (
            <details className="mb-4 text-left">
              <summary className="cursor-pointer text-sm font-medium text-red-800 dark:text-red-200">
                Error details (dev only)
              </summary>
              <pre className="mt-2 overflow-auto rounded bg-red-100 p-2 text-xs text-red-900 dark:bg-red-900 dark:text-red-100">
                {error.toString()}
                {'\n\n'}
                {errorInfo.componentStack}
              </pre>
            </details>
          )}

          <button
            onClick={reset}
            className="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 dark:bg-red-700 dark:hover:bg-red-600"
          >
            Reload Widget
          </button>
        </div>
      )}
      onError={(error, errorInfo) => {
        // Log to console in development
        if (import.meta.env.DEV) {
          console.error(`[${widgetName}] Error caught by boundary:`, error);
          console.error('Component stack:', errorInfo.componentStack);
        }

        // TODO: Send to error tracking service in production
        // if (import.meta.env.PROD) {
        //   errorTrackingService.logError({
        //     error,
        //     componentStack: errorInfo.componentStack,
        //     widgetName,
        //   });
        // }
      }}
    >
      {children}
    </ErrorBoundary>
  );
}
```

### Files to Modify

**Existing widgets should be wrapped in WidgetErrorBoundary:**

**`web/src/pages/Home.tsx`** (or wherever widgets are rendered)
```typescript
import { WidgetErrorBoundary } from '@/components/WidgetErrorBoundary';
import { ServerStatus } from '@/components/ServerStatus';
import { CopyIPButton } from '@/components/CopyIPButton';

// In render:
<WidgetErrorBoundary widgetName="Server Status">
  <ServerStatus />
</WidgetErrorBoundary>

<WidgetErrorBoundary widgetName="Copy IP Button">
  <CopyIPButton />
</WidgetErrorBoundary>
```

**`web/src/pages/Contact.tsx`** (or wherever ContactForm is rendered)
```typescript
import { WidgetErrorBoundary } from '@/components/WidgetErrorBoundary';
import { ContactForm } from '@/components/ContactForm';

// In render:
<WidgetErrorBoundary widgetName="Contact Form">
  <ContactForm />
</WidgetErrorBoundary>
```

### API Contracts

**ErrorBoundary Props:**
```typescript
interface ErrorBoundaryProps {
  children: ReactNode;                          // Components to protect
  fallback?: ReactNode | FallbackFunction;       // Custom fallback UI
  onError?: (error: Error, errorInfo: ErrorInfo) => void;  // Error callback
  resetKeys?: Array<string | number>;            // Reset trigger
}
```

**WidgetErrorBoundary Props:**
```typescript
interface WidgetErrorBoundaryProps {
  children: ReactNode;    // Widget to protect
  widgetName: string;     // Display name for error message
}
```

**Error types caught:**
- Rendering errors in child components
- Lifecycle method errors (constructor, render, componentDidMount, etc.)
- Errors in component tree (bubbles up to nearest error boundary)

**Error types NOT caught:**
- Event handler errors (use try/catch)
- Async code errors (use try/catch or .catch())
- Server-side rendering errors
- Errors in error boundary itself

### Database Changes

None - Frontend error handling only.

### State Management

**ErrorBoundary state shape:**
```typescript
{
  hasError: boolean;       // True if error caught
  error: Error | null;     // Error object
  errorInfo: ErrorInfo | null;  // Component stack trace
}
```

**State transitions:**
1. **Normal state**: `hasError: false`, renders children
2. **Error caught**: `hasError: true`, `getDerivedStateFromError` called
3. **Error logged**: `componentDidCatch` called, error logged to console
4. **Fallback rendered**: Error boundary renders fallback UI instead of children
5. **Reset**: User clicks "Reload", state resets to normal, children re-render

**Reset behavior:**
- Manual reset: User clicks "Reload" button, calls `reset()` method
- Automatic reset: When `resetKeys` prop changes (e.g., route change)

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Widget crashes but site continues
**Verification:**
- Unit test: Throw error in child component, verify error boundary catches it
- Unit test: Verify fallback UI renders, children do not render
- Unit test: Verify console.error called with error details
- Manual check: Force error in ServerStatus, verify rest of page works

**Story criterion 2:** Multiple widgets protected independently
**Verification:**
- Unit test: Mount two error boundaries, throw error in one, verify other unaffected
- Integration test: Crash ContactForm, verify ServerStatus continues working
- Manual check: Open app, crash one widget, verify others still functional

**Story criterion 3:** Fallback UI provides helpful message
**Verification:**
- Unit test: Verify fallback contains "Unable to load {widgetName}"
- Unit test: Verify fallback contains "Reload" button
- Unit test: Verify fallback has dark mode classes (dark:*)
- Manual check: Crash widget, verify friendly message and reload button appear

**Story criterion 4:** Error logged for debugging
**Verification:**
- Unit test: Verify console.error called with error and component stack
- Unit test: Verify onError callback called with error details
- Unit test: Verify dev mode shows error details, prod mode hides them
- Manual check: Crash widget in dev mode, verify error details in console

## Testing Requirements

### Unit Tests

**File:** `web/src/components/__tests__/ErrorBoundary.test.tsx`

```typescript
import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ErrorBoundary } from '../ErrorBoundary';

// Component that throws an error
function BrokenComponent({ shouldThrow }: { shouldThrow?: boolean }) {
  if (shouldThrow) {
    throw new Error('Test error');
  }
  return <div>Working component</div>;
}

// Suppress console.error for cleaner test output
const originalError = console.error;
beforeAll(() => {
  console.error = jest.fn();
});
afterAll(() => {
  console.error = originalError;
});

describe('ErrorBoundary', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should render children when no error', () => {
    render(
      <ErrorBoundary>
        <BrokenComponent />
      </ErrorBoundary>
    );

    expect(screen.getByText('Working component')).toBeInTheDocument();
  });

  it('should catch errors and render default fallback', () => {
    render(
      <ErrorBoundary>
        <BrokenComponent shouldThrow />
      </ErrorBoundary>
    );

    expect(screen.getByRole('alert')).toBeInTheDocument();
    expect(screen.getByText('Something went wrong')).toBeInTheDocument();
    expect(screen.getByText(/Test error/)).toBeInTheDocument();
  });

  it('should render custom fallback when provided', () => {
    render(
      <ErrorBoundary fallback={<div>Custom error message</div>}>
        <BrokenComponent shouldThrow />
      </ErrorBoundary>
    );

    expect(screen.getByText('Custom error message')).toBeInTheDocument();
  });

  it('should render functional fallback with error details', () => {
    render(
      <ErrorBoundary
        fallback={(error, errorInfo, reset) => (
          <div>
            <p>Error: {error.message}</p>
            <button onClick={reset}>Reset</button>
          </div>
        )}
      >
        <BrokenComponent shouldThrow />
      </ErrorBoundary>
    );

    expect(screen.getByText('Error: Test error')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Reset' })).toBeInTheDocument();
  });

  it('should log error to console', () => {
    render(
      <ErrorBoundary>
        <BrokenComponent shouldThrow />
      </ErrorBoundary>
    );

    expect(console.error).toHaveBeenCalledWith(
      'ErrorBoundary caught an error:',
      expect.any(Error),
      expect.objectContaining({ componentStack: expect.any(String) })
    );
  });

  it('should call onError callback when error occurs', () => {
    const onError = jest.fn();

    render(
      <ErrorBoundary onError={onError}>
        <BrokenComponent shouldThrow />
      </ErrorBoundary>
    );

    expect(onError).toHaveBeenCalledWith(
      expect.any(Error),
      expect.objectContaining({ componentStack: expect.any(String) })
    );
  });

  it('should reset error state when reset called', async () => {
    const user = userEvent.setup();
    let shouldThrow = true;

    const { rerender } = render(
      <ErrorBoundary>
        <BrokenComponent shouldThrow={shouldThrow} />
      </ErrorBoundary>
    );

    // Error state
    expect(screen.getByRole('alert')).toBeInTheDocument();

    // Fix the error
    shouldThrow = false;

    // Click reset
    const resetButton = screen.getByRole('button', { name: 'Try again' });
    await user.click(resetButton);

    // Component should render normally now
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
    expect(screen.getByText('Working component')).toBeInTheDocument();
  });

  it('should reset when resetKeys change', () => {
    let shouldThrow = true;

    const { rerender } = render(
      <ErrorBoundary resetKeys={['key1']}>
        <BrokenComponent shouldThrow={shouldThrow} />
      </ErrorBoundary>
    );

    // Error state
    expect(screen.getByRole('alert')).toBeInTheDocument();

    // Fix the error
    shouldThrow = false;

    // Change resetKeys
    rerender(
      <ErrorBoundary resetKeys={['key2']}>
        <BrokenComponent shouldThrow={shouldThrow} />
      </ErrorBoundary>
    );

    // Component should render normally now
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
    expect(screen.getByText('Working component')).toBeInTheDocument();
  });

  it('should not reset when resetKeys stay the same', () => {
    const { rerender } = render(
      <ErrorBoundary resetKeys={['key1']}>
        <BrokenComponent shouldThrow />
      </ErrorBoundary>
    );

    // Error state
    expect(screen.getByRole('alert')).toBeInTheDocument();

    // Re-render with same resetKeys
    rerender(
      <ErrorBoundary resetKeys={['key1']}>
        <BrokenComponent shouldThrow />
      </ErrorBoundary>
    );

    // Should still show error
    expect(screen.getByRole('alert')).toBeInTheDocument();
  });
});
```

**File:** `web/src/components/__tests__/WidgetErrorBoundary.test.tsx`

```typescript
import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { WidgetErrorBoundary } from '../WidgetErrorBoundary';

// Component that throws an error
function BrokenWidget({ shouldThrow }: { shouldThrow?: boolean }) {
  if (shouldThrow) {
    throw new Error('Widget crashed');
  }
  return <div>Working widget</div>;
}

// Suppress console.error
const originalError = console.error;
beforeAll(() => {
  console.error = jest.fn();
});
afterAll(() => {
  console.error = originalError;
});

describe('WidgetErrorBoundary', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should render children when no error', () => {
    render(
      <WidgetErrorBoundary widgetName="Test Widget">
        <BrokenWidget />
      </WidgetErrorBoundary>
    );

    expect(screen.getByText('Working widget')).toBeInTheDocument();
  });

  it('should show widget-specific error message', () => {
    render(
      <WidgetErrorBoundary widgetName="Server Status">
        <BrokenWidget shouldThrow />
      </WidgetErrorBoundary>
    );

    expect(screen.getByText('Unable to load Server Status')).toBeInTheDocument();
    expect(
      screen.getByText(/Something went wrong with this widget/)
    ).toBeInTheDocument();
  });

  it('should render reload button', () => {
    render(
      <WidgetErrorBoundary widgetName="Test Widget">
        <BrokenWidget shouldThrow />
      </WidgetErrorBoundary>
    );

    expect(screen.getByRole('button', { name: 'Reload Widget' })).toBeInTheDocument();
  });

  it('should have dark mode classes', () => {
    const { container } = render(
      <WidgetErrorBoundary widgetName="Test Widget">
        <BrokenWidget shouldThrow />
      </WidgetErrorBoundary>
    );

    const fallback = screen.getByRole('alert');
    expect(fallback).toHaveClass('dark:border-red-700', 'dark:bg-red-950');
  });

  it('should show error details in dev mode', () => {
    // Mock dev environment
    import.meta.env.DEV = true;

    render(
      <WidgetErrorBoundary widgetName="Test Widget">
        <BrokenWidget shouldThrow />
      </WidgetErrorBoundary>
    );

    expect(screen.getByText('Error details (dev only)')).toBeInTheDocument();
    expect(screen.getByText(/Widget crashed/)).toBeInTheDocument();
  });

  it('should hide error details in prod mode', () => {
    // Mock prod environment
    import.meta.env.DEV = false;

    render(
      <WidgetErrorBoundary widgetName="Test Widget">
        <BrokenWidget shouldThrow />
      </WidgetErrorBoundary>
    );

    expect(screen.queryByText('Error details (dev only)')).not.toBeInTheDocument();
  });

  it('should reload widget when button clicked', async () => {
    const user = userEvent.setup();
    let shouldThrow = true;

    const { rerender } = render(
      <WidgetErrorBoundary widgetName="Test Widget">
        <BrokenWidget shouldThrow={shouldThrow} />
      </WidgetErrorBoundary>
    );

    // Error state
    expect(screen.getByRole('alert')).toBeInTheDocument();

    // Fix the error
    shouldThrow = false;

    // Click reload
    const reloadButton = screen.getByRole('button', { name: 'Reload Widget' });
    await user.click(reloadButton);

    // Widget should render normally now
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
    expect(screen.getByText('Working widget')).toBeInTheDocument();
  });

  it('should log error with widget name in dev mode', () => {
    import.meta.env.DEV = true;

    render(
      <WidgetErrorBoundary widgetName="Server Status">
        <BrokenWidget shouldThrow />
      </WidgetErrorBoundary>
    );

    expect(console.error).toHaveBeenCalledWith(
      '[Server Status] Error caught by boundary:',
      expect.any(Error)
    );
  });

  it('should render warning icon', () => {
    const { container } = render(
      <WidgetErrorBoundary widgetName="Test Widget">
        <BrokenWidget shouldThrow />
      </WidgetErrorBoundary>
    );

    const svg = container.querySelector('svg');
    expect(svg).toBeInTheDocument();
    expect(svg).toHaveClass('text-red-500', 'dark:text-red-400');
  });
});
```

**Coverage target:** 95%+ (all branches except production error tracking)

### Integration Tests

**Scenario 1:** Multiple independent error boundaries
- Setup: Render page with ServerStatus, ContactForm, CopyIPButton (each wrapped)
- Action: Force error in ServerStatus widget
- Assert: ServerStatus shows fallback UI
- Assert: ContactForm and CopyIPButton continue working normally

**Scenario 2:** Error boundary reset
- Setup: Render widget wrapped in error boundary
- Action: Force error, click "Reload Widget" button
- Assert: Widget attempts to re-render
- Assert: If error fixed, widget renders normally
- Assert: If error persists, fallback UI shows again

**Scenario 3:** Dark mode support
- Setup: Enable dark mode, force widget error
- Action: Observe fallback UI
- Assert: Fallback UI uses dark mode colors
- Assert: Text is readable with proper contrast

### Manual Testing

- [ ] Force error in ServerStatus, verify rest of page works
- [ ] Force error in ContactForm, verify ServerStatus still works
- [ ] Force error in CopyIPButton, verify other widgets work
- [ ] Click "Reload Widget" button, verify widget attempts to re-render
- [ ] Enable dark mode, force error, verify fallback UI themed correctly
- [ ] Open DevTools console, verify error logged with component stack
- [ ] Test in dev mode, verify error details visible
- [ ] Build for production, verify error details hidden
- [ ] Test in Chrome, Firefox, Safari (cross-browser)

## Dependencies

**Must complete first:**
- Epic 001: Theme System - fallback UI uses dark mode classes

**Enables:**
- Protects Story 02 (ServerStatus widget)
- Protects Story 04 (ContactForm widget)
- Protects Story 05 (CopyIPButton widget)

## Risks & Mitigations

**Risk 1:** Error boundary itself has a bug and crashes
**Mitigation:** Thorough testing of error boundary, keep implementation simple
**Fallback:** React will catch unhandled errors and show blank screen (better than infinite loop)

**Risk 2:** Error boundary catches errors but doesn't log them properly
**Mitigation:** Log to console in development, add tests to verify logging
**Fallback:** Add production error tracking service (Sentry) to capture errors

**Risk 3:** Fallback UI causes accessibility issues
**Mitigation:** Use semantic HTML (role="alert"), proper ARIA labels, keyboard navigation
**Fallback:** Test with screen readers, ensure fallback UI is accessible

**Risk 4:** Error boundary doesn't catch async errors or event handler errors
**Mitigation:** Document limitations clearly, use try/catch in event handlers
**Fallback:** Add global error handler for unhandled promise rejections (window.onunhandledrejection)

**Risk 5:** Error boundary reset doesn't fix the underlying error
**Mitigation:** Reset button is best-effort, document that underlying issue must be fixed
**Fallback:** User can refresh entire page if widget won't recover

## Performance Considerations

**Expected load:** Negligible - error boundaries only activate on errors
- Normal operation: Zero overhead (no re-renders, no computations)
- Error state: One-time render of fallback UI (<10ms)
- Reset: Re-render child components (depends on component complexity)

**Optimization strategy:**
- Error boundaries don't re-render unless error occurs
- Fallback UI is simple HTML/CSS (no expensive operations)
- Component stack trace captured automatically by React

**Benchmarks:**
- Error boundary initialization: <1ms
- Error caught + fallback render: <10ms
- Reset: <5ms + child component render time
- Memory footprint: <500 bytes per boundary

**Bundle size:**
- ErrorBoundary: ~2KB uncompressed
- WidgetErrorBoundary: ~3KB uncompressed (includes Tailwind classes + SVG icon)
- Total: ~5KB for both components

## Security Considerations

**Authentication:** Not applicable (error handling only)

**Authorization:** Not applicable (error handling only)

**Data validation:**
- Error messages sanitized automatically by React
- Component stack traces safe to display (no user data)

**Sensitive data:**
- Do NOT log sensitive user data in error messages
- Component stack traces may reveal component names (acceptable)
- In production, hide detailed error messages from users

**Additional notes:**
- Error boundaries prevent information disclosure (don't show stack traces in prod)
- Console logging only in development (no sensitive data exposed)
- Production error tracking should sanitize user data before sending

## Success Verification

After implementation, verify:
- [ ] All unit tests pass (`pnpm test ErrorBoundary WidgetErrorBoundary`)
- [ ] 95%+ code coverage achieved
- [ ] Integration tests pass (multiple boundaries)
- [ ] Manual testing checklist complete (all browsers)
- [ ] Acceptance criteria from story satisfied (all 4 scenarios)
- [ ] Fallback UI displays correctly in light and dark modes
- [ ] Errors logged to console in development
- [ ] Error details hidden in production build
- [ ] TypeScript compiles with no errors (`pnpm tsc`)
- [ ] ESLint passes with no warnings (`pnpm lint`)
- [ ] Bundle size impact <10KB (`pnpm build && pnpm analyze`)
- [ ] Accessibility: Fallback UI works with screen readers

## Traceability

**Parent story:** [.storyline/stories/epic-004/story-07-error-boundary-protection.md](../../stories/epic-004/story-07-error-boundary-protection.md)

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

## Implementation Notes

**Package manager:** Use `pnpm` not `npm`

**Import aliases:** Use `@/` for `src/` directory (configured in tsconfig.json)

**Testing library:** `@testing-library/react` for component testing, `vitest` as test runner

**TypeScript version:** 5.7+ with strict mode enabled

**React version:** React 19 (error boundaries work with concurrent features)

**Tailwind CSS:** Use utility classes for fallback UI styling

**Browser support:**
- Error boundaries: React 16.0+ (universal support)
- componentDidCatch API: React 16.0+ (universal support)
- getDerivedStateFromError API: React 16.6+ (universal support)

**Open questions:**
- Should we integrate with error tracking service (Sentry)? (Decided: Add TODO for future, not required for MVP)
- Should we add retry logic with exponential backoff? (Decided: No, simple reload button sufficient)
- Should we show a "Report Error" button? (Decided: No, not needed for internal app)

**Assumptions:**
- Class components acceptable for error boundaries (React requirement)
- Console logging sufficient for development (production tracking later)
- Tailwind CSS available for styling fallback UI
- Dark mode implemented via Tailwind dark: classes

**Future enhancements:**
- Integrate with error tracking service (Sentry, Rollbar, LogRocket)
- Add retry logic with exponential backoff
- Add "Report Error" button for user feedback
- Add error boundary for entire app (not just widgets)
- Add telemetry for error frequency and types
- Add automatic screenshots on error (for debugging)

---

**Next step:** Run `/dev-story .storyline/specs/epic-004/spec-07-error-boundary-protection.md`
