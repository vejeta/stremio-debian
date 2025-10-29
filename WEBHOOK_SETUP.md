# Webhook Setup Guide: Salsa GitLab → GitHub Actions

This guide explains how to configure webhooks from Salsa Debian repositories to trigger instant builds on GitHub Actions.

## 📋 Overview

**Traditional Approach** (cron-based):
- Push to Salsa → wait up to 24 hours → GitHub detects changes

**Webhook Approach** (event-driven):
- Push to Salsa → instant webhook → GitHub builds immediately (seconds)

**Benefits**:
- ⚡ Instant updates (seconds vs hours)
- 💰 Lower GitHub Actions minutes (only runs when needed)
- ✅ More reliable (active notification vs polling)

---

## 🔑 Prerequisites

1. **GitHub Personal Access Token** (PAT) with permissions:
   - `repo` (full control of private repositories)
   - `workflow` (update GitHub Action workflows)

2. **Access to Salsa GitLab repositories**:
   - https://salsa.debian.org/mendezr/stremio (maintainer access)
   - https://salsa.debian.org/mendezr/stremio-server (maintainer access)

3. **GitHub repository**: `vejeta/stremio-debian`

---

## Step 1: Create GitHub Personal Access Token

### 1.1 Generate Token

1. Go to: https://github.com/settings/tokens/new
2. Configure token:
   - **Note**: `Salsa Webhook Token`
   - **Expiration**: `1 year` (or longer)
   - **Scopes**:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Action workflows)
