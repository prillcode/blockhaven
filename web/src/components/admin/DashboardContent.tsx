// src/components/admin/DashboardContent.tsx
// Main dashboard content with server status and controls

import { useServerStatus } from "../../hooks/useServerStatus";
import { ErrorBoundary } from "./ErrorBoundary";
import { ServerStatusCard } from "./ServerStatusCard";
import { ServerControls } from "./ServerControls";
import { CostEstimator } from "./CostEstimator";
import { LogsViewer } from "./LogsViewer";
import { QuickActions } from "./QuickActions";

export function DashboardContent() {
  const { status, loading, error, lastUpdated, refresh } = useServerStatus();

  const handleStart = async () => {
    const response = await fetch("/api/admin/server/start", { method: "POST" });
    if (!response.ok) {
      throw new Error("Failed to start server");
    }
    // Refresh status after action
    setTimeout(refresh, 1000);
  };

  const handleStop = async () => {
    const response = await fetch("/api/admin/server/stop", { method: "POST" });
    if (!response.ok) {
      throw new Error("Failed to stop server");
    }
    // Refresh status after action
    setTimeout(refresh, 1000);
  };

  return (
    <div className="grid gap-4 sm:gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
      <ErrorBoundary sectionName="Server Status">
        <ServerStatusCard
          status={status}
          loading={loading}
          error={error}
          lastUpdated={lastUpdated}
          onRefresh={refresh}
        />
      </ErrorBoundary>
      <ErrorBoundary sectionName="Server Controls">
        <ServerControls
          serverState={status?.ec2?.state || null}
          loading={loading}
          onStart={handleStart}
          onStop={handleStop}
        />
      </ErrorBoundary>
      <ErrorBoundary sectionName="Cost Estimation">
        <CostEstimator
          uptimeSeconds={status?.ec2?.uptimeSeconds || null}
          serverState={status?.ec2?.state || null}
        />
      </ErrorBoundary>
      <ErrorBoundary sectionName="Quick Actions">
        <QuickActions serverState={status?.ec2?.state || null} />
      </ErrorBoundary>
      <div className="lg:col-span-2">
        <ErrorBoundary sectionName="Server Logs">
          <LogsViewer serverState={status?.ec2?.state || null} />
        </ErrorBoundary>
      </div>
    </div>
  );
}
