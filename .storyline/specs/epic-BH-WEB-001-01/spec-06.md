---
spec_id: 06
story_ids: [06]
epic_id: BH-WEB-001-01
identifier: BH-WEB-001
title: Create Placeholder Routes for Dashboard and API
status: ready_for_implementation
complexity: simple
parent_story: ../../stories/epic-BH-WEB-001-01/story-06.md
created: 2026-01-22
---

# Technical Spec 06: Create Placeholder Routes for Dashboard and API

## Overview

**User story:** [Story 06: Create Placeholder Routes for Dashboard and API](../../stories/epic-BH-WEB-001-01/story-06.md)

**Goal:** Create minimal placeholder routes for the admin dashboard (`/dashboard`) and API endpoint (`/api/request-access`) to validate hybrid rendering architecture and provide scaffolding for future Phase 2 (admin dashboard) and Epic 4 (form submission) work.

**Approach:** Create two placeholder files: (1) an SSR-enabled dashboard page using `export const prerender = false`, and (2) a TypeScript API route that handles POST requests and returns a JSON placeholder response. Both files include clear comments explaining they're placeholders and documenting future implementation plans.

## Technical Design

### Architecture Decision

**Chosen approach:** Minimal placeholder files with inline documentation

**Why this approach:**
- **Validates hybrid rendering:** Dashboard with `prerender = false` confirms SSR works
- **Validates API routes:** TypeScript API route confirms Cloudflare Workers integration works
- **Future-ready scaffolding:** Provides clear entry points for Phase 2 and Epic 4
- **Self-documenting:** Inline comments explain purpose and future implementation

**Alternatives considered:**
- **Full-featured "Coming Soon" page with styling** - Unnecessary complexity; wastes time on throwaway UI
- **Skip placeholders entirely** - Risky; wouldn't validate architecture before building real features

**Rationale:** Minimal placeholders provide maximum validation with minimum effort, while inline docs ensure future developers understand intent.

### System Components

**Frontend (Dashboard):**
- Single SSR-enabled Astro page at `/dashboard`
- Uses Tailwind CSS classes (validates Tailwind setup)
- Minimal HTML with "Coming Soon" message
- Link back to homepage

**Backend (API Route):**
- TypeScript API route at `/api/request-access`
- Handles POST requests (validates API route handler)
- Returns JSON response with placeholder message
- Runs on Cloudflare Workers (validates adapter integration)

**Routing:**
- Dashboard: File-based routing (`src/pages/dashboard.astro` → `/dashboard`)
- API: File-based API routing (`src/pages/api/request-access.ts` → `/api/request-access`)

## Implementation Details

### Files to Create

#### 1. Dashboard Placeholder Page

**`web/src/pages/dashboard.astro`**
- **Purpose:** SSR-enabled placeholder page for future admin dashboard
- **Key features:**
  - `export const prerender = false` - Opt into SSR (validate hybrid rendering)
  - Uses Tailwind classes (validate Tailwind integration)
  - "Coming Soon" message with Phase 2 context
  - Link back to homepage
- **Exports:** None (page component)

**Full implementation:**
```astro
---
// src/pages/dashboard.astro
// Phase 2: Admin Dashboard with GitHub OAuth + AWS SDK integration
//
// This is a placeholder page to validate SSR (server-side rendering) works
// with the Cloudflare adapter. In Phase 2, this will become the admin dashboard
// with GitHub OAuth authentication and AWS EC2 management features.

export const prerender = false; // Enable SSR for this route (not pre-rendered at build time)
---

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Dashboard - Coming Soon | BlockHaven</title>
</head>
<body class="bg-background-dark text-text-light min-h-screen flex items-center justify-center p-8">
  <div class="max-w-2xl text-center">
    <h1 class="text-5xl font-bold text-primary-grass mb-6">
      Admin Dashboard
    </h1>
    <p class="text-xl text-text-light mb-4">
      Coming in Phase 2
    </p>
    <div class="bg-secondary-darkGray p-6 rounded-lg mb-8">
      <p class="text-text-light mb-4">
        Future features:
      </p>
      <ul class="text-left space-y-2 text-text-light">
        <li>• GitHub OAuth authentication</li>
        <li>• AWS SDK integration for EC2 server management</li>
        <li>• Server start/stop controls</li>
        <li>• Player whitelist management</li>
        <li>• Server status monitoring</li>
      </ul>
    </div>
    <a
      href="/"
      class="inline-block text-accent-diamond hover:text-accent-gold transition-colors"
    >
      ← Back to Home
    </a>
  </div>
</body>
</html>
```

#### 2. API Route Placeholder

**`web/src/pages/api/request-access.ts`**
- **Purpose:** Placeholder API endpoint for form submission (Epic 4)
- **HTTP Method:** POST
- **Key features:**
  - TypeScript API route handler
  - Returns JSON response
  - Includes TODO comments for Epic 4 implementation
  - Validates Cloudflare Workers integration
