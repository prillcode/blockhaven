# BlockHaven In-Game Protection Setup Checklist

**Date:** January 10, 2026
**Purpose:** Set up WorldGuard regions and test UltimateLandClaim before adding economy plugins

---

## Phase 1: WorldGuard Basics

### Get Your WorldEdit Wand
```
//wand
```
- You'll receive a wooden axe
- **Left-click** = Select position 1 (first corner)
- **Right-click** = Select position 2 (opposite corner)

### Basic WorldGuard Commands Reference
```
/rg define <region-name>          - Create region from your selection
/rg flag <region> build deny      - Prevent building/breaking
/rg flag <region> pvp deny        - Disable PvP
/rg list                          - Show all regions in current world
/rg info <region-name>            - Show region details
/rg remove <region-name>          - Delete a region (if you make a mistake)
```

---

## Phase 2: Protect Spawn Hub World

**World:** `Spawn_Hub` (spawn)

### [ ] Task 1: Protect Central Spawn Area
1. Stand in the center of your spawn hub
2. `/tp @s ~ ~ ~ ` (note your coordinates)
3. Select area with WorldEdit wand (make it large enough for safety)
   - Example: 100 blocks in each direction from center
4. Create region:
   ```
   /rg define spawn_hub_center
   /rg flag spawn_hub_center build deny
   /rg flag spawn_hub_center pvp deny
   /rg addowner spawn_hub_center PrLLager207
   ```

### [ ] Task 2: Protect Each Portal in Spawn Hub
For each portal (6 total), repeat:

1. Stand at portal location
2. Select portal area with `//wand` (left-click one corner, right-click opposite)
3. Create protection:
   ```
   /rg define portal_to_<world-name>
   /rg flag portal_to_<world-name> build deny
   /rg flag portal_to_<world-name> pvp deny
   ```

**Portal names to protect:**
- [ ] `portal_to_survival_easy` (Portal to SMP Smokey Plains)
- [ ] `portal_to_survival_hard` (Portal to SMP Forest Cliffs)
- [ ] `portal_to_resource` (Portal to Resource Ravine)
- [ ] `portal_to_creative_flat` (Portal to Creative Plots)
- [ ] `portal_to_creative_terrain` (Portal to Creative Hills)

### [ ] Task 3: Verify Spawn Hub Regions
```
/rg list
```
- Should see: spawn_hub_center + 5 portal regions

---

## Phase 3: Protect Return Portals in Each World

### [ ] World: SMP Smokey Plains (survival_easy)

1. **Teleport:** `/mvtp SMP_Smokey_Plains`
2. **Protect return portal:**
   ```
   // Use //wand to select portal area
   /rg define survival_easy_return_portal
   /rg flag survival_easy_return_portal build deny
   /rg flag survival_easy_return_portal pvp deny
   ```
3. **Optional: Protect spawn area around portal**
   ```
   // Select larger area around portal (safe spawn zone)
   /rg define survival_easy_spawn
   /rg flag survival_easy_spawn pvp deny
   // Note: Don't deny build here so players can claim nearby
   ```

### [ ] World: SMP Forest Cliffs (survival_hard)

1. **Teleport:** `/mvtp SMP_Forest_Cliffs`
2. **Protect return portal:**
   ```
   // Use //wand to select portal area
   /rg define survival_hard_return_portal
   /rg flag survival_hard_return_portal build deny
   /rg flag survival_hard_return_portal pvp deny
   ```
3. **Optional: Protect spawn area around portal**
   ```
   /rg define survival_hard_spawn
   /rg flag survival_hard_spawn pvp deny
   ```

### [ ] World: Resource Ravine (resource)

1. **Teleport:** `/mvtp Resource_Ravine`
2. **Protect return portal:**
   ```
   // Use //wand to select portal area
   /rg define resource_return_portal
   /rg flag resource_return_portal build deny
   /rg flag resource_return_portal pvp deny
   ```
3. **Optional: Protect spawn area**
   ```
   /rg define resource_spawn
   /rg flag resource_spawn pvp deny
   ```

### [ ] World: Creative Plots (creative_flat)

1. **Teleport:** `/mvtp Creative_Plots`
2. **Protect return portal:**
   ```
   // Use //wand to select portal area
   /rg define creative_flat_return_portal
   /rg flag creative_flat_return_portal build deny
   ```

### [ ] World: Creative Hills (creative_terrain)

1. **Teleport:** `/mvtp Creative_Hills`
2. **Protect return portal:**
   ```
   // Use //wand to select portal area
   /rg define creative_terrain_return_portal
   /rg flag creative_terrain_return_portal build deny
   ```

---

