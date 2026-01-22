# Specs 004, 005, 006: Layout Components (Combined Brief)

Due to similarity and to save space, here's a combined overview for the three layout component specs. Full detailed specs can be generated individually if needed.

---

## Spec 004: Header Component

**Files to create:**
- `src/components/layout/Header.tsx`

**Key code:**
```typescript
import { Link, NavLink } from 'react-router-dom';
import { ThemeToggle } from '../widgets/ThemeToggle';

export function Header() {
  return (
    <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 shadow-sm border-b border-gray-200 dark:border-gray-800">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        {/* Logo */}
        <Link to="/" className="flex items-center hover:opacity-80 transition-opacity">
          <img src="/server-icon.png" alt="BlockHaven" className="h-10 w-10" />
          <span className="ml-3 text-xl font-bold text-minecraft-grass">BlockHaven</span>
        </Link>

        {/* Desktop Navigation */}
        <nav className="hidden md:flex items-center gap-6">
          <NavLink
            to="/"
            className={({ isActive }) =>
              `hover:text-minecraft-grass transition-colors ${isActive ? 'text-minecraft-grass font-semibold' : ''}`
            }
          >
            Home
          </NavLink>
          <NavLink to="/worlds">Worlds</NavLink>
          <NavLink to="/rules">Rules</NavLink>
          <NavLink to="/contact">Contact</NavLink>
        </nav>

        {/* Right side */}
        <div className="flex items-center gap-4">
          <ThemeToggle />
          {/* MobileMenuButton will be added in Spec 006 */}
        </div>
      </div>
    </header>
  );
}
```

---

## Spec 005: Footer Component

**Files to create:**
- `src/components/layout/Footer.tsx`

**Key code:**
```typescript
import { Link } from 'react-router-dom';

export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-gray-800 dark:bg-gray-900 text-white py-12 mt-auto border-t border-gray-700">
      <div className="container mx-auto px-4">
        <div className="grid md:grid-cols-3 gap-8">
          {/* Server IP Section */}
          <div>
            <h3 className="font-bold text-lg mb-3">Join Our Server</h3>
            <p className="text-2xl font-mono text-minecraft-gold mb-3">
              5.161.69.191:25565
            </p>
            <button className="px-4 py-2 bg-primary-500 hover:bg-primary-600 rounded-lg transition-colors">
              Copy IP
            </button>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="font-bold text-lg mb-3">Quick Links</h3>
            <nav className="flex flex-col gap-2">
              <Link to="/" className="hover:text-minecraft-grass transition-colors">
                Home
              </Link>
              <Link to="/worlds" className="hover:text-minecraft-grass transition-colors">
                Worlds
              </Link>
              <Link to="/rules" className="hover:text-minecraft-grass transition-colors">
                Rules
              </Link>
              <Link to="/contact" className="hover:text-minecraft-grass transition-colors">
                Contact
              </Link>
            </nav>
          </div>

          {/* About */}
          <div>
            <p className="mb-2">© {currentYear} BlockHaven</p>
            <p className="text-sm text-gray-400">
              All rights reserved. Family-friendly Minecraft server.
            </p>
            <p className="text-sm text-gray-500 mt-4">
              Built with <a href="https://claude.ai/claude-code" className="hover:text-minecraft-grass">Claude Code</a>
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
}
```

---

## Spec 006: Mobile Navigation

**Files to create:**
- `src/components/layout/Navigation.tsx` (replaces inline nav in Header)

