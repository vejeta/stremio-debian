# Self-Hosted Runner Setup for CEF Builds

This document describes how to set up a self-hosted GitHub Actions runner for building Chromium Embedded Framework (CEF) packages.

## Why Self-Hosted?

CEF builds require resources that exceed GitHub's free hosted runners:

| Resource | GitHub Free Runner | CEF Requirements |
|----------|-------------------|------------------|
| CPU | 2 vCPU | 4+ cores (8+ recommended) |
| RAM | 7 GB | 8+ GB (16+ recommended) |
| Disk | 14 GB | 40+ GB |
| Timeout | 6 hours | Up to 24 hours |

## Hardware Requirements

### Minimum
- **CPU**: 4 cores
- **RAM**: 8 GB
- **Disk**: 50 GB free (SSD strongly recommended)
- **Network**: Stable connection

### Recommended
- **CPU**: 8+ cores (significantly faster builds)
- **RAM**: 16+ GB
- **Disk**: 100 GB SSD
- **Network**: Fast connection for initial source download

### Build Time Estimates

| Hardware | Approximate Build Time |
|----------|----------------------|
| 4-core, 8GB RAM | 4-6 hours |
| 8-core, 16GB RAM | 2-4 hours |
| 16-core, 32GB RAM | 1-2 hours |
| 24-core, 64GB RAM | ~1 hour |

## Software Requirements

The runner must be running **Debian sid (unstable)** or have access to:

- clang-19, lld-19, llvm-19
- libc++-19-dev, libc++abi-19-dev
- All CEF build dependencies (see `debian/control`)

## Installation Steps

### 1. Prepare the Host Machine

```bash
# Ensure you're on Debian sid or have sid packages available
cat /etc/debian_version

# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages for the runner
sudo apt install -y curl git jq

# Install CEF build dependencies
sudo apt install -y \
    clang-19 lld-19 llvm-19 \
    libc++-19-dev libc++abi-19-dev \
    python3 python3-setuptools \
    libx11-dev libxcomposite-dev libxcursor-dev \
    libxdamage-dev libxext-dev libxfixes-dev \
    libxi-dev libxrandr-dev libxrender-dev \
    libxss-dev libxtst-dev libglib2.0-dev \
    libatk1.0-dev libatk-bridge2.0-dev \
    libcups2-dev libdrm-dev libxkbcommon-dev \
    libpango1.0-dev libcairo2-dev libasound2-dev \
    libpulse-dev libnss3-dev libnspr4-dev \
    devscripts lintian dpkg-dev fakeroot \
    git-buildpackage pristine-tar
```

### 2. Create Runner Directory

```bash
# Create directory for the runner
mkdir -p ~/actions-runner && cd ~/actions-runner
```

### 3. Download GitHub Actions Runner

