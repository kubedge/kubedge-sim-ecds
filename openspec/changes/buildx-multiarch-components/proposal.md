# Buildx multi-arch images per component

## Why

The Makefile builds each of the five components as a separate image with the
architecture baked into the name (`IMG_<COMPONENT>_{DEV,AMD64,ARM64V8,ARM32V7}`). The real
target is arm64 (Apple-Silicon dev + Pi armv8). `docker buildx` produces one multi-arch
image per component under a single name:tag and the runtime resolves the arch — and it
collapses the paired operator's per-arch example CRs into one.

## What Changes

- Add a `docker-buildx` target that builds each component with
  `docker buildx build --platform linux/arm64[,linux/amd64] -t hack4easy/ecds-<component>:<tag>`.
- Drop the `_AMD64/_ARM64V8/_ARM32V7` image-name variants (one name per component).
- Coordinate with `kubedge-operator-ecds`: update its example CR to the arch-independent
  `hack4easy/ecds-<component>:<tag>` (removes the per-arch example CRs).

## Capabilities

### New Capabilities
- container-packaging: how the five ECDS component images are built.
