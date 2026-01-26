---
spec_id: 01-02
story_ids: [01, 02]
epic_id: BG-WEB-002-03
identifier: BG-WEB-002
title: Cost Estimation Logic and Dashboard Component
status: ready_for_implementation
complexity: simple
parent_stories:
  - ../../stories/epic-BG-WEB-002-03/story-01.md
  - ../../stories/epic-BG-WEB-002-03/story-02.md
created: 2026-01-25
---

# Technical Spec 01-02: Cost Estimation Logic and Dashboard Component

## Overview

**User stories:**
- [Story 01: Implement Cost Calculation Logic](../../stories/epic-BG-WEB-002-03/story-01.md)
- [Story 02: Build CostEstimator Component](../../stories/epic-BG-WEB-002-03/story-02.md)

**Goal:** Create cost calculation utilities with AWS pricing constants and build a dashboard component that displays estimated monthly costs based on server uptime.

**Approach:** Create a `costs.ts` module with pricing constants and calculation functions, then build a React component that receives uptime from server status and displays month-to-date and projected costs.

## Technical Design

### Cost Calculation Model

```
Month-to-Date Cost:
  EC2 Cost = uptimeHours × $0.0752/hour
  EBS Cost = (daysElapsed / daysInMonth) × $4.00
  Total MTD = EC2 + EBS

Projected Monthly Cost:
  Avg Hours/Day = uptimeHours / daysElapsed
  Projected Hours = avgHoursPerDay × daysInMonth
  Projected EC2 = projectedHours × $0.0752
  Projected Total = EC2 + EBS ($4.00) + Data Transfer (~$0.90)
```

### Pricing Constants

| Resource | Pricing | Notes |
|----------|---------|-------|
| EC2 t3a.large | $0.0752/hour | On-demand pricing, us-east-2 |
| EBS gp3 50GB | $4.00/month | 50 × $0.08/GB-month |
| Data Transfer | ~$0.90/month | Estimate: 10GB × $0.09/GB |

## Implementation Details

### Files to Create

#### 1. Cost Calculation Module

**`web/src/lib/costs.ts`**

```typescript
// src/lib/costs.ts
// Cost calculation utilities for AWS resource estimation
//
// Pricing based on us-east-2 region, on-demand pricing.
// These are estimates - actual billing may vary.

/**
 * AWS pricing constants (us-east-2, on-demand)
 */
export const PRICING = {
  ec2: {
    instanceType: "t3a.large",
    hourlyRate: 0.0752,  // $/hour
  },
  ebs: {
    volumeType: "gp3",
    sizeGB: 50,
    ratePerGB: 0.08,     // $/GB-month
    monthlyBase: 4.0,    // 50 × 0.08
  },
  dataTransfer: {
    estimatedMonthlyGB: 10,
    ratePerGB: 0.09,     // $/GB (outbound)
    estimatedMonthly: 0.9,
  },
} as const;

/**
 * Cost estimate breakdown
 */
export interface CostEstimate {
  mtd: {
    hours: number;
    ec2Cost: number;
    ebsCost: number;
    total: number;
  };
  projected: {
    hours: number;
    ec2Cost: number;
    ebsCost: number;
    dataTransferCost: number;
    total: number;
  };
  daysElapsed: number;
  daysInMonth: number;
}

/**
 * Calculate cost estimates based on uptime.
 *
 * @param uptimeHours - Total hours the server has run this month
 * @param daysElapsed - Days elapsed in current month (1-31)
 * @param daysInMonth - Total days in current month (28-31)
 * @returns Cost estimate breakdown
 */
export function calculateCosts(
  uptimeHours: number,
  daysElapsed: number,
  daysInMonth: number
): CostEstimate {
  // Ensure valid inputs
  const validDaysElapsed = Math.max(1, Math.min(daysElapsed, daysInMonth));
  const validDaysInMonth = Math.max(28, Math.min(daysInMonth, 31));
  const validUptimeHours = Math.max(0, uptimeHours);

  // Month-to-date calculations
  const mtdEc2Cost = validUptimeHours * PRICING.ec2.hourlyRate;
  const mtdEbsCost = (validDaysElapsed / validDaysInMonth) * PRICING.ebs.monthlyBase;
  const mtdTotal = mtdEc2Cost + mtdEbsCost;

  // Projection calculations
  const avgHoursPerDay = validUptimeHours / validDaysElapsed;
  const projectedHours = avgHoursPerDay * validDaysInMonth;
  const projectedEc2Cost = projectedHours * PRICING.ec2.hourlyRate;
  const projectedTotal =
    projectedEc2Cost + PRICING.ebs.monthlyBase + PRICING.dataTransfer.estimatedMonthly;

  return {
    mtd: {
      hours: round(validUptimeHours),
      ec2Cost: round(mtdEc2Cost),
      ebsCost: round(mtdEbsCost),
      total: round(mtdTotal),
    },
    projected: {
      hours: round(projectedHours),
      ec2Cost: round(projectedEc2Cost),
      ebsCost: PRICING.ebs.monthlyBase,
      dataTransferCost: PRICING.dataTransfer.estimatedMonthly,
      total: round(projectedTotal),
    },
    daysElapsed: validDaysElapsed,
    daysInMonth: validDaysInMonth,
  };
}

/**
 * Get current month info (days elapsed, days in month)
 */
export function getCurrentMonthInfo(): { daysElapsed: number; daysInMonth: number } {
  const now = new Date();
  const daysElapsed = now.getDate();
  const daysInMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
  return { daysElapsed, daysInMonth };
}

/**
 * Estimate uptime hours from current uptime and average pattern.
 * This is a rough estimate - assumes consistent daily usage.
 *
 * @param currentUptimeSeconds - Current session uptime in seconds
 * @param daysElapsed - Days elapsed in month
 * @returns Estimated total uptime hours for the month
 */
export function estimateMonthlyUptimeHours(
  currentUptimeSeconds: number | null,
  daysElapsed: number
): number {
  if (!currentUptimeSeconds) return 0;

  // Assume current session represents average daily usage
  const currentUptimeHours = currentUptimeSeconds / 3600;

  // If server just started today, extrapolate from current session
  // Otherwise, assume this represents a typical day
  const estimatedHoursPerDay = Math.min(currentUptimeHours, 24);
  return estimatedHoursPerDay * daysElapsed;
}

/**
 * Round to 2 decimal places
 */
function round(value: number): number {
  return Math.round(value * 100) / 100;
}
```

