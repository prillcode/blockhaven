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
