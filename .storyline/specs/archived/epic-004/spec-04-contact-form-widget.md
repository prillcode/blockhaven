---
spec_id: 04
story_id: 004
epic_id: 004
title: Contact Form Widget
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 04: Contact Form Widget

## Overview

**User story:** [.storyline/stories/epic-004/story-04-contact-form-widget.md](../../stories/epic-004/story-04-contact-form-widget.md)

**Goal:** Create a React contact form component with client-side validation, integration with the `/api/contact` endpoint, loading states, error handling, and toast notifications for user feedback.

**Approach:** Build a controlled form component with React state, implement validation logic for name/email/message fields, use fetch API for submission, integrate with `useToast` for success/error feedback, and provide clear loading/error states.

## Technical Design

### Architecture Decision

**Chosen approach:** Controlled form component with custom validation

**Alternatives considered:**
- **react-hook-form library** - Adds 30KB+ dependency; overkill for simple 3-field form
- **Formik** - Heavier library (50KB+); more complex than needed
- **HTML5 validation only** - Insufficient UX; lacks custom error messages
- **Uncontrolled form with refs** - Less predictable; harder to test

**Rationale:** Controlled form with custom validation provides full control over UX, minimal bundle size, and is easy to understand. Built-in React state is sufficient for 3 fields. Custom validation allows precise error messages matching our requirements.

### System Components

**Frontend:**
- `web/src/widgets/ContactForm.tsx` - Main form component (new file)
- `web/src/lib/validation.ts` - Validation utility functions (new file)
- Uses `web/src/hooks/useToast.ts` (Spec 03)
- Uses `/api/contact` endpoint (Epic 003, Spec 03)

**Backend:**
- Uses existing `/api/contact` endpoint (Epic 003, Story 03)
- No backend changes required

**Database:**
- None (backend handles Discord webhook)

**External integrations:**
- Discord webhook (handled by backend)

## Implementation Details

### Files to Create

#### `web/src/lib/validation.ts`
**Purpose:** Reusable validation utility functions
**Exports:** Validation functions for form fields

**Implementation:**
```typescript
export interface ValidationResult {
  valid: boolean;
  error?: string;
}

/**
 * Validate name field
 * - Required
 * - Minimum 2 characters
 * - Maximum 100 characters
 */
export function validateName(name: string): ValidationResult {
  const trimmed = name.trim();

  if (!trimmed) {
    return { valid: false, error: 'Name is required' };
  }

  if (trimmed.length < 2) {
    return { valid: false, error: 'Name must be at least 2 characters' };
  }

  if (trimmed.length > 100) {
    return { valid: false, error: 'Name must be less than 100 characters' };
  }

  return { valid: true };
}

/**
 * Validate email field
 * - Required
 * - Valid email format (basic regex)
 */
export function validateEmail(email: string): ValidationResult {
  const trimmed = email.trim();

  if (!trimmed) {
    return { valid: false, error: 'Email is required' };
  }

  // Basic email regex - not overly strict
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(trimmed)) {
    return { valid: false, error: 'Please enter a valid email address' };
  }

  return { valid: true };
}

/**
 * Validate message field
 * - Required
 * - Minimum 10 characters
 * - Maximum 1000 characters
 */
export function validateMessage(message: string): ValidationResult {
  const trimmed = message.trim();

  if (!trimmed) {
    return { valid: false, error: 'Message is required' };
  }

  if (trimmed.length < 10) {
    return { valid: false, error: 'Message must be at least 10 characters' };
  }

  if (trimmed.length > 1000) {
    return { valid: false, error: 'Message must be less than 1000 characters' };
  }

  return { valid: true };
}

/**
 * Validate entire contact form
 */
export function validateContactForm(data: {
  name: string;
  email: string;
  message: string;
}): { valid: boolean; errors: Record<string, string> } {
  const errors: Record<string, string> = {};

  const nameResult = validateName(data.name);
  if (!nameResult.valid) errors.name = nameResult.error!;

  const emailResult = validateEmail(data.email);
  if (!emailResult.valid) errors.email = emailResult.error!;

  const messageResult = validateMessage(data.message);
  if (!messageResult.valid) errors.message = messageResult.error!;

  return {
    valid: Object.keys(errors).length === 0,
    errors,
  };
}
```

#### `web/src/widgets/ContactForm.tsx`
**Purpose:** Contact form component with validation and submission
**Exports:** ContactForm component (default export)

