// src/components/admin/LogsViewer.tsx
// Terminal-style log viewer component

import { useState, useEffect, useRef } from "react";

interface LogEntry {
  timestamp: string;
  message: string;
  level: "INFO" | "WARN" | "ERROR" | "DEBUG";
}

interface LogsViewerProps {
  serverState: string | null;
}

const LEVEL_COLORS: Record<string, string> = {
  INFO: "text-mc-green",
  WARN: "text-accent-gold",
  ERROR: "text-accent-redstone",
  DEBUG: "text-text-muted",
};

const LINE_COUNTS = [100, 250, 500];

export function LogsViewer({ serverState }: LogsViewerProps) {
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lineCount, setLineCount] = useState(100);
  const [filter, setFilter] = useState("");
  const [autoScroll, setAutoScroll] = useState(true);

  const containerRef = useRef<HTMLDivElement>(null);

  const fetchLogs = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`/api/admin/logs?count=${lineCount}`);
      const data = await response.json();

      if (data.error) {
        setError(data.error);
      } else {
        setLogs(data.logs || []);
      }
    } catch (err) {
      setError("Failed to fetch logs");
    } finally {
      setLoading(false);
    }
  };

  // Fetch logs on mount and when lineCount changes
  useEffect(() => {
    fetchLogs();
  }, [lineCount]);

  // Auto-scroll to bottom
  useEffect(() => {
    if (autoScroll && containerRef.current) {
      containerRef.current.scrollTop = containerRef.current.scrollHeight;
    }
  }, [logs, autoScroll]);

  // Filter logs client-side
  const filteredLogs = filter
    ? logs.filter((log) =>
        log.message.toLowerCase().includes(filter.toLowerCase())
      )
    : logs;

  const formatTimestamp = (iso: string) => {
    const date = new Date(iso);
    return date.toLocaleTimeString("en-US", {
      hour12: false,
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
  };

  return (
    <div className="bg-gray-900 rounded-lg overflow-hidden">
      {/* Controls */}
      <div className="flex flex-wrap items-center gap-3 p-3 bg-gray-800 border-b border-gray-700">
        {/* Line Count Selector */}
        <select
          value={lineCount}
          onChange={(e) => setLineCount(Number(e.target.value))}
          className="px-3 py-2 bg-gray-700 text-text-light rounded border border-gray-600 text-sm"
        >
          {LINE_COUNTS.map((count) => (
            <option key={count} value={count}>
              {count} lines
            </option>
          ))}
        </select>

        {/* Filter Input */}
        <input
          type="text"
          placeholder="Filter logs..."
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="flex-1 min-w-[150px] px-3 py-2 bg-gray-700 text-text-light rounded border border-gray-600 text-sm placeholder-text-muted"
        />

        {/* Auto-scroll Toggle */}
        <label className="flex items-center gap-2 text-sm text-text-muted cursor-pointer">
          <input
            type="checkbox"
            checked={autoScroll}
            onChange={(e) => setAutoScroll(e.target.checked)}
            className="rounded"
          />
          Auto-scroll
        </label>

        {/* Refresh Button */}
        <button
          onClick={fetchLogs}
          disabled={loading}
          className="px-4 py-2 bg-secondary-stone/50 hover:bg-secondary-stone/70 text-text-light rounded text-sm transition-colors disabled:opacity-50"
        >
          {loading ? "Loading..." : "Refresh"}
        </button>
      </div>

      {/* Log Container */}
      <div
        ref={containerRef}
        className="h-96 overflow-auto p-4 font-mono text-sm overflow-x-auto"
      >
        {/* Server Offline Message */}
        {serverState === "stopped" && (
          <div className="text-text-muted mb-4">
            Server is offline. Showing cached logs.
          </div>
        )}

        {/* Error Message */}
        {error && (
          <div className="text-accent-redstone mb-4">{error}</div>
        )}

        {/* Log Lines */}
        {filteredLogs.length > 0 ? (
          filteredLogs.map((log, index) => (
            <div
              key={index}
              className={`whitespace-pre ${LEVEL_COLORS[log.level]}`}
            >
              <span className="text-text-muted/70">
                {formatTimestamp(log.timestamp)}
              </span>{" "}
              {log.message}
            </div>
          ))
        ) : (
          !loading &&
          !error && (
            <div className="text-text-muted">No logs available</div>
          )
        )}

        {/* Loading Indicator */}
        {loading && logs.length === 0 && (
          <div className="text-text-muted">Loading logs...</div>
        )}
      </div>

      {/* Footer */}
      <div className="px-4 py-2 bg-gray-800 border-t border-gray-700 text-xs text-text-muted">
        Showing {filteredLogs.length} of {logs.length} logs
        {filter && ` (filtered)`}
      </div>
    </div>
  );
}
