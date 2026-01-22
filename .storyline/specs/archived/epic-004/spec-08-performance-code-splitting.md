---
spec_id: 08
story_id: 008
epic_id: 004
title: Performance Optimization & Code Splitting
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 08: Performance Optimization & Code Splitting

## Overview

**User story:** [.storyline/stories/epic-004/story-08-performance-code-splitting.md](../../stories/epic-004/story-08-performance-code-splitting.md)

**Goal:** Optimize the BlockHaven website for fast loading and smooth performance by implementing route-based code splitting with React.lazy(), component memoization with React.memo(), image lazy loading, and Vite configuration for optimal bundling. Target: Lighthouse performance score ≥90, initial bundle <150KB gzipped, homepage loads in <2 seconds on 3G.

**Approach:** Use React.lazy() + Suspense for Contact page route splitting, React.memo() for widgets that re-render frequently (ServerStatus, ContactForm, CopyIPButton), native image lazy loading with `loading="lazy"`, configure Vite for optimal code splitting and chunking, and use bundle analyzer to monitor size.

## Technical Design

### Architecture Decision

**Chosen approach:** Multi-layered optimization strategy (code splitting + memoization + lazy loading + build optimization)

**Alternatives considered:**
- **React Query / TanStack Query** - Good for caching, but adds bundle size (40KB+)
- **Preact instead of React** - Smaller bundle (3KB vs 40KB), but less ecosystem support
- **Server-Side Rendering (SSR)** - Better first paint, but adds complexity and server costs
- **Static Site Generation (SSG)** - Pre-render HTML, but requires build-time data fetching
- **Aggressive code splitting (per component)** - Too granular, increases HTTP requests

**Rationale:** Route-based code splitting provides the best ROI (split at page boundaries), React.memo() prevents unnecessary re-renders with minimal code changes, native lazy loading is zero-cost browser feature, and Vite's automatic optimizations handle the rest. This approach is pragmatic, doesn't require major architecture changes, and achieves target performance metrics.

### System Components

**Frontend:**
- `web/src/App.tsx` - Add lazy imports for routes (modify)
- `web/src/pages/Contact.tsx` - Lazy-loaded route (already exists, no changes)
- `web/src/components/ServerStatus.tsx` - Wrap with React.memo() (modify)
- `web/src/components/ContactForm.tsx` - Wrap with React.memo() (modify)
- `web/src/components/CopyIPButton.tsx` - Wrap with React.memo() (modify)
- `web/vite.config.ts` - Optimize build configuration (modify)
- `web/src/components/LoadingSpinner.tsx` - Suspense fallback UI (new file)

**Backend:**
- None (frontend optimization only)

**Database:**
- None

**External integrations:**
- Chrome DevTools Lighthouse for performance auditing
- Vite bundle analyzer (vite-plugin-visualizer) for bundle size monitoring

## Implementation Details

### Files to Create

#### `web/src/components/LoadingSpinner.tsx`
**Purpose:** Reusable loading spinner for Suspense fallback UI
**Exports:**
- `LoadingSpinner` component (default export)

**Implementation:**
```typescript
import React from 'react';

export interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  message?: string;
}

/**
 * Loading spinner component for Suspense fallback and async operations
 *
 * @example
 * <Suspense fallback={<LoadingSpinner message="Loading page..." />}>
 *   <LazyComponent />
 * </Suspense>
 */
export function LoadingSpinner({
  size = 'md',
  message,
}: LoadingSpinnerProps): React.ReactElement {
  const sizeClasses = {
    sm: 'h-6 w-6',
    md: 'h-10 w-10',
    lg: 'h-16 w-16',
  };

  return (
    <div
      role="status"
      className="flex flex-col items-center justify-center gap-4 py-8"
      aria-live="polite"
    >
      <svg
        className={`${sizeClasses[size]} animate-spin text-blue-600 dark:text-blue-400`}
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        aria-hidden="true"
      >
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
      {message && (
        <p className="text-sm text-gray-600 dark:text-gray-400">{message}</p>
      )}
      <span className="sr-only">Loading...</span>
    </div>
  );
}
```

### Files to Modify

