// src/components/admin/ErrorBoundary.tsx
// React error boundary for graceful component failure handling

import { Component, type ErrorInfo, type ReactNode } from "react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  sectionName?: string;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error(
      `[ErrorBoundary] ${this.props.sectionName || "Component"} error:`,
      error
    );
    console.error("Component stack:", errorInfo.componentStack);
  }

  handleRetry = () => {
    this.setState({ hasError: false, error: undefined });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <div className="p-6 bg-accent-redstone/10 border border-accent-redstone/30 rounded-lg">
          <h3 className="text-accent-redstone font-semibold mb-2">
            {this.props.sectionName || "This section"} encountered an error
          </h3>
          <p className="text-text-muted text-sm mb-4">
            Something went wrong. Please try again or refresh the page.
          </p>
          <button
            onClick={this.handleRetry}
            className="px-4 py-2 bg-accent-redstone hover:bg-accent-redstone/80 text-white text-sm rounded-lg transition-colors"
          >
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
