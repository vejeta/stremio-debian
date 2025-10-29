# Quick Start Guide

Get your GitHub Pages APT repository running in 30 minutes.

**Updates**: Now supports Debian 13 (trixie) and 12 (bookworm) with instant webhook-based syncing!

## Prerequisites Checklist

- [ ] GitHub account with repository created: `vejeta/stremio-debian`
- [ ] Domain `debian.vejeta.com` (or use `vejeta.github.io/stremio-debian`)
- [ ] GPG installed locally: `gpg --version`
- [ ] GitHub CLI installed (optional): `gh --version`
- [ ] Git configured with your identity

## Step-by-Step Setup

### 1️⃣ Generate GPG Key (5 minutes)

```bash
# Generate key
gpg --full-generate-key
# Choose: RSA 4096, no expiration, name: "Stremio Debian Repository"

# Get your key ID
gpg --list-secret-keys --keyid-format=long
# Look for: sec   rsa4096/YOUR_KEY_ID

# Export private key
gpg --armor --export-secret-keys YOUR_KEY_ID > ~/private-key.asc

# Export public key
gpg --armor --export YOUR_KEY_ID > ~/public-key.asc

# Print for verification
echo "Your Key ID: YOUR_KEY_ID"
gpg --fingerprint YOUR_KEY_ID
```

⚠️ **Keep `private-key.asc` secure!** Never commit to git.

### 2️⃣ Configure GitHub Secrets (2 minutes)

Go to: `https://github.com/vejeta/stremio-debian/settings/secrets/actions`

**Add three secrets:**

1. **GPG_PRIVATE_KEY**
   ```bash
   cat ~/private-key.asc
   # Copy entire output including headers
   ```

2. **GPG_KEY_ID**
   ```
   YOUR_KEY_ID
   # Example: 1234ABCD5678EFGH
   ```

3. **PAT_TOKEN** (Optional - for auto-sync)
   - Create at: https://github.com/settings/tokens/new
   - Scopes: `repo`, `workflow`
   - Copy token value

### 3️⃣ Enable GitHub Pages (1 minute)

1. Go to: `https://github.com/vejeta/stremio-debian/settings/pages`
2. Source: **GitHub Actions**
3. Custom domain: `debian.vejeta.com` (optional)
4. Save

### 4️⃣ Configure DNS (5 minutes)

**If using custom domain `debian.vejeta.com`:**

Add CNAME record in your DNS provider:
```
Type:  CNAME
Name:  debian
Value: vejeta.github.io
TTL:   3600
```

**Verify DNS:**
```bash
dig debian.vejeta.com CNAME
# Wait 5-60 minutes for propagation
```

### 5️⃣ Setup Repository Structure (5 minutes)

**Option A: Git Submodules (Recommended)**

```bash
cd github-stremio-debian

# Add Salsa repositories as submodules
git submodule add https://salsa.debian.org/mendezr/stremio.git stremio-client
git submodule add https://salsa.debian.org/mendezr/stremio-server.git stremio-server
git submodule update --init --recursive

# Commit
git add .gitmodules stremio-client stremio-server
git commit -m "Add package sources as submodules"
git push origin main
```

**Option B: Automatic Sync (Alternative)**

Skip this step. The `sync-from-salsa.yml` workflow will auto-populate on first run.

### 6️⃣ Push Workflows (2 minutes)

```bash
cd github-stremio-debian

# Verify workflows exist
ls -la .github/workflows/
# Should see:
# - build-and-release.yml
# - deploy-repository.yml
# - sync-from-salsa.yml

# Commit and push if not already done
git add .github/ repository-scripts/ docs/ SETUP.md README.md
git commit -m "Add GitHub Actions workflows and documentation"
git push origin main
```

### 7️⃣ Create First Release (2 minutes)

```bash
cd github-stremio-debian

# Create release tag
git tag -a v4.4.169-1 -m "Initial release: Stremio 4.4.169-1"

# Push tag (triggers build)
git push origin v4.4.169-1
```

