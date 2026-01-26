// src/components/admin/QuickActions.tsx
// Quick actions panel for common server commands

import { useState } from "react";

interface QuickActionsProps {
  serverState: string | null;
}

interface Command {
  id: string;
  name: string;
  command: string;
  description: string;
  requiresArg: boolean;
  argPlaceholder?: string;
  argPattern?: RegExp;
}

const COMMANDS: Command[] = [
  {
    id: "whitelist-list",
    name: "View Whitelist",
    command: "whitelist list",
    description: "Show all whitelisted players",
    requiresArg: false,
  },
  {
    id: "whitelist-add",
    name: "Whitelist Add",
    command: "whitelist add",
    description: "Add a player to the whitelist",
    requiresArg: true,
    argPlaceholder: "Minecraft username",
    argPattern: /^[a-zA-Z0-9_]{3,16}$/,
  },
  {
    id: "whitelist-remove",
    name: "Whitelist Remove",
    command: "whitelist remove",
    description: "Remove a player from the whitelist",
    requiresArg: true,
    argPlaceholder: "Minecraft username",
    argPattern: /^[a-zA-Z0-9_]{3,16}$/,
  },
  {
    id: "list",
    name: "Online Players",
    command: "list",
    description: "Show currently online players",
    requiresArg: false,
  },
  {
    id: "save-all",
    name: "Save World",
    command: "save-all",
    description: "Force save all worlds",
    requiresArg: false,
  },
  {
    id: "say",
    name: "Broadcast Message",
    command: "say",
    description: "Send a message to all players",
    requiresArg: true,
    argPlaceholder: "Message to broadcast",
    argPattern: /^[a-zA-Z0-9_ !?.,'"-]{1,100}$/,
  },
];

export function QuickActions({ serverState }: QuickActionsProps) {
  const [selectedCommand, setSelectedCommand] = useState<Command | null>(null);
  const [args, setArgs] = useState("");
  const [output, setOutput] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const isServerRunning = serverState === "running";

  const isValidArg = !selectedCommand?.requiresArg ||
    (args && selectedCommand.argPattern?.test(args));

  const canExecute = isServerRunning && selectedCommand && isValidArg && !loading;

  const handleExecute = async () => {
    if (!selectedCommand || !canExecute) return;

    setLoading(true);
    setOutput(null);
    setError(null);

    try {
      const response = await fetch("/api/admin/rcon", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          command: selectedCommand.command,
          args: selectedCommand.requiresArg ? args : undefined,
        }),
      });

      const data = await response.json();

      if (data.success) {
        setOutput(data.output);
        // Clear args after successful execution (for add/remove commands)
        if (selectedCommand.id.includes("add") || selectedCommand.id.includes("remove")) {
          setArgs("");
        }
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError("Failed to execute command");
    } finally {
      setLoading(false);
    }
  };

  const handleCommandChange = (commandId: string) => {
    const cmd = COMMANDS.find((c) => c.id === commandId);
    setSelectedCommand(cmd || null);
    setArgs("");
    setOutput(null);
    setError(null);
  };

  return (
    <div className="bg-secondary-stone/20 border border-secondary-stone/30 rounded-lg p-6">
      <h2 className="text-lg font-semibold text-text-light mb-4">Quick Actions</h2>

      {/* Server Offline Warning */}
      {!isServerRunning && (
        <div className="mb-4 p-3 bg-accent-gold/20 border border-accent-gold/40 rounded-lg">
          <p className="text-accent-gold text-sm">
            Server must be running to execute commands
          </p>
        </div>
      )}

      {/* Command Selection */}
      <div className="space-y-4">
        <select
          value={selectedCommand?.id || ""}
          onChange={(e) => handleCommandChange(e.target.value)}
          disabled={!isServerRunning}
          className="w-full px-4 py-3 bg-bg-dark text-text-light rounded-lg border border-secondary-stone/30 disabled:opacity-50"
        >
          <option value="">Select a command...</option>
          {COMMANDS.map((cmd) => (
            <option key={cmd.id} value={cmd.id}>
              {cmd.name}
            </option>
          ))}
        </select>

        {/* Command Description */}
        {selectedCommand && (
          <p className="text-sm text-text-muted">{selectedCommand.description}</p>
        )}

        {/* Argument Input */}
        {selectedCommand?.requiresArg && (
          <input
            type="text"
            placeholder={selectedCommand.argPlaceholder}
            value={args}
            onChange={(e) => setArgs(e.target.value)}
            disabled={!isServerRunning || loading}
            className="w-full px-4 py-3 bg-bg-dark text-text-light rounded-lg border border-secondary-stone/30 placeholder-text-muted disabled:opacity-50"
          />
        )}

        {/* Execute Button */}
        <button
          onClick={handleExecute}
          disabled={!canExecute}
          className="w-full px-4 py-3 bg-accent-diamond hover:bg-accent-diamond/80 text-white font-medium rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? "Executing..." : "Execute"}
        </button>
      </div>

      {/* Output Display */}
      {output && (
        <div className="mt-4 p-4 bg-gray-900 rounded-lg font-mono text-sm text-mc-green whitespace-pre-wrap">
          {output}
        </div>
      )}

      {/* Error Display */}
      {error && (
        <div className="mt-4 p-4 bg-accent-redstone/20 border border-accent-redstone/40 rounded-lg">
          <p className="text-accent-redstone text-sm">{error}</p>
        </div>
      )}
    </div>
  );
}