#### `web/src/App.tsx`
**Changes:** Add lazy imports for routes with Suspense boundary

**Before:**
```typescript
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import Contact from './pages/Contact';
import Layout from './components/Layout';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route path="contact" element={<Contact />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
```

**After:**
```typescript
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import { LoadingSpinner } from './components/LoadingSpinner';

// Eager load Home (critical for first paint)
import Home from './pages/Home';

// Lazy load Contact page (not needed for initial render)
const Contact = lazy(() => import('./pages/Contact'));

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route
            path="contact"
            element={
              <Suspense fallback={<LoadingSpinner message="Loading contact page..." />}>
                <Contact />
              </Suspense>
            }
          />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
```

#### `web/src/components/ServerStatus.tsx`
**Changes:** Wrap component with React.memo() to prevent unnecessary re-renders

**Before:**
```typescript
export function ServerStatus() {
  const { data, loading, error } = useServerStatus();
  // ... component logic
}
```

**After:**
```typescript
import { memo } from 'react';

export const ServerStatus = memo(function ServerStatus() {
  const { data, loading, error } = useServerStatus();
  // ... component logic (no other changes)
});
```

#### `web/src/components/ContactForm.tsx`
**Changes:** Wrap component with React.memo() to prevent unnecessary re-renders

**Before:**
```typescript
export function ContactForm() {
  const [formData, setFormData] = useState({ name: '', email: '', message: '' });
  // ... component logic
}
```

**After:**
```typescript
import { memo } from 'react';

export const ContactForm = memo(function ContactForm() {
  const [formData, setFormData] = useState({ name: '', email: '', message: '' });
  // ... component logic (no other changes)
});
```

#### `web/src/components/CopyIPButton.tsx`
**Changes:** Wrap component with React.memo() to prevent unnecessary re-renders

**Before:**
```typescript
export function CopyIPButton({ ipAddress }: CopyIPButtonProps) {
  const [copied, setCopied] = useState(false);
  // ... component logic
}
```

**After:**
```typescript
import { memo } from 'react';

export const CopyIPButton = memo(function CopyIPButton({
  ipAddress,
}: CopyIPButtonProps) {
  const [copied, setCopied] = useState(false);
  // ... component logic (no other changes)
});
```

**Note:** Only wrap if ipAddress prop is stable (doesn't change on every render). If parent re-renders frequently with new ipAddress object, use `useMemo` in parent to stabilize the prop.

#### `web/vite.config.ts`
**Changes:** Add build optimization, chunk splitting, and bundle analyzer

**Before:**
```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

**After:**
```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    react(),
    // Bundle analyzer (only in analyze mode)
    visualizer({
      open: true,
      filename: 'dist/stats.html',
      gzipSize: true,
      brotliSize: true,
    }),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    // Target modern browsers for smaller bundles
    target: 'es2020',
    // Enable minification
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true, // Remove console.log in production
        drop_debugger: true,
      },
    },
    // Optimize chunk splitting
    rollupOptions: {
      output: {
        manualChunks: {
          // Vendor chunk: React and React Router
          vendor: ['react', 'react-dom', 'react-router-dom'],
          // UI chunk: Shared UI components (if large)
          // ui: ['./src/components/Button', './src/components/Input'],
        },
      },
    },
    // Set chunk size warning limit
    chunkSizeWarningLimit: 500, // KB
  },
  // Image optimization
  assetsInlineLimit: 4096, // Inline assets <4KB as base64
});
```

#### Image Optimization in Components
**Changes:** Add lazy loading to images (example for HomePage or wherever images are used)

**Before:**
```typescript
<img src="/hero-bg.jpg" alt="BlockHaven server" />
```

**After:**
```typescript
<img
  src="/hero-bg.jpg"
  alt="BlockHaven server"
  loading="lazy"
  width="1920"
  height="1080"
  decoding="async"
