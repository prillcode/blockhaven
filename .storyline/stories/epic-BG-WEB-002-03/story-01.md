---
story_id: 01
epic_id: BG-WEB-002-03
identifier: BG-WEB-002
title: Implement Cost Calculation Logic
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-03-cost-estimation.md
created: 2026-01-25
---

# Story 01: Implement Cost Calculation Logic

## User Story

**As a** developer,
**I want** cost calculation utilities with AWS pricing constants,
**so that** we can estimate monthly server costs based on uptime.

## Acceptance Criteria

### Scenario 1: Pricing constants defined
**Given** the cost module is implemented
**When** I check the pricing configuration
**Then** EC2 hourly rate for t3a.large is defined ($0.0752)
**And** EBS monthly rate for 50GB gp3 is defined ($4.00)
**And** estimated data transfer cost is defined

### Scenario 2: Calculate month-to-date cost
**Given** the server has run for 240 hours this month
**And** 14 days have elapsed
**When** I calculate MTD cost
**Then** EC2 cost is 240 * $0.0752 = $18.05
**And** EBS cost is prorated: (14/30) * $4.00 = $1.87
**And** total MTD is approximately $19.92

### Scenario 3: Calculate projected monthly cost
**Given** the server has averaged 8 hours/day
**And** the month has 30 days
**When** I calculate projected cost
**Then** projected hours is 8 * 30 = 240 hours
**And** projected EC2 cost is 240 * $0.0752 = $18.05
**And** projected total includes EC2 + EBS + data transfer

### Scenario 4: Handle edge cases
**Given** various edge conditions
**When** I calculate costs
**Then** first day of month returns reasonable projection
**And** zero uptime returns only EBS cost
**And** 24/7 uptime calculates maximum cost

### Scenario 5: TypeScript types exported
**Given** the cost module is implemented
**When** I import types
**Then** `CostEstimate` interface is available
**And** `PRICING` constants are typed

## Business Value

**Why this matters:** Cost visibility helps admins make informed decisions about server uptime. Simple calculations are transparent and maintainable.

**Impact:** Admins can see estimated costs without accessing AWS Billing.

**Success metric:** Estimates are within 10% of actual AWS billing.

## Technical Considerations

**Implementation:**
```typescript
// src/lib/costs.ts
export const PRICING = {
  ec2: {
    instanceType: "t3a.large",
    hourlyRate: 0.0752,
  },
  ebs: {
    volumeType: "gp3",
    sizeGB: 50,
    monthlyRate: 0.08,
    monthlyBase: 4.0, // 50 * 0.08
  },
  dataTransfer: {
    estimatedMonthlyGB: 10,
    ratePerGB: 0.09,
    estimatedMonthly: 0.9,
  },
} as const

export interface CostEstimate {
  mtdHours: number
  mtdEc2Cost: number
  mtdEbsCost: number
  mtdTotal: number
  projectedHours: number
  projectedEc2Cost: number
  projectedTotal: number
}

export function calculateCosts(
  uptimeHours: number,
  daysElapsed: number,
  daysInMonth: number
): CostEstimate {
  // Month-to-date
  const mtdEc2Cost = uptimeHours * PRICING.ec2.hourlyRate
  const mtdEbsCost = (daysElapsed / daysInMonth) * PRICING.ebs.monthlyBase
  const mtdTotal = mtdEc2Cost + mtdEbsCost

  // Projection
  const avgHoursPerDay = uptimeHours / Math.max(daysElapsed, 1)
  const projectedHours = avgHoursPerDay * daysInMonth
  const projectedEc2Cost = projectedHours * PRICING.ec2.hourlyRate
  const projectedTotal =
    projectedEc2Cost + PRICING.ebs.monthlyBase + PRICING.dataTransfer.estimatedMonthly

  return {
    mtdHours: uptimeHours,
    mtdEc2Cost: round(mtdEc2Cost),
    mtdEbsCost: round(mtdEbsCost),
    mtdTotal: round(mtdTotal),
    projectedHours: round(projectedHours),
    projectedEc2Cost: round(projectedEc2Cost),
    projectedTotal: round(projectedTotal),
  }
}

function round(value: number): number {
  return Math.round(value * 100) / 100
}
```

**Getting Uptime Hours:**
- Option A: Calculate from current uptime + estimated daily average
- Option B: Track actual usage in KV (more accurate, more complex)
- Recommended: Start with Option A for simplicity

## Dependencies

**Depends on stories:**
- Epic 2: Server Status (uptime data)

**Enables stories:**
- Story 02: CostEstimator Component

## Out of Scope

- AWS Cost Explorer API integration
- Historical cost tracking
- Multiple instance aggregation
- Reserved instance pricing

## Notes

- Pricing data should be reviewed periodically
- EBS costs apply even when server is stopped
- Data transfer is a rough estimate
- Clearly label all values as "estimated"

## Traceability

**Parent epic:** [epic-BG-WEB-002-03-cost-estimation.md](../../epics/epic-BG-WEB-002-03-cost-estimation.md)

**Related stories:** Story 02 (CostEstimator Component)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-03/story-01.md`