## Phase 4: Test UltimateLandClaim

### [ ] Task 1: Get Claiming Tools

UltimateLandClaim uses vanilla items:
- **Golden Shovel** = Create claims (you already have this)
- **Stick** = View claim boundaries

**Get a stick:**
```
/give @s stick
```

### [ ] Task 2: Test Claiming in Survival Easy

1. **Go to survival world:** `/mvtp SMP_Smokey_Plains`
2. **Move away from spawn** (at least 100 blocks from protected areas)
3. **Check your claim blocks:**
   ```
   /claim info
   ```
   - Should show: 100 starting blocks + any earned from playtime

4. **Create a test claim (FREE mode):**
   - Hold Golden Shovel
   - **Right-click** on the ground = Set corner 1
   - Walk to opposite corner
   - **Right-click** on the ground = Set corner 2
   - Claim should be created!

5. **View your claim:**
   - Hold a stick
   - Particles will show claim boundaries

6. **Test claim protection:**
   - Walk outside your claim
   - Try to place/break a block inside your claim → Should be blocked
   - Walk inside your claim
   - Place/break blocks → Should work

### [ ] Task 3: Test Trust System

1. **Add a trusted player (if you have a friend online):**
   ```
   /claim trust <player-name> build
   ```
   - Trust levels: `access`, `container`, `build`, `manager`

2. **Remove trust:**
   ```
   /claim untrust <player-name>
   ```

### [ ] Task 4: Test Claim Management

1. **List your claims:**
   ```
   /claim list
   ```

2. **Abandon test claim:**
   ```
   /claim abandon
   ```
   - Stand inside the claim you want to delete
   - Confirms deletion
   - Claim blocks are refunded!

### [ ] Task 5: Verify WorldGuard Integration

1. **Try to claim inside a protected region:**
   - Go back to spawn hub: `/mvtp Spawn_Hub`
   - Try to create a claim inside the `spawn_hub_center` region
   - **Expected result:** "You cannot claim inside a WorldGuard region!"

2. **Verify portals can't be claimed:**
   - Stand at any portal
   - Try to create a claim around it
   - Should be blocked ✅

---

## Phase 5: Final Verification

### [ ] Check All Regions Created

Run in each world:
```
/mvtp Spawn_Hub
/rg list

/mvtp SMP_Smokey_Plains
/rg list

/mvtp SMP_Forest_Cliffs
/rg list

/mvtp Resource_Ravine
/rg list

/mvtp Creative_Plots
/rg list

/mvtp Creative_Hills
/rg list
```

**Expected totals:**
- Spawn Hub: 6 regions (1 spawn + 5 portals)
- Each survival/resource world: 1-2 regions (return portal + optional spawn)
- Each creative world: 1 region (return portal)

### [ ] Test Non-OP Player Access

**Option 1: Have a friend join**
- Ask them to try breaking blocks in protected regions → Should be denied
- Ask them to use portals → Should work (LuckPerms configured)
- Ask them to create a claim in survival → Should work

**Option 2: De-op yourself temporarily**
```
/deop PrLLager207
```
- Try breaking blocks in spawn → Should be denied
- Use portals → Should work
- Re-op yourself:
```
/op PrLLager207
```

---

## Quick Reference: UltimateLandClaim Commands

```
/claim info               - View your claim blocks and status
/claim list               - List all your claims
/claim abandon            - Delete claim you're standing in (refunds blocks)
/claim trust <player> <level>  - Trust a player (access/container/build/manager)
/claim untrust <player>   - Remove trust from player
/claim transfer <player>  - Transfer claim ownership
```

**Tools:**
- Golden Shovel = Create claims (2 corners in FREE mode)
- Stick = View claim boundaries (hold it, particles appear)

---

## Troubleshooting

### "You don't have enough claim blocks"
- Check: `/claim info`
- Wait for playtime accrual (1 block per minute)
- Or reduce claim size

### "You cannot claim inside a WorldGuard region"
- This is correct! Move away from protected spawn/portal areas
- WorldGuard regions are for staff-protected areas only

### "Region already exists"
- Use `/rg list` to see all regions
- Remove it: `/rg remove <region-name>`
- Then recreate with correct settings

### Claim boundaries not showing with stick
- Make sure you're within 50 blocks of the claim (particle distance)
- Check server performance (particles may lag)

---

## Ready for Economy?

Once you've completed this checklist and everything works:
✅ All spawn areas protected
✅ All portals protected
✅ Claims working in survival worlds
✅ WorldGuard blocking claims in protected areas

**Next step:** Add economy plugins (Vault, EssentialsX, Jobs Reborn)

Let me know when you're ready to continue!