### 8️⃣ Monitor Build (10 minutes)

Watch workflows at: `https://github.com/vejeta/stremio-debian/actions`

**Expected sequence:**

1. **Build and Release** (~10 min)
   - Builds stremio and stremio-server
   - Creates GitHub Release
   - Uploads .deb files

2. **Deploy Repository** (~3 min)
   - Downloads packages from release
   - Generates APT metadata
   - Signs with GPG
   - Deploys to GitHub Pages

**Check results:**

```bash
# View release
open https://github.com/vejeta/stremio-debian/releases

# Check repository
curl https://debian.vejeta.com
curl https://debian.vejeta.com/key.gpg
curl https://debian.vejeta.com/dists/bookworm/Release
```

### 9️⃣ Test Installation (5 minutes)

**On a Debian/Ubuntu system:**

```bash
# Add GPG key
wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com bookworm main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# Update and install
sudo apt update
sudo apt install stremio stremio-server

# Verify
stremio --version
which stremio-server
```

**Expected output:**
```
Get:1 https://debian.vejeta.com bookworm InRelease [...]
Reading package lists... Done
Building dependency tree... Done
The following NEW packages will be installed:
  stremio stremio-server
```

## ✅ Success Checklist

After setup, verify:

- [ ] GPG key generated and secrets configured
- [ ] GitHub Pages enabled and DNS configured
- [ ] Workflows pushed to repository
- [ ] First tag created and build succeeded
- [ ] GitHub Release created with .deb files
- [ ] Repository deployed to `debian.vejeta.com`
- [ ] `curl https://debian.vejeta.com` returns HTML
- [ ] `curl https://debian.vejeta.com/key.gpg` returns GPG key
- [ ] `apt update` sees your repository
- [ ] `apt install stremio` works successfully

## 🔄 Daily Operations

### Update Packages

**Automatic (Recommended):**
- Sync runs daily at 02:00 UTC
- Checks Salsa for updates
- Builds and deploys automatically

**Manual:**
```bash
# Trigger sync
gh workflow run sync-from-salsa.yml

# Or update submodules and tag
cd github-stremio-debian
git submodule update --remote --merge
git commit -am "Update packages to latest"
git tag -a v4.4.170-1 -m "Release 4.4.170-1"
git push origin main --tags
```

### Monitor Status

```bash
# Check workflow runs
gh run list

# View latest workflow
gh run view

# Check repository health
curl -I https://debian.vejeta.com/dists/bookworm/Release

# View download statistics
open https://github.com/vejeta/stremio-debian/releases
```

## 🆘 Troubleshooting

### Build Fails

**Check logs:**
```bash
gh run view --log
# Or visit: https://github.com/vejeta/stremio-debian/actions
```

**Common issues:**
- Missing build dependencies → Check container logs
- Lintian errors → Review package quality issues
- GPG signing fails → Verify secrets are correct

### Repository Not Accessible

**Check DNS:**
```bash
dig debian.vejeta.com
# Should resolve to GitHub Pages IPs
```

**Check GitHub Pages:**
- Settings → Pages → Should show "Your site is live"
- Wait for DNS propagation (up to 60 minutes)

### APT Update Fails

**"GPG error: NO_PUBKEY"**
```bash
# Re-import key
wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg
```

**"404 Not Found"**
- Check GitHub Actions completed successfully
- Verify DNS resolution
- Check `https://debian.vejeta.com/dists/bookworm/Release` exists

## 📚 Next Steps

- Read [SETUP.md](SETUP.md) for detailed configuration options
- Review [ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design
- Check [repository-scripts/](repository-scripts/) for management tools
- Monitor [GitHub Actions](https://github.com/vejeta/stremio-debian/actions) for builds

## 🎉 Done!

Your GitHub Pages APT repository is now live with:
- ✅ Automated builds
- ✅ GPG signing
- ✅ Zero hosting costs
- ✅ Unlimited bandwidth
- ✅ Download statistics

Share your repository: `https://debian.vejeta.com`
