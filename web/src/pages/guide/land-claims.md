---
layout: ../../layouts/GuideLayout.astro
title: Land Claims
description: Learn how to protect your builds with land claims on BlockHaven
currentPage: land-claims
---

# Land Claims

Protect your builds from griefing with BlockHaven's land claiming system.

## How Land Claims Work

Land claims create a protected area where only you (and players you trust) can build, break blocks, or interact with items. Claims extend from bedrock to sky limit, so you're protected at all heights.

:::note[Free Protection!]
Land claims are completely free on BlockHaven. You start with claim blocks and earn more as you play. There's no cost to protect your builds!
:::

## Creating Your First Claim

When you join a Survival world for the first time, you receive a **Golden Shovel** in your Starter Kit. This is your claiming tool!

### Step-by-Step Instructions

1. **Equip your Golden Shovel** - Hold it in your hand
2. **Right-click the first corner** - Click a block at one corner of the area you want to claim
3. **Right-click the opposite corner** - Click a block at the diagonal opposite corner
4. **Done!** - Your claim is now created and protected

When you create or inspect a claim, you'll see temporary visual markers showing the boundaries of your claim. These help you verify the area you've protected.

## Claim Blocks

Claim blocks determine how much area you can protect. You use claim blocks to create claims, and the size of a claim is calculated by the area you select.

### Earning Claim Blocks

- **Starting blocks** - You begin with a set number of claim blocks
- **Playtime** - You earn additional claim blocks for every hour you play
- **Accrued blocks** - Claim blocks accumulate even if you're not actively claiming

### Checking Your Claim Blocks

| Command | Description |
|---------|-------------|
| `/claim list` | Shows your total, used, and available claim blocks |
| `/claim info` | Shows details about the claim you're standing in |

## Managing Claims

### Viewing Claim Info

Stand inside any claim and type `/claim info` to see details about it, including the owner, area size, and trusted players.

### Deleting a Claim

Stand inside the claim you want to delete and type `/claim delete`. This returns the claim blocks to your total.

:::warning
Deleting a claim removes all protection. Make sure you really want to remove it before using this command!
:::

## Trusting Other Players

Want to build with friends? You can grant different levels of trust to other players using the `/claim trust` command with different trust levels:

| Command | Permission Level |
|---------|-----------------|
| `/claim trust [player] ACCESS` | **Basic access** - Can use buttons, levers, and doors |
| `/claim trust [player] CONTAINER` | **Container access** - Can open chests, furnaces, etc. |
| `/claim trust [player] BUILD` | **Build access** - Can build, break, and access containers |
| `/claim trust [player] MANAGER` | **Manager** - Can trust other players (be careful!) |

### Removing Trust

To remove a player's trust, stand in the claim and use `/claim untrust [player]`.

:::tip[Trust Level Hierarchy]
Trust levels are hierarchical: MANAGER includes BUILD permissions, BUILD includes CONTAINER, and CONTAINER includes ACCESS. Give the minimum level needed for what you want players to do.
:::

## Getting Unstuck

If you ever find yourself stuck inside someone else's claim and can't get out, use the `/unstuck` command to teleport to safety.

## All Claim Commands

| Command | Description |
|---------|-------------|
| `/claim info` | Show details about the current claim |
| `/claim list` | Show your claim blocks balance |
| `/claim delete` | Delete the claim you're standing in |
| `/claim trust [player] [level]` | Trust a player (ACCESS, CONTAINER, BUILD, MANAGER) |
| `/claim untrust [player]` | Remove a player's trust |
| `/unstuck` | Teleport out of a claim you're stuck in |

## Tips and Best Practices

- **Claim early** - Protect your base as soon as you start building
- **Claim big** - Leave room to expand by claiming extra space around your build
- **Check claim info** - Use `/claim info` to see claim details anytime
- **Trust carefully** - Only trust players you know and trust in real life
- **Use appropriate trust levels** - Don't give BUILD when ACCESS is enough

## Next Steps

- [Jobs & Economy](/guide/economy) - Learn how to earn money and trade with other players.
- [Worlds & Travel](/guide/worlds) - Explore different worlds and learn how to travel between them.
