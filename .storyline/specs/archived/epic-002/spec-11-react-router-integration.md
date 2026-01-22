---
spec_id: 11
story_id: 11
epic_id: 002
title: React Router Integration
status: ready_for_implementation
created: 2026-01-12
---

# Technical Spec 11: React Router Integration

## Overview
Integrate React Router with all pages and update App structure.

## Files to Modify
```
src/App.tsx
src/main.tsx
```

## Implementation

### App.tsx
```typescript
import { Routes, Route } from 'react-router-dom';
import { Header, Footer } from '@/components/layout';
import { Home, Worlds, Rules, Contact } from '@/pages';

function App() {
  return (
    <div className="flex flex-col min-h-screen">
      <Header />
      <main className="flex-1">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/worlds" element={<Worlds />} />
          <Route path="/rules" element={<Rules />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="*" element={<Home />} /> {/* 404 redirect to home */}
        </Routes>
      </main>
      <Footer />
    </div>
  );
}

export default App;
```

### main.tsx (update)
```typescript
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { HelmetProvider } from 'react-helmet-async';
import './styles/index.css';
import App from './App.tsx';
import { ThemeProvider } from './contexts/ThemeContext';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <HelmetProvider>
        <ThemeProvider>
          <App />
        </ThemeProvider>
      </HelmetProvider>
    </BrowserRouter>
  </StrictMode>
);
```

### pages/index.ts (create barrel export)
```typescript
export { Home } from './Home';
export { Worlds } from './Worlds';
export { Rules } from './Rules';
export { Contact } from './Contact';
```

## Dependencies
**Depends on:** All previous specs (all pages must exist)
**Note:** react-router-dom should already be installed from Epic 001

---

**Next:** `/dev-story .storyline/specs/epic-002/spec-11-react-router-integration.md`
