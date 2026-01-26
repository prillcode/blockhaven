// src/hooks/useServerStatus.ts
// React hook for fetching and auto-refreshing server status

import { useState, useEffect, useCallback, useRef } from "react";

interface ServerStatus {
  ec2: {
    state: string;
    publicIp: string | null;
    instanceId: string;
    launchTime: string | null;
    uptimeSeconds: number | null;
  };
  minecraft: {
    online: boolean;
    players: { online: number; max: number; list: string[] };
    version: string | null;
    motd: string | null;
  } | null;
  timestamp: string;
}

interface UseServerStatusResult {
  status: ServerStatus | null;
  loading: boolean;
  error: string | null;
  lastUpdated: Date | null;
  refresh: () => Promise<void>;
}

// Refresh intervals
const NORMAL_INTERVAL = 30000;      // 30 seconds
const TRANSITION_INTERVAL = 5000;   // 5 seconds during state changes

export function useServerStatus(): UseServerStatusResult {
  const [status, setStatus] = useState<ServerStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null);

  // Use ref to track if component is mounted
  const isMounted = useRef(true);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  const fetchStatus = useCallback(async () => {
    try {
      setLoading(true);
      const response = await fetch("/api/admin/server/status");

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();

      if (isMounted.current) {
        setStatus(data);
        setError(null);
        setLastUpdated(new Date());
      }
    } catch (err) {
      if (isMounted.current) {
        setError(err instanceof Error ? err.message : "Failed to fetch status");
      }
    } finally {
      if (isMounted.current) {
        setLoading(false);
      }
    }
  }, []);

  // Determine refresh interval based on state
  const getRefreshInterval = useCallback(() => {
    const state = status?.ec2?.state;
    if (state === "starting" || state === "stopping" || state === "pending") {
      return TRANSITION_INTERVAL;
    }
    return NORMAL_INTERVAL;
  }, [status?.ec2?.state]);

  // Setup auto-refresh
  useEffect(() => {
    isMounted.current = true;
    fetchStatus();

    return () => {
      isMounted.current = false;
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [fetchStatus]);

  // Update interval when state changes
  useEffect(() => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }

    const interval = getRefreshInterval();
    intervalRef.current = setInterval(fetchStatus, interval);

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [fetchStatus, getRefreshInterval]);

  // Pause when tab is hidden, refresh when visible
  useEffect(() => {
    const handleVisibilityChange = () => {
      if (document.visibilityState === "visible") {
        fetchStatus();
      }
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);
    return () => {
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [fetchStatus]);

  return { status, loading, error, lastUpdated, refresh: fetchStatus };
}
