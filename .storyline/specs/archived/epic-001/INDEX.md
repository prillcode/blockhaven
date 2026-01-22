# Epic 001: Technical Specifications Summary

**Epic:** Website Foundation & Theme System
**Generated:** 2026-01-10
**Total Specs:** 6 (2 complete, 4 pending detailed creation)

---

## Completed Specs

### ✅ Spec 01: Vite + React Project Initialization
**Status:** Complete and ready for implementation
**File:** .storyline/specs/epic-001/spec-01-vite-react-project-initialization.md
**Key deliverables:**
- Vite 6.0 + React 19 + TypeScript 5.7 project
- Complete directory structure
- All dependencies installed via pnpm

### ✅ Spec 02: Tailwind CSS Configuration
**Status:** Complete and ready for implementation
**File:** .storyline/specs/epic-001/spec-02-tailwind-css-minecraft-theme.md
**Key deliverables:**
- Tailwind CSS v4 with @tailwindcss/vite plugin
- Custom Minecraft color palette
- Class-based dark mode configuration

---

## Specs Needing Detailed Creation

Due to the comprehensive nature required, I recommend creating the remaining 4 specs individually. Here's a quick overview of what each needs:

### Spec 03: Theme Context & Dark Mode
**Story:** story-03-theme-context-dark-mode.md
**Files to create:**
- src/contexts/ThemeContext.tsx
- src/hooks/useTheme.ts
- src/components/widgets/ThemeToggle.tsx

**Key implementation details:**
- Theme type: 'light' | 'dark'
- localStorage key: 'blockhaven-theme'
- System preference detection via window.matchMedia
- Prevent FOUC by applying theme before React hydration
- Icons: Sun (lucide-react) for light, Moon for dark

**Critical logic:**
```typescript
const getInitialTheme = (): Theme => {
  // 1. Check localStorage first
  const stored = localStorage.getItem('blockhaven-theme');
  if (stored === 'light' || stored === 'dark') return stored;

  // 2. Fall back to system preference
  if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    return 'dark';
  }
  return 'light';
};
```

---

### Spec 004: Header Component
**Story:** story-04-header-component.md
**Files to create:**
- src/components/layout/Header.tsx

**Key implementation details:**
- Sticky positioning: position: sticky, top: 0
- Layout: Logo (left), Nav links (center), ThemeToggle (right)
- Uses React Router NavLink for active states
- Responsive: full nav on desktop, hamburger on mobile
- Z-index: z-50 to stay above content

**Component structure:**
```tsx
<header className="sticky top-0 z-50 bg-white dark:bg-gray-900 shadow-sm">
  <div className="container mx-auto px-4 py-4 flex items-center justify-between">
    <Link to="/">
      <img src="/server-icon.png" alt="BlockHaven" className="h-10" />
    </Link>

    <nav className="hidden md:flex gap-6">
      <NavLink to="/">Home</NavLink>
      <NavLink to="/worlds">Worlds</NavLink>
      <NavLink to="/rules">Rules</NavLink>
      <NavLink to="/contact">Contact</NavLink>
    </nav>

    <div className="flex items-center gap-4">
      <ThemeToggle />
      <MobileMenuButton className="md:hidden" />
    </div>
  </div>
</header>
```

---

### Spec 005: Footer Component
**Story:** story-05-footer-component.md
**Files to create:**
- src/components/layout/Footer.tsx

**Key implementation details:**
- 3-column grid layout (collapses to single column on mobile)
- Server IP prominently displayed: 5.161.69.191:25565
- CopyIPButton placeholder (full functionality in Epic 004)
- Dynamic copyright year: {new Date().getFullYear()}

**Component structure:**
```tsx
<footer className="bg-gray-800 dark:bg-gray-900 text-white py-12 mt-auto">
  <div className="container mx-auto px-4">
    <div className="grid md:grid-cols-3 gap-8">
      {/* Server IP Section */}
      <div>
        <h3 className="font-bold mb-4">Join Our Server</h3>
        <p className="text-2xl font-mono mb-2">5.161.69.191:25565</p>
        <button className="btn-primary">Copy IP</button>
      </div>

      {/* Quick Links */}
      <div>
        <h3 className="font-bold mb-4">Quick Links</h3>
        <nav className="flex flex-col gap-2">
          <Link to="/">Home</Link>
          <Link to="/worlds">Worlds</Link>
          <Link to="/rules">Rules</Link>
          <Link to="/contact">Contact</Link>
        </nav>
      </div>

      {/* About */}
      <div>
        <p>© {new Date().getFullYear()} BlockHaven</p>
        <p className="text-sm text-gray-400">Built with Claude Code</p>
      </div>
    </div>
  </div>
</footer>
```

---

### Spec 006: Mobile Navigation
**Story:** story-06-mobile-navigation.md
**Files to create:**
- src/components/layout/Navigation.tsx (shared between Header and mobile menu)

**Key implementation details:**
- useState for menu open/close state
- useEffect to close menu on route change
- Body scroll lock when menu open: document.body.style.overflow = 'hidden'
- Backdrop overlay with onClick to close menu
- Slide-in animation from right using transform: translateX()
- ESC key closes menu

**Component structure:**
```tsx
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
    return () => { document.body.style.overflow = ''; };
  }, [isOpen]);

  return (
    <>
      {/* Desktop nav */}
      <nav className="hidden md:flex gap-6">
        {navItems.map(item => (
          <NavLink key={item.path} to={item.path}>{item.label}</NavLink>
        ))}
      </nav>

      {/* Mobile hamburger button */}
      <button className="md:hidden" onClick={() => setIsOpen(!isOpen)}>
        {isOpen ? <X /> : <Menu />}
      </button>

      {/* Mobile menu */}
      {isOpen && (
        <>
          <div
            className="fixed inset-0 bg-black/50 z-40"
            onClick={() => setIsOpen(false)}
          />
          <nav className="fixed top-0 right-0 h-full w-64 bg-white dark:bg-gray-900 shadow-xl z-50 p-6 transform transition-transform">
            {navItems.map(item => (
              <NavLink
                key={item.path}
                to={item.path}
                onClick={() => setIsOpen(false)}
                className="block py-3"
              >
                {item.label}
              </NavLink>
            ))}
          </nav>
        </>
      )}
    </>
  );
}
```

---

## Recommendation

I suggest creating full detailed specs for stories 003-006 individually to maintain the same level of detail as specs 001 and 002. Each spec should include:

1. **Complete file contents** for all components
2. **Acceptance criteria mapping** with verification steps
3. **Manual testing checklist** with step-by-step instructions
4. **Implementation notes** with code examples
5. **Risk mitigation strategies**

Would you like me to create the remaining 4 detailed specs now, or shall we proceed with implementing specs 001 and 002 first?

---

## Next Steps

**Option A: Create detailed specs for 003-006**
```bash
# Create each spec individually with full detail
/spec-story .storyline/stories/epic-001/story-03-theme-context-dark-mode.md
/spec-story .storyline/stories/epic-001/story-04-header-component.md
/spec-story .storyline/stories/epic-001/story-05-footer-component.md
/spec-story .storyline/stories/epic-001/story-06-mobile-navigation.md
```

**Option B: Begin implementation**
```bash
# Start implementing the foundation
/dev-story .storyline/specs/epic-001/spec-01-vite-react-project-initialization.md
```

**Recommended approach:** Create all detailed specs first (Option A) so we have complete documentation, then implement sequentially starting with spec-01.
