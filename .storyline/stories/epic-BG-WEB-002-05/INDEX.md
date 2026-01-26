# Epic BG-WEB-002-05: Quick Actions Panel (RCON) - Story Index

**Epic:** Quick Actions Panel (RCON)
**Identifier:** BG-WEB-002
**Priority:** P2 (Could Have)
**Created:** January 25, 2026

---

## Stories

| ID | Title | Status | Priority |
|----|-------|--------|----------|
| 01 | Setup AWS SSM Integration | ready_for_spec | P2 |
| 02 | Create RCON API Endpoint | ready_for_spec | P2 |
| 03 | Build QuickActions Component | ready_for_spec | P2 |

---

## Story Dependency Graph

```
Story 01 (SSM Setup)
    ↓
Story 02 (RCON API)
    ↓
Story 03 (QuickActions Component)
```

---

## Note

This is a P2 (Could Have) epic. Implement if time permits after P0 and P1 features are complete. The feature requires AWS SSM agent to be installed on the EC2 instance.

---

## Next Steps

To create specs for these stories:
```bash
/sl-spec-story .storyline/stories/epic-BG-WEB-002-05/story-01.md
```