#### 2. Cost Estimator Component

**`web/src/components/admin/CostEstimator.tsx`**

```tsx
// src/components/admin/CostEstimator.tsx
// Dashboard component for displaying estimated AWS costs

import React, { useMemo } from "react";
import {
  calculateCosts,
  getCurrentMonthInfo,
  estimateMonthlyUptimeHours,
  PRICING,
} from "../../lib/costs";

interface CostEstimatorProps {
  uptimeSeconds: number | null;
  serverState: string | null;
}

export function CostEstimator({ uptimeSeconds, serverState }: CostEstimatorProps) {
  const costs = useMemo(() => {
    const { daysElapsed, daysInMonth } = getCurrentMonthInfo();

    // Estimate monthly uptime from current uptime
    const estimatedHours = estimateMonthlyUptimeHours(uptimeSeconds, daysElapsed);

    return calculateCosts(estimatedHours, daysElapsed, daysInMonth);
  }, [uptimeSeconds]);

  return (
    <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 className="text-lg font-semibold text-text-light mb-4 flex items-center gap-2">
        <DollarIcon />
        Estimated Monthly Cost
      </h2>

      <div className="space-y-6">
        {/* Month-to-Date */}
        <div>
          <div className="flex justify-between items-baseline mb-2">
            <span className="text-text-muted">
              Current ({costs.daysElapsed} days)
            </span>
            <span className="text-2xl font-bold text-primary-gold">
              ${costs.mtd.total.toFixed(2)}
            </span>
          </div>
          <div className="text-sm text-text-muted space-y-1">
            <CostBreakdownItem
              label="EC2 runtime"
              amount={costs.mtd.ec2Cost}
              detail={`${costs.mtd.hours.toFixed(0)}h`}
            />
            <CostBreakdownItem
              label="EBS storage"
              amount={costs.mtd.ebsCost}
              detail="prorated"
            />
          </div>
        </div>

        {/* Projected */}
        <div className="pt-4 border-t border-secondary-stone/30">
          <div className="flex justify-between items-baseline mb-2">
            <span className="text-text-muted">Projected (full month)</span>
            <span className="text-2xl font-bold text-accent-diamond">
              ${costs.projected.total.toFixed(2)}
            </span>
          </div>
          <div className="text-sm text-text-muted space-y-1">
            <CostBreakdownItem
              label="EC2 runtime"
              amount={costs.projected.ec2Cost}
              detail={`~${costs.projected.hours.toFixed(0)}h`}
            />
            <CostBreakdownItem
              label="EBS storage"
              amount={costs.projected.ebsCost}
            />
            <CostBreakdownItem
              label="Data transfer"
              amount={costs.projected.dataTransferCost}
              prefix="~"
            />
          </div>
        </div>
      </div>

      {/* Disclaimer */}
      <p className="mt-4 pt-4 border-t border-secondary-stone/30 text-xs text-text-muted">
        * Estimated costs based on {PRICING.ec2.instanceType} @ ${PRICING.ec2.hourlyRate}/hr.
        Actual AWS billing may vary.
      </p>
    </div>
  );
}

interface CostBreakdownItemProps {
  label: string;
  amount: number;
  detail?: string;
  prefix?: string;
}

function CostBreakdownItem({ label, amount, detail, prefix = "" }: CostBreakdownItemProps) {
  return (
    <div className="flex justify-between">
      <span>
        {label}
        {detail && <span className="text-text-muted/70"> ({detail})</span>}
      </span>
      <span>
        {prefix}${amount.toFixed(2)}
      </span>
    </div>
  );
}

function DollarIcon() {
  return (
    <svg className="w-5 h-5 text-primary-gold" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={2}
        d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      />
    </svg>
  );
}
```

