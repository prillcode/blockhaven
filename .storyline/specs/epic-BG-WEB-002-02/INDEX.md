# Epic BG-WEB-002-02: Server Controls - Technical Specs Index

## Overview

This epic implements EC2 server management with real-time status display and start/stop controls.

**Total Stories:** 8
**Total Specs:** 4 (stories combined logically)

## Specs

| Spec | Stories | Title | Complexity | Status |
|------|---------|-------|------------|--------|
| [spec-01](spec-01-aws-sdk-setup.md) | 01 | Setup AWS SDK for EC2 Operations | Simple | Ready |
| [spec-02-03](spec-02-03-status-api.md) | 02, 03 | Server Status API with EC2 and Minecraft Status | Medium | Ready |
| [spec-04-05](spec-04-05-start-stop-apis.md) | 04, 05 | Start and Stop Server API Endpoints | Simple | Ready |
| [spec-06-07-08](spec-06-07-08-dashboard-components.md) | 06, 07, 08 | Dashboard Components - Status Card, Controls, Auto-Refresh | Medium | Ready |

## Implementation Order

1. **spec-01** - AWS SDK setup (foundation)
2. **spec-02-03** - Status API (needed for components)
3. **spec-04-05** - Start/Stop APIs (needed for controls)
4. **spec-06-07-08** - Dashboard components (consumes APIs)

## Dependencies

```
spec-01 (AWS SDK)
    │
    ├──► spec-02-03 (Status API)
    │         │
    │         └──► spec-06-07-08 (Components)
    │                    ▲
    └──► spec-04-05 (Start/Stop) ───┘
```

## Key Files Created

| File | Purpose |
|------|---------|
| `src/lib/aws/ec2.ts` | EC2 client configuration |
| `src/lib/minecraft.ts` | mcstatus.io integration |
| `src/pages/api/admin/server/status.ts` | Status endpoint |
| `src/pages/api/admin/server/start.ts` | Start endpoint |
| `src/pages/api/admin/server/stop.ts` | Stop endpoint |
| `src/hooks/useServerStatus.ts` | Status polling hook |
| `src/components/admin/ServerStatusCard.tsx` | Status display |
| `src/components/admin/ServerControls.tsx` | Start/stop buttons |
| `src/components/admin/DashboardContent.tsx` | Main dashboard |

## Environment Variables Required

```bash
AWS_ACCESS_KEY_ID=     # IAM user access key
AWS_SECRET_ACCESS_KEY= # IAM user secret key
AWS_REGION=us-east-2   # AWS region
EC2_INSTANCE_ID=       # Target EC2 instance ID
MC_SERVER_IP=          # Minecraft server address for mcstatus.io
```

## To Execute All Specs

```bash
# In order:
/sl-develop .storyline/specs/epic-BG-WEB-002-02/spec-01-aws-sdk-setup.md
/sl-develop .storyline/specs/epic-BG-WEB-002-02/spec-02-03-status-api.md
/sl-develop .storyline/specs/epic-BG-WEB-002-02/spec-04-05-start-stop-apis.md
/sl-develop .storyline/specs/epic-BG-WEB-002-02/spec-06-07-08-dashboard-components.md
```
