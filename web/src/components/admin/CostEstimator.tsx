// src/components/admin/CostEstimator.tsx
// Dashboard component for displaying estimated AWS costs

import { useMemo } from "react";
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

export function CostEstimator({ uptimeSeconds }: CostEstimatorProps) {
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
