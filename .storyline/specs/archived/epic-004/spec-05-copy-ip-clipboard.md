---
spec_id: 05
story_id: 005
epic_id: 004
title: Copy IP to Clipboard Button
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 05: Copy IP to Clipboard Button

## Overview

**User story:** [.storyline/stories/epic-004/story-05-copy-ip-clipboard.md](../../stories/epic-004/story-05-copy-ip-clipboard.md)

**Goal:** Create a reusable "Copy IP" button component that copies the server IP address to the clipboard using modern Clipboard API with fallback, provides visual feedback via toast notifications and success animation, and handles errors gracefully.

**Approach:** Build a custom React component with a reusable `useCopyToClipboard` hook that uses `navigator.clipboard.writeText()` with `document.execCommand()` fallback for older browsers. Integrate with toast system for feedback and provide temporary success animation (checkmark icon).

## Technical Design

### Architecture Decision

**Chosen approach:** Custom hook + presentational component with Clipboard API

**Alternatives considered:**
- **Third-party library (react-copy-to-clipboard)** - Adds unnecessary dependency for simple feature
- **Direct clipboard access in component** - Not reusable; harder to test
- **Browser extension approach** - Not applicable; website-only feature
- **Auto-copy on page load** - Intrusive UX; not user-initiated

**Rationale:** Custom hook provides reusability for future copy features (Discord link, commands, etc.). Modern Clipboard API is well-supported (97%+ browsers) with fallback for legacy browsers. Separating logic from presentation enables easier testing and flexibility in UI.

### System Components

**Frontend:**
- `web/src/hooks/useCopyToClipboard.ts` - Reusable clipboard hook (new file)
- `web/src/widgets/CopyIPButton.tsx` - Button component (new file)
- `web/src/lib/constants.ts` - Server constants (modify existing or create)
- Uses `web/src/hooks/useToast.ts` (Spec 03)

**Backend:**
- None (client-side only)

**Database:**
- None

**External integrations:**
- Browser Clipboard API

## Implementation Details

### Files to Create

#### `web/src/lib/constants.ts`
**Purpose:** Centralized application constants
**Exports:** Server configuration constants

**Implementation:**
```typescript
/**
 * Minecraft server configuration
 */
export const SERVER_CONFIG = {
  IP: '5.161.69.191',
  PORT: 25565,
  FULL_ADDRESS: '5.161.69.191:25565',
} as const;

/**
 * Discord configuration
 */
export const DISCORD_CONFIG = {
  INVITE_URL: 'https://discord.gg/your-invite-code',
} as const;
```

#### `web/src/hooks/useCopyToClipboard.ts`
**Purpose:** Reusable hook for copying text to clipboard
**Exports:** useCopyToClipboard hook (default export)

**Implementation:**
```typescript
import { useState, useCallback } from 'react';

export interface CopyToClipboardResult {
  copied: boolean;
  copy: (text: string) => Promise<void>;
  error: Error | null;
}

/**
 * Custom hook for copying text to clipboard
 * Uses modern Clipboard API with fallback to document.execCommand
 */
export function useCopyToClipboard(): CopyToClipboardResult {
  const [copied, setCopied] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const copy = useCallback(async (text: string) => {
    try {
      // Reset state
      setError(null);

      // Try modern Clipboard API first
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(text);
      } else {
        // Fallback for older browsers or non-HTTPS contexts
        const success = copyToClipboardFallback(text);
        if (!success) {
          throw new Error('Failed to copy to clipboard');
        }
      }

      // Set copied state to true
      setCopied(true);

      // Reset copied state after 2 seconds
      setTimeout(() => {
        setCopied(false);
      }, 2000);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to copy');
      setError(error);
      throw error;
    }
  }, []);

  return { copied, copy, error };
}

/**
 * Fallback method using document.execCommand for older browsers
 */
function copyToClipboardFallback(text: string): boolean {
  // Create temporary textarea element
  const textarea = document.createElement('textarea');
  textarea.value = text;
  textarea.style.position = 'fixed';
  textarea.style.left = '-9999px';
  textarea.setAttribute('readonly', '');

  document.body.appendChild(textarea);

  try {
    // Select text
    textarea.select();
    textarea.setSelectionRange(0, text.length);

    // Copy to clipboard
    const success = document.execCommand('copy');

    return success;
  } catch (err) {
    console.error('Fallback copy failed:', err);
    return false;
  } finally {
    // Clean up
    document.body.removeChild(textarea);
  }
}
```

#### `web/src/widgets/CopyIPButton.tsx`
**Purpose:** Button component for copying server IP to clipboard
**Exports:** CopyIPButton component (default export)