- **Exports:** `POST` (named export, type: `APIRoute`)

**Full implementation:**
```typescript
// src/pages/api/request-access.ts
// Epic 4: Request Access Form - Email submission via Resend
//
// This is a placeholder API endpoint to validate that API routes work correctly
// with the Cloudflare adapter and hybrid rendering. In Epic 4, this will be
// implemented to handle form submissions from the /request-access page and send
// emails via the Resend API.

import type { APIRoute } from 'astro';

/**
 * Handle POST requests to /api/request-access
 *
 * Future implementation (Epic 4):
 * - Parse JSON body with { minecraft_username, email, reason }
 * - Validate input (required fields, email format, username format)
 * - Send email to admin via Resend API
 * - Return success/error response
 *
 * @param request - Incoming HTTP request
 * @returns JSON response with success/error message
 */
export const POST: APIRoute = async ({ request }) => {
  // TODO: Implement in Epic 4 (Request Form & API Integration)
  //
  // Steps:
  // 1. Parse request body: const data = await request.json()
  // 2. Validate required fields: minecraft_username, email, reason
  // 3. Validate email format with regex
  // 4. Validate Minecraft username (3-16 chars, alphanumeric + underscore)
  // 5. Send email via Resend:
  //    - To: import.meta.env.ADMIN_EMAIL
  //    - From: noreply@bhsmp.com
  //    - Subject: "New Access Request from {username}"
  //    - Body: Include username, email, reason
  // 6. Return { success: true, message: "Request submitted" } on success
  // 7. Return { success: false, error: "..." } on failure

  console.log('API route placeholder - POST /api/request-access called');

  return new Response(
    JSON.stringify({
      message: "API endpoint placeholder - Implement in Epic 4",
      status: "not_implemented"
    }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json'
      }
    }
  );
};
```

### Files to Modify

**None** - This spec only creates new files, no existing files are modified.

### API Contract

#### Endpoint: POST /api/request-access

**Current Behavior (Placeholder):**

**Request:**
```
POST /api/request-access
Content-Type: application/json

(any body - ignored in placeholder)
```

**Response (Success - 200):**
```json
{
  "message": "API endpoint placeholder - Implement in Epic 4",
  "status": "not_implemented"
}
```

**Future Implementation (Epic 4):**

**Request:**
```json
{
  "minecraft_username": "string (3-16 chars, alphanumeric + underscore)",
  "email": "string (valid email)",
  "reason": "string (1-500 chars)"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Request submitted successfully"
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
  "error": "Failed to send email"
}
```

## Acceptance Criteria Mapping

### Story Criterion 1: Placeholder dashboard page created

**Acceptance criteria:**
- File `src/pages/dashboard.astro` exists
- Displays "Coming Soon" or "Admin Dashboard (Phase 2)" message
- Configured for SSR: `export const prerender = false`
- Navigating to `/dashboard` shows the placeholder page

**Verification:**
1. Check file exists: `ls web/src/pages/dashboard.astro`
2. Check file contains `export const prerender = false` in frontmatter
3. Run `npm run dev` and navigate to `http://localhost:4321/dashboard`
4. Verify page loads with "Admin Dashboard" heading and "Coming Soon" text
5. Verify Tailwind classes are applied (check background color, text color)

### Story Criterion 2: Dashboard page uses SSR

**Acceptance criteria:**
- Includes `export const prerender = false` (opt into SSR)
- Page is NOT pre-rendered at build time (stays dynamic)
- Verifies Cloudflare adapter's hybrid rendering works

**Verification:**
1. Run `npm run build`
2. Check build output - dashboard route should be marked as SSR (not static)
3. Inspect `dist/` folder - `dashboard.html` should NOT exist (confirms SSR)
4. Check for `_worker.js` in `dist/` (Cloudflare Workers bundle includes dashboard)
5. Run `npm run preview` and test `/dashboard` still works

### Story Criterion 3: API route structure created

**Acceptance criteria:**
- File `src/pages/api/request-access.ts` exists
- Exports an API route handler (POST method)
- Returns a JSON response with placeholder message
- Navigating to `/api/request-access` (POST) returns the placeholder response

**Verification:**
1. Check file exists: `ls web/src/pages/api/request-access.ts`
2. Check file exports `POST: APIRoute`
3. Check file returns JSON with `message` field
4. Run dev server: `npm run dev`
5. Test endpoint with curl:
   ```bash
   curl -X POST http://localhost:4321/api/request-access
   ```
6. Verify JSON response: `{"message":"API endpoint placeholder - Implement in Epic 4","status":"not_implemented"}`

### Story Criterion 4: API route works with hybrid rendering

