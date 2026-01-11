# How to Disable Dokploy Auto-Deployment

**Date:** January 10, 2026
**Issue:** Dokploy automatically redeploys on every git push, causing data loss with bind mounts

---

## Why Disable Auto-Deploy?

Dokploy's auto-deployment feature is useful for web applications, but for Minecraft servers:
- ❌ Every git push triggers a redeploy
- ❌ Redeployments recreate containers from scratch
- ❌ With bind mounts to git repo, data gets wiped on redeploy
- ❌ Results in repeated data loss and world resets

**With Docker named volumes (our new setup), this is less critical, but manual deploys are still safer for production Minecraft servers.**

---

## How to Disable in Dokploy Dashboard

### Option 1: Via Dokploy Web UI

1. **Access Dokploy Dashboard**
   - Go to your Dokploy instance (usually on port 3000)
   - Log in with your admin credentials

2. **Navigate to Your Application**
   - Find "blockhaven-mcserver" in your applications list
   - Click to open the application settings

3. **Disable Auto-Deploy**
   - Look for "Auto Deploy" or "Git Auto Deploy" setting
   - Toggle it to **OFF** or **Disabled**
   - Save changes

### Option 2: Via Dokploy Configuration File

If your Dokploy setup uses configuration files:

1. **SSH into your VPS**
   ```bash
   ssh blockhaven_vps
   ```

2. **Find Dokploy config**
   ```bash
   cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/
   ls -la
   ```

3. **Edit deployment settings**
   - Look for `dokploy.json` or similar config file
   - Set `autoDeploy: false`

### Option 3: Disconnect Git Webhook

1. **GitHub Repository Settings**
   - Go to your GitHub repo: `https://github.com/prillcode/blockhaven`
   - Settings → Webhooks

2. **Find Dokploy Webhook**
   - Look for webhook pointing to your Dokploy instance
   - Delete or disable it

---

## Manual Deployment After Disabling Auto-Deploy

When you want to deploy changes manually:

### Via Dokploy UI:
1. Log into Dokploy dashboard
2. Navigate to blockhaven-mcserver application
3. Click "Deploy" or "Redeploy" button

### Via SSH (Alternative):
```bash
ssh blockhaven_vps
cd /etc/dokploy/compose/blockhaven-mcserver-yst1sp/code
git pull origin main
cd mc-server
docker compose down
docker compose up -d
```

---

## When to Deploy Manually

**Deploy when you change:**
- ✅ docker-compose.yml configuration
- ✅ Environment variables (.env)
- ✅ Plugin versions or settings
- ✅ Server properties

**No need to deploy for:**
- ❌ Documentation updates (.md files)
- ❌ Local testing changes
- ❌ Scripts that don't affect the running server

---

## Recommended Workflow Going Forward

1. **Make changes locally** and test with `docker compose up -d`
2. **Commit and push to GitHub** for version control
3. **Manually trigger Dokploy deployment** only when ready
4. **Verify server is running** after deployment

This gives you:
- ✅ Version control (git)
- ✅ Controlled deployments (manual)
- ✅ No accidental data loss
- ✅ Ability to test locally first

---

## Docker Named Volumes = Data Persists

With the updated `docker-compose.yml`:

```yaml
volumes:
  - minecraft-data:/data  # Named volume (persists across redeployments)
```

**Even with auto-deploy enabled:**
- ✅ World data persists (stored in Docker volume, not git repo)
- ✅ Plugins persist
- ✅ Configurations persist
- ✅ No more data loss

**But manual deploy is still recommended for production servers to:**
- Control when updates happen
- Verify changes before applying
- Avoid unexpected downtime

---

## Verifying Auto-Deploy is Disabled

After disabling, test it:

1. Make a small documentation change locally
2. Commit and push to GitHub:
   ```bash
   git add README.md
   git commit -m "test: verify auto-deploy disabled"
   git push origin main
   ```
3. Check if Dokploy redeployed:
   ```bash
   ssh blockhaven_vps "docker ps | grep blockhaven-mc"
   ```
   - Check the "Created" timestamp
   - If it's old (hours/days), auto-deploy is disabled ✅
   - If it's recent (seconds/minutes), auto-deploy is still active ❌

---

## Summary

✅ **Auto-deploy disabled** = You control when updates happen
✅ **Named volumes** = Data persists even if you accidentally redeploy
✅ **Manual deploys** = Safer for production Minecraft servers

This combination gives you the best of both worlds: version control with git, and stable production environment.
