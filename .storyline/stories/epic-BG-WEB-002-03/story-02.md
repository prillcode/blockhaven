---
story_id: 02
epic_id: BG-WEB-002-03
identifier: BG-WEB-002
title: Build CostEstimator Component
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-03-cost-estimation.md
created: 2026-01-25
---

# Story 02: Build CostEstimator Component

## User Story

**As an** authenticated admin,
**I want** to see estimated monthly costs on the dashboard,
**so that** I can understand the financial impact of server uptime.

## Acceptance Criteria

### Scenario 1: Displays month-to-date cost
**Given** the dashboard is loaded
**When** I view the cost estimator
**Then** current month-to-date cost is prominently displayed
**And** it shows the number of days elapsed

### Scenario 2: Displays projected monthly cost
**Given** the dashboard is loaded
**When** I view the cost estimator
**Then** projected full-month cost is displayed
**And** it's based on current usage pattern

### Scenario 3: Shows cost breakdown
**Given** the dashboard is loaded
**When** I view the cost estimator
**Then** breakdown shows EC2 runtime cost
**And** breakdown shows EBS storage cost
**And** breakdown shows estimated data transfer

### Scenario 4: Updates with server status
**Given** the server starts or stops
**When** status refreshes
**Then** cost projection updates accordingly

### Scenario 5: Mobile responsive layout
**Given** I'm on a mobile device
**When** I view the cost estimator
**Then** layout adapts to narrow screens
**And** all numbers are readable

### Scenario 6: Shows disclaimer
**Given** the dashboard is loaded
**When** I view the cost estimator
**Then** a note indicates these are estimates
**And** actual billing may vary

## Business Value

**Why this matters:** Cost visibility helps admins make informed decisions about when to run the server. Seeing projected costs encourages cost-conscious behavior.

**Impact:** Admins can predict monthly bills and optimize usage.

**Success metric:** Cost estimates are within 10% of actual billing.

## Technical Considerations

**Component Structure:**
```tsx
// src/components/admin/CostEstimator.tsx
interface CostEstimatorProps {
  uptimeSeconds: number | null
  serverState: string | null
}

export function CostEstimator({ uptimeSeconds, serverState }: CostEstimatorProps) {
  const costs = useMemo(() => {
    const now = new Date()
    const daysInMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate()
    const daysElapsed = now.getDate()

    // Convert uptime to estimated monthly hours
    // This is a simplification - assumes average usage pattern
    const uptimeHours = (uptimeSeconds || 0) / 3600
    const avgHoursPerDay = uptimeHours / Math.max(daysElapsed, 1)
    const estimatedMtdHours = avgHoursPerDay * daysElapsed

    return calculateCosts(estimatedMtdHours, daysElapsed, daysInMonth)
  }, [uptimeSeconds])

  return (
    <div className="bg-secondary-darkGray rounded-lg p-6">
      <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
        <DollarIcon /> Estimated Monthly Cost
      </h2>

      <div className="space-y-4">
        <CostRow
          label={`Current (${new Date().getDate()} days)`}
          amount={costs.mtdTotal}
          breakdown={[
            { label: "EC2 runtime", amount: costs.mtdEc2Cost, hours: costs.mtdHours },
            { label: "EBS storage", amount: costs.mtdEbsCost },
          ]}
        />

        <CostRow
          label="Projected (full month)"
          amount={costs.projectedTotal}
          breakdown={[
            { label: "EC2 runtime", amount: costs.projectedEc2Cost, hours: costs.projectedHours },
            { label: "EBS storage", amount: PRICING.ebs.monthlyBase },
            { label: "Data transfer", amount: PRICING.dataTransfer.estimatedMonthly, prefix: "~" },
          ]}
        />
      </div>

      <p className="text-xs text-gray-400 mt-4">
        * Estimated costs. Actual AWS billing may vary.
      </p>
    </div>
  )
}

function CostRow({ label, amount, breakdown }) {
  return (
    <div>
      <div className="flex justify-between items-baseline">
        <span className="text-gray-300">{label}</span>
        <span className="text-xl font-bold text-primary-grass">
          ${amount.toFixed(2)}
        </span>
      </div>
      <div className="text-sm text-gray-400 mt-1">
        {breakdown.map(item => (
          <div key={item.label}>
            • {item.label}: {item.prefix || ""}${item.amount.toFixed(2)}
            {item.hours !== undefined && ` (${Math.round(item.hours)}h)`}
          </div>
        ))}
      </div>
    </div>
  )
}
```

**Color Coding (optional):**
```typescript
function getCostColor(projected: number): string {
  if (projected < 50) return "text-green-400"
  if (projected < 100) return "text-yellow-400"
  return "text-red-400"
}
```

**Styling:**
- Currency formatted with $ and 2 decimal places
- Hours shown in parentheses where relevant
- Clear visual hierarchy (totals vs breakdown)
- Disclaimer in smaller, muted text

## Dependencies

**Depends on stories:**
- Story 01: Cost Calculation Logic
- Epic 2 Story 02: Server Status API (uptime data)

**Enables stories:** None (completes Epic 3)

## Out of Scope

- Interactive cost calculator
- Historical cost graphs
- Budget alerts
- AWS billing API integration

## Notes

- Component receives uptime from server status
- Cost calculation happens client-side for simplicity
- Disclaimer is important - these are estimates
- Consider adding link to AWS Billing dashboard

## Traceability

**Parent epic:** [epic-BG-WEB-002-03-cost-estimation.md](../../epics/epic-BG-WEB-002-03-cost-estimation.md)

**Related stories:** Story 01 (Cost Logic), Epic 2 (Server Status)

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-03/story-02.md`
