## ADDED Requirements

### Requirement: Each ECDS component is one multi-arch image via `docker buildx`

Each of the five components (platform, frontend, enrichment, businesslogic, loadbalancer)
SHALL be built as one multi-arch image `hack4easy/ecds-<component>:v${VERSION}` covering at
least `linux/arm64` via `docker buildx`, driven by the existing multi-stage
`build/Dockerfile.ecds-<component>.buildkit`. `docker buildx` is the sole go-forward path.

#### Scenario: a component image serves all target arches
- **WHEN** `docker buildx imagetools inspect hack4easy/ecds-frontend:v${VERSION}` runs after a build
- **THEN** it resolves to a manifest list including `linux/arm64`, with no arch-suffixed variant

### Requirement: Legacy per-arch build machinery is commented out, not deleted

The legacy per-arch machinery SHALL be **commented out (retired-but-preserved, marked
`# RETIRED: superseded by docker-buildx`), not deleted**: the
`docker-build-<component>-{dev,amd64,arm32v7,arm64v8}` targets, the
`IMG_<C>_{DEV,AMD64,ARM64V8,ARM32V7}` vars, and the plain + per-arch Dockerfiles
(`build/Dockerfile.ecds-<component>[.amd64|.arm32v7|.arm64v8]`) — only the `.buildkit`
Dockerfile stays live.

#### Scenario: no live reference to the legacy paths
- **WHEN** `make -n docker-buildx` is run
- **THEN** it references only `hack4easy/ecds-<component>:v${VERSION}` images and the `.buildkit` Dockerfiles — never a `-dev/-amd64/-arm32v7/-arm64v8` image or a per-arch Dockerfile

### Requirement: Component image names stay in sync with the paired operator CR

The image names produced here SHALL match what `kubedge-operator-ecds`'s ECDSCluster
example CR references; dropping the arch suffix requires updating that CR to
`hack4easy/ecds-<component>:v<ver>`.

#### Scenario: operator can deploy the built images
- **WHEN** operator-ecds applies its example ECDSCluster CR
- **THEN** the image refs resolve to the multi-arch `hack4easy/ecds-<component>:v<ver>` images built here
