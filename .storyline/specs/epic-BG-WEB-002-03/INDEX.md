# Epic BG-WEB-002-03: Cost Estimation - Technical Specs Index

## Overview

This epic implements AWS cost estimation based on server uptime.

**Total Stories:** 2
**Total Specs:** 1 (stories combined)

## Specs

| Spec | Stories | Title | Complexity | Status |
|------|---------|-------|------------|--------|
| [spec-01-02](spec-01-02-cost-estimation.md) | 01, 02 | Cost Estimation Logic and Dashboard Component | Simple | Ready |

## Key Files Created

| File | Purpose |
|------|---------|
| `src/lib/costs.ts` | Pricing constants and calculation functions |
| `src/components/admin/CostEstimator.tsx` | Cost display component |

## Pricing Reference

| Resource | Cost | Notes |
|----------|------|-------|
| EC2 t3a.large | $0.0752/hour | On-demand, us-east-2 |
| EBS gp3 50GB | $4.00/month | Fixed storage cost |
| Data Transfer | ~$0.90/month | Estimate |

## To Execute

```bash
/sl-develop .storyline/specs/epic-BG-WEB-002-03/spec-01-02-cost-estimation.md
```