**Implementation:**
```typescript
import { useState } from 'react';
import { Copy, Check } from 'lucide-react';
import { useCopyToClipboard } from '@/hooks/useCopyToClipboard';
import { useToast } from '@/hooks/useToast';
import { SERVER_CONFIG } from '@/lib/constants';
import { cn } from '@/lib/utils';

export interface CopyIPButtonProps {
  className?: string;
  variant?: 'default' | 'icon-only';
  showIP?: boolean;
}

export default function CopyIPButton({
  className = '',
  variant = 'default',
  showIP = true,
}: CopyIPButtonProps) {
  const { copied, copy } = useCopyToClipboard();
  const toast = useToast();
  const [isAnimating, setIsAnimating] = useState(false);

  const handleCopy = async () => {
    try {
      await copy(SERVER_CONFIG.FULL_ADDRESS);
      toast.success('IP copied to clipboard!');

      // Trigger success animation
      setIsAnimating(true);
      setTimeout(() => setIsAnimating(false), 2000);
    } catch (error) {
      toast.error('Failed to copy IP. Please copy manually.');
      console.error('Copy failed:', error);
    }
  };

  if (variant === 'icon-only') {
    return (
      <button
        onClick={handleCopy}
        className={cn(
          'inline-flex items-center justify-center',
          'rounded-md p-2',
          'border border-border bg-background',
          'hover:bg-muted transition-colors',
          'focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2',
          copied && 'bg-green-500/10 border-green-500/50',
          className
        )}
        title="Copy server IP"
        aria-label="Copy server IP to clipboard"
      >
        {copied ? (
          <Check className="h-5 w-5 text-green-500" />
        ) : (
          <Copy className="h-5 w-5 text-foreground" />
        )}
      </button>
    );
  }

  return (
    <div className={cn('flex flex-col gap-2', className)}>
      {showIP && (
        <div className="flex items-center justify-between gap-3 px-4 py-2 rounded-md border border-border bg-card">
          <div className="flex-1">
            <p className="text-xs text-muted-foreground mb-1">Server IP</p>
            <p className="font-mono text-sm font-medium text-foreground">
              {SERVER_CONFIG.FULL_ADDRESS}
            </p>
          </div>

          <button
            onClick={handleCopy}
            className={cn(
              'inline-flex items-center gap-2 px-4 py-2 rounded-md',
              'border border-border bg-background',
              'hover:bg-muted transition-all',
              'focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2',
              'text-sm font-medium',
              copied && 'bg-green-500/10 border-green-500/50 text-green-600',
              isAnimating && 'scale-105'
            )}
            title="Click to copy"
            aria-label="Copy server IP to clipboard"
          >
            {copied ? (
              <>
                <Check className="h-4 w-4" />
                Copied!
              </>
            ) : (
              <>
                <Copy className="h-4 w-4" />
                Copy
              </>
            )}
          </button>
        </div>
      )}

      {!showIP && (
        <button
          onClick={handleCopy}
          className={cn(
            'inline-flex items-center gap-2 px-4 py-2 rounded-md',
            'border border-border bg-background',
            'hover:bg-muted transition-all',
            'focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2',
            'text-sm font-medium',
            copied && 'bg-green-500/10 border-green-500/50 text-green-600',
            isAnimating && 'scale-105',
            className
          )}
          title="Click to copy server IP"
          aria-label="Copy server IP to clipboard"
        >
          {copied ? (
            <>
              <Check className="h-4 w-4" />
              Copied!
            </>
          ) : (
            <>
              <Copy className="h-4 w-4" />
              Copy Server IP
            </>
          )}
        </button>
      )}
    </div>
  );
}
```

### Files to Modify

None - All new files for this feature.

### API Contracts

None - This is a client-side only feature with no backend integration.

### Database Changes

None

### State Management

**Hook state (useCopyToClipboard):**
```typescript
{
  copied: boolean,      // True for 2 seconds after successful copy
  error: Error | null   // Error if copy failed
}
```

**Component state (CopyIPButton):**
```typescript
{
  isAnimating: boolean  // True for 2 seconds after copy for scale animation
}
```

**State flow:**
1. **Initial:** `copied: false`, `isAnimating: false`
2. **Click button:** Call `copy()` with server IP
3. **Copy success:** `copied: true`, `isAnimating: true`, show success toast
4. **After 2 seconds:** `copied: false`, `isAnimating: false` (auto-reset)
5. **Copy failure:** `error: Error`, show error toast

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Successful IP copy (modern browser)
**Verification:**
- Unit test: Mock `navigator.clipboard.writeText`, call copy, verify success
- Unit test: Verify `copied` state becomes true
- Unit test: Verify success toast called with "IP copied to clipboard!"
- Unit test: Verify checkmark icon displayed
- Manual check: Click button, verify toast, paste in notepad, verify IP correct

