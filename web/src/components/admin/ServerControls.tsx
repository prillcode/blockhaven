// src/components/admin/ServerControls.tsx
// Start/Stop server buttons with confirmation dialog

import { useState } from "react";

interface ServerControlsProps {
  serverState: string | null;
  loading: boolean;
  onStart: () => Promise<void>;
  onStop: () => Promise<void>;
}

export function ServerControls({
  serverState,
  loading,
  onStart,
  onStop,
}: ServerControlsProps) {
  const [actionLoading, setActionLoading] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);

  const isRunning = serverState === "running";
  const isStopped = serverState === "stopped";
  const isTransitioning = serverState === "starting" || serverState === "stopping" || serverState === "pending";

  const handleStart = async () => {
    setActionLoading(true);
    setMessage(null);
    try {
      await onStart();
      setMessage({ type: "success", text: "Server is starting..." });
    } catch (err) {
      setMessage({ type: "error", text: "Failed to start server" });
    } finally {
      setActionLoading(false);
    }
  };

  const handleStop = async () => {
    setShowConfirm(false);
    setActionLoading(true);
    setMessage(null);
    try {
      await onStop();
      setMessage({ type: "success", text: "Server is stopping..." });
    } catch (err) {
      setMessage({ type: "error", text: "Failed to stop server" });
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 className="text-lg font-semibold text-text-light mb-4">Server Controls</h2>

      {/* Action Buttons */}
      <div className="flex gap-4">
        {isStopped && (
          <button
            onClick={handleStart}
            disabled={actionLoading || loading}
            className="flex-1 px-6 py-3 bg-mc-green hover:bg-mc-dark-green text-white font-medium rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {actionLoading ? (
              <LoadingSpinner />
            ) : (
              <>
                <PlayIcon />
                Start Server
              </>
            )}
          </button>
        )}

        {isRunning && (
          <button
            onClick={() => setShowConfirm(true)}
            disabled={actionLoading || loading}
            className="flex-1 px-6 py-3 bg-accent-redstone hover:bg-accent-redstone/80 text-white font-medium rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            <StopIcon />
            Stop Server
          </button>
        )}

        {isTransitioning && (
          <div className="flex-1 px-6 py-3 bg-accent-gold/20 text-accent-gold font-medium rounded-lg flex items-center justify-center gap-2">
            <LoadingSpinner />
            Server is {serverState}...
          </div>
        )}
      </div>

      {/* Message */}
      {message && (
        <div
          className={`mt-4 p-3 rounded-lg ${
            message.type === "success"
              ? "bg-mc-green/20 text-mc-green"
              : "bg-accent-redstone/20 text-accent-redstone"
          }`}
        >
          {message.text}
        </div>
      )}

      {/* Confirmation Dialog */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-bg-dark border border-secondary-stone/30 rounded-lg p-6 max-w-md w-full">
            <h3 className="text-xl font-bold text-text-light mb-2">Stop Server?</h3>
            <p className="text-text-muted mb-6">
              This will disconnect all players. The world data will be saved before shutdown.
            </p>
            <div className="flex gap-4">
              <button
                onClick={() => setShowConfirm(false)}
                className="flex-1 px-4 py-2 bg-secondary-stone/30 hover:bg-secondary-stone/50 text-text-light rounded-lg transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleStop}
                disabled={actionLoading}
                className="flex-1 px-4 py-2 bg-accent-redstone hover:bg-accent-redstone/80 text-white rounded-lg transition-colors disabled:opacity-50"
              >
                {actionLoading ? <LoadingSpinner /> : "Stop Server"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// Icons
function PlayIcon() {
  return (
    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
      <path d="M8 5v14l11-7z" />
    </svg>
  );
}

function StopIcon() {
  return (
    <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
      <path d="M6 6h12v12H6z" />
    </svg>
  );
}

function LoadingSpinner() {
  return (
    <svg className="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
      <circle
        className="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="4"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      />
    </svg>
  );
}
