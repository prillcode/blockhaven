---
spec_id: 03
story_id: 003
epic_id: 004
title: Toast Notification System
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 03: Toast Notification System

## Overview

**User story:** [.storyline/stories/epic-004/story-03-toast-notification-system.md](../../stories/epic-004/story-03-toast-notification-system.md)

**Goal:** Implement a global toast notification system with queue management, auto-dismiss, manual dismissal, and support for success/error/info/warning variants. Maximum 3 toasts visible simultaneously with smooth animations.

**Approach:** Create a custom React hook `useToast` for toast state management with React Context, implement Toast and ToastContainer components with CSS transitions for animations, and provide a queue system with FIFO behavior and max visible limit.

## Technical Design

### Architecture Decision

**Chosen approach:** React Context + Custom Hook + Portal-based Rendering

**Alternatives considered:**
- **Third-party libraries (react-hot-toast, sonner)** - Reduces control and learning opportunity; adds dependency
- **Redux/Zustand for state** - Overkill for simple toast queue; adds complexity
- **Event emitter pattern** - More complex than Context API; harder to test
- **Component-level state only** - Can't be accessed globally across all components

**Rationale:** React Context provides global access to toast state while keeping it simple. Custom hook pattern is familiar to React developers. Portal rendering ensures toasts render at root level regardless of component hierarchy. This approach is lightweight (<3KB), fully customizable, and integrates seamlessly with our theme system.

### System Components

**Frontend:**
- `web/src/hooks/useToast.ts` - Custom hook with toast queue logic (new file)
- `web/src/contexts/ToastContext.tsx` - React Context provider (new file)
- `web/src/components/ui/Toast.tsx` - Individual toast component (new file)
- `web/src/components/ui/ToastContainer.tsx` - Container with positioning and stacking (new file)
- `web/src/types/toast.ts` - TypeScript types (new file)

**Backend:**
- None (client-side only)

**Database:**
- None

**External integrations:**
- None

## Implementation Details

### Files to Create

#### `web/src/types/toast.ts`
**Purpose:** TypeScript types for toast system
**Exports:** Toast interfaces and enums

**Implementation:**
```typescript
export type ToastVariant = 'success' | 'error' | 'info' | 'warning';

export interface Toast {
  id: string;
  message: string;
  variant: ToastVariant;
  duration?: number;
  dismissible?: boolean;
}

export interface ToastOptions {
  variant?: ToastVariant;
  duration?: number;
  dismissible?: boolean;
}
```

#### `web/src/contexts/ToastContext.tsx`
**Purpose:** React Context for global toast state
**Exports:** ToastProvider, useToastContext

**Implementation:**
```typescript
import { createContext, useContext, useState, useCallback, useEffect } from 'react';
import type { Toast, ToastOptions } from '@/types/toast';

const MAX_VISIBLE_TOASTS = 3;
const DEFAULT_DURATION = 5000; // 5 seconds

interface ToastContextValue {
  toasts: Toast[];
  addToast: (message: string, options?: ToastOptions) => string;
  removeToast: (id: string) => void;
}

const ToastContext = createContext<ToastContextValue | undefined>(undefined);

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const removeToast = useCallback((id: string) => {
    setToasts((prev) => prev.filter((toast) => toast.id !== id));
  }, []);

  const addToast = useCallback((message: string, options?: ToastOptions): string => {
    const id = `toast-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    const newToast: Toast = {
      id,
      message,
      variant: options?.variant || 'info',
      duration: options?.duration ?? DEFAULT_DURATION,
      dismissible: options?.dismissible ?? true,
    };

    setToasts((prev) => {
      // Add new toast
      const updated = [...prev, newToast];

      // Keep only the most recent MAX_VISIBLE_TOASTS
      if (updated.length > MAX_VISIBLE_TOASTS) {
        return updated.slice(-MAX_VISIBLE_TOASTS);
      }

      return updated;
    });

    // Auto-dismiss after duration
    if (newToast.duration > 0) {
      setTimeout(() => {
        removeToast(id);
      }, newToast.duration);
    }

    return id;
  }, [removeToast]);

  return (
    <ToastContext.Provider value={{ toasts, addToast, removeToast }}>
      {children}
    </ToastContext.Provider>
  );
}