### Update Dashboard Content

**`web/src/components/admin/DashboardContent.tsx`** - Add CostEstimator:

```tsx
// Add import
import { CostEstimator } from "./CostEstimator";

// Update component to include CostEstimator
export function DashboardContent() {
  const { status, loading, error, lastUpdated, refresh } = useServerStatus();

  // ... existing handlers ...

  return (
    <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
      <ServerStatusCard
        status={status}
        loading={loading}
        error={error}
        lastUpdated={lastUpdated}
        onRefresh={refresh}
      />
      <ServerControls
        serverState={status?.ec2?.state || null}
        loading={loading}
        onStart={handleStart}
        onStop={handleStop}
      />
      <CostEstimator
        uptimeSeconds={status?.ec2?.uptimeSeconds || null}
        serverState={status?.ec2?.state || null}
      />
    </div>
  );
}
```

## Acceptance Criteria Mapping

### Story 01: Cost Calculation Logic

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Pricing constants defined | `PRICING` object | Check code |
| EC2 rate correct ($0.0752) | `PRICING.ec2.hourlyRate` | Check value |
| EBS rate correct ($4.00) | `PRICING.ebs.monthlyBase` | Check value |
| Calculate MTD cost | `costs.mtd.total` | Test calculation |
| Calculate projected cost | `costs.projected.total` | Test calculation |
| Handle edge cases | `Math.max/min` guards | Test day 1, zero uptime |
| TypeScript types exported | `CostEstimate` interface | Import check |

### Story 02: CostEstimator Component

| Criterion | Implementation | Verification |
|-----------|---------------|--------------|
| Displays MTD cost | `${costs.mtd.total.toFixed(2)}` | Visual check |
| Displays projected cost | `${costs.projected.total.toFixed(2)}` | Visual check |
| Shows cost breakdown | `CostBreakdownItem` components | Visual check |
| Shows EC2 hours | `costs.mtd.hours` / `costs.projected.hours` | Visual check |
| Updates with status | `useMemo` recalculates | Change uptime |
| Shows disclaimer | Footer text | Visual check |
| Mobile responsive | Single column on mobile | Test at 320px |

## Testing Requirements

### Unit Test Scenarios

**Cost Calculation:**
```typescript
// Test: 240 hours, 14 days elapsed, 30 days in month
const costs = calculateCosts(240, 14, 30);
// Expected MTD EC2: 240 × 0.0752 = $18.05
// Expected MTD EBS: (14/30) × 4.00 = $1.87
// Expected MTD Total: ~$19.92

// Test: First day of month (1 day elapsed)
const day1Costs = calculateCosts(2, 1, 30);
// Should not divide by zero, should project reasonably

// Test: Zero uptime
const zeroCosts = calculateCosts(0, 15, 30);
// Should return only EBS costs
```

### Manual Testing Checklist

- [ ] Cost card displays on dashboard
- [ ] MTD total shows reasonable value
- [ ] Projected total shows reasonable value
- [ ] Hours breakdown is shown
- [ ] Disclaimer text is visible
- [ ] Values update when server state changes
- [ ] Mobile layout is readable

### Build Verification

```bash
npm run build
```

Expected: Build succeeds; no TypeScript errors.

## Success Verification

After implementation:

- [ ] `src/lib/costs.ts` exports `calculateCosts`, `PRICING`, `CostEstimate`
- [ ] `CostEstimator` component displays costs
- [ ] Dashboard shows cost card
- [ ] Costs update with server uptime
- [ ] Disclaimer indicates estimates

## Traceability

**Parent stories:**
- [Story 01: Implement Cost Calculation Logic](../../stories/epic-BG-WEB-002-03/story-01.md)
- [Story 02: Build CostEstimator Component](../../stories/epic-BG-WEB-002-03/story-02.md)

**Parent epic:** [Epic BG-WEB-002-03: Cost Estimation](../../epics/epic-BG-WEB-002-03-cost-estimation.md)

---

**Next step:** Implement with `/sl-develop .storyline/specs/epic-BG-WEB-002-03/spec-01-02-cost-estimation.md`
