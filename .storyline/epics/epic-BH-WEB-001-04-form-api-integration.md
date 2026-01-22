# Epic 4: Request Form & API Integration

**Epic ID:** BH-WEB-001-04
**Status:** Not Started
**Priority:** P0 (Must Have)
**Source:** web/.docs/ASTRO-SITE-PRD.md

---

## Business Goal

Implement a secure, spam-resistant whitelist request system that captures prospective player information through a validated form and delivers email notifications to administrators via Resend API, running on Cloudflare Workers with rate limiting to prevent abuse.

## User Value

**Who Benefits:** Prospective players, server administrators

**How They Benefit:**
- **Players:** Easy-to-use form to request server access from any device
- **Admins:** Automated email notifications with all player details for whitelist processing
- **Both:** Spam prevention ensures only legitimate requests are processed
- **Both:** Form validation prevents incomplete or invalid submissions

## Success Criteria

- [ ] Request form validates all required fields (client-side and server-side)
- [ ] Form submits successfully to `/api/request-access` API route
- [ ] Admin receives formatted email via Resend for each submission
- [ ] Rate limiting prevents spam (3 submissions per 15 minutes per IP)
- [ ] Form displays clear success/error messages to users
- [ ] Form is fully accessible (ARIA labels, keyboard navigation)
- [ ] Form works smoothly on mobile devices
- [ ] API route works correctly in Cloudflare Workers environment

## Scope

### In Scope
- **RequestForm Component (`components/RequestForm.astro` or `.tsx`):**
  - Form UI with all fields
  - Client-side validation (HTML5 + JavaScript)
  - Loading states during submission
  - Success and error message displays
  - Accessible markup (ARIA labels, proper form semantics)

- **API Route (`pages/api/request-access.ts`):**
  - POST endpoint that runs as Cloudflare Worker
  - Server-side validation and sanitization
  - Resend API integration for email delivery
  - Rate limiting (IP-based, 3 per 15 min)
  - Error handling with appropriate HTTP status codes
  - Security: XSS prevention, SQL injection protection (no DB, but good practice)

- **Form Fields:**
  - Name (required, text, max 100 chars)
  - Minecraft Username (required, text, max 16 chars)
  - Email (required, validated email format)
  - Age (optional, number, 1-120)
  - Relationship to existing player (optional, text, max 200 chars)
  - Why do you want to play? (optional, textarea, max 500 chars)

- **Email Delivery:**
  - Resend API integration
  - Formatted email template with all form data
  - Subject: "New BlockHaven Whitelist Request"
  - Includes timestamp and IP address
  - Sent to admin email from environment variable

- **Rate Limiting:**
  - Track submissions by IP address
  - 3 submissions per 15-minute window
  - Return 429 Too Many Requests if exceeded
  - Consider using Cloudflare KV for storage (or in-memory Map for simplicity)

### Out of Scope
- Email template customization beyond basic formatting
- Multi-step form wizard
- File uploads (screenshots, etc.)
- Admin dashboard to view submissions (Phase 2)
- Automated whitelist application (admin still processes manually)
- CAPTCHA or bot detection (rely on rate limiting)

## Technical Notes

**Resend API Setup:**
```typescript
// lib/resend.ts
import { Resend } from 'resend';

const resend = new Resend(import.meta.env.RESEND_API_KEY);

export async function sendWhitelistRequest(data: FormData) {
  await resend.emails.send({
    from: 'noreply@bhsmp.com',
    to: import.meta.env.ADMIN_EMAIL,
    subject: 'New BlockHaven Whitelist Request',
    text: formatEmailBody(data),
  });
}
```

**API Route Structure:**
```typescript
// pages/api/request-access.ts
export const prerender = false; // Enable SSR for this route

export async function POST({ request }: APIContext) {
  // 1. Parse request body
  // 2. Validate input
  // 3. Check rate limit
  // 4. Send email via Resend
  // 5. Return success/error response
}
```

**Rate Limiting Strategy:**
- Simple in-memory Map for MVP: `Map<string, number[]>`
  - Key: IP address
  - Value: Array of submission timestamps
  - On each request: filter timestamps older than 15 minutes, check length
- Production: Use Cloudflare KV for distributed rate limiting

**Validation:**
```typescript
const schema = z.object({
  name: z.string().min(1).max(100),
  minecraftUsername: z.string().min(1).max(16),
  email: z.string().email(),
  age: z.number().int().min(1).max(120).optional(),
  relationship: z.string().max(200).optional(),
  message: z.string().max(500).optional(),
});
```

**Email Format (from PRD):**
```
Subject: New BlockHaven Whitelist Request

Name: [Name]
Minecraft Username: [Username]
Email: [Email]
Age: [Age]
Connection: [Relationship to existing player]

Message:
[Why do you want to play?]

---
Submitted: [Timestamp]
IP: [IP Address] (for spam prevention)
```

## Dependencies

**Depends On:**
- Epic 1: Site Foundation & Infrastructure (Cloudflare adapter, Resend dependency)
- Epic 3: Core Pages & Components (Request page structure)

