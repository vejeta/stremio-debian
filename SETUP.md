# Setup Guide: GitHub Pages APT Repository

Complete setup instructions for deploying your Debian repository to GitHub Pages with automated builds.

## Prerequisites

- GitHub repository: `vejeta/stremio-debian`
- Domain: `debian.vejeta.com` (or use `username.github.io/repo-name`)
- GPG key for signing packages
- Admin access to GitHub repository

## 🔐 Step 1: Generate GPG Key

### Create new GPG key for package signing

```bash
# Generate GPG key
gpg --full-generate-key

# Follow prompts:
# - Key type: (1) RSA and RSA (default)
# - Key size: 4096
# - Expiration: 0 (no expiration) or 2-5 years
# - Real name: "Stremio Debian Repository"
# - Email: your-email@domain.com
# - Comment: "Package signing key"
```

### Export GPG key components

```bash
# List keys to get KEY_ID
gpg --list-secret-keys --keyid-format=long

# Example output:
# sec   rsa4096/1234ABCD5678EFGH 2024-01-01 [SC]
#       FULL_FINGERPRINT_HERE
# uid   [ultimate] Stremio Debian Repository <email@domain.com>
# ssb   rsa4096/9876FEDC5432HGFE 2024-01-01 [E]

# Your KEY_ID is: 1234ABCD5678EFGH

# Export private key (for GitHub Secrets)
gpg --armor --export-secret-keys 1234ABCD5678EFGH > private-key.asc

# Export public key (will be hosted at debian.vejeta.com/key.gpg)
gpg --armor --export 1234ABCD5678EFGH > public-key.asc

# Display key fingerprint (users will verify this)
gpg --fingerprint 1234ABCD5678EFGH
```

⚠️ **Important**: Keep `private-key.asc` secure and never commit it to git!

## 🔧 Step 2: Configure GitHub Secrets

Navigate to: `https://github.com/vejeta/stremio-debian/settings/secrets/actions`

### Required Secrets

1. **GPG_PRIVATE_KEY**
   ```bash
   # Copy entire contents of private-key.asc
   cat private-key.asc
   ```
   - Name: `GPG_PRIVATE_KEY`
   - Value: Full content including `-----BEGIN PGP PRIVATE KEY BLOCK-----` headers

2. **GPG_KEY_ID**
   - Name: `GPG_KEY_ID`
   - Value: Your key ID (e.g., `1234ABCD5678EFGH`)

3. **PAT_TOKEN** (Optional, for automatic sync workflow)
   - Create at: https://github.com/settings/tokens/new
   - Scopes needed: `repo`, `workflow`
   - Name: `PAT_TOKEN`
   - Value: Your generated personal access token
   - Note: Only needed if you want automatic Salsa sync to trigger builds

### Verify Secrets

All three secrets should appear in your repository secrets:
- ✅ `GPG_PRIVATE_KEY`
- ✅ `GPG_KEY_ID`
- ✅ `PAT_TOKEN` (optional)

## 🌐 Step 3: Enable GitHub Pages

### Enable Pages in Repository Settings

1. Go to: `https://github.com/vejeta/stremio-debian/settings/pages`

2. Configure:
   - **Source**: GitHub Actions
   - **Branch**: Not applicable (using Actions deployment)

3. Save settings

### Configure Custom Domain (Optional)

If using `debian.vejeta.com`:

1. **In GitHub Settings** (same Pages settings page):
   - Custom domain: `debian.vejeta.com`
   - Check "Enforce HTTPS" (after DNS propagates)

2. **In DNS Provider** (e.g., Cloudflare, Route53):

   Add CNAME record:
   ```
   Type:  CNAME
   Name:  debian
   Value: vejeta.github.io
   TTL:   Auto/3600
   ```

   Alternative (using A records):
   ```
   Type:  A
   Name:  debian
   Value: 185.199.108.153

   Type:  A
   Name:  debian
   Value: 185.199.109.153

   Type:  A
   Name:  debian
   Value: 185.199.110.153

   Type:  A
   Name:  debian
   Value: 185.199.111.153
   ```

3. **Create CNAME file** (handled automatically by workflow):
   The workflow creates this, but you can also add manually:
   ```bash
   echo "debian.vejeta.com" > github-stremio-debian/CNAME
   git add CNAME
   git commit -m "Add custom domain"
   git push
   ```

### Verify DNS Configuration

```bash
# Check CNAME resolution
dig debian.vejeta.com CNAME

# Check A record resolution
dig debian.vejeta.com A

# Wait 5-60 minutes for DNS propagation
```

## 📦 Step 4: Setup Repository Structure

### Option A: Using Git Submodules (Recommended)

```bash
cd github-stremio-debian

# Add stremio-client as submodule
git submodule add https://salsa.debian.org/mendezr/stremio.git stremio-client

# Add stremio-server as submodule
git submodule add https://salsa.debian.org/mendezr/stremio-server.git stremio-server

# Initialize and update
git submodule update --init --recursive

# Commit
git add .gitmodules stremio-client stremio-server
git commit -m "Add Salsa repositories as submodules"
git push
```

**Benefits**:
- Direct link to upstream repositories
- Easy to see which commit is being built
- Standard git workflow for updates

**Update submodules**:
```bash
git submodule update --remote --merge
git commit -am "Update submodules to latest upstream"
git push
```

### Option B: Using Automatic Sync Workflow (Alternative)

The `sync-from-salsa.yml` workflow will automatically:
- Clone repositories daily at 02:00 UTC
- Check for updates
- Commit changes if updates found
- Trigger builds automatically

Enable by:
1. Ensure `PAT_TOKEN` secret is configured
2. Wait for scheduled run, or trigger manually:
   - Go to Actions → "Sync from Salsa Debian"
   - Click "Run workflow"

