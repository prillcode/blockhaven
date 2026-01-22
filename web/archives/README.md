# Archived Web Plans

This directory contains archived planning documents that are no longer active.

## Contents

### WEB-COMPLETE-PLAN.md
**Date Archived:** January 22, 2026
**Original Date:** January 10, 2026
**Status:** Superseded

This was the original plan for a comprehensive React-based marketing website with:
- Vite + React 19 + TypeScript
- Express.js backend API
- Live server status widget
- Discord webhook contact form
- Docker deployment
- Self-hosted on Hetzner VPS

**Why Archived:**
The server moved to an **invite-only model** with whitelist functionality, making the extensive React-based marketing site unnecessary. The project pivoted to a simpler Astro static site with auto-generated content and a "Request to Play" form.

**Current Plan:**
See [../.docs/ASTRO-SITE-PRD.md](../.docs/ASTRO-SITE-PRD.md) for the active Astro site plan.

---

## Why the Change?

The original plan was designed for a public Minecraft server that needed:
- Live player count and server status
- Extensive marketing features
- Contact form for general inquiries
- Complex backend API

The new approach is better suited for an invite-only server:
- Content-driven static site
- Auto-generated from markdown docs
- Simple whitelist request form
- No backend needed (uses Resend API)
- Deployed to Cloudflare Pages (simpler, free)

---

**References:**
- New plan: `../.docs/ASTRO-SITE-PRD.md`
- Deployment: Cloudflare Pages (bhsmp.com)
- Server: AWS EC2 (play.bhsmp.com)