**Story criterion 2:** Copy in older browser (fallback)
**Verification:**
- Unit test: Mock `navigator.clipboard` as undefined, verify fallback used
- Unit test: Mock `document.execCommand`, verify returns success
- Unit test: Verify success toast still displayed
- Manual check: Test in IE11 or Firefox ESR (if available)

**Story criterion 3:** Copy failure
**Verification:**
- Unit test: Mock `navigator.clipboard.writeText` to throw error
- Unit test: Verify error toast called with "Failed to copy IP. Please copy manually."
- Unit test: Verify IP text still visible for manual copy
- Unit test: Verify app doesn't crash
- Manual check: Block clipboard access in browser settings, verify error handling

**Story criterion 4:** Button hover state
**Verification:**
- Unit test: Render button, verify hover class exists
- Unit test: Verify cursor pointer style applied
- Manual check: Hover button, see background color change
- Manual check: Verify tooltip/title shows "Click to copy"

## Testing Requirements

### Unit Tests

**File:** `web/src/hooks/__tests__/useCopyToClipboard.test.ts`

```typescript
import { renderHook, act, waitFor } from '@testing-library/react';
import { useCopyToClipboard } from '../useCopyToClipboard';

describe('useCopyToClipboard', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });

  it('should copy text successfully with Clipboard API', async () => {
    const writeTextMock = jest.fn().mockResolvedValue(undefined);
    Object.assign(navigator, {
      clipboard: { writeText: writeTextMock },
    });

    const { result } = renderHook(() => useCopyToClipboard());

    await act(async () => {
      await result.current.copy('test text');
    });

    expect(writeTextMock).toHaveBeenCalledWith('test text');
    expect(result.current.copied).toBe(true);
    expect(result.current.error).toBeNull();
  });

  it('should reset copied state after 2 seconds', async () => {
    const writeTextMock = jest.fn().mockResolvedValue(undefined);
    Object.assign(navigator, {
      clipboard: { writeText: writeTextMock },
    });

    const { result } = renderHook(() => useCopyToClipboard());

    await act(async () => {
      await result.current.copy('test text');
    });

    expect(result.current.copied).toBe(true);

    // Fast-forward 2 seconds
    act(() => {
      jest.advanceTimersByTime(2000);
    });

    await waitFor(() => {
      expect(result.current.copied).toBe(false);
    });
  });

  it('should use fallback when Clipboard API unavailable', async () => {
    // Mock clipboard API as undefined
    Object.assign(navigator, { clipboard: undefined });

    // Mock document.execCommand
    const execCommandMock = jest.fn().mockReturnValue(true);
    document.execCommand = execCommandMock;

    const { result } = renderHook(() => useCopyToClipboard());

    await act(async () => {
      await result.current.copy('fallback text');
    });

    expect(execCommandMock).toHaveBeenCalledWith('copy');
    expect(result.current.copied).toBe(true);
  });

  it('should handle copy failure', async () => {
    const writeTextMock = jest.fn().mockRejectedValue(new Error('Permission denied'));
    Object.assign(navigator, {
      clipboard: { writeText: writeTextMock },
    });

    const { result } = renderHook(() => useCopyToClipboard());

    await act(async () => {
      try {
        await result.current.copy('test text');
      } catch (err) {
        // Expected to throw
      }
    });

    expect(result.current.copied).toBe(false);
    expect(result.current.error).toBeInstanceOf(Error);
  });

  it('should handle fallback failure', async () => {
    Object.assign(navigator, { clipboard: undefined });
    const execCommandMock = jest.fn().mockReturnValue(false);
    document.execCommand = execCommandMock;

    const { result } = renderHook(() => useCopyToClipboard());

    await expect(
      act(async () => {
        await result.current.copy('test text');
      })
    ).rejects.toThrow('Failed to copy to clipboard');
  });
});
```

**File:** `web/src/widgets/__tests__/CopyIPButton.test.tsx`

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { vi } from 'vitest';
import CopyIPButton from '../CopyIPButton';
import * as useCopyToClipboardModule from '@/hooks/useCopyToClipboard';
import * as useToastModule from '@/hooks/useToast';

vi.mock('@/hooks/useCopyToClipboard');
vi.mock('@/hooks/useToast');

const mockCopy = vi.fn();
const mockToast = {
  toast: vi.fn(),
  success: vi.fn(),
  error: vi.fn(),
  info: vi.fn(),
  warning: vi.fn(),
  dismiss: vi.fn(),
};