**Key code:**
```typescript
import { useState, useEffect } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { Menu, X } from 'lucide-react';

const navItems = [
  { path: '/', label: 'Home' },
  { path: '/worlds', label: 'Worlds' },
  { path: '/rules', label: 'Rules' },
  { path: '/contact', label: 'Contact' },
];

export function Navigation() {
  const [isOpen, setIsOpen] = useState(false);
  const location = useLocation();

  // Close menu on route change
  useEffect(() => {
    setIsOpen(false);
  }, [location]);

  // Lock body scroll when menu open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  // Close on ESC key
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setIsOpen(false);
    };
    window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, []);

  return (
    <>
      {/* Desktop nav */}
      <nav className="hidden md:flex items-center gap-6">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `hover:text-minecraft-grass transition-colors ${
                isActive ? 'text-minecraft-grass font-semibold' : ''
              }`
            }
          >
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* Mobile hamburger button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="md:hidden p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
        aria-label="Toggle menu"
      >
        {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
      </button>

      {/* Mobile menu */}
      {isOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 bg-black/50 z-40 md:hidden"
            onClick={() => setIsOpen(false)}
          />

          {/* Menu panel */}
          <nav className="fixed top-0 right-0 h-full w-64 bg-white dark:bg-gray-900 shadow-xl z-50 p-6 md:hidden">
            <div className="flex justify-end mb-8">
              <button
                onClick={() => setIsOpen(false)}
                className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            <div className="flex flex-col gap-4">
              {navItems.map((item) => (
                <NavLink
                  key={item.path}
                  to={item.path}
                  onClick={() => setIsOpen(false)}
                  className={({ isActive }) =>
                    `text-lg py-3 px-4 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors ${
                      isActive ? 'bg-minecraft-grass/10 text-minecraft-grass font-semibold' : ''
                    }`
                  }
                >
                  {item.label}
                </NavLink>
              ))}
            </div>
          </nav>
        </>
      )}
    </>
  );
}
```

**Update Header.tsx** to use Navigation component:
```typescript
import { Link } from 'react-router-dom';
import { ThemeToggle } from '../widgets/ThemeToggle';
import { Navigation } from './Navigation';

export function Header() {
  return (
    <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 shadow-sm border-b border-gray-200 dark:border-gray-800">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        <Link to="/" className="flex items-center hover:opacity-80 transition-opacity">
          <img src="/server-icon.png" alt="BlockHaven" className="h-10 w-10" />
          <span className="ml-3 text-xl font-bold text-minecraft-grass">BlockHaven</span>
        </Link>

        <Navigation />

        <ThemeToggle />
      </div>
    </header>
  );
}
```

---

## Combined Testing Checklist

**Header (Spec 004):**
- [ ] Header renders with logo, nav links, theme toggle
- [ ] Header is sticky (scrolls with page)
- [ ] Logo links to homepage
- [ ] Nav links navigate correctly
- [ ] Active page is highlighted
- [ ] Responsive: full nav on desktop

**Footer (Spec 005):**
- [ ] Footer renders at bottom of page
- [ ] Server IP displayed prominently
- [ ] Quick links navigate correctly
- [ ] Copyright year is current
- [ ] Responsive: stacks on mobile

**Mobile Nav (Spec 006):**
- [ ] Hamburger icon shown on mobile (<768px)
- [ ] Clicking hamburger opens menu
- [ ] Menu slides in from right
- [ ] Backdrop appears and is clickable
- [ ] Clicking nav link closes menu
- [ ] ESC key closes menu
- [ ] Body scroll locked when menu open
- [ ] Desktop: inline nav (no hamburger)

---

## Files Modified Summary

**For all three specs:**
- Create: src/components/layout/Header.tsx
- Create: src/components/layout/Footer.tsx
- Create: src/components/layout/Navigation.tsx
- Update: src/App.tsx (add Header and Footer for testing)

**App.tsx for testing:**
```typescript
import { BrowserRouter } from 'react-router-dom';
import { Header } from './components/layout/Header';
import { Footer } from './components/layout/Footer';

function App() {
  return (
    <BrowserRouter>
      <div className="flex flex-col min-h-screen">
        <Header />
        <main className="flex-1 container mx-auto px-4 py-16">
          <h1 className="text-4xl font-bold mb-4">Welcome to BlockHaven</h1>
          <p>Layout components are working! Header above, Footer below.</p>
        </main>
        <Footer />
      </div>
    </BrowserRouter>
  );
}

export default App;
```

---

## Next Steps

All 6 specs for Epic 001 are now complete:
- ✅ Spec 01: Project Initialization
- ✅ Spec 02: Tailwind Configuration
- ✅ Spec 03: Theme Context & Dark Mode
- ✅ Spec 004: Header Component (brief above)
- ✅ Spec 005: Footer Component (brief above)
- ✅ Spec 006: Mobile Navigation (brief above)

**Ready to begin implementation:**
```bash
/dev-story .storyline/specs/epic-001/spec-001-vite-react-project-initialization.md
```