export function useToastContext() {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToastContext must be used within ToastProvider');
  }
  return context;
}
```

#### `web/src/hooks/useToast.ts`
**Purpose:** Consumer-facing hook for triggering toasts
**Exports:** useToast hook (default export)

**Implementation:**
```typescript
import { useCallback } from 'react';
import { useToastContext } from '@/contexts/ToastContext';
import type { ToastOptions } from '@/types/toast';

export interface UseToastReturn {
  toast: (message: string, options?: ToastOptions) => string;
  success: (message: string) => string;
  error: (message: string) => string;
  info: (message: string) => string;
  warning: (message: string) => string;
  dismiss: (id: string) => void;
}

export function useToast(): UseToastReturn {
  const { addToast, removeToast } = useToastContext();

  const toast = useCallback(
    (message: string, options?: ToastOptions) => {
      return addToast(message, options);
    },
    [addToast]
  );

  const success = useCallback(
    (message: string) => {
      return addToast(message, { variant: 'success' });
    },
    [addToast]
  );

  const error = useCallback(
    (message: string) => {
      return addToast(message, { variant: 'error' });
    },
    [addToast]
  );

  const info = useCallback(
    (message: string) => {
      return addToast(message, { variant: 'info' });
    },
    [addToast]
  );

  const warning = useCallback(
    (message: string) => {
      return addToast(message, { variant: 'warning' });
    },
    [addToast]
  );

  const dismiss = useCallback(
    (id: string) => {
      removeToast(id);
    },
    [removeToast]
  );

  return { toast, success, error, info, warning, dismiss };
}
```

#### `web/src/components/ui/Toast.tsx`
**Purpose:** Individual toast component with styling and animations
**Exports:** Toast component (default export)

**Implementation:**
```typescript
import { useEffect, useState } from 'react';
import { X, CheckCircle, XCircle, Info, AlertTriangle } from 'lucide-react';
import type { Toast as ToastType } from '@/types/toast';
import { cn } from '@/lib/utils';

interface ToastProps {
  toast: ToastType;
  onDismiss: (id: string) => void;
}

const variantStyles = {
  success: 'bg-green-500/10 border-green-500/50 text-green-700 dark:text-green-300',
  error: 'bg-red-500/10 border-red-500/50 text-red-700 dark:text-red-300',
  info: 'bg-blue-500/10 border-blue-500/50 text-blue-700 dark:text-blue-300',
  warning: 'bg-yellow-500/10 border-yellow-500/50 text-yellow-700 dark:text-yellow-300',
};

const variantIcons = {
  success: CheckCircle,
  error: XCircle,
  info: Info,
  warning: AlertTriangle,
};

const variantIconColors = {
  success: 'text-green-500',
  error: 'text-red-500',
  info: 'text-blue-500',
  warning: 'text-yellow-500',
};

export default function Toast({ toast, onDismiss }: ToastProps) {
  const [isExiting, setIsExiting] = useState(false);
  const Icon = variantIcons[toast.variant];

  const handleDismiss = () => {
    setIsExiting(true);
    // Wait for exit animation to complete
    setTimeout(() => {
      onDismiss(toast.id);
    }, 300);
  };

  return (
    <div
      role="status"
      aria-live="polite"
      className={cn(
        'flex items-start gap-3 rounded-lg border p-4 shadow-lg',
        'transition-all duration-300 ease-in-out',
        'min-w-[300px] max-w-[500px]',
        variantStyles[toast.variant],
        isExiting
          ? 'opacity-0 translate-x-full'
          : 'opacity-100 translate-x-0 animate-in slide-in-from-right'
      )}
    >
      {/* Icon */}
      <Icon className={cn('h-5 w-5 flex-shrink-0 mt-0.5', variantIconColors[toast.variant])} />

      {/* Message */}
      <p className="flex-1 text-sm font-medium leading-relaxed">{toast.message}</p>

      {/* Dismiss Button */}
      {toast.dismissible && (
        <button
          onClick={handleDismiss}
          className="flex-shrink-0 rounded-md p-1 hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
          aria-label="Dismiss notification"
        >
          <X className="h-4 w-4" />
        </button>
      )}
    </div>
  );
}
```

#### `web/src/components/ui/ToastContainer.tsx`
**Purpose:** Container that manages toast positioning and stacking
**Exports:** ToastContainer component (default export)

**Implementation:**
```typescript
import { createPortal } from 'react-dom';
import { useToastContext } from '@/contexts/ToastContext';
import Toast from './Toast';