**Implementation:**
```typescript
import { useState, FormEvent, ChangeEvent } from 'react';
import { useToast } from '@/hooks/useToast';
import { validateContactForm } from '@/lib/validation';
import { Loader2, Send } from 'lucide-react';
import type { ContactFormData } from '@/types/api';

type FormState = 'idle' | 'submitting' | 'success' | 'error';

interface FormErrors {
  name?: string;
  email?: string;
  message?: string;
}

export default function ContactForm() {
  const toast = useToast();

  const [formState, setFormState] = useState<FormState>('idle');
  const [formData, setFormData] = useState<ContactFormData>({
    name: '',
    email: '',
    message: '',
  });
  const [errors, setErrors] = useState<FormErrors>({});
  const [touched, setTouched] = useState<Record<string, boolean>>({});

  const handleChange = (
    e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));

    // Clear error for this field when user starts typing
    if (errors[name as keyof FormErrors]) {
      setErrors((prev) => ({ ...prev, [name]: undefined }));
    }
  };

  const handleBlur = (field: string) => {
    setTouched((prev) => ({ ...prev, [field]: true }));
  };

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    // Mark all fields as touched
    setTouched({ name: true, email: true, message: true });

    // Validate form
    const validation = validateContactForm(formData);
    if (!validation.valid) {
      setErrors(validation.errors);
      return;
    }

    // Submit form
    setFormState('submitting');
    setErrors({});

    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to send message');
      }

      // Success
      setFormState('success');
      toast.success('Message sent successfully!');

      // Clear form
      setFormData({ name: '', email: '', message: '' });
      setTouched({});
    } catch (error) {
      setFormState('error');
      const errorMessage =
        error instanceof Error
          ? error.message
          : 'Failed to send message. Please try again.';
      toast.error(errorMessage);
    } finally {
      // Reset to idle after a brief delay
      setTimeout(() => {
        if (formState !== 'idle') {
          setFormState('idle');
        }
      }, 1000);
    }
  };

  const isSubmitting = formState === 'submitting';

  return (
    <form
      onSubmit={handleSubmit}
      className="w-full max-w-2xl mx-auto space-y-6"
      noValidate
    >
      {/* Name Field */}
      <div>
        <label
          htmlFor="name"
          className="block text-sm font-medium text-foreground mb-2"
        >
          Name <span className="text-destructive">*</span>
        </label>
        <input
          type="text"
          id="name"
          name="name"
          value={formData.name}
          onChange={handleChange}
          onBlur={() => handleBlur('name')}
          disabled={isSubmitting}
          className={`
            w-full px-4 py-2 rounded-md border bg-background text-foreground
            focus:outline-none focus:ring-2 focus:ring-primary
            disabled:opacity-50 disabled:cursor-not-allowed
            ${
              touched.name && errors.name
                ? 'border-destructive focus:ring-destructive'
                : 'border-border'
            }
          `}
          placeholder="John Doe"
          aria-invalid={touched.name && !!errors.name}
          aria-describedby={errors.name ? 'name-error' : undefined}
        />
        {touched.name && errors.name && (
          <p id="name-error" className="mt-1 text-sm text-destructive">
            {errors.name}
          </p>
        )}
      </div>

      {/* Email Field */}
      <div>
        <label
          htmlFor="email"
          className="block text-sm font-medium text-foreground mb-2"
        >
          Email <span className="text-destructive">*</span>
        </label>
        <input
          type="email"
          id="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          onBlur={() => handleBlur('email')}
          disabled={isSubmitting}
          className={`
            w-full px-4 py-2 rounded-md border bg-background text-foreground
            focus:outline-none focus:ring-2 focus:ring-primary
            disabled:opacity-50 disabled:cursor-not-allowed
            ${
              touched.email && errors.email
                ? 'border-destructive focus:ring-destructive'
                : 'border-border'
            }
          `}
          placeholder="john@example.com"
          aria-invalid={touched.email && !!errors.email}
          aria-describedby={errors.email ? 'email-error' : undefined}
        />
        {touched.email && errors.email && (
          <p id="email-error" className="mt-1 text-sm text-destructive">
            {errors.email}
          </p>
        )}
      </div>

      {/* Message Field */}
      <div>
        <label
          htmlFor="message"
          className="block text-sm font-medium text-foreground mb-2"
        >
          Message <span className="text-destructive">*</span>
        </label>
        <textarea
          id="message"
          name="message"
          value={formData.message}
          onChange={handleChange}
          onBlur={() => handleBlur('message')}
          disabled={isSubmitting}
          rows={5}
          className={`
            w-full px-4 py-2 rounded-md border bg-background text-foreground
            focus:outline-none focus:ring-2 focus:ring-primary
            disabled:opacity-50 disabled:cursor-not-allowed resize-none
            ${
              touched.message && errors.message
                ? 'border-destructive focus:ring-destructive'
                : 'border-border'
            }
          `}
          placeholder="How do I join the server?"
          aria-invalid={touched.message && !!errors.message}
          aria-describedby={errors.message ? 'message-error' : undefined}
        />
        {touched.message && errors.message && (
          <p id="message-error" className="mt-1 text-sm text-destructive">
            {errors.message}
          </p>
        )}
      </div>

      {/* Submit Button */}
      <button
        type="submit"
        disabled={isSubmitting}
        className="
          w-full flex items-center justify-center gap-2
          px-6 py-3 rounded-md
          bg-primary text-primary-foreground
          hover:bg-primary/90
          focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2
          disabled:opacity-50 disabled:cursor-not-allowed
          transition-colors font-medium
        "
      >
        {isSubmitting ? (
          <>
            <Loader2 className="h-5 w-5 animate-spin" />
            Sending...
          </>
        ) : (
          <>
            <Send className="h-5 w-5" />
            Send Message
          </>
        )}
      </button>
    </form>
  );
}
```

