# BlockHaven Monetization Guide

## Overview

BlockHaven uses **Tebex (formerly BuyCraft)** for donation processing with tiered monthly subscriptions and a lifetime option.

**Revenue Model:** Family-friendly premium features (cosmetics, convenience, private worlds) - **NO pay-to-win**

---

## Rank Structure & Pricing

### Donor Ranks

| Rank | Price | Private Worlds | Max Plots | Homes | Benefits |
|------|-------|----------------|-----------|-------|----------|
| **Default** | Free | 0 | 3 | 1 | Base server access |
| **Friend** | $4.99/mo | 0 | 5 | 3 | Chat colors, particle effects, Discord role |
| **Family** | $9.99/mo | 1 | 10 | 5 | 1 private world, priority join, custom nickname |
| **VIP** | $19.99/mo | 3 | 20 | 10 | 3 private worlds, fly in spawn, cosmetic pets |
| **Lifetime VIP** | $99.99 one-time | 3 | Unlimited | 20 | All VIP perks forever, exclusive chat tag |

### Staff Ranks (Non-Purchasable)

| Rank | Responsibilities |
|------|------------------|
| **Helper** | Chat moderation, basic support (`/warn`, `/mute 10m`, `/kick`) |
| **Moderator** | Full moderation (`/ban`, `/vanish`, CoreProtect) |
| **Admin** | Full server control, plugin configuration |

---

## Tebex Package Configuration

### 1. Friend Rank - $4.99/month

**Package Name:** "Friend Rank - Monthly"

**Description:**
```
Become a Friend of BlockHaven!

✅ Colored chat messages
✅ Particle effect trails
✅ 5 plot claims (up from 3)
✅ 3 home locations
✅ Exclusive Discord role
✅ Join full server (priority queue)
✅ Support development!

This is a monthly subscription.
```

**Commands to Execute:**
```bash
# On Purchase
lp user {username} parent add friend
say §a{username} just became a Friend! Thank you for supporting BlockHaven!

# On Expiry/Chargeback
lp user {username} parent remove friend
```

**Category:** Ranks
**Limit:** 1 per player
**Expiry:** Subscription-based (automatic renewal)

---

### 2. Family Rank - $9.99/month

**Package Name:** "Family Rank - Monthly"

**Description:**
```
Join the BlockHaven Family!

✅ Everything from Friend rank
✅ 1 Private World (your own invite-only world!)
✅ 10 plot claims
✅ 5 home locations
✅ Custom nickname (/nick)
✅ Priority support
✅ Warm fuzzy feeling 💚

This is a monthly subscription.
```

**Commands to Execute:**
```bash
# On Purchase
lp user {username} parent remove friend
lp user {username} parent add family
lp user {username} permission set privateworld.create.1 true
say §6{username} joined the Family! Welcome! 🏡

# On Expiry
lp user {username} parent remove family
lp user {username} permission unset privateworld.create.1
# Note: Private world remains but becomes read-only until resubscribed
```

**Category:** Ranks
**Limit:** 1 per player
**Expiry:** Subscription-based

---

### 3. VIP Rank - $19.99/month

**Package Name:** "VIP Rank - Monthly"

**Description:**
```
Become a BlockHaven VIP!

✅ Everything from Family rank
✅ 3 Private Worlds (bring your whole crew!)
✅ 20 plot claims
✅ 10 home locations
✅ Fly in spawn hub
✅ Cosmetic pets
✅ Custom particle effects
✅ Reserved slot (never wait in queue)
✅ VIP Discord channel access
✅ Be awesome!

This is a monthly subscription.
```

**Commands to Execute:**
```bash
# On Purchase
lp user {username} parent remove family
lp user {username} parent add vip
lp user {username} permission set privateworld.create.3 true
lp user {username} permission set essentials.fly true world=spawn
say §5§l{username} is now a VIP! 👑

# On Expiry
lp user {username} parent remove vip
lp user {username} permission unset privateworld.create.3
lp user {username} permission unset essentials.fly
```

**Category:** Ranks
**Limit:** 1 per player
**Expiry:** Subscription-based

---

### 4. Lifetime VIP - $99.99 one-time

**Package Name:** "Lifetime VIP - One Time Payment"