### Option C: Manual Mirror (Not Recommended)

```bash
# Clone and copy manually
git clone https://salsa.debian.org/mendezr/stremio.git tmp-stremio
cp -r tmp-stremio github-stremio-debian/stremio-client
rm -rf tmp-stremio

# Same for server
git clone https://salsa.debian.org/mendezr/stremio-server.git tmp-server
cp -r tmp-server github-stremio-debian/stremio-server
rm -rf tmp-server

# Commit
git add stremio-client stremio-server
git commit -m "Add package sources"
git push
```

## 🚀 Step 5: Create First Release

### Create a Git Tag

```bash
cd github-stremio-debian

# Create annotated tag
git tag -a v4.4.169-1 -m "Release Stremio 4.4.169-1"

# Push tag to GitHub
git push origin v4.4.169-1
```

### Watch Build Process

1. Go to: `https://github.com/vejeta/stremio-debian/actions`

2. Watch workflows:
   - **"Build and Release Debian Packages"** - Builds .deb files
   - **"Deploy APT Repository"** - Deploys to GitHub Pages

3. Check outputs:
   - Release created at: `https://github.com/vejeta/stremio-debian/releases`
   - Repository deployed at: `https://debian.vejeta.com`

### Verify Deployment

```bash
# Check website
curl https://debian.vejeta.com

# Check GPG key availability
curl https://debian.vejeta.com/key.gpg

# Check repository structure
curl https://debian.vejeta.com/dists/bookworm/Release

# Check package index
curl https://debian.vejeta.com/dists/bookworm/main/binary-amd64/Packages
```

## 🧪 Step 6: Test APT Repository

### On a Debian/Ubuntu System

```bash
# Add GPG key
wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com bookworm main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# Update package index
sudo apt update

# Should see: "Get:1 https://debian.vejeta.com bookworm InRelease"

# Install packages
sudo apt install stremio stremio-server

# Verify installation
which stremio
stremio --version
```

### Troubleshooting

**"GPG error: NO_PUBKEY"**:
```bash
# Re-import key
wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg
```

**"404 Not Found" for packages**:
- Check GitHub Actions completed successfully
- Verify DNS resolution: `dig debian.vejeta.com`
- Wait for DNS propagation (up to 60 minutes)

**"Release file signature verification failed"**:
- GPG key might be wrong in GitHub Secrets
- Check: `curl https://debian.vejeta.com/key.gpg | gpg --import`
- Compare fingerprint with your local key

## 🔄 Step 7: Automated Updates Workflow

### Push-based Updates (Manual)

```bash
# Make changes to packages in Salsa repositories
# Then update GitHub repository:

cd github-stremio-debian

# If using submodules:
git submodule update --remote --merge
git commit -am "Update to latest upstream"

# Create new tag
git tag -a v4.4.170-1 -m "Release 4.4.170-1"
git push origin main --tags

# Automatic build will trigger
```

### Schedule-based Updates (Automatic)

The `sync-from-salsa.yml` workflow runs daily:
- Checks Salsa repositories for updates
- Syncs changes automatically
- Triggers build if changes detected

Monitor at: `https://github.com/vejeta/stremio-debian/actions`

### Manual Trigger

```bash
# Via GitHub CLI
gh workflow run sync-from-salsa.yml

# Or via web interface:
# Actions → "Sync from Salsa Debian" → "Run workflow"
```

## 📊 Step 8: Monitor and Maintain

### Check Build Status

GitHub Actions badge (add to README):
```markdown
![Build Status](https://github.com/vejeta/stremio-debian/actions/workflows/build-and-release.yml/badge.svg)
```

### View Download Statistics

- GitHub Releases page shows download counts
- Individual release assets show download numbers
- No additional analytics needed (GitHub provides built-in stats)

### Update GPG Key (if expiring)

```bash
# Extend expiration
gpg --edit-key 1234ABCD5678EFGH
gpg> expire
# Select new expiration
gpg> save

# Export updated keys
gpg --armor --export-secret-keys 1234ABCD5678EFGH > private-key-updated.asc
gpg --armor --export 1234ABCD5678EFGH > public-key-updated.asc

# Update GitHub Secret GPG_PRIVATE_KEY
# Deployment workflow will publish updated public key automatically
```

### Clean Up Old Releases (Optional)

```bash
# Via GitHub CLI
gh release list
gh release delete v4.4.168-1  # Delete old release

# Or via web interface
```

## ✅ Verification Checklist

After completing setup:

- [ ] GPG key generated and exported
- [ ] GitHub Secrets configured (GPG_PRIVATE_KEY, GPG_KEY_ID, PAT_TOKEN)
- [ ] GitHub Pages enabled
- [ ] Custom domain configured and DNS propagated
- [ ] Repository structure created (submodules or sync workflow)
- [ ] First tag created and pushed
- [ ] Build workflow completed successfully
- [ ] Deploy workflow completed successfully
- [ ] Repository accessible at https://debian.vejeta.com
- [ ] GPG key downloadable at https://debian.vejeta.com/key.gpg
- [ ] Packages installable via `apt install stremio`
- [ ] Automatic sync workflow running (if enabled)

## 🆘 Support

- **GitHub Issues**: https://github.com/vejeta/stremio-debian/issues
- **Workflow Logs**: Check Actions tab for detailed error messages
- **Salsa Repositories**:
  - https://salsa.debian.org/mendezr/stremio
  - https://salsa.debian.org/mendezr/stremio-server

---

**Next Steps**: See [USAGE.md](docs/USAGE.md) for ongoing maintenance and [ARCHITECTURE.md](docs/ARCHITECTURE.md) for system design details.
