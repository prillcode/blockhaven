# Epic BG-WEB-002-04: Logs Viewer - Technical Specs Index

## Overview

This epic implements CloudWatch Logs integration for viewing Minecraft server logs.

**Total Stories:** 3
**Total Specs:** 1 (stories combined)

## Specs

| Spec | Stories | Title | Complexity | Status |
|------|---------|-------|------------|--------|
| [spec-01-02-03](spec-01-02-03-logs-viewer.md) | 01, 02, 03 | CloudWatch Logs Integration with API and Viewer Component | Medium | Ready |

## Key Files Created

| File | Purpose |
|------|---------|
| `src/lib/aws/logs.ts` | CloudWatch Logs client and helper |
| `src/pages/api/admin/logs.ts` | Logs API endpoint |
| `src/components/admin/LogsViewer.tsx` | Terminal-style viewer |

## Prerequisites

- CloudWatch agent installed on EC2 instance
- Agent configured to send Docker logs to CloudWatch
- Log group `blockhaven-minecraft` exists
- IAM policy includes `logs:GetLogEvents`, `logs:DescribeLogStreams`

## Environment Variables

```bash
CLOUDWATCH_LOG_GROUP=blockhaven-minecraft
```

## To Execute

```bash
npm install @aws-sdk/client-cloudwatch-logs
/sl-develop .storyline/specs/epic-BG-WEB-002-04/spec-01-02-03-logs-viewer.md
```
