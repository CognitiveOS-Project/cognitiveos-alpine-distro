# CognitiveOS Distribution

Build scripts and configurations for producing a bootable CognitiveOS image based on Alpine Linux.

## Critical Findings

### Repository Setup
- **Always use `gh repo clone`** — plain `git clone` may resolve SSH URLs incorrectly,
  resulting in remotes pointing to wrong repositories.
- All repos use SSH (`git@github.com:CognitiveOS-Project/*`), never HTTPS.

### Per-Repo Build Architecture
Each Go repo (cpm, cognitiveosd, cli, inference, core-mcp-bridges) builds independently
via its own `Makefile` and `scripts/build.sh`. The distro's `build-binaries.sh` orchestrates
by invoking each repo's `make build` and collecting the resulting binaries from `build/bin/`.

### Workflow Notes
- `libgpiod-tools` does not exist in Alpine edge — removed from all package lists.
- `build-binaries.sh`, `build-image.sh`, `build-overlay.sh`, `publish-cgp.sh`,
  `sign.sh`, `build-distro-tarball.sh` all use `#!/bin/bash` (not `#!/bin/sh`).
- `nproc` quoting: use `$(nproc)`, not `"$(nproc)"` or `nproc` alone (SC2046).
- Inference builds: `CGO_ENABLED=0` in CI (mock backend); CGo with llama.cpp for production.

## Build Output

- Bootable ISO image for x86_64
- Raspberry Pi image (aarch64)
- Bootable ARM image (armv7)
- Docker image (`docker/Dockerfile.release` → `ghcr.io/CognitiveOS-Project/cognitiveos-distro`)
- Distro tarball (portable overlay + binaries, build ISO/RPi on any Alpine host)
- `.cgp` packages published to the CognitiveOS registry-server

## CI/CD

### Workflows

- `ci.yml` — shellcheck + Go compilation verification on PR/commit
- `docker.yml` — build & push Docker image to GHCR on push to main or v* tags
- `release.yml` — on v* tag:
  1. Build Go binaries + overlay
  2. Create distro tarball (upload to Release)
  3. Publish `.cgp` packages to registry-server
  4. Create GitHub Release with artifacts

### Secrets

| Secret | Used By | Description |
|--------|---------|-------------|
| `REGISTRY_TOKEN` | release.yml | Bearer token for registry-server publish |
| `REGISTRY_URL` | release.yml | Registry base URL (default: official primary) |

## Makefile Targets

| Target | Description |
|--------|-------------|
| `iso` | Build x86_64 ISO (requires Alpine + mkimage) |
| `rpi` | Build aarch64 RPi image |
| `install-local` | Orchestrate per-repo builds (make build) + assemble overlay |
| `distro-tarball` | Build portable distro tarball (overlay + binaries) |
| `publish-cgp` | Publish .cgp packages to registry (needs REGISTRY_TOKEN) |
| `docker-release` | Build Docker release image from Dockerfile.release |
| `release` | distro-tarball + docker-release |
| `docker` | Build Docker build image (cross-compilation) |
| `shell` | Interactive shell in build container |
| `checksums` / `sign` | Generate SHA-256 + GPG signatures |

## Structure

```
├── overlay/                  # Files baked into root filesystem
│   └── etc/
│       ├── inittab           # Boot into cognitiveos-cli
│       ├── hostname
│       └── cognitiveos/      # config.toml, registries.toml
├── packages.*                # Alpine package lists per architecture
├── scripts/
│   ├── build-binaries.sh     # Orchestrate per-repo builds (make build)
│   ├── build-overlay.sh      # Assemble overlay from built binaries
│   ├── build-image.sh        # Run mkimage with Docker fallback (--profile x86_64|aarch64)
│   ├── build-distro-tarball.sh # Portable distro archive
│   ├── publish-cgp.sh        # Build .cgp from binary + publish to registry
│   └── sign.sh               # Checksums and GPG signatures
├── docker/
│   ├── Dockerfile.build      # Cross-compilation build environment
│   └── Dockerfile.release    # Minimal runtime image for GHCR
└── Makefile                  # Top-level automation
```