**Acceptance criteria:**
- Endpoint responds correctly
- Runs on Cloudflare Workers runtime (not static)
- Verifies API routes work with the Cloudflare adapter

**Verification:**
1. Run `npm run build`
2. Check build output - API route should be bundled into Workers
3. Run `npm run preview` (simulates production)
4. Test endpoint with curl:
   ```bash
   curl -X POST http://localhost:4321/api/request-access
   ```
5. Verify JSON response is returned
6. Check browser Network tab - response served by Cloudflare Workers (not static file)

### Story Criterion 5: Routes are documented

**Acceptance criteria:**
- Clear comments in files explaining:
  - `/dashboard` is for Phase 2 (Admin Dashboard)
  - `/api/request-access` will be implemented in Epic 4
- Future developers understand these are placeholders

**Verification:**
1. Read `src/pages/dashboard.astro` - check for inline comments about Phase 2
2. Read `src/pages/api/request-access.ts` - check for TODO comments about Epic 4
3. Verify comments explain future implementation details

## Testing Requirements

### Manual Testing Checklist

**After implementation:**

- [ ] Run `npm run dev` - dev server starts without errors
- [ ] Navigate to `/dashboard` - page loads with "Admin Dashboard" heading
- [ ] Verify Tailwind styles applied - dark background, green heading, diamond-colored link
- [ ] Click "Back to Home" link - navigates to `/` (when homepage exists)
- [ ] Test API route with curl:
  ```bash
  curl -X POST http://localhost:4321/api/request-access
  ```
- [ ] Verify JSON response:
  ```json
  {"message":"API endpoint placeholder - Implement in Epic 4","status":"not_implemented"}
  ```
- [ ] Run `npm run build` - builds successfully
- [ ] Check build output - dashboard marked as SSR, API route bundled
- [ ] Run `npm run preview` - production build serves correctly
- [ ] Test `/dashboard` in preview - still works (SSR)
- [ ] Test `/api/request-access` in preview - still works (Workers)

### Build Verification

**Build command:**
```bash
cd web && npm run build
```

**Expected output:**
```
✓ Generating static routes
✓ Complete!

Route                         File
/dashboard                    (SSR)
/api/request-access           (SSR)
```

**Verify SSR behavior:**
```bash
ls web/dist/ | grep dashboard
# Should return nothing (not pre-rendered)

ls web/dist/_worker.js
# Should exist (Cloudflare Workers bundle includes SSR routes)
```

### Integration Testing

**Test dashboard route:**
```bash
# Start dev server
npm run dev

# In another terminal:
curl http://localhost:4321/dashboard
```

**Expected:** HTML response with "Admin Dashboard" content

**Test API route:**
```bash
# POST request
curl -X POST http://localhost:4321/api/request-access \
  -H "Content-Type: application/json"
```

**Expected:** JSON response `{"message":"API endpoint placeholder - Implement in Epic 4","status":"not_implemented"}`

**Test other HTTP methods (should fail):**
```bash
# GET request (not implemented)
curl http://localhost:4321/api/request-access
```

**Expected:** 404 or 405 error (only POST is defined)

## Dependencies

**Must complete first:**
- Spec stories-01-05-combined: Project initialization, Tailwind, directory structure
- Dashboard page uses Tailwind classes (requires Tailwind configured)
- API route uses Astro types (requires Astro + TypeScript installed)

**Enables:**
- Epic 4: Request Form & API Integration (will replace API route placeholder)
- Phase 2: Admin Dashboard (will replace dashboard placeholder)

## Risks & Mitigations

**Risk 1: SSR not working in Cloudflare adapter**
- **Likelihood:** Low (adapter is mature)
- **Impact:** High (breaks Phase 2 architecture)
- **Mitigation:** Test `/dashboard` in both dev and build modes; check build output confirms SSR
- **Fallback:** Temporarily switch to `output: 'server'` (all SSR) to debug adapter issue

**Risk 2: API route not handling POST requests**
- **Likelihood:** Low
- **Impact:** Medium (Epic 4 implementation may have issues)
- **Mitigation:** Test with curl immediately after creation; verify JSON response
- **Fallback:** Check Astro docs for API route examples; ensure correct export syntax

