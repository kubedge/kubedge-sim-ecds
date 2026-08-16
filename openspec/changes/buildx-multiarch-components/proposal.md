# Buildx multi-arch images per component (promote the existing .buildkit Dockerfiles)

## Why

The five ECDS components currently build as arch-suffixed images
(`hack4easy/ecds-<component>-{dev,amd64,arm32v7,arm64v8}`) via a **25-Dockerfile per-arch
explosion** — the painful legacy Note 18 targets. But multi-stage, `TARGETARCH`-aware,
distroless Dockerfiles **already exist** at `build/Dockerfile.ecds-<component>.buildkit`.
Promote those and drive them with `docker buildx` to produce one multi-arch image per
component; the runtime resolves the arch.

## What Changes (buildx is the sole go-forward path)

- Per component, wire a buildx target using the existing `.buildkit` Dockerfile:
  `docker buildx build --platform ${PLATFORMS} -f build/Dockerfile.ecds-<component>.buildkit
   -t hack4easy/ecds-<component>:v${VERSION} --push .` (`PLATFORMS ?= linux/arm64,linux/amd64`).
- `VERSION_V1` → `VERSION`; drop the `-<arch>` image suffixes (one name per component).
- **Comment out (retire, don't delete)** — marked `# RETIRED: superseded by docker-buildx`:
  the per-arch `docker-build-<component>-{dev,amd64,arm32v7,arm64v8}` targets; the
  `IMG_<C>_{DEV,AMD64,ARM64V8,ARM32V7}` vars; the plain + per-arch Dockerfiles
  (`build/Dockerfile.ecds-<component>[.amd64|.arm32v7|.arm64v8]`) — keep only the `.buildkit` one.
- **Coordinate with `kubedge-operator-ecds`:** update its example CR image refs from
  `hack4easy/ecds-<component>-arm64v8:v<ver>` to `hack4easy/ecds-<component>:v<ver>`.

## Non-goals

- Rewriting the `.buildkit` Dockerfiles — they're already correct multi-stage. Only align
  the go builder image with the bumped go version if needed.

## Capabilities

### New Capabilities
- container-packaging: how the five ECDS component images are built (single multi-arch each).
