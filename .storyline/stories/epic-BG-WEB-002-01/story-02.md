---
story_id: 02
epic_id: BG-WEB-002-01
identifier: BG-WEB-002
title: Configure GitHub OAuth Provider
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-01-authentication.md
created: 2026-01-25
---

# Story 02: Configure GitHub OAuth Provider

## User Story

**As a** developer,
**I want** to configure the GitHub OAuth provider with multi-user authorization,
**so that** only authorized GitHub users can access the admin dashboard.

## Acceptance Criteria

### Scenario 1: GitHub provider configured
**Given** Auth.js is installed
**When** I configure the GitHub provider
**Then** `src/lib/auth.ts` includes GitHub provider configuration
**And** it reads `GITHUB_CLIENT_ID` from environment
**And** it reads `GITHUB_CLIENT_SECRET` from environment

### Scenario 2: Multi-user authorization implemented
**Given** the GitHub provider is configured
**When** a user attempts to sign in
**Then** the `signIn` callback checks their GitHub username
**And** the username is compared against `ADMIN_GITHUB_USERNAMES` env var
**And** comparison is case-insensitive

### Scenario 3: Authorized user list parsing
**Given** `ADMIN_GITHUB_USERNAMES=user1,user2, user3`
**When** the authorized users are parsed
**Then** whitespace is trimmed from each username
**And** empty values are filtered out
**And** all usernames are lowercased for comparison

### Scenario 4: Unauthorized user rejected
**Given** a user with GitHub username "unauthorized_user"
**And** that username is NOT in `ADMIN_GITHUB_USERNAMES`
**When** they attempt to sign in
**Then** the sign-in is rejected
**And** they cannot access protected routes

### Scenario 5: Environment variables documented
**Given** the GitHub provider is configured
**When** I check `.env.example`
**Then** it includes `GITHUB_CLIENT_ID`
**And** it includes `GITHUB_CLIENT_SECRET`
**And** it includes `ADMIN_GITHUB_USERNAMES` with example format

## Business Value

**Why this matters:** GitHub OAuth provides secure, passwordless authentication leveraging users' existing GitHub accounts. The multi-user authorization allows family members or trusted admins to access the dashboard.

**Impact:** Secure authentication without managing passwords, easy to add/remove authorized users.

**Success metric:** Only users in `ADMIN_GITHUB_USERNAMES` can complete the OAuth flow.

## Technical Considerations

**Implementation:**
```typescript
// src/lib/auth.ts
import GitHub from "@auth/core/providers/github"

const getAuthorizedUsers = (): string[] => {
  const usernames = import.meta.env.ADMIN_GITHUB_USERNAMES || ""
  return usernames.split(",").map(u => u.trim().toLowerCase()).filter(Boolean)
}

// In Auth config:
callbacks: {
  async signIn({ profile }) {
    const authorizedUsers = getAuthorizedUsers()
    const githubUsername = profile?.login?.toLowerCase()
    return githubUsername ? authorizedUsers.includes(githubUsername) : false
  },
}
```

**GitHub OAuth App Setup:**
1. Go to github.com/settings/developers
2. Create new OAuth App
3. Homepage URL: `https://bhsmp.com`
4. Callback URL: `https://bhsmp.com/api/auth/callback/github`

**Constraints:**
- GitHub username is case-insensitive
- Callback URL must match exactly
- Client secret must never be exposed to client

## Dependencies

**Depends on stories:** Story 01 (Auth.js Install)

**Enables stories:**
- Story 03: Session Storage
- Story 04: Login Page

## Out of Scope

- Session storage implementation (Story 03)
- Login page UI (Story 04)
- Role-based permissions (not planned)

## Notes

- GitHub OAuth app must be created manually in GitHub Developer Settings
- For local development, create a separate OAuth app with `localhost` callback
- The `signIn` callback runs server-side, so env vars are accessible

## Traceability

**Parent epic:** [epic-BG-WEB-002-01-authentication.md](../../epics/epic-BG-WEB-002-01-authentication.md)

**Related stories:** Story 01 (Auth.js), Story 03 (Sessions)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-01/story-02.md`