export default function ToastContainer() {
  const { toasts, removeToast } = useToastContext();

  if (toasts.length === 0) return null;

  return createPortal(
    <div
      className="fixed top-4 right-4 z-50 flex flex-col gap-3 pointer-events-none"
      aria-live="polite"
      aria-atomic="false"
    >
      {toasts.map((toast) => (
        <div key={toast.id} className="pointer-events-auto">
          <Toast toast={toast} onDismiss={removeToast} />
        </div>
      ))}
    </div>,
    document.body
  );
}
```

### Files to Modify

#### `web/src/App.tsx`
**Modification:** Wrap app with ToastProvider and add ToastContainer

**Changes:**
```typescript
import { ToastProvider } from '@/contexts/ToastContext';
import ToastContainer from '@/components/ui/ToastContainer';

function App() {
  return (
    <ThemeProvider>
      <ToastProvider>
        {/* Existing app content */}
        <ToastContainer />
      </ToastProvider>
    </ThemeProvider>
  );
}
```

### API Contracts

None - This is a client-side UI feature with no backend integration.

### Database Changes

None

### State Management

**Toast Context State:**
```typescript
{
  toasts: Toast[],           // Array of active toasts (max 3)
  addToast: (message, options) => string,  // Add toast, returns ID
  removeToast: (id) => void  // Remove toast by ID
}
```

**Toast Lifecycle:**
1. **Add toast**: `addToast()` → generates unique ID → adds to queue
2. **Queue limit**: If >3 toasts, remove oldest (FIFO)
3. **Auto-dismiss**: `setTimeout()` removes toast after duration
4. **Manual dismiss**: User clicks X → exit animation → remove from queue
5. **Component unmount**: Context cleanup handled by React

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Show success toast
**Verification:**
- Unit test: Call `toast.success()`, verify toast rendered with green checkmark
- Unit test: Verify message displays correctly
- Unit test: Mock timers, verify toast auto-dismisses after 5 seconds
- Unit test: Click X button, verify toast dismisses immediately
- Manual check: Trigger success action, see green toast with checkmark

**Story criterion 2:** Show error toast
**Verification:**
- Unit test: Call `toast.error()`, verify toast rendered with red X icon
- Unit test: Verify error message displays
- Unit test: Verify auto-dismiss after 5 seconds
- Manual check: Trigger error, see red toast with X icon

**Story criterion 3:** Toast queue management
**Verification:**
- Unit test: Add 3 toasts rapidly, verify all 3 visible
- Unit test: Add 4th toast, verify oldest is removed (only 3 visible)
- Unit test: Verify toasts stacked vertically with gap
- Unit test: Dismiss middle toast, verify others shift smoothly
- Manual check: Rapidly trigger 5 toasts, verify only 3 visible at once

**Story criterion 4:** Manual dismissal
**Verification:**
- Unit test: Render toast, click X button, verify removal
- Unit test: Verify auto-dismiss timer cancelled on manual dismiss
- Unit test: Dismiss toast, verify others maintain position
- Manual check: Click X on toast, verify smooth exit animation

## Testing Requirements

### Unit Tests

**File:** `web/src/hooks/__tests__/useToast.test.ts`

```typescript
import { renderHook, act, waitFor } from '@testing-library/react';
import { ToastProvider, useToastContext } from '@/contexts/ToastContext';
import { useToast } from '../useToast';