3. Click **"Generate token"**
4. **IMPORTANT**: Copy the token immediately (you won't see it again)

Example token format: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### 1.2 Store Token Securely

```bash
# Save to password manager or secure file
echo "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" > ~/github-webhook-token.txt
chmod 600 ~/github-webhook-token.txt
```

⚠️ **Never commit this token to git!**

---

## Step 2: Configure Webhook in Salsa (stremio repository)

### 2.1 Navigate to Webhook Settings

1. Go to: https://salsa.debian.org/mendezr/stremio
2. Click **Settings** → **Webhooks**
3. Click **"Add new webhook"**

### 2.2 Configure Webhook

Fill in the following settings:

**URL**:
```
https://api.github.com/repos/vejeta/stremio-debian/dispatches
```

**Secret Token**:
```
<your-github-pat-token>
```
(The token from Step 1)

**Trigger**:
- ✅ **Push events** (check this)
- ✅ **Tag push events** (optional, recommended)
- ❌ Everything else (uncheck)

**SSL verification**:
- ✅ **Enable SSL verification** (recommended)

### 2.3 Advanced: Custom Webhook Payload (Optional)

If Salsa supports custom payloads, configure:

**Method**: `POST`

**Headers**:
```
Authorization: Bearer <your-github-pat-token>
Content-Type: application/json
Accept: application/vnd.github+json
X-GitHub-Api-Version: 2022-11-28
```

**Body** (JSON):
```json
{
  "event_type": "salsa-push",
  "client_payload": {
    "repository": "stremio",
    "ref": "$CI_COMMIT_REF_NAME",
    "sha": "$CI_COMMIT_SHA",
    "timestamp": "$CI_COMMIT_TIMESTAMP"
  }
}
```

### 2.4 Test Webhook

1. Click **"Add webhook"** to save
2. Click **"Test"** → **"Push events"**
3. Check for successful response:
   - ✅ Status: `204 No Content` (success)
   - ❌ Status: `401 Unauthorized` (check token)
   - ❌ Status: `404 Not Found` (check URL)

---

## Step 3: Configure Webhook in Salsa (stremio-server repository)

Repeat Step 2 for the second repository:

1. Go to: https://salsa.debian.org/mendezr/stremio-server
2. Click **Settings** → **Webhooks**
3. Configure identical webhook settings:
   - URL: `https://api.github.com/repos/vejeta/stremio-debian/dispatches`
   - Secret Token: (same GitHub PAT)
   - Trigger: Push events
4. Test webhook

---

## Step 4: Verify GitHub Actions Workflow

The sync workflow should already be configured to listen for webhooks:

```yaml
# .github/workflows/sync-from-salsa.yml
on:
  repository_dispatch:
    types: [salsa-push]  # Listens for webhook events
  schedule:
    - cron: '0 2 * * 0'  # Weekly fallback
  workflow_dispatch:     # Manual trigger
```

**No changes needed** - this is already configured.

---

## Step 5: Test End-to-End Webhook Flow

### 5.1 Make a Test Commit to Salsa

```bash
# Clone one of your Salsa repositories
git clone https://salsa.debian.org/mendezr/stremio.git
cd stremio

# Make a trivial change
echo "# Test webhook" >> README.md
git add README.md
git commit -m "test: Verify webhook trigger"
git push origin main
```

### 5.2 Monitor GitHub Actions

1. Go to: https://github.com/vejeta/stremio-debian/actions
2. Within **seconds**, you should see:
   - New workflow run: **"Sync from Salsa Debian"**
   - Status: Running or Completed
   - Triggered by: `repository_dispatch`

### 5.3 Verify Results

Check the workflow logs:
```
=== Cloning stremio-client from Salsa ===
Latest Salsa commit: abc123def
Current commit: xyz789abc
Client needs update
=== Syncing stremio-client ===
✓ stremio-client synced successfully
✓ Changes committed and pushed
```

---

## Troubleshooting

### Webhook Not Triggering

**Issue**: Push to Salsa doesn't trigger GitHub Actions

**Solutions**:

1. **Check webhook delivery logs in Salsa**:
   - Settings → Webhooks → Recent Deliveries
   - Look for HTTP status codes:
     - 204 = Success
     - 401 = Invalid token
     - 404 = Wrong URL
     - 500 = GitHub API error

2. **Verify token has correct permissions**:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" \
        https://api.github.com/user
   # Should return your GitHub user info
   ```

3. **Check GitHub webhook events**:
   - Go to: https://github.com/vejeta/stremio-debian/settings/hooks
   - Recent Deliveries tab
   - Look for `repository_dispatch` events

4. **Ensure workflow file is correct**:
   ```bash
   # Check workflow exists
   cat .github/workflows/sync-from-salsa.yml | grep "repository_dispatch"
   ```

### Token Expired or Invalid

**Symptoms**:
- Webhook delivers but nothing happens
- HTTP 401 errors in Salsa webhook logs

**Solution**:
1. Generate new GitHub PAT (Step 1)
2. Update webhook secret token in Salsa (Step 2)
3. Test webhook delivery

### Webhook Triggers But Workflow Doesn't Run

**Possible causes**:

1. **Event type mismatch**:
   - Webhook sends: `push`
   - Workflow expects: `salsa-push`
   - **Solution**: Ensure webhook sends correct `event_type` in payload

2. **Workflow not on main branch**:
   - GitHub Actions only runs workflows from default branch
   - **Solution**: Merge `.github/workflows/` to main branch

3. **Syntax error in workflow**:
   - GitHub silently ignores broken workflows
   - **Solution**: Validate YAML syntax:
     ```bash
     yamllint .github/workflows/sync-from-salsa.yml
     ```

### Fallback to Cron

If webhooks consistently fail, the weekly cron (Sunday 02:00 UTC) will catch missed updates:

```yaml
schedule:
  - cron: '0 2 * * 0'  # Runs every Sunday
```

This ensures updates never fall more than 7 days behind.

---

## Security Best Practices

### 1. Token Rotation

Rotate GitHub PAT every 6-12 months:
1. Generate new token
2. Update Salsa webhooks with new token
3. Test webhooks
4. Revoke old token

### 2. Webhook Secret Validation

GitLab webhooks support signature validation. Consider adding webhook signature verification in GitHub Actions for enhanced security.

### 3. Least Privilege

Use PAT with minimum required permissions:
- ✅ `repo` (required for private repos)
- ✅ `workflow` (required to trigger workflows)
- ❌ `admin:org` (not needed)
- ❌ `delete_repo` (not needed)

### 4. Monitor Webhook Activity

Regularly review webhook delivery logs:
- Salsa: Settings → Webhooks → Recent Deliveries
- GitHub: Settings → Hooks → Recent Deliveries

Look for:
- ⚠️ Repeated failures (indicates problem)
- ⚠️ Unusual frequency (possible abuse)
- ⚠️ Unknown sources (security issue)

---

## Alternative: Using GitLab CI/CD to Trigger GitHub

If direct webhooks don't work, use GitLab CI as intermediary:

**.gitlab-ci.yml** (in Salsa repository):
```yaml
trigger_github:
  stage: deploy
  only:
    - main
  script:
    - |
      curl -X POST \
        -H "Authorization: Bearer $GITHUB_PAT" \
        -H "Accept: application/vnd.github+json" \
        https://api.github.com/repos/vejeta/stremio-debian/dispatches \
        -d '{"event_type":"salsa-push"}'
```

Store `GITHUB_PAT` as protected variable in GitLab CI/CD settings.

---

## Monitoring and Maintenance

### Weekly Checks

- [ ] Review webhook delivery success rate (Salsa)
- [ ] Check GitHub Actions workflow success rate
- [ ] Verify latest Salsa commits are synced to GitHub

### Monthly Tasks

- [ ] Review token expiration dates
- [ ] Check for webhook errors in logs
- [ ] Validate fallback cron is working

### Yearly Tasks

- [ ] Rotate GitHub PAT
- [ ] Review and update webhook configurations
- [ ] Test disaster recovery (manual sync)

---

## Summary

✅ **Webhooks configured** → Instant sync from Salsa to GitHub
✅ **Weekly fallback cron** → Catches any missed updates
✅ **Manual trigger** → Always available via `gh workflow run`

**Result**: Near-instant updates with multiple fallback mechanisms for maximum reliability.

---

## Support

- **GitHub Issues**: https://github.com/vejeta/stremio-debian/issues
- **Salsa Issues**: https://salsa.debian.org/mendezr/stremio/-/issues
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **GitLab Webhooks Docs**: https://docs.gitlab.com/ee/user/project/integrations/webhooks.html
