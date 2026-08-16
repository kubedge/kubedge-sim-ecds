## ADDED Requirements

### Requirement: Each ECDS component is a single multi-arch image built with buildx

Each of the five components (platform, frontend, enrichment, businesslogic,
loadbalancer) SHALL be built as one multi-arch image `hack4easy/ecds-<component>:<tag>`
covering at least `linux/arm64` via `docker buildx`, replacing the arch-suffixed image
variants. The paired operator's example CR SHALL reference these arch-independent names.

#### Scenario: a component image serves all target arches
- **WHEN** `docker buildx imagetools inspect hack4easy/ecds-frontend:<tag>` runs after a build
- **THEN** it resolves to a manifest list including `linux/arm64`, and no arch-suffixed variant is produced