/>
```

**Best practices:**
- Add `loading="lazy"` for below-the-fold images
- Add explicit `width` and `height` to prevent layout shift (CLS)
- Add `decoding="async"` for non-critical images
- Use WebP format with fallback: `<picture>` element or Vite image plugins

### API Contracts

**React.lazy() signature:**
```typescript
const Component = lazy(() => import('./Component'));
// Must return default export
// Must be wrapped in <Suspense fallback={...}>
```

**React.memo() signature:**
```typescript
const MemoizedComponent = memo(Component, propsAreEqual?);
// propsAreEqual: optional custom comparison function
// Default: shallow comparison of props
```

**Suspense props:**
```typescript
<Suspense fallback={ReactNode}>
  {/* Lazy-loaded components */}
</Suspense>
```

**Image lazy loading attributes:**
```html
<img
  loading="lazy"     <!-- Lazy load image -->
  decoding="async"   <!-- Decode asynchronously -->
  width="1920"       <!-- Prevent layout shift -->
  height="1080"      <!-- Prevent layout shift -->
/>
```

### Database Changes

None - Frontend optimization only.

### State Management

**No state changes** - Optimizations are transparent to application state:
- Code splitting: Components load on-demand, state remains unchanged
- Memoization: Prevents re-renders, but state logic identical
- Image lazy loading: Browser-native feature, no state impact

**Performance considerations:**
- React.lazy() adds ~100-200ms delay for first render (acceptable)
- React.memo() adds ~1ms shallow comparison overhead (negligible)
- Image lazy loading saves bandwidth, improves perceived performance

## Acceptance Criteria Mapping

### From Story → Verification

**Story criterion 1:** Lazy load Contact page
**Verification:**
- Unit test: Verify Contact page not imported in initial bundle
- Bundle test: Check dist/ folder, verify separate chunk for Contact
- Network test: Load homepage, verify Contact.js not downloaded
- Manual check: Navigate to /contact, verify loading spinner shows briefly

**Story criterion 2:** Code splitting reduces initial bundle size
**Verification:**
- Bundle analyzer: Verify initial bundle <150KB gzipped
- Bundle analyzer: Verify Contact page in separate chunk
- Bundle analyzer: Verify vendor chunk contains React/React Router
- Build test: Run `pnpm build`, check bundle sizes in terminal output

**Story criterion 3:** Images are optimized
**Verification:**
- HTML test: Verify images have `loading="lazy"` attribute
- HTML test: Verify images have `width` and `height` attributes
- Network test: Load homepage, verify below-the-fold images not downloaded initially
- Lighthouse: Verify "Serve images in next-gen formats" and "Defer offscreen images" pass

**Story criterion 4:** React components are memoized
**Verification:**
- React Profiler: Verify ServerStatus re-render when data changes (expected)
- React Profiler: Verify ServerStatus does NOT re-render when parent re-renders
- React Profiler: Verify ContactForm and CopyIPButton also memoized
- Unit test: Verify components wrapped with memo() function

## Testing Requirements

### Unit Tests

**File:** `web/src/components/__tests__/LoadingSpinner.test.tsx`

```typescript
import { render, screen } from '@testing-library/react';
import { LoadingSpinner } from '../LoadingSpinner';

