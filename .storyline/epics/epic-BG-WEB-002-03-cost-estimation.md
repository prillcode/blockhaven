# Epic 3: Cost Estimation

**Epic ID:** BG-WEB-002-03
**Status:** Not Started
**Priority:** P1 (Should Have)
**Source:** web/.docs/ASTRO-SITE-ADMIN-DASH-PRD.md

---

## Business Goal

Provide visibility into AWS costs associated with running the Minecraft server, helping admins understand the financial impact of server uptime and make informed decisions about when to keep the server running.

## User Value

**Who Benefits:** Authorized admins

**How They Benefit:**
- Cost transparency: Know exactly how much the server costs to run
- Budget planning: See projected monthly costs based on current usage
- Usage optimization: Understand correlation between uptime and costs
- No AWS Console: View billing information without accessing AWS directly

## Success Criteria

- [ ] Month-to-date cost displays on dashboard
- [ ] Projected full-month cost calculated based on current usage pattern
- [ ] Cost breakdown shows EC2, EBS, and data transfer components
- [ ] Costs update when server status changes (start/stop)
- [ ] Estimates are within 10% accuracy of actual AWS billing
- [ ] Cost display is mobile-friendly

## Scope

### In Scope
- Cost calculation logic based on instance runtime hours
- CostEstimator component with clear breakdown display
- Integration with server status data (uptime hours)
- Month-to-date calculation
- Projected monthly cost calculation
- Breakdown by service type (EC2, EBS, data transfer estimate)
- Visual indicators for cost thresholds

### Out of Scope
- AWS Cost Explorer API integration (complexity vs value)
- Historical cost data tracking
- Cost alerts or notifications
- Multiple instance cost aggregation
- Reserved instance or savings plan calculations
- Detailed data transfer cost tracking

## Technical Notes

**Pricing Data (us-east-2, as of 2025):**
```typescript
// src/lib/costs.ts
export const PRICING = {
  ec2: {
    instanceType: 't3a.large',
    hourlyRate: 0.0752, // USD per hour
  },
  ebs: {
    volumeType: 'gp3',
    sizeGB: 50,
    monthlyRate: 0.08, // USD per GB per month
    monthlyBase: 4.00, // 50GB * $0.08 = $4.00
  },
  dataTransfer: {
    estimatedMonthlyGB: 10,
    ratePerGB: 0.09,
    estimatedMonthly: 0.90, // Rough estimate
  },
}
```

**Cost Calculation Logic:**
```typescript
// src/lib/costs.ts
export interface CostEstimate {
  mtdHours: number           // Month-to-date runtime hours
  mtdEc2Cost: number         // MTD EC2 cost
  mtdEbsCost: number         // MTD EBS cost (prorated)
  mtdTotal: number           // MTD total
  projectedHours: number     // Projected full-month hours
  projectedEc2Cost: number   // Projected EC2 cost
  projectedTotal: number     // Projected total (EC2 + EBS + data)
}

export function calculateCosts(uptimeHours: number, daysElapsed: number, daysInMonth: number): CostEstimate {
  // Month-to-date
  const mtdEc2Cost = uptimeHours * PRICING.ec2.hourlyRate
  const mtdEbsCost = (daysElapsed / daysInMonth) * PRICING.ebs.monthlyBase

  // Projection: extrapolate current usage to full month
  const avgHoursPerDay = uptimeHours / Math.max(daysElapsed, 1)
  const projectedHours = avgHoursPerDay * daysInMonth
  const projectedEc2Cost = projectedHours * PRICING.ec2.hourlyRate
  const projectedTotal = projectedEc2Cost + PRICING.ebs.monthlyBase + PRICING.dataTransfer.estimatedMonthly

  return {
    mtdHours: uptimeHours,
    mtdEc2Cost,
    mtdEbsCost,
    mtdTotal: mtdEc2Cost + mtdEbsCost,
    projectedHours,
    projectedEc2Cost,
    projectedTotal,
  }
}
```

**Tracking Runtime Hours:**

Option A: Calculate from start/stop events (complex, requires storage)
Option B: Query current uptime + estimate based on usage pattern (simpler)