describe('useToast', () => {
  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <ToastProvider>{children}</ToastProvider>
  );

  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('should add success toast', () => {
    const { result: contextResult } = renderHook(() => useToastContext(), { wrapper });
    const { result } = renderHook(() => useToast(), { wrapper });

    act(() => {
      result.current.success('Success message');
    });

    expect(contextResult.current.toasts).toHaveLength(1);
    expect(contextResult.current.toasts[0].message).toBe('Success message');
    expect(contextResult.current.toasts[0].variant).toBe('success');
  });

  it('should add error toast', () => {
    const { result: contextResult } = renderHook(() => useToastContext(), { wrapper });
    const { result } = renderHook(() => useToast(), { wrapper });

    act(() => {
      result.current.error('Error message');
    });

    expect(contextResult.current.toasts).toHaveLength(1);
    expect(contextResult.current.toasts[0].variant).toBe('error');
  });

  it('should auto-dismiss toast after duration', async () => {
    const { result: contextResult } = renderHook(() => useToastContext(), { wrapper });
    const { result } = renderHook(() => useToast(), { wrapper });

    act(() => {
      result.current.success('Auto-dismiss test');
    });

    expect(contextResult.current.toasts).toHaveLength(1);

    // Fast-forward 5 seconds
    act(() => {
      jest.advanceTimersByTime(5000);
    });

    await waitFor(() => {
      expect(contextResult.current.toasts).toHaveLength(0);
    });
  });

  it('should limit to 3 visible toasts', () => {
    const { result: contextResult } = renderHook(() => useToastContext(), { wrapper });
    const { result } = renderHook(() => useToast(), { wrapper });

    act(() => {
      result.current.info('Toast 1');
      result.current.info('Toast 2');
      result.current.info('Toast 3');
      result.current.info('Toast 4');
    });

    expect(contextResult.current.toasts).toHaveLength(3);
    expect(contextResult.current.toasts[0].message).toBe('Toast 2'); // Oldest removed
    expect(contextResult.current.toasts[2].message).toBe('Toast 4'); // Latest kept
  });

  it('should manually dismiss toast', () => {
    const { result: contextResult } = renderHook(() => useToastContext(), { wrapper });
    const { result } = renderHook(() => useToast(), { wrapper });

    let toastId: string;
    act(() => {
      toastId = result.current.success('Dismissible toast');
    });

    expect(contextResult.current.toasts).toHaveLength(1);

    act(() => {
      result.current.dismiss(toastId);
    });

    expect(contextResult.current.toasts).toHaveLength(0);
  });

  it('should support all variants', () => {
    const { result: contextResult } = renderHook(() => useToastContext(), { wrapper });
    const { result } = renderHook(() => useToast(), { wrapper });

    act(() => {
      result.current.success('Success');
      result.current.error('Error');
      result.current.info('Info');
    });

    expect(contextResult.current.toasts).toHaveLength(3);
    expect(contextResult.current.toasts[0].variant).toBe('success');
    expect(contextResult.current.toasts[1].variant).toBe('error');
    expect(contextResult.current.toasts[2].variant).toBe('info');
  });

  it('should allow custom duration', async () => {
    const { result: contextResult } = renderHook(() => useToastContext(), { wrapper });
    const { result } = renderHook(() => useToast(), { wrapper });

    act(() => {
      result.current.toast('Custom duration', { duration: 2000 });
    });

    expect(contextResult.current.toasts).toHaveLength(1);

    // Should NOT dismiss after 1 second
    act(() => {
      jest.advanceTimersByTime(1000);
    });
    expect(contextResult.current.toasts).toHaveLength(1);

    // SHOULD dismiss after 2 seconds
    act(() => {
      jest.advanceTimersByTime(1000);
    });

    await waitFor(() => {
      expect(contextResult.current.toasts).toHaveLength(0);
    });
  });
});
```

**File:** `web/src/components/ui/__tests__/Toast.test.tsx`

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import Toast from '../Toast';
import type { Toast as ToastType } from '@/types/toast';

describe('Toast', () => {
  const mockDismiss = jest.fn();

  const baseToast: ToastType = {
    id: 'test-toast',
    message: 'Test message',
    variant: 'success',
    duration: 5000,
    dismissible: true,
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should render success variant with checkmark', () => {
    render(<Toast toast={baseToast} onDismiss={mockDismiss} />);

    expect(screen.getByText('Test message')).toBeInTheDocument();
    expect(screen.getByRole('status')).toHaveClass('bg-green-500/10');
  });

  it('should render error variant with X icon', () => {
    const errorToast = { ...baseToast, variant: 'error' as const };
    render(<Toast toast={errorToast} onDismiss={mockDismiss} />);

    expect(screen.getByRole('status')).toHaveClass('bg-red-500/10');
  });

  it('should render info variant with info icon', () => {
    const infoToast = { ...baseToast, variant: 'info' as const };
    render(<Toast toast={infoToast} onDismiss={mockDismiss} />);

    expect(screen.getByRole('status')).toHaveClass('bg-blue-500/10');
  });

  it('should render warning variant with warning icon', () => {
    const warningToast = { ...baseToast, variant: 'warning' as const };
    render(<Toast toast={warningToast} onDismiss={mockDismiss} />);

    expect(screen.getByRole('status')).toHaveClass('bg-yellow-500/10');
  });

  it('should call onDismiss when X button clicked', () => {
    jest.useFakeTimers();
    render(<Toast toast={baseToast} onDismiss={mockDismiss} />);

    const dismissButton = screen.getByLabelText('Dismiss notification');
    fireEvent.click(dismissButton);

    // Wait for exit animation
    jest.advanceTimersByTime(300);

    expect(mockDismiss).toHaveBeenCalledWith('test-toast');
    jest.useRealTimers();
  });

  it('should not render dismiss button if not dismissible', () => {
    const nonDismissibleToast = { ...baseToast, dismissible: false };
    render(<Toast toast={nonDismissibleToast} onDismiss={mockDismiss} />);

    expect(screen.queryByLabelText('Dismiss notification')).not.toBeInTheDocument();
  });

  it('should have proper ARIA attributes', () => {
    render(<Toast toast={baseToast} onDismiss={mockDismiss} />);

    const toast = screen.getByRole('status');
    expect(toast).toHaveAttribute('aria-live', 'polite');
  });
});
```