### Files to Modify

None - All new files for this feature.

### API Contracts

#### Endpoint: POST /api/contact

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "message": "How do I join the server?"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Message sent successfully"
}
```

**Response (Validation Error - 400):**
```json
{
  "success": false,
  "error": "Invalid email format"
}
```

**Response (Server Error - 500):**
```json
{
  "success": false,
  "error": "Failed to send message"
}
```

**Headers:**
- Request: `Content-Type: application/json`
- Response: `Content-Type: application/json`

### Database Changes

None - Backend endpoint handles Discord webhook integration.

### State Management

**Component state:**
```typescript
{
  formState: 'idle' | 'submitting' | 'success' | 'error',
  formData: {
    name: string,
    email: string,
    message: string
  },
  errors: {
    name?: string,
    email?: string,
    message?: string
  },
  touched: {
    name?: boolean,
    email?: boolean,
    message?: boolean
  }
}
```

**State transitions:**
1. **Initial:** `formState: 'idle'`, all fields empty
2. **User typing:** Update `formData`, clear field errors
3. **Field blur:** Mark field as `touched`
4. **Submit attempt:** Validate all fields, set errors if invalid
5. **Submitting:** `formState: 'submitting'`, disable form
6. **Success:** `formState: 'success'`, show toast, clear form, reset to idle
7. **Error:** `formState: 'error'`, show toast, keep form data, reset to idle

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Successful form submission
**Verification:**
- Unit test: Fill valid data, submit, mock successful API response
- Unit test: Verify success toast called with "Message sent successfully!"
- Unit test: Verify form fields cleared after success
- Unit test: Verify submit button re-enabled after success
- Manual check: Fill form, submit, see success toast, verify form cleared

**Story criterion 2:** Client-side validation errors
**Verification:**
- Unit test: Leave name empty, submit, verify error "Name is required"
- Unit test: Verify API not called when validation fails
- Unit test: Verify name field highlighted with red border
- Unit test: Verify submit button remains enabled (not stuck in loading state)
- Manual check: Submit empty form, see validation errors, no API call

**Story criterion 3:** API submission error
**Verification:**
- Unit test: Mock API to return 500 error
- Unit test: Verify error toast called with "Failed to send message. Please try again."
- Unit test: Verify form data retained (not cleared)
- Unit test: Verify submit button re-enabled, allowing retry
- Manual check: Stop backend, submit form, see error toast, data retained

**Story criterion 4:** Loading state prevents double submission
**Verification:**
- Unit test: Mock slow API response, click submit twice rapidly
- Unit test: Verify only one API request made
- Unit test: Verify button disabled during submission
- Unit test: Verify button shows spinner while loading
- Manual check: Submit form, rapidly click button, verify only one submission

## Testing Requirements

### Unit Tests

**File:** `web/src/lib/__tests__/validation.test.ts`

```typescript
import {
  validateName,
  validateEmail,
  validateMessage,
  validateContactForm,
} from '../validation';