**Risk 3: Tailwind classes not applying in dashboard**
- **Likelihood:** Low (Tailwind configured in previous spec)
- **Impact:** Low (visual only, doesn't affect functionality)
- **Mitigation:** Import `global.css` if styles don't apply automatically
- **Fallback:** Use inline styles temporarily; debug Tailwind setup

## Performance Considerations

**SSR overhead:**
- Dashboard page served dynamically (not cached)
- Minimal impact: page is simple HTML, no database queries
- Cloudflare Workers are fast (<10ms response time)

**API route latency:**
- Placeholder returns static JSON (no external calls)
- Expected response time: <5ms
- Epic 4 implementation will add Resend API call (~100-300ms)

**Build time:**
- Adding 2 routes has negligible impact on build time
- No additional static pages to pre-render

## Security Considerations

**Dashboard page:**
- No authentication yet (Phase 2)
- No sensitive data displayed
- SSR-enabled but publicly accessible (intentional for now)

**API route:**
- Currently returns placeholder response (no security risk)
- Epic 4 will add:
  - Input validation (prevent injection attacks)
  - Rate limiting (prevent spam)
  - CORS headers (if needed)
  - Environment variable usage (API keys not hardcoded)

**Cloudflare Workers:**
- Isolated runtime environment (secure by design)
- No access to server filesystem
- Environment variables encrypted at rest

## Success Verification

After implementation, verify all criteria:

**Dashboard Page:**
- [ ] File exists at `src/pages/dashboard.astro`
- [ ] Contains `export const prerender = false` in frontmatter
- [ ] Displays "Admin Dashboard" heading with Tailwind styling
- [ ] Shows "Coming in Phase 2" text with future features list
- [ ] Has link back to homepage
- [ ] Accessible at `http://localhost:4321/dashboard`
- [ ] NOT pre-rendered (check build output)

**API Route:**
- [ ] File exists at `src/pages/api/request-access.ts`
- [ ] Exports `POST: APIRoute` handler
- [ ] Returns JSON with `message` and `status` fields
- [ ] Responds to POST requests at `/api/request-access`
- [ ] Returns 200 status code
- [ ] Returns `Content-Type: application/json` header
- [ ] Runs in Cloudflare Workers (check build bundle)

**Documentation:**
- [ ] Dashboard file has comments about Phase 2
- [ ] API route has TODO comments about Epic 4 implementation
- [ ] Both files explain future purpose clearly

**Hybrid Rendering:**
- [ ] Build output confirms dashboard is SSR (not static)
- [ ] Build output confirms API route is bundled into Workers
- [ ] `dist/_worker.js` exists and includes both routes
- [ ] No `dist/dashboard.html` file (not pre-rendered)

## Traceability

**Parent story:** [Story 06: Create Placeholder Routes](../../stories/epic-BH-WEB-001-01/story-06.md)

**Parent epic:** [Epic BH-WEB-001-01: Site Foundation & Infrastructure](../../epics/epic-BH-WEB-001-01-site-foundation.md)

**Full chain:**
```
web/.docs/ASTRO-SITE-PRD.md
└─ epic-BH-WEB-001-01-site-foundation.md
   └─ stories/epic-BH-WEB-001-01/story-06.md
      └─ specs/epic-BH-WEB-001-01/spec-06.md (this file)
         └─ [Implementation via /sl-develop]
```

## Implementation Notes

**Recommended execution order:**

1. **Create dashboard placeholder:**
   ```bash
   # In /web/src/pages/
   touch dashboard.astro
   ```
   - Copy code from spec above
   - Verify `export const prerender = false` is present
   - Save file

2. **Create API directory (if not exists):**
   ```bash
   mkdir -p web/src/pages/api
   ```

3. **Create API route placeholder:**
   ```bash
   # In /web/src/pages/api/
   touch request-access.ts
   ```
   - Copy code from spec above
   - Verify `export const POST: APIRoute` is present
   - Save file

4. **Test dashboard:**
   ```bash
   npm run dev
   # Open http://localhost:4321/dashboard in browser
   ```

5. **Test API route:**
   ```bash
   # In another terminal:
   curl -X POST http://localhost:4321/api/request-access
   ```

6. **Test production build:**
   ```bash
   npm run build
   npm run preview
   # Test both routes in preview mode
   ```

**Open questions:**
- Should we add a `/api` directory README explaining API route structure? (Optional, can add later)
- Should dashboard have more detailed Phase 2 feature list? (Current list is sufficient)

**Assumptions:**
- Spec stories-01-05-combined is completed (Astro + Tailwind + directories configured)
- Dev server runs on default port 4321
- Tailwind classes auto-apply without additional imports (handled by Astro integration)
- `/` homepage doesn't exist yet (dashboard's "Back to Home" link will work when Epic 3 creates it)

**Notes for implementation:**
- Dashboard uses Tailwind classes: verify they apply (may need to import global.css in layout later)
- API route uses `import type` for `APIRoute` - TypeScript-only import (no runtime overhead)
- Both files have extensive comments - don't remove them; they document future work
- `export const prerender = false` MUST be in frontmatter, not in `<script>` tag
- API route only defines `POST` - other methods (GET, PUT, DELETE) will return 405 Method Not Allowed

---

**Next step:** Implement this spec with `/sl-develop .storyline/specs/epic-BH-WEB-001-01/spec-06.md`