**Recommended: Option B (Simpler Approach)**
- Store daily usage summary in Cloudflare KV (optional enhancement)
- For MVP: estimate based on current session uptime and days in month

**Component Display:**
```
💰 Estimated Monthly Cost
───────────────────────────
Current (14 days):  $48.50
  • EC2 runtime:    $42.00 (560 hours)
  • EBS storage:    $2.00
  • Data transfer:  ~$0.50

Projected (full month): $97.00
  • EC2 runtime:    $90.00 (1,200 hours)
  • EBS storage:    $4.00
  • Data transfer:  ~$1.00
───────────────────────────
Last updated: Just now
```

## Dependencies

**Depends On:**
- Epic 1: Authentication (protected dashboard)
- Epic 2: Server Status & Controls (uptime data)

**Blocks:**
- Epic 6: Polish & Security Audit

## Risks & Mitigations

**Risk:** Cost estimates diverge from actual AWS billing
- **Likelihood:** Medium
- **Impact:** Low
- **Mitigation:** Clearly label as "estimate", include disclaimer about actual billing

**Risk:** Tracking runtime hours accurately
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:** Use simpler projection model, accept ~10% variance

**Risk:** AWS pricing changes
- **Likelihood:** Low
- **Impact:** Low
- **Mitigation:** Document pricing in config, update periodically

## Acceptance Criteria

### Cost Calculation Logic
- [ ] `calculateCosts` function implemented with pricing constants
- [ ] Month-to-date calculation uses actual uptime hours
- [ ] Projected calculation extrapolates based on usage pattern
- [ ] Handles edge cases (first day of month, server always off, etc.)

### CostEstimator Component
- [ ] Displays month-to-date cost prominently
- [ ] Shows projected full-month cost
- [ ] Breaks down costs by service (EC2, EBS, data transfer)
- [ ] Shows runtime hours alongside costs
- [ ] Updates when server status changes
- [ ] Shows "last updated" timestamp
- [ ] Responsive design for mobile
- [ ] Loading state during calculation

### Visual Design
- [ ] Cost amounts clearly formatted as currency ($XX.XX)
- [ ] Hours formatted with appropriate precision
- [ ] Color coding for cost thresholds (optional):
  - Green: < $50/month
  - Yellow: $50-$100/month
  - Red: > $100/month
- [ ] Clear visual hierarchy (total vs breakdown)

### Data Integration
- [ ] Receives uptime data from server status
- [ ] Uses current date for month calculations
- [ ] Recalculates on server start/stop events
- [ ] Handles missing/unavailable data gracefully

### Disclaimer
- [ ] Clear label: "Estimated costs"
- [ ] Note that actual billing may vary
- [ ] Link to AWS billing dashboard (optional)

### Environment Variables
```bash
# No new env vars required - uses existing AWS and instance config
# Pricing constants are hardcoded in lib/costs.ts
```

### Directory Structure Additions
```
/web/src/
├── components/
│   └── admin/
│       └── CostEstimator.tsx    # Cost display component
└── lib/
    └── costs.ts                  # Cost calculation utilities
```

### Verification Checklist
- [ ] Dashboard shows cost estimate after login
- [ ] MTD cost increases as server runs
- [ ] Projected cost is reasonable based on usage
- [ ] Starting server: cost projection may increase
- [ ] Stopping server: cost projection stabilizes
- [ ] Breakdown totals match summary
- [ ] Mobile view is readable and usable
- [ ] First day of month shows appropriate projections

## Related User Stories

From PRD:
- User Story 8: "As the admin, I want to see estimated monthly costs so I can monitor AWS billing"

## Notes

- This feature provides visibility without the complexity of AWS Cost Explorer API
- Simple calculation model is preferred over accuracy - users understand it's an estimate
- Pricing data should be reviewed and updated occasionally
- EBS costs are incurred even when server is stopped (storage persists)
- Data transfer estimate is rough - actual usage varies significantly
- Could be enhanced later with Cloudflare KV to track daily usage history

---

**Next Epic:** Epic 4 - Server Logs Viewer