**Blocks:**
- Epic 5: Deployment & Production (needs working form to test in production)

## Risks & Mitigations

**Risk:** Resend API rate limits or deliverability issues
- **Likelihood:** Low
- **Impact:** High
- **Mitigation:** Test thoroughly; verify domain in Resend; have backup (Discord webhook)

**Risk:** Spam abuse despite rate limiting
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Start with conservative rate limit (3/15min); can add CAPTCHA later if needed

**Risk:** Cloudflare Workers environment differences from local dev
- **Likelihood:** Low
- **Impact:** Medium
- **Mitigation:** Test with Wrangler locally; deploy to staging environment first

**Risk:** CORS issues with API route
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Cloudflare adapter handles CORS; test from same origin

## Acceptance Criteria

### Form Component
- [ ] All form fields render correctly
- [ ] Required fields marked with asterisk (*)
- [ ] Client-side validation prevents invalid submissions
- [ ] Email field validates proper format
- [ ] Age field only accepts numbers 1-120
- [ ] Character limits enforced (name 100, username 16, relationship 200, message 500)
- [ ] Form is keyboard-accessible (tab navigation works)
- [ ] All inputs have proper ARIA labels
- [ ] Form works on mobile (touch-friendly, no layout issues)

### Form States
- [ ] **Loading State:**
  - Submit button shows spinner/loading text
  - Form inputs disabled during submission
  - "Submitting..." or similar indicator visible
- [ ] **Success State:**
  - Success message displays: "Request submitted! We'll review your application and email you."
  - Form clears after successful submission
  - Success message styled with green background
- [ ] **Error State:**
  - Error messages display for specific field errors
  - Generic error message for API failures
  - Error messages styled with red background
  - Form remains filled (don't clear on error)

### API Route
- [ ] Endpoint accessible at `/api/request-access`
- [ ] Accepts POST requests only (returns 405 for other methods)
- [ ] Parses JSON request body
- [ ] Server-side validation catches all invalid inputs
- [ ] Returns 400 Bad Request for validation errors with error details
- [ ] Returns 429 Too Many Requests if rate limit exceeded
- [ ] Returns 500 Internal Server Error for Resend failures
- [ ] Returns 200 OK on successful email send

### Rate Limiting
- [ ] Tracks submissions by IP address
- [ ] Allows 3 submissions in 15-minute window
- [ ] 4th submission within 15 minutes returns 429 error
- [ ] Counter resets after 15 minutes
- [ ] Rate limit message clear: "Too many requests. Please wait 15 minutes before trying again."

### Email Delivery
- [ ] Resend API sends email successfully
- [ ] Email contains all form fields
- [ ] Email includes timestamp (ISO 8601 format)
- [ ] Email includes submitter IP address
- [ ] Email subject is "New BlockHaven Whitelist Request"
- [ ] Email sent to address from `ADMIN_EMAIL` environment variable
- [ ] Email "from" address configured correctly in Resend

### Security
- [ ] All user input sanitized before email (prevent XSS in email body)
- [ ] IP address safely extracted from Cloudflare headers
- [ ] Environment variables not exposed to client
- [ ] No sensitive data logged to console in production
- [ ] HTTPS enforced (Cloudflare handles this)

### Validation Error Messages
- [ ] Name required: "Name is required"
- [ ] Username required: "Minecraft username is required"
- [ ] Email required: "Email is required"
- [ ] Email format: "Please enter a valid email address"
- [ ] Age range: "Age must be between 1 and 120"
- [ ] Character limits: "Message cannot exceed 500 characters"

### Testing
- [ ] Successful submission test (dev environment)
- [ ] Email received by admin (dev environment)
- [ ] Rate limiting test (3 submissions, 4th blocked)
- [ ] Form validation test (empty fields, invalid email)
- [ ] Mobile responsiveness test (iPhone, Android)
- [ ] Cloudflare Workers test (via Wrangler or staging)

## Related User Stories

From PRD:
- User Story 3: "As a prospective player, I want to request access to the server so I can join"
- User Story 4: "As the admin, I want to receive email notifications of play requests so I can process whitelist applications"

## Environment Variables Required

```bash
# .env or Cloudflare Pages environment
RESEND_API_KEY=re_xxxxxxxxxxxxx
ADMIN_EMAIL=your-email@example.com
```

## Resend Setup Steps

1. Create account at https://resend.com
2. Verify admin email or domain
3. Generate API key
4. Add API key to `.env` and Cloudflare Pages env vars
5. Test email delivery in dev

## Notes

- Resend free tier: 3,000 emails/month (plenty for whitelist requests)
- Rate limiting can be upgraded to Cloudflare KV for production if traffic grows
- Consider adding honeypot field for additional spam prevention (hidden field that bots fill)
- Form should work without JavaScript (progressive enhancement), but JS enhances UX

---

**Previous Epic:** Epic 3 - Core Pages & Components
**Next Epic:** Epic 5 - Deployment & Production