**Description:**
```
BlockHaven VIP... FOREVER! 🚀

✅ EVERYTHING from VIP rank
✅ 3 Private Worlds
✅ UNLIMITED plot claims
✅ 20 home locations
✅ Exclusive "Founder" chat tag
✅ Name in hall of fame
✅ All future perks included
✅ Never pay again!

This is a ONE-TIME payment. You'll have VIP status forever!
```

**Commands to Execute:**
```bash
# On Purchase
lp user {username} parent remove vip
lp user {username} parent remove family
lp user {username} parent remove friend
lp user {username} parent add lifetime_vip
lp user {username} permission set privateworld.create.3 true
lp user {username} permission set essentials.fly true world=spawn
say §d§l✨ {username} is now a LIFETIME VIP! A true BlockHaven legend! ✨
# Add to hall of fame (manual)

# No Expiry Commands (permanent)
```

**Category:** Lifetime Ranks
**Limit:** 1 per player
**Expiry:** NEVER

---

## Tebex Setup Guide

### Step 1: Create Tebex Account

1. Go to https://www.tebex.io/
2. Create account and set up store
3. Connect to Minecraft server

### Step 2: Install Tebex Plugin

**Already included in SPIGET_RESOURCES**, but manual installation:

```bash
# Download from:
https://www.spigotmc.org/resources/tebex-buycraft.82261/

# Or add to extras/plugins.txt
```

### Step 3: Link Server to Tebex

```bash
# In-game or via RCON:
/tebex secret <your-secret-key>
```

**Secret Key Location:** Tebex Dashboard → Game Servers → Secret Key

### Step 4: Create Packages

For each rank (Friend, Family, VIP, Lifetime VIP):

1. **Package Name:** "Friend Rank - Monthly"
2. **Price:** $4.99
3. **Category:** Ranks
4. **Limit:** 1 per player
5. **Expiry:** Subscription (except Lifetime)
6. **Commands:** Copy from sections above

**Important Settings:**
- ✅ Enable "Require player online" = NO (commands run when offline)
- ✅ Enable "Execute commands in order" = YES
- ✅ "One-time purchase only" = YES (prevents buying multiple)

### Step 5: Test Purchases

1. Create test package ($0.01)
2. Buy with test credit card
3. Verify commands execute
4. Check LuckPerms groups updated

### Step 6: Configure Payment Gateway

**Recommended: Stripe or PayPal**

1. Connect payment gateway in Tebex dashboard
2. Set up tax collection (required by law in some regions)
3. Configure currency (USD recommended)
4. Enable automatic email receipts

---

## LuckPerms Permission Nodes

### Friend Rank Permissions
```yaml
permissions:
  - essentials.nick.color
  - essentials.hat
  - plotsquared.plot.limit.5
  - essentials.sethome.multiple.friend
  - minecraft.particle.effect
```

### Family Rank Permissions
```yaml
inherits: friend
permissions:
  - essentials.nick
  - privateworld.create.1
  - plotsquared.plot.limit.10
  - essentials.sethome.multiple.family
  - server.priorityjoin.1
```

### VIP Rank Permissions
```yaml
inherits: family
permissions:
  - privateworld.create.3
  - essentials.fly world=spawn
  - plotsquared.plot.limit.20
  - essentials.sethome.multiple.vip
  - pet.summon.*
  - server.priorityjoin.2
```

### Lifetime VIP Permissions
```yaml
inherits: vip
permissions:
  - plotsquared.plot.unlimited
  - essentials.sethome.multiple.lifetime
  - privateworld.create.3
  - blockhaven.founder
```

**Apply via LuckPerms:**
```bash
/lp editor
# (Configure in web editor, export to groups.yml)
```

---

## Revenue Projections

### Conservative Estimate (50 players)

| Rank | Subscribers | Revenue/Month |
|------|-------------|---------------|
| Friend ($4.99) | 10 | $49.90 |
| Family ($9.99) | 8 | $79.92 |
| VIP ($19.99) | 5 | $99.95 |
| Lifetime VIP ($99.99) | 2/month | $199.98 |

**Total Monthly Revenue:** ~$430
**Minus Tebex Fees (5%):** ~$408.50
**Minus Server Costs (€14):** ~$393