Check the [latest runner release](https://github.com/actions/runner/releases) and download:

```bash
# Download (update version as needed)
curl -o actions-runner-linux-x64-2.330.0.tar.gz -L \
    https://github.com/actions/runner/releases/download/v2.330.0/actions-runner-linux-x64-2.330.0.tar.gz

# Extract
tar xzf actions-runner-linux-x64-2.330.0.tar.gz
```

### 4. Get Registration Token

1. Go to repository: https://github.com/vejeta/stremio-debian
2. Navigate to: Settings > Actions > Runners
3. Click "New self-hosted runner"
4. Copy the registration token from the configuration command

### 5. Register the Runner

```bash
./config.sh --url https://github.com/vejeta/stremio-debian \
            --token YOUR_REGISTRATION_TOKEN \
            --labels self-hosted,linux,x64,cef-builder \
            --name cef-build-runner \
            --work _work
```

**Important Labels**: The CEF workflow requires these labels:
- `self-hosted`
- `linux`
- `x64`
- `cef-builder`

### 6. Install as System Service

```bash
# Install the service
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
```

### 7. Verify Runner is Online

1. Go to: https://github.com/vejeta/stremio-debian/settings/actions/runners
2. Confirm the runner shows as "Idle" (green dot)

## Running the Runner Manually (Alternative)

For testing or one-off builds, you can run interactively:

```bash
cd ~/actions-runner
./run.sh
```

Press `Ctrl+C` to stop.

## Security Considerations

### Repository Access

Self-hosted runners execute code from the repository. Ensure:

1. **Trusted Contributors Only**: Only allow trusted users to trigger workflows
2. **Protected Branches**: Use branch protection rules
3. **Review PRs**: Don't auto-run workflows on PRs from forks

### Dedicated Machine

Consider using a dedicated machine for the runner:
- Isolate from other services
- Regular security updates
- Monitor for unusual activity

### Network Isolation

If possible:
- Place runner on isolated network segment
- Restrict outbound connections to required services
- Use firewall rules

## Maintenance

### Updating the Runner

```bash
cd ~/actions-runner
sudo ./svc.sh stop

# Download new version (check latest at https://github.com/actions/runner/releases)
curl -o actions-runner-linux-x64-2.330.0.tar.gz -L \
    https://github.com/actions/runner/releases/download/v2.330.0/actions-runner-linux-x64-2.330.0.tar.gz

# Extract (overwrites existing)
tar xzf actions-runner-linux-x64-2.330.0.tar.gz

sudo ./svc.sh start
```

### Disk Space Management

CEF builds consume significant disk space. After successful builds:

```bash
# Check disk usage
df -h

# Clean up old build artifacts if needed
rm -rf ~/actions-runner/_work/stremio-debian/stremio-debian/chromium-embedded-framework/chromium_src
rm -rf ~/actions-runner/_work/stremio-debian/stremio-debian/chromium-embedded-framework/tmp
```

### Monitoring

```bash
# Check service status
sudo systemctl status actions.runner.vejeta-stremio-debian.cef-build-runner

# View logs
journalctl -u actions.runner.vejeta-stremio-debian.cef-build-runner -f

# Check runner in GitHub UI
# https://github.com/vejeta/stremio-debian/settings/actions/runners
```

## Troubleshooting

### Runner Shows Offline

```bash
# Check service status
sudo systemctl status actions.runner.*

# Restart if needed
sudo systemctl restart actions.runner.*

# Check logs for errors
journalctl -u actions.runner.* -n 50
```

### Build Fails - Out of Memory

- Increase RAM or add swap space
- Reduce parallel jobs in ninja (modify workflow)
- Consider hardware upgrade

### Build Fails - Out of Disk Space

```bash
# Check disk usage
df -h

# Clean previous builds
rm -rf ~/actions-runner/_work/stremio-debian/stremio-debian/chromium-embedded-framework/chromium_src

# Consider using larger disk
```

### Build Timeout

The workflow has a 24-hour timeout. If builds consistently timeout:
- Check for hardware issues
- Verify network stability
- Consider more powerful hardware

### Can't Register Runner

- Ensure registration token is fresh (they expire)
- Check network connectivity to GitHub
- Verify repository permissions

## Triggering CEF Builds

CEF builds are triggered manually via GitHub Actions:

### Using GitHub CLI

```bash
gh workflow run "Build CEF Packages" -f version="138.0.1"
```

### Using GitHub Web UI

1. Go to: https://github.com/vejeta/stremio-debian/actions
2. Select "Build CEF Packages" workflow
3. Click "Run workflow"
4. Enter the CEF version
5. Click "Run workflow"

### Monitoring Build Progress

```bash
# Watch the build
gh run watch

# Or view in browser
# https://github.com/vejeta/stremio-debian/actions
```

## Alternative: Cloud-Based Self-Hosted Runner

For occasional builds without dedicated hardware, consider cloud instances:

### AWS EC2

- Instance type: `c5.2xlarge` (8 vCPU, 16GB RAM)
- Storage: 100GB gp3 SSD
- Estimated cost: ~$0.34/hour
- ~$5-10 per CEF build

### Google Cloud

- Machine type: `e2-standard-8` (8 vCPU, 32GB RAM)
- Storage: 100GB SSD persistent disk
- Estimated cost: ~$0.27/hour
- Use preemptible instances for lower cost

### Setup for Cloud

1. Launch instance with Debian sid
2. Install dependencies
3. Register runner
4. Run build
5. Terminate instance when done

This approach trades convenience for cost efficiency.
