// src/lib/minecraft.ts
// Minecraft server status via mcstatus.io API
//
// Uses the free mcstatus.io API to get Minecraft-specific server info
// including player count, version, and MOTD.

/**
 * Minecraft server status from mcstatus.io
 */
export interface MinecraftStatus {
  online: boolean;
  players: {
    online: number;
    max: number;
    list: string[];
  };
  version: string | null;
  motd: string | null;
}

/**
 * mcstatus.io API response type (partial)
 */
interface MCStatusResponse {
  online: boolean;
  players?: {
    online: number;
    max: number;
    list?: Array<{
      name_raw: string;
      name_clean: string;
      uuid: string;
    }>;
  };
  version?: {
    name_raw: string;
    name_clean: string;
  };
  motd?: {
    raw: string;
    clean: string;
  };
}

/**
 * Get Minecraft server status from mcstatus.io
 *
 * @param serverAddress - Minecraft server address (IP or hostname)
 * @returns Minecraft status or offline status on error
 */
export async function getMinecraftStatus(serverAddress: string): Promise<MinecraftStatus> {
  const offlineStatus: MinecraftStatus = {
    online: false,
    players: { online: 0, max: 0, list: [] },
    version: null,
    motd: null,
  };

  try {
    // Use AbortController for timeout (5 seconds)
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000);

    const response = await fetch(
      `https://api.mcstatus.io/v2/status/java/${encodeURIComponent(serverAddress)}`,
      { signal: controller.signal }
    );

    clearTimeout(timeoutId);

    if (!response.ok) {
      console.log(`[Minecraft] mcstatus.io returned ${response.status} for ${serverAddress}`);
      return offlineStatus;
    }

    const data: MCStatusResponse = await response.json();

    if (!data.online) {
      return offlineStatus;
    }

    return {
      online: true,
      players: {
        online: data.players?.online || 0,
        max: data.players?.max || 0,
        list: data.players?.list?.map((p) => p.name_clean) || [],
      },
      version: data.version?.name_clean || null,
      motd: data.motd?.clean || null,
    };
  } catch (error) {
    // Timeout or network error - server likely offline or mcstatus.io unavailable
    if (error instanceof Error && error.name === "AbortError") {
      console.log(`[Minecraft] mcstatus.io timeout for ${serverAddress}`);
    } else {
      console.log(`[Minecraft] Error fetching status:`, error);
    }
    return offlineStatus;
  }
}