describe('CopyIPButton', () => {
  beforeEach(() => {
    vi.clearAllMocks();

    vi.mocked(useCopyToClipboardModule.useCopyToClipboard).mockReturnValue({
      copied: false,
      copy: mockCopy,
      error: null,
    });

    vi.mocked(useToastModule.useToast).mockReturnValue(mockToast);
  });

  it('should render button with default variant', () => {
    render(<CopyIPButton />);

    expect(screen.getByText('5.161.69.191:25565')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy server ip/i })).toBeInTheDocument();
  });

  it('should render icon-only variant', () => {
    render(<CopyIPButton variant="icon-only" />);

    const button = screen.getByRole('button', { name: /copy server ip/i });
    expect(button).toBeInTheDocument();
    expect(screen.queryByText('5.161.69.191:25565')).not.toBeInTheDocument();
  });

  it('should hide IP when showIP is false', () => {
    render(<CopyIPButton showIP={false} />);

    expect(screen.queryByText('5.161.69.191:25565')).not.toBeInTheDocument();
    expect(screen.getByRole('button', { name: /copy server ip/i })).toBeInTheDocument();
  });

  it('should copy IP on button click', async () => {
    mockCopy.mockResolvedValueOnce(undefined);

    render(<CopyIPButton />);

    const button = screen.getByRole('button', { name: /copy server ip/i });
    fireEvent.click(button);

    await waitFor(() => {
      expect(mockCopy).toHaveBeenCalledWith('5.161.69.191:25565');
      expect(mockToast.success).toHaveBeenCalledWith('IP copied to clipboard!');
    });
  });

  it('should show checkmark when copied', () => {
    vi.mocked(useCopyToClipboardModule.useCopyToClipboard).mockReturnValue({
      copied: true,
      copy: mockCopy,
      error: null,
    });

    render(<CopyIPButton />);

    expect(screen.getByText('Copied!')).toBeInTheDocument();
  });

  it('should handle copy failure', async () => {
    mockCopy.mockRejectedValueOnce(new Error('Permission denied'));

    render(<CopyIPButton />);

    const button = screen.getByRole('button', { name: /copy server ip/i });
    fireEvent.click(button);

    await waitFor(() => {
      expect(mockToast.error).toHaveBeenCalledWith(
        'Failed to copy IP. Please copy manually.'
      );
    });
  });

  it('should have proper ARIA attributes', () => {
    render(<CopyIPButton />);

    const button = screen.getByRole('button', { name: /copy server ip/i });
    expect(button).toHaveAttribute('aria-label', 'Copy server IP to clipboard');
    expect(button).toHaveAttribute('title');
  });

  it('should apply custom className', () => {
    const { container } = render(<CopyIPButton className="custom-class" />);

    expect(container.firstChild).toHaveClass('custom-class');
  });

  it('should show copy icon by default', () => {
    render(<CopyIPButton />);

    const button = screen.getByRole('button', { name: /copy server ip/i });
    expect(button.querySelector('svg')).toBeInTheDocument();
  });
});
```

**Coverage target:** 95%+

### Integration Tests

**Scenario 1:** Copy IP from homepage
- Action: Navigate to homepage
- Action: Click "Copy IP" button
- Assert: Success toast appears
- Action: Paste in text editor
- Assert: IP is "5.161.69.191:25565"

**Scenario 2:** Copy IP in ServerStatus widget
- Action: Render ServerStatus widget with `showIP={true}`
- Action: Click copy button
- Assert: Toast appears
- Assert: Clipboard contains IP

### Manual Testing

- [ ] Click "Copy IP" button - verify success toast appears
- [ ] Paste clipboard into Minecraft server address - verify correct IP
- [ ] Click button - verify checkmark icon appears for 2 seconds
- [ ] Click button - verify button background turns green briefly
- [ ] Hover button - verify background color change
- [ ] Hover button - verify cursor changes to pointer
- [ ] Test in Chrome - verify works
- [ ] Test in Firefox - verify works
- [ ] Test in Safari - verify works
- [ ] Test in Edge - verify works
- [ ] Block clipboard permission - verify error toast appears
- [ ] Test on mobile - verify button touch target large enough
- [ ] Test in light mode - verify readable
- [ ] Test in dark mode - verify readable
- [ ] Test keyboard navigation (Tab to button, Enter to copy)
- [ ] Test screen reader announces "Copied!" state

## Dependencies

**Must complete first:**
- Spec 03: Toast Notification System - provides feedback UI
- Epic 001: Theme System - provides styling tokens

**Enables:**
- Homepage displays functional "Copy IP" button
- ServerStatus widget can include copy functionality

## Risks & Mitigations

**Risk 1:** Clipboard API not available (older browsers, non-HTTPS)
**Mitigation:** Implement `document.execCommand` fallback for 99%+ browser support
**Fallback:** Display IP prominently for manual copy

**Risk 2:** Browser blocks clipboard access (permissions)
**Mitigation:** Proper error handling with clear user feedback; IP remains visible
**Fallback:** Add "Select all" helper text if copy consistently fails

**Risk 3:** User clicks button multiple times rapidly
**Mitigation:** Button state changes immediately; subsequent clicks are no-ops during animation
**Fallback:** Debounce click handler if multiple toasts become an issue

**Risk 4:** Success animation may be jarring or distracting
**Mitigation:** Subtle scale animation (1.05x) and color change; respects `prefers-reduced-motion`
**Fallback:** Remove animation if users report issues

**Risk 5:** IP hardcoded in component may need updating
**Mitigation:** Use centralized constants file (`lib/constants.ts`)
**Fallback:** Environment variable if IP needs to be configurable

## Performance Considerations

**Expected load:** Very low - copy action is infrequent (once per user session)
- Component very lightweight (<1KB)
- No polling or network requests
- No expensive computations

**Optimization strategy:**
- Use CSS for animations (GPU-accelerated)
- Minimize re-renders (only update state on copy)
- Cleanup timers on unmount

**Benchmarks:**
- Component render: <2ms
- Copy operation: <10ms
- Animation: 60fps (CSS transform)

## Security Considerations

**No sensitive data:** Server IP is public information, safe to copy

**XSS prevention:** IP hardcoded constant (not user input), no risk

**Clipboard access:** Modern browsers require user interaction (click) before allowing clipboard write

**No tracking:** Copy action doesn't send analytics (can add if needed)

## Success Verification

After implementation, verify:
- [ ] All unit tests pass (`pnpm test CopyIPButton useCopyToClipboard`)
- [ ] Integration tests pass (copy from homepage, ServerStatus widget)
- [ ] Manual testing checklist complete (all browsers)
- [ ] Acceptance criteria from story satisfied (all 4 scenarios)
- [ ] No console errors or warnings
- [ ] Performance benchmarks met (render <2ms)
- [ ] Accessibility check (ARIA labels, keyboard navigation, screen reader)
- [ ] TypeScript compiles with no errors (`pnpm tsc`)
- [ ] ESLint passes (`pnpm lint`)
- [ ] Works in light and dark mode
- [ ] Responsive on mobile and desktop
- [ ] Bundle size impact <1KB (`pnpm build && pnpm analyze`)

## Traceability

**Parent story:** [.storyline/stories/epic-004/story-05-copy-ip-clipboard.md](../../stories/epic-004/story-05-copy-ip-clipboard.md)

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

## Implementation Notes

**Icon library:** Use `lucide-react` for Copy and Check icons

**Animation approach:** CSS transition with `scale-105` transform for success animation

**Clipboard API support:** 97%+ browsers support `navigator.clipboard.writeText()`

**Fallback approach:** `document.execCommand('copy')` covers remaining 2-3% of browsers

**Accessibility:**
- Ensure button has proper `aria-label` for screen readers
- Provide visual feedback (icon change, color change) for deaf users
- Provide toast announcement for blind users
- Ensure keyboard accessible (focusable, Enter key works)

**Constants location:** Centralize server configuration in `lib/constants.ts` for easy updates

**Reusability:** `useCopyToClipboard` hook can be reused for:
- Copying Discord invite link
- Copying Minecraft commands
- Copying player names/UUIDs
- Future copy features

**Open questions:**
- Should we add analytics for copy button usage? (Decided: Not yet, can add later)
- Should we show IP in multiple formats (with/without port)? (Decided: No, full address only)
- Should we add "Select all" option as fallback? (Decided: No, copy is sufficient)

**Assumptions:**
- Server IP is static and won't change frequently
- Users have modern browsers (97%+ Clipboard API support)
- HTTPS in production (required for Clipboard API)
- Users have JavaScript enabled

**Future enhancements:**
- Add copy button for Discord invite link
- Add copy button for common Minecraft commands
- Add QR code generation for mobile users
- Add "Share" button using Web Share API
- Track copy analytics (conversion funnel)
- Add haptic feedback on mobile devices
- Add animated confetti on first copy (delight moment)

---

**Next step:** Run `/dev-story .storyline/specs/epic-004/spec-05-copy-ip-clipboard.md`