**Coverage target:** 95%+

### Integration Tests

**Scenario 1:** Full toast lifecycle
- Action: Trigger success toast from ContactForm
- Assert: Toast appears with success styling
- Wait: 5 seconds
- Assert: Toast auto-dismisses
- Assert: No console errors

**Scenario 2:** Queue overflow
- Action: Rapidly trigger 5 toasts
- Assert: Only 3 toasts visible
- Assert: Oldest toast removed
- Assert: Toasts stacked properly

**Scenario 3:** Manual dismissal
- Action: Trigger 3 toasts
- Action: Dismiss middle toast
- Assert: Toast exits smoothly
- Assert: Remaining toasts shift position

### Manual Testing

- [ ] Trigger success toast - verify green checkmark, message, auto-dismiss after 5s
- [ ] Trigger error toast - verify red X icon, message, auto-dismiss
- [ ] Trigger info toast - verify blue info icon
- [ ] Trigger warning toast - verify yellow warning icon
- [ ] Click X button - verify immediate dismissal with smooth animation
- [ ] Rapidly trigger 5 toasts - verify only 3 visible
- [ ] Verify toasts stacked vertically with proper spacing
- [ ] Test in light mode - verify colors readable
- [ ] Test in dark mode - verify colors readable
- [ ] Test on mobile (375px) - verify responsive positioning
- [ ] Test on desktop (1920px) - verify positioning in top-right
- [ ] Verify no layout shift when toast enters/exits
- [ ] Test screen reader announces toast messages

## Dependencies

**Must complete first:**
- Epic 001: Theme System - provides Tailwind theme tokens
- Epic 001: App.tsx root component - provides mount point for ToastProvider

**Enables:**
- Story 04: Contact Form Widget - uses toasts for feedback
- Story 05: Copy IP Button - uses toasts for "Copied!" feedback

## Risks & Mitigations

**Risk 1:** Too many toasts triggered rapidly could overwhelm user
**Mitigation:** Limit to 3 visible toasts; oldest removed automatically (FIFO queue)
**Fallback:** Increase max to 5 if users miss important notifications (gather feedback)

