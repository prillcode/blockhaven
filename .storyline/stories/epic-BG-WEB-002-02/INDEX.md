# Epic BG-WEB-002-02: Server Status & Controls - Story Index

**Epic:** Server Status & Controls
**Identifier:** BG-WEB-002
**Created:** January 25, 2026

---

## Stories

| ID | Title | Status | Priority |
|----|-------|--------|----------|
| 01 | Setup AWS SDK for EC2 | ready_for_spec | P0 |
| 02 | Create Server Status API | ready_for_spec | P0 |
| 03 | Integrate mcstatus.io for Minecraft Status | ready_for_spec | P0 |
| 04 | Create Start Server API | ready_for_spec | P0 |
| 05 | Create Stop Server API | ready_for_spec | P0 |
| 06 | Build ServerStatusCard Component | ready_for_spec | P0 |
| 07 | Build ServerControls Component | ready_for_spec | P0 |
| 08 | Implement Auto-Refresh | ready_for_spec | P0 |

---

## Story Dependency Graph

```
Story 01 (AWS SDK)
    ↓
Story 02 (Status API) ←── Story 03 (mcstatus.io)
    ↓
Story 04 (Start API) ──┬── Story 05 (Stop API)
    ↓                  ↓
Story 06 (StatusCard) ←┴── Story 07 (Controls)
                            ↓
                       Story 08 (Auto-Refresh)
```

---

## Next Steps

To create specs for these stories:
```bash
/sl-spec-story .storyline/stories/epic-BG-WEB-002-02/story-01.md
```