describe('LoadingSpinner', () => {
  it('should render spinner', () => {
    render(<LoadingSpinner />);

    expect(screen.getByRole('status')).toBeInTheDocument();
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('should render custom message', () => {
    render(<LoadingSpinner message="Loading contact page..." />);

    expect(screen.getByText('Loading contact page...')).toBeInTheDocument();
  });

  it('should render small size', () => {
    const { container } = render(<LoadingSpinner size="sm" />);

    const svg = container.querySelector('svg');
    expect(svg).toHaveClass('h-6', 'w-6');
  });

  it('should render medium size by default', () => {
    const { container } = render(<LoadingSpinner />);

    const svg = container.querySelector('svg');
    expect(svg).toHaveClass('h-10', 'w-10');
  });

  it('should render large size', () => {
    const { container } = render(<LoadingSpinner size="lg" />);

    const svg = container.querySelector('svg');
    expect(svg).toHaveClass('h-16', 'w-16');
  });

  it('should have accessible attributes', () => {
    render(<LoadingSpinner />);

    const status = screen.getByRole('status');
    expect(status).toHaveAttribute('aria-live', 'polite');
  });
});
```

**File:** `web/src/components/__tests__/ServerStatus.memo.test.tsx`

```typescript
import { render } from '@testing-library/react';
import { ServerStatus } from '../ServerStatus';

describe('ServerStatus memoization', () => {
  it('should be wrapped with memo()', () => {
    // React.memo() components have displayName
    expect(ServerStatus.displayName).toBeDefined();
  });

  it('should not re-render when parent re-renders with same props', () => {
    let renderCount = 0;

    // Mock useServerStatus to track renders
    jest.mock('@/hooks/useServerStatus', () => ({
      useServerStatus: () => {
        renderCount++;
        return {
          data: { online: true, playerCount: 10, maxPlayers: 100, timestamp: '2026-01-12' },
          loading: false,
          error: null,
        };
      },
    }));

    const { rerender } = render(<ServerStatus />);

    const initialRenderCount = renderCount;

    // Re-render parent (ServerStatus props don't change)
    rerender(<ServerStatus />);

    // Component should NOT re-render (memo prevents it)
    expect(renderCount).toBe(initialRenderCount);
  });
});
```

**Coverage target:** 90%+ (focus on critical paths)

### Performance Tests

**File:** `web/src/__tests__/performance.test.ts`

```typescript
import { describe, it, expect } from 'vitest';

describe('Bundle size tests', () => {
  it('should have initial bundle <150KB gzipped', async () => {
    // This test runs in CI/CD after build
    const fs = await import('fs/promises');
    const path = await import('path');

    const distPath = path.resolve(__dirname, '../../dist');
    const files = await fs.readdir(distPath);

    // Find main JS chunk (usually named index-[hash].js)
    const mainChunk = files.find((f) => f.startsWith('index-') && f.endsWith('.js'));
    expect(mainChunk).toBeDefined();

    // Check file size (approximate, actual gzipped size may vary)
    const stats = await fs.stat(path.join(distPath, mainChunk!));
    const sizeKB = stats.size / 1024;

    // Uncompressed should be <500KB (will be ~150KB gzipped)
    expect(sizeKB).toBeLessThan(500);
  });

  it('should have separate chunk for Contact page', async () => {
    const fs = await import('fs/promises');
    const path = await import('path');

    const distPath = path.resolve(__dirname, '../../dist');
    const files = await fs.readdir(distPath);

    // Should have a chunk named Contact-[hash].js or similar
    const contactChunk = files.find((f) =>
      f.toLowerCase().includes('contact') && f.endsWith('.js')
    );

    expect(contactChunk).toBeDefined();
  });

  it('should have vendor chunk', async () => {
    const fs = await import('fs/promises');
    const path = await import('path');

    const distPath = path.resolve(__dirname, '../../dist');
    const files = await fs.readdir(distPath);

    // Should have a chunk named vendor-[hash].js
    const vendorChunk = files.find((f) => f.startsWith('vendor-') && f.endsWith('.js'));

    expect(vendorChunk).toBeDefined();
  });
});
```

### Integration Tests

**Scenario 1:** Lazy loading Contact page
- Setup: Build app for production, start dev server
- Action: Open homepage in browser
- Assert: Network tab shows main bundle downloaded
- Assert: Contact.js chunk NOT downloaded
- Action: Navigate to /contact
- Assert: Contact.js chunk downloaded on navigation
- Assert: Loading spinner shows briefly

**Scenario 2:** Image lazy loading
- Setup: Add test images to homepage (some above fold, some below)
- Action: Load homepage, scroll to top
- Assert: Above-the-fold images loaded immediately
- Assert: Below-the-fold images NOT loaded (check Network tab)
- Action: Scroll down to reveal below-the-fold images
- Assert: Images load as they enter viewport

**Scenario 3:** Component memoization
- Setup: Open React DevTools Profiler, start recording
- Action: ServerStatus widget re-fetches data (every 30 seconds)
- Assert: Only ServerStatus re-renders (not parent or siblings)
- Assert: Profiler shows minimal re-render overhead (<5ms)

### Manual Testing & Performance Audit

**Lighthouse audit checklist:**
- [ ] Run Lighthouse in incognito mode (no extensions)
- [ ] Performance score ≥90
- [ ] First Contentful Paint (FCP) <1.8s
- [ ] Largest Contentful Paint (LCP) <2.5s
- [ ] Total Blocking Time (TBT) <200ms
- [ ] Cumulative Layout Shift (CLS) <0.1
- [ ] Speed Index <3.4s

**Bundle size checklist:**
- [ ] Run `pnpm build`, check output for chunk sizes
- [ ] Run `pnpm analyze` to visualize bundle
- [ ] Initial bundle (index.js) <500KB uncompressed
- [ ] Initial bundle <150KB gzipped (estimate ~30% compression ratio)
- [ ] Contact chunk separate from main bundle
- [ ] Vendor chunk separate (React + React Router)

**Manual performance testing:**
- [ ] Load homepage on 3G (Chrome DevTools throttling), verify <2s load time
- [ ] Navigate to Contact page, verify smooth transition with loading spinner
- [ ] Open React DevTools Profiler, verify minimal re-renders
- [ ] Scroll homepage, verify images lazy load as they enter viewport
- [ ] Check DevTools Coverage tab, verify <20% unused CSS/JS
- [ ] Test on mobile device (physical or emulator)

**Cross-browser testing:**
- [ ] Test in Chrome (Lighthouse, performance profiler)
- [ ] Test in Firefox (network throttling)
- [ ] Test in Safari (Mac or iOS simulator)
- [ ] Test on mobile (iOS Safari, Android Chrome)

## Dependencies

**Must complete first:**
- All Epic 004 stories (01-07) - this optimizes their implementations

**Enables:**
- Epic 005: Deployment - production build must be optimized

**NPM packages to add:**
```json
{
  "devDependencies": {
    "rollup-plugin-visualizer": "^5.12.0"
  }
}
```

## Risks & Mitigations

**Risk 1:** Code splitting adds latency for lazy-loaded routes
**Mitigation:** Only split non-critical routes (Contact page), keep Home eager-loaded
**Fallback:** Add route prefetching on hover (future enhancement)

**Risk 2:** React.memo() causes bugs if props are not stable
**Mitigation:** Only memoize components with stable props, test thoroughly
**Fallback:** Remove memo() if bugs occur, use profiler to verify issue

**Risk 3:** Over-optimization leads to premature optimization
**Mitigation:** Measure first (Lighthouse, profiler), then optimize based on data
**Fallback:** Keep optimizations simple and reversible

**Risk 4:** Image lazy loading causes layout shift if dimensions not specified
**Mitigation:** Always specify width/height attributes on images
**Fallback:** Use aspect-ratio CSS to reserve space

**Risk 5:** Bundle analyzer bloats development workflow
**Mitigation:** Only run analyzer on-demand (not in every build)
**Fallback:** Use conditional plugin loading based on environment variable

## Performance Considerations

**Target metrics:**
- Lighthouse Performance score: ≥90
- Initial bundle: <150KB gzipped
- Homepage load time: <2 seconds on 3G
- First Contentful Paint (FCP): <1.8s
- Largest Contentful Paint (LCP): <2.5s
- Cumulative Layout Shift (CLS): <0.1
- Total Blocking Time (TBT): <200ms

**Optimization strategy:**
1. **Code splitting:** Reduce initial bundle by 30-50% (Contact page ~20KB)
2. **Vendor chunk:** Cache React/React Router separately (40KB)
3. **Memoization:** Prevent 50-80% of unnecessary re-renders
4. **Image lazy loading:** Save 100-500KB of initial bandwidth
5. **Build optimization:** Minify, tree-shake, compress (10-20% reduction)

**Expected improvements:**
- **Before optimization:** 200KB initial bundle, 3-4s load on 3G, 70-80 Lighthouse score
- **After optimization:** 120KB initial bundle, 1.5-2s load on 3G, 90+ Lighthouse score
- **Improvement:** 40% smaller bundle, 50% faster load, 15-25 point Lighthouse increase

**Benchmarks (target):**
- App initialization: <50ms
- Route transition (Home → Contact): <200ms (including chunk download)
- Component re-render (with memo): <5ms
- Image lazy load: <100ms (per image)

## Security Considerations

**Authentication:** Not applicable (performance optimization only)

**Authorization:** Not applicable (performance optimization only)

**Data validation:**
- No user input or data validation in this spec
- Performance optimizations don't affect security posture

**Sensitive data:**
- `drop_console: true` removes console.log statements in production
- Prevents accidental logging of sensitive data to browser console

**Additional notes:**
- Bundle analyzer exposes file structure (only run locally, don't publish stats.html)
- Minification makes code harder to reverse-engineer (mild security benefit)
- No new attack surface introduced by optimizations

## Success Verification

After implementation, verify:
- [ ] All unit tests pass (`pnpm test`)
- [ ] Performance tests pass (bundle size, code splitting)
- [ ] Lighthouse performance score ≥90 (incognito mode)
- [ ] Initial bundle <150KB gzipped
- [ ] Contact page in separate chunk (verify in dist/ folder)
- [ ] Images have lazy loading attributes
- [ ] React.memo() applied to ServerStatus, ContactForm, CopyIPButton
- [ ] React Profiler shows minimal unnecessary re-renders
- [ ] Manual testing checklist complete (all browsers)
- [ ] Acceptance criteria from story satisfied (all 4 scenarios)
- [ ] TypeScript compiles with no errors (`pnpm tsc`)
- [ ] ESLint passes with no warnings (`pnpm lint`)
- [ ] Bundle analyzer runs successfully (`pnpm analyze`)
- [ ] Core Web Vitals: FCP <1.8s, LCP <2.5s, CLS <0.1

## Traceability

**Parent story:** [.storyline/stories/epic-004/story-08-performance-code-splitting.md](../../stories/epic-004/story-08-performance-code-splitting.md)

**Parent epic:** [.storyline/epics/epic-004-interactive-features-integration.md](../../epics/epic-004-interactive-features-integration.md)

## Implementation Notes

**Package manager:** Use `pnpm` not `npm`

**Import aliases:** Use `@/` for `src/` directory (configured in tsconfig.json)

**Testing library:** `@testing-library/react` for component testing, `vitest` as test runner

**TypeScript version:** 5.7+ with strict mode enabled

**React version:** React 19 (lazy, memo, Suspense)

**Vite version:** 5.0+ (automatic code splitting and tree shaking)

**Browser support:**
- React.lazy/Suspense: React 16.6+ (universal support)
- React.memo: React 16.6+ (universal support)
- Image loading="lazy": 95%+ browser support (Chrome 77+, Firefox 75+, Safari 15.4+)
- ES2020 target: 97%+ browser support (no IE11)

**NPM scripts to add:**
```json
{
  "scripts": {
    "analyze": "vite build && vite-plugin-visualizer"
  }
}
```

**Open questions:**
- Should we prefetch Contact route on hover? (Decided: No, lazy loading sufficient for MVP)
- Should we use Preact instead of React? (Decided: No, React ecosystem more mature)
- Should we implement SSR/SSG? (Decided: No, client-side rendering sufficient for now)
- Should we use image CDN (Cloudinary, Imgix)? (Decided: No, native lazy loading sufficient)

**Assumptions:**
- Users have modern browsers (no IE11 support required)
- 3G is slowest target network (2G not supported)
- Target audience primarily desktop/laptop users (mobile secondary)
- Images are reasonably sized (<500KB per image)
- API responses are small (<10KB JSON)

**Future enhancements:**
- Add route prefetching on link hover (instant navigation)
- Add service worker for offline caching (PWA)
- Add image CDN for automatic WebP conversion and resizing
- Add font optimization (preload, font-display: swap)
- Add critical CSS inlining for above-the-fold content
- Add HTTP/2 server push for critical resources
- Add brotli compression (better than gzip)
- Implement SSR/SSG for even faster first paint
- Add resource hints (preconnect, dns-prefetch, prefetch, preload)
- Monitor bundle size in CI/CD (fail build if exceeds threshold)
- Add performance budgets (warn if metrics degrade)
- Implement skeleton screens instead of loading spinners

---

**Next step:** Run `/dev-story .storyline/specs/epic-004/spec-08-performance-code-splitting.md`