**Risk 2:** Auto-dismiss timers not cleaned up on unmount
**Mitigation:** Use React's built-in cleanup with Context; setTimeout IDs tracked properly
**Fallback:** Add explicit cleanup logic in useEffect if leaks detected

**Risk 3:** Portal rendering may cause issues with SSR (future consideration)
**Mitigation:** Use conditional rendering (only render portal in browser)
**Fallback:** Render inline if portal fails (still functional)

**Risk 4:** Animations may cause performance issues on low-end devices
**Mitigation:** Use CSS transitions (GPU-accelerated), not JavaScript animations
**Fallback:** Add `prefers-reduced-motion` media query to disable animations

**Risk 5:** Toasts may cover important UI elements
**Mitigation:** Position fixed in top-right with safe margins; pointer-events-none on container
**Fallback:** Allow positioning customization if issues reported

## Performance Considerations

**Expected load:** 1-5 toasts per user session (very low)
- Component very lightweight (<2KB)
- CSS animations GPU-accelerated
- Context re-renders only affect ToastContainer, not whole app

**Optimization strategy:**
- Use React Portal to avoid prop drilling
- Use CSS for animations (no JavaScript interval)
- Limit max toasts to prevent DOM bloat
- Auto-dismiss prevents indefinite accumulation

**Benchmarks:**
- Toast render: <3ms
- Add toast: <1ms
- Remove toast: <1ms
- Animation: 60fps (hardware accelerated)

## Security Considerations

**XSS risk:** Toast messages display user-provided text
**Mitigation:** React automatically escapes text content; no `dangerouslySetInnerHTML` used
**Additional:** Validate/sanitize messages before passing to toast (caller responsibility)

**No sensitive data in toasts:** Avoid displaying passwords, tokens, or PII

**ARIA accessibility:** Proper `role="status"` and `aria-live="polite"` for screen readers

## Success Verification

After implementation, verify:
- [ ] All unit tests pass (`pnpm test useToast Toast ToastContainer`)
- [ ] Integration tests pass (ContactForm, CopyIPButton use toasts)
- [ ] Manual testing checklist complete (all browsers, light/dark mode)
- [ ] Acceptance criteria from story satisfied (all 4 scenarios)
- [ ] No console errors or warnings
- [ ] Performance benchmarks met (render <3ms)
- [ ] Accessibility check (screen reader, keyboard navigation)
- [ ] TypeScript compiles with no errors (`pnpm tsc`)
- [ ] ESLint passes (`pnpm lint`)
- [ ] Bundle size impact <3KB (`pnpm build && pnpm analyze`)

## Traceability

**Parent story:** [.storyline/stories/epic-004/story-03-toast-notification-system.md](../../stories/epic-004/story-03-toast-notification-system.md)

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

## Implementation Notes

**Icon library:** Use `lucide-react` for icons (CheckCircle, XCircle, Info, AlertTriangle, X)

**Animation approach:** CSS transitions with Tailwind classes (`animate-in`, `slide-in-from-right`)

**Positioning:** Fixed top-right with `top-4 right-4`, safe area for mobile notches

**Dark mode:** Use semantic Tailwind tokens (e.g., `dark:text-green-300`) for theme support

**Accessibility:**
- Use `role="status"` for non-intrusive announcements
- Use `aria-live="polite"` to avoid interrupting screen readers
- Ensure dismiss button has `aria-label="Dismiss notification"`

**Open questions:**
- Should we support custom toast durations? (Decided: Yes, via options parameter)
- Should we support persistent toasts (no auto-dismiss)? (Decided: Yes, via `duration: 0`)
- Should we add sound effects? (Decided: No, avoid audio without user consent)

**Assumptions:**
- Modern browsers with Portal support (99%+ browsers)
- Tailwind CSS configured with animation utilities
- Theme system provides semantic color tokens
- Users have JavaScript enabled (React requirement)

**Future enhancements:**
- Add toast history/notification center
- Add undo action button for reversible operations
- Add progress bar showing remaining time
- Add haptic feedback on mobile devices
- Add swipe-to-dismiss gesture on mobile

---

**Next step:** Run `/dev-story .storyline/specs/epic-004/spec-03-toast-notification-system.md`