describe('validation', () => {
  describe('validateName', () => {
    it('should reject empty name', () => {
      expect(validateName('').valid).toBe(false);
      expect(validateName('').error).toBe('Name is required');
    });

    it('should reject name with only whitespace', () => {
      expect(validateName('   ').valid).toBe(false);
    });

    it('should reject name shorter than 2 characters', () => {
      expect(validateName('A').valid).toBe(false);
      expect(validateName('A').error).toBe('Name must be at least 2 characters');
    });

    it('should accept valid name', () => {
      expect(validateName('John Doe').valid).toBe(true);
      expect(validateName('John Doe').error).toBeUndefined();
    });

    it('should reject name longer than 100 characters', () => {
      const longName = 'A'.repeat(101);
      expect(validateName(longName).valid).toBe(false);
    });
  });

  describe('validateEmail', () => {
    it('should reject empty email', () => {
      expect(validateEmail('').valid).toBe(false);
      expect(validateEmail('').error).toBe('Email is required');
    });

    it('should reject invalid email format', () => {
      expect(validateEmail('invalid').valid).toBe(false);
      expect(validateEmail('invalid@').valid).toBe(false);
      expect(validateEmail('@example.com').valid).toBe(false);
    });

    it('should accept valid email', () => {
      expect(validateEmail('john@example.com').valid).toBe(true);
      expect(validateEmail('user+tag@domain.co.uk').valid).toBe(true);
    });
  });

  describe('validateMessage', () => {
    it('should reject empty message', () => {
      expect(validateMessage('').valid).toBe(false);
    });

    it('should reject message shorter than 10 characters', () => {
      expect(validateMessage('Short').valid).toBe(false);
      expect(validateMessage('Short').error).toBe(
        'Message must be at least 10 characters'
      );
    });

    it('should accept valid message', () => {
      expect(validateMessage('This is a valid message.').valid).toBe(true);
    });

    it('should reject message longer than 1000 characters', () => {
      const longMessage = 'A'.repeat(1001);
      expect(validateMessage(longMessage).valid).toBe(false);
    });
  });

  describe('validateContactForm', () => {
    it('should validate entire form', () => {
      const result = validateContactForm({
        name: 'John Doe',
        email: 'john@example.com',
        message: 'This is a test message.',
      });

      expect(result.valid).toBe(true);
      expect(Object.keys(result.errors)).toHaveLength(0);
    });

    it('should return all field errors', () => {
      const result = validateContactForm({
        name: '',
        email: 'invalid',
        message: 'Short',
      });

      expect(result.valid).toBe(false);
      expect(result.errors.name).toBeDefined();
      expect(result.errors.email).toBeDefined();
      expect(result.errors.message).toBeDefined();
    });
  });
});
```

**File:** `web/src/widgets/__tests__/ContactForm.test.tsx`

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { vi } from 'vitest';
import ContactForm from '../ContactForm';
import * as useToastModule from '@/hooks/useToast';

vi.mock('@/hooks/useToast');

const mockToast = {
  toast: vi.fn(),
  success: vi.fn(),
  error: vi.fn(),
  info: vi.fn(),
  warning: vi.fn(),
  dismiss: vi.fn(),
};

vi.mocked(useToastModule.useToast).mockReturnValue(mockToast);

describe('ContactForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    global.fetch = vi.fn();
  });

  it('should render form fields', () => {
    render(<ContactForm />);

    expect(screen.getByLabelText(/name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/message/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /send message/i })).toBeInTheDocument();
  });

  it('should show validation errors when submitting empty form', async () => {
    render(<ContactForm />);

    const submitButton = screen.getByRole('button', { name: /send message/i });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Name is required')).toBeInTheDocument();
      expect(screen.getByText('Email is required')).toBeInTheDocument();
      expect(screen.getByText('Message is required')).toBeInTheDocument();
    });

    expect(global.fetch).not.toHaveBeenCalled();
  });

  it('should clear field error when user starts typing', async () => {
    render(<ContactForm />);

    // Submit to show errors
    fireEvent.click(screen.getByRole('button', { name: /send message/i }));
    await waitFor(() => {
      expect(screen.getByText('Name is required')).toBeInTheDocument();
    });

    // Type in name field
    const nameInput = screen.getByLabelText(/name/i);
    fireEvent.change(nameInput, { target: { value: 'John' } });

    await waitFor(() => {
      expect(screen.queryByText('Name is required')).not.toBeInTheDocument();
    });
  });

  it('should submit form successfully', async () => {
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ success: true, message: 'Message sent' }),
    });

    render(<ContactForm />);

    // Fill form
    fireEvent.change(screen.getByLabelText(/name/i), {
      target: { value: 'John Doe' },
    });
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'john@example.com' },
    });
    fireEvent.change(screen.getByLabelText(/message/i), {
      target: { value: 'This is a test message.' },
    });

    // Submit
    fireEvent.click(screen.getByRole('button', { name: /send message/i }));

    // Verify loading state
    await waitFor(() => {
      expect(screen.getByText('Sending...')).toBeInTheDocument();
    });

    // Verify success
    await waitFor(() => {
      expect(mockToast.success).toHaveBeenCalledWith('Message sent successfully!');
    });

    // Verify form cleared
    expect(screen.getByLabelText(/name/i)).toHaveValue('');
    expect(screen.getByLabelText(/email/i)).toHaveValue('');
    expect(screen.getByLabelText(/message/i)).toHaveValue('');
  });

  it('should handle API error', async () => {
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: false,
      json: async () => ({ success: false, error: 'Server error' }),
    });

    render(<ContactForm />);

    // Fill form
    fireEvent.change(screen.getByLabelText(/name/i), {
      target: { value: 'John Doe' },
    });
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'john@example.com' },
    });
    fireEvent.change(screen.getByLabelText(/message/i), {
      target: { value: 'This is a test message.' },
    });

    // Submit
    fireEvent.click(screen.getByRole('button', { name: /send message/i }));

    // Verify error toast
    await waitFor(() => {
      expect(mockToast.error).toHaveBeenCalledWith('Server error');
    });

    // Verify form data retained
    expect(screen.getByLabelText(/name/i)).toHaveValue('John Doe');
    expect(screen.getByLabelText(/email/i)).toHaveValue('john@example.com');
  });

  it('should prevent double submission', async () => {
    (global.fetch as jest.Mock).mockImplementation(
      () =>
        new Promise((resolve) =>
          setTimeout(
            () => resolve({ ok: true, json: async () => ({ success: true }) }),
            1000
          )
        )
    );

    render(<ContactForm />);

    // Fill form
    fireEvent.change(screen.getByLabelText(/name/i), {
      target: { value: 'John Doe' },
    });
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'john@example.com' },
    });
    fireEvent.change(screen.getByLabelText(/message/i), {
      target: { value: 'This is a test message.' },
    });

    const submitButton = screen.getByRole('button', { name: /send message/i });

    // Click submit twice
    fireEvent.click(submitButton);
    fireEvent.click(submitButton);

    // Wait for request to complete
    await waitFor(
      () => {
        expect(mockToast.success).toHaveBeenCalled();
      },
      { timeout: 2000 }
    );

    // Verify only one API call
    expect(global.fetch).toHaveBeenCalledTimes(1);
  });

  it('should validate email format', async () => {
    render(<ContactForm />);

    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'invalid-email' },
    });

    fireEvent.click(screen.getByRole('button', { name: /send message/i }));

    await waitFor(() => {
      expect(
        screen.getByText('Please enter a valid email address')
      ).toBeInTheDocument();
    });
  });

  it('should validate message minimum length', async () => {
    render(<ContactForm />);

    fireEvent.change(screen.getByLabelText(/message/i), {
      target: { value: 'Short' },
    });

    fireEvent.click(screen.getByRole('button', { name: /send message/i }));

    await waitFor(() => {
      expect(
        screen.getByText('Message must be at least 10 characters')
      ).toBeInTheDocument();
    });
  });
});
```