**Net Profit:** ~$393/month

### Growth Target (100 players)

| Rank | Subscribers | Revenue/Month |
|------|-------------|---------------|
| Friend ($4.99) | 20 | $99.80 |
| Family ($9.99) | 15 | $149.85 |
| VIP ($19.99) | 10 | $199.90 |
| Lifetime VIP ($99.99) | 3/month | $299.97 |

**Total Monthly Revenue:** ~$750
**Minus Tebex Fees (5%):** ~$712.50
**Minus Server Costs (€20):** ~$690

**Net Profit:** ~$690/month

---

## Fair Play Policy

**BlockHaven is NOT Pay-to-Win!**

### Prohibited Perks (Never Offer)
❌ Stronger weapons/armor
❌ Extra hearts/health
❌ Fly in survival worlds
❌ Unlimited resources
❌ Admin commands (e.g., /give)
❌ Bypassing economy system
❌ Unfair PvP advantages

### Allowed Perks (What We Offer)
✅ Cosmetic features (particle effects, pets, chat colors)
✅ Convenience (extra homes, plots, private worlds)
✅ Priority support
✅ Priority queue (when server full)
✅ Custom nicknames
✅ Discord perks

**Goal:** Make donors feel special without giving gameplay advantages!

---

## Chargeback Handling

### Automatic Rank Removal

Tebex automatically detects chargebacks and executes expiry commands.

**Chargeback Commands (same as expiry):**
```bash
lp user {username} parent remove <rank>
lp user {username} permission unset privateworld.create.*
```

### Ban Policy

**3-strike policy for fraudulent chargebacks:**
1. First chargeback: Rank removed, 7-day temp ban
2. Second chargeback: Permanent ban, IP ban
3. Report to Tebex fraud database

**Legitimate disputes:** Handled case-by-case (accidental double charge, etc.)

---

## Marketing Strategy

### Server Listing Sites
- **Planet Minecraft:** Highlight donation perks
- **MC-Server-List:** Premium listing ($10/mo)
- **Minecraft-Server.net:** Free listing

### In-Game Promotion
```bash
# Broadcast every 30 minutes
/broadcast §6Support BlockHaven! Get perks at §bhttps://store.bhsmp.com

# Join message
/lp user <player> permission set blockhaven.joinmessage.donor
# "Thanks for supporting BlockHaven!" (for donors)
```

### Discord Integration
- Automatic role assignment via DiscordSRV
- Exclusive donor channels
- Donor-only events (building contests, etc.)

### Website Integration
- Tebex store embedded on bhsmp.com
- Showcase donor perks with screenshots/videos
- Testimonials from current donors

---

## Legal Compliance

### Required Policies

1. **Terms of Service:** Define donation terms, refund policy
2. **Privacy Policy:** GDPR/CCPA compliant data handling
3. **Age Restrictions:** Parental consent required for under-13s (COPPA)

**Tebex handles:**
- Payment processing (PCI compliance)
- Transaction records
- Email receipts

**You must provide:**
- Clear refund policy (e.g., "No refunds for digital goods")
- Server rules
- Ban appeal process

---

## Refund Policy (Recommended)

```
BlockHaven Refund Policy:

✅ Refunds available within 24 hours of purchase IF:
   - Server was offline during purchase
   - Package was not delivered due to technical error
   - Accidental duplicate purchase

❌ NO refunds for:
   - Buyer's remorse
   - Ban due to rule violation
   - Server shutdown (rank will transfer if we migrate)

To request refund: Email support@bhsmp.com with order ID
```

---

## Next Steps

1. ✅ Create Tebex account
2. ✅ Install Tebex plugin
3. ✅ Link server to Tebex
4. ✅ Create 4 packages (Friend, Family, VIP, Lifetime VIP)
5. ✅ Configure LuckPerms permission nodes
6. ✅ Test purchases with dummy account
7. ✅ Write Terms of Service & Privacy Policy
8. ✅ Embed Tebex store on bhsmp.com
9. ✅ Promote store in-game and Discord

**See:** Phase 7 in [blockhaven-planning-doc.md](../../blockhaven-planning-doc.md) for detailed implementation.
