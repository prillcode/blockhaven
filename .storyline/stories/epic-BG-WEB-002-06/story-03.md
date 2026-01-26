---
story_id: 03
epic_id: BG-WEB-002-06
identifier: BG-WEB-002
title: Create Error Boundary Components
status: ready_for_spec
parent_epic: ../../epics/epic-BG-WEB-002-06-polish-security.md
created: 2026-01-25
---

# Story 03: Create Error Boundary Components

## User Story

**As a** user,
**I want** component errors to be contained,
**so that** one failing component doesn't break the entire dashboard.

## Acceptance Criteria

### Scenario 1: Error boundary catches component errors
**Given** a component throws an error during render
**When** the error occurs
**Then** only that component shows an error state
**And** the rest of the dashboard continues working

### Scenario 2: Friendly error message
**Given** an error boundary catches an error
**When** the fallback UI renders
**Then** a user-friendly message is displayed
**And** the error message is not technical jargon

### Scenario 3: Retry functionality
**Given** an error boundary is showing an error
**When** I click "Try again"
**Then** the component attempts to re-render
**And** state is reset

### Scenario 4: Error logged
**Given** an error boundary catches an error
**When** the error is processed
**Then** the error is logged to console
**And** stack trace is available for debugging

### Scenario 5: Each dashboard section wrapped
**Given** the dashboard is rendered
**When** I inspect the component tree
**Then** ServerStatusCard has an error boundary
**And** ServerControls has an error boundary
**And** CostEstimator has an error boundary
**And** LogsViewer has an error boundary
**And** QuickActions has an error boundary

### Scenario 6: Styling matches theme
**Given** an error boundary is showing an error
**When** I view the fallback UI
**Then** it matches the dashboard theme
**And** doesn't look out of place

## Business Value

**Why this matters:** Error boundaries prevent cascading failures. A bug in one component shouldn't prevent the entire dashboard from being usable.

**Impact:** Improved reliability and user experience.

**Success metric:** Component errors don't crash the entire dashboard.

## Technical Considerations

**Error Boundary Component:**
```tsx
// src/components/admin/ErrorBoundary.tsx
import { Component, ErrorInfo, ReactNode } from "react"

interface Props {
  children: ReactNode
  fallback?: ReactNode
  sectionName?: string
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error(`[ErrorBoundary] ${this.props.sectionName || "Component"} error:`, error)
    console.error("Component stack:", errorInfo.componentStack)

    // Could send to error tracking service in production
    // logErrorToService(error, errorInfo)
  }

  handleRetry = () => {
    this.setState({ hasError: false, error: undefined })
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback
      }

      return (
        <div className="p-4 bg-red-900/20 border border-red-500/50 rounded-lg">
          <h3 className="text-red-400 font-medium mb-2">
            {this.props.sectionName || "This section"} encountered an error
          </h3>
          <p className="text-gray-400 text-sm mb-3">
            Something went wrong. Please try again or refresh the page.
          </p>
          <button
            onClick={this.handleRetry}
            className="px-4 py-2 bg-red-600 hover:bg-red-700 rounded text-sm"
          >
            Try again
          </button>
        </div>
      )
    }

    return this.props.children
  }
}
```

**Usage in Dashboard:**
```astro
---
// src/pages/dashboard.astro
---
<DashboardLayout>
  <div class="grid gap-6">
    <ErrorBoundary sectionName="Server Status" client:load>
      <ServerStatusCard client:load />
    </ErrorBoundary>

    <ErrorBoundary sectionName="Server Controls" client:load>
      <ServerControls client:load />
    </ErrorBoundary>

    <ErrorBoundary sectionName="Cost Estimation" client:load>
      <CostEstimator client:load />
    </ErrorBoundary>

    <ErrorBoundary sectionName="Server Logs" client:load>
      <LogsViewer client:load />
    </ErrorBoundary>

    <ErrorBoundary sectionName="Quick Actions" client:load>
      <QuickActions client:load />
    </ErrorBoundary>
  </div>
</DashboardLayout>
```

**Styling:**
- Red-tinted background for visibility
- Border to delineate the error area
- Clear "Try again" button
- Matches dark theme of dashboard

## Dependencies

**Depends on stories:**
- Epic 2-5: Dashboard components exist

**Enables stories:**
- Story 05: Security Audit (graceful error handling)

## Out of Scope

- Error tracking service integration
- Global error boundary
- Server-side error handling

## Notes

- Error boundaries only catch errors in children, not in event handlers
- Consider adding error tracking service for production (Sentry, etc.)
- The "Try again" button resets component state
- Each section should be independently recoverable

## Traceability

**Parent epic:** [epic-BG-WEB-002-06-polish-security.md](../../epics/epic-BG-WEB-002-06-polish-security.md)

**Related stories:** Epic 2-5 components

---

**Next step:** Run `/sl-spec-story .storyline/stories/epic-BG-WEB-002-06/story-03.md`