**Coverage target:** 95%+

### Integration Tests

**Scenario 1:** Full form submission flow
- Action: Fill valid form data and submit
- Assert: Loading state appears
- Assert: API called with correct payload
- Assert: Success toast appears
- Assert: Form cleared

**Scenario 2:** Error recovery
- Action: Submit form with network error
- Assert: Error toast appears
- Action: Fix network, resubmit
- Assert: Success toast appears

### Manual Testing

- [ ] Render form on Contact page
- [ ] Submit empty form - verify all 3 validation errors appear
- [ ] Fill name only, submit - verify email and message errors
- [ ] Fill invalid email, submit - verify email format error
- [ ] Fill message with 5 chars, submit - verify min length error
- [ ] Fill all fields validly, submit - verify success toast
- [ ] Verify form fields cleared after success
- [ ] Verify loading state (spinner, disabled button) during submission
- [ ] Stop backend API, submit - verify error toast, data retained
- [ ] Rapidly click submit - verify only one submission
- [ ] Test on mobile (375px) - verify responsive layout
- [ ] Test in light and dark mode - verify readable
- [ ] Test keyboard navigation (Tab, Enter to submit)
- [ ] Test screen reader announcements for errors

## Dependencies

**Must complete first:**
- Spec 03: Toast Notification System - provides feedback UI
- Epic 003, Spec 03: Contact Form Endpoint - provides backend API

