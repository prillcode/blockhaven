// src/components/admin/ServerStatusCard.tsx
// Displays server status with state indicator, IP, uptime, and players


interface ServerStatusCardProps {
  status: {
    ec2: {
      state: string;
      publicIp: string | null;
      uptimeSeconds: number | null;
    };
    minecraft: {
      online: boolean;
      players: { online: number; max: number; list: string[] };
    } | null;
  } | null;
  loading: boolean;
  error: string | null;
  lastUpdated: Date | null;
  onRefresh: () => void;
}

const STATE_COLORS: Record<string, string> = {
  running: "bg-mc-green",
  stopped: "bg-accent-redstone",
  starting: "bg-accent-gold",
  stopping: "bg-accent-gold",
  pending: "bg-accent-gold",
};

const STATE_LABELS: Record<string, string> = {
  running: "Running",
  stopped: "Stopped",
  starting: "Starting...",
  stopping: "Stopping...",
  pending: "Pending...",
};

function formatUptime(seconds: number | null): string {
  if (!seconds) return "\u2014";

  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);

  if (hours >= 24) {
    const days = Math.floor(hours / 24);
    const remainingHours = hours % 24;
    return `${days}d ${remainingHours}h`;
  }

  return `${hours}h ${minutes}m`;
}

function formatLastUpdated(date: Date | null): string {
  if (!date) return "";
  const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
  if (seconds < 5) return "Just now";
  if (seconds < 60) return `${seconds}s ago`;
  return `${Math.floor(seconds / 60)}m ago`;
}

export function ServerStatusCard({
  status,
  loading,
  error,
  lastUpdated,
  onRefresh,
}: ServerStatusCardProps) {
  const state = status?.ec2?.state || "unknown";
  const stateColor = STATE_COLORS[state] || "bg-secondary-stone";
  const stateLabel = STATE_LABELS[state] || state;
  const isTransitioning = state === "starting" || state === "stopping" || state === "pending";

  // Loading skeleton
  if (loading && !status) {
    return (
      <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6 animate-pulse">
        <div className="h-6 bg-secondary-stone/30 rounded w-1/3 mb-4" />
        <div className="space-y-3">
          <div className="h-4 bg-secondary-stone/30 rounded w-2/3" />
          <div className="h-4 bg-secondary-stone/30 rounded w-1/2" />
          <div className="h-4 bg-secondary-stone/30 rounded w-3/4" />
        </div>
      </div>
    );
  }

  return (
    <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      {/* Header */}
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-lg font-semibold text-text-light">Server Status</h2>
        <button
          onClick={onRefresh}
          disabled={loading}
          className="p-2 hover:bg-secondary-stone/30 rounded-lg transition-colors disabled:opacity-50"
          title="Refresh status"
        >
          <svg
            className={`w-5 h-5 text-text-muted ${loading ? "animate-spin" : ""}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
            />
          </svg>
        </button>
      </div>

      {/* Error State */}
      {error && (
        <div className="mb-4 p-3 bg-accent-redstone/20 border border-accent-redstone/40 rounded-lg">
          <p className="text-accent-redstone text-sm">{error}</p>
        </div>
      )}

      {/* Status Grid */}
      <div className="space-y-3">
        {/* State */}
        <div className="flex justify-between items-center">
          <span className="text-text-muted">State</span>
          <div className="flex items-center gap-2">
            <span className={`w-3 h-3 rounded-full ${stateColor} ${isTransitioning ? "animate-pulse" : ""}`} />
            <span className="text-text-light font-medium">{stateLabel}</span>
          </div>
        </div>

        {/* IP Address */}
        <div className="flex justify-between items-center">
          <span className="text-text-muted">IP Address</span>
          <span className="text-text-light font-mono text-sm">
            {status?.ec2?.publicIp || "\u2014"}
          </span>
        </div>

        {/* Uptime */}
        <div className="flex justify-between items-center">
          <span className="text-text-muted">Uptime</span>
          <span className="text-text-light">
            {formatUptime(status?.ec2?.uptimeSeconds || null)}
          </span>
        </div>

        {/* Players */}
        {status?.minecraft && (
          <div className="flex justify-between items-center">
            <span className="text-text-muted">Players</span>
            <span className="text-text-light">
              {status.minecraft.online
                ? `${status.minecraft.players.online} / ${status.minecraft.players.max}`
                : "Offline"}
            </span>
          </div>
        )}
      </div>

      {/* Player List */}
      {status?.minecraft?.players?.list && status.minecraft.players.list.length > 0 && (
        <div className="mt-4 pt-4 border-t border-secondary-stone/30">
          <p className="text-text-muted text-sm mb-2">Online Players:</p>
          <div className="flex flex-wrap gap-2">
            {status.minecraft.players.list.map((player) => (
              <span
                key={player}
                className="px-2 py-1 bg-mc-green/20 text-mc-green text-sm rounded"
              >
                {player}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Last Updated */}
      {lastUpdated && (
        <div className="mt-4 pt-4 border-t border-secondary-stone/30">
          <p className="text-text-muted text-xs">
            Updated {formatLastUpdated(lastUpdated)}
          </p>
        </div>
      )}
    </div>
  );
}
