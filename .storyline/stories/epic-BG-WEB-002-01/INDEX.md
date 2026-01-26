# Epic BG-WEB-002-01: GitHub OAuth Authentication - Story Index

**Epic:** GitHub OAuth Authentication
**Identifier:** BG-WEB-002
**Created:** January 25, 2026

---

## Stories

| ID | Title | Status | Priority |
|----|-------|--------|----------|
| 01 | Install Auth.js with Astro Adapter | ready_for_spec | P0 |
| 02 | Configure GitHub OAuth Provider | ready_for_spec | P0 |
| 03 | Implement Session Storage with Cloudflare KV | ready_for_spec | P0 |
| 04 | Create Login Page | ready_for_spec | P0 |
| 05 | Create Protected Dashboard Route | ready_for_spec | P0 |
| 06 | Implement Auth Middleware | ready_for_spec | P0 |
| 07 | Add Logout Functionality | ready_for_spec | P0 |

---

## Story Dependency Graph

```
Story 01 (Auth.js Install)
    ↓
Story 02 (GitHub Provider)
    ↓
Story 03 (KV Sessions)
    ↓
Story 06 (Auth Middleware)
    ↓
Story 04 (Login Page) ──┬── Story 05 (Dashboard)
                        └── Story 07 (Logout)
```

---

## Next Steps

To create specs for these stories:
```bash
/sl-spec-story .storyline/stories/epic-BG-WEB-002-01/story-01.md
```