**Enables:**
- Contact page is fully functional
- Users can submit support requests

## Risks & Mitigations

**Risk 1:** Spam submissions without rate limiting
**Mitigation:** Backend already implements rate limiting (Epic 003, Spec 04)
**Fallback:** Add client-side debouncing or cooldown period between submissions

**Risk 2:** Network errors during submission
**Mitigation:** Proper error handling with clear user feedback; form data retained
**Fallback:** Add retry mechanism with exponential backoff

**Risk 3:** Validation regex may be too strict or too lenient
**Mitigation:** Use reasonable email regex (not RFC-compliant, but practical)
**Fallback:** Adjust validation based on user feedback

**Risk 4:** Form state not cleared after successful submission
**Mitigation:** Explicit state reset in success handler
**Fallback:** Add manual "Clear form" button if issues reported

**Risk 5:** CORS errors if API not configured
**Mitigation:** Backend already configured with CORS (Epic 003, Spec 04)
**Fallback:** Add proxy in Vite config for local development

## Performance Considerations

**Expected load:** Form submission is infrequent (1-5 per user session)
- Component renders only on Contact page (code-split)
- Validation runs on submit only (not on every keystroke)
- No expensive computations

**Optimization strategy:**
- Use controlled inputs (no unnecessary re-renders)
- Validate only touched fields
- Debounce validation on blur (not implemented yet, can add if needed)

**Benchmarks:**
- Initial render: <10ms
- Validation: <1ms
- Form submission: <500ms (network dependent)

## Security Considerations

**XSS prevention:** All form data sanitized by React (no dangerouslySetInnerHTML)

**CSRF protection:** Not required (no authentication/session)

**Input validation:**
- Client-side validation for UX
- Backend validation for security (Epic 003)
- Trim whitespace to prevent bypass

**Rate limiting:** Backend implements rate limiting (Epic 003, Spec 04)

**No sensitive data:** Form does not collect passwords, credit cards, etc.

## Success Verification

After implementation, verify:
- [ ] All unit tests pass (`pnpm test ContactForm validation`)
- [ ] Integration tests pass (full submission flow)
- [ ] Manual testing checklist complete
- [ ] Acceptance criteria from story satisfied (all 4 scenarios)
- [ ] No console errors or warnings
- [ ] Performance benchmarks met
- [ ] Accessibility check (ARIA labels, keyboard navigation, screen reader)
- [ ] TypeScript compiles with no errors (`pnpm tsc`)
- [ ] ESLint passes (`pnpm lint`)
- [ ] Works in light and dark mode
- [ ] Responsive on mobile and desktop

## Traceability

**Parent story:** [.storyline/stories/epic-004/story-04-contact-form-widget.md](../../stories/epic-004/story-04-contact-form-widget.md)

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

## Implementation Notes

**Form patterns:** Use controlled inputs with `value` and `onChange`

**Validation strategy:** Validate on submit, clear errors on change, show errors only on touched fields

**Loading states:** Disable form and show spinner during submission

**Error handling:** Retain form data on error to allow retry without re-typing

**Accessibility:**
- Use semantic HTML (`<label>`, `<input>`, `<textarea>`, `<form>`)
- Associate labels with inputs via `htmlFor` and `id`
- Add `aria-invalid` and `aria-describedby` for error messages
- Ensure keyboard navigation works (Tab order, Enter to submit)
- Mark required fields with visual indicator (*) and `required` in label text

**Icon library:** Use `lucide-react` for Loader2 and Send icons

**Open questions:**
- Should we add a "Clear form" button? (Decided: No, form auto-clears on success)
- Should we save draft to localStorage? (Decided: No, out of scope)
- Should we add character counters? (Decided: No, not required)

**Assumptions:**
- Backend `/api/contact` endpoint is functional (Epic 003)
- Toast system is available (Spec 03)
- Theme system provides semantic tokens
- Users have JavaScript enabled

**Future enhancements:**
- Add auto-save to localStorage (prevent data loss on accidental close)
- Add character counters for textarea
- Add field-level validation on blur (not just on submit)
- Add reCAPTCHA or hCaptcha for bot prevention
- Add confirmation email to user after submission
- Add file attachment support (e.g., screenshots)

---

**Next step:** Run `/dev-story .storyline/specs/epic-004/spec-04-contact-form-widget.md`
