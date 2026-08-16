# Tasks — buildx-multiarch-components (promote .buildkit; retire the rest)

> Note 18 policy: buildx is the sole go-forward path. Comment out the legacy per-arch
> machinery (retire, don't delete) — `# RETIRED: superseded by docker-buildx`.

- [ ] Ensure a live builder: `docker buildx ls`; on Apple-Silicon **`colima start`** first.
- [ ] Makefile: `VERSION_V1`→`VERSION`; add `PLATFORMS ?= linux/arm64,linux/amd64`.
- [ ] Confirm the `.buildkit` Dockerfiles build the right binary per component
      (`cmd/<component>/main.go`, `-tags` if needed). Align the builder image with the bumped go
      (they use `golang:1.23` — fine if go-version-bump targets ≤1.23).
- [ ] Add a buildx target per component (or a loop over `platform frontend enrichment businesslogic loadbalancer`):
      ```
      docker-buildx-<component>: vet
      	docker buildx build --platform ${PLATFORMS} -f build/Dockerfile.ecds-<component>.buildkit \
      		-t hack4easy/ecds-<component>:v${VERSION} -t hack4easy/ecds-<component>:latest --push .
      docker-buildx: docker-buildx-platform docker-buildx-frontend docker-buildx-enrichment docker-buildx-businesslogic docker-buildx-loadbalancer
      ```
- [ ] **Comment out (retire)**: the per-arch `docker-build-<component>-{dev,amd64,arm32v7,arm64v8}`
      targets and the `IMG_<C>_{DEV,AMD64,ARM64V8,ARM32V7}` vars.
- [ ] **Comment out / move to legacy/**: the plain + per-arch Dockerfiles
      `build/Dockerfile.ecds-<component>[.amd64|.arm32v7|.arm64v8]` — keep only `.buildkit`.
- [ ] Verify: `make -n docker-buildx` references only `hack4easy/ecds-<component>:v${VERSION}`
      (no `-dev/-amd64/-arm32v7/-arm64v8`); Go build/vet/test stay green.
- [ ] With colima up: `make docker-buildx`; `docker buildx imagetools inspect hack4easy/ecds-frontend:v${VERSION}` → manifest list incl. linux/arm64.
- [ ] **Coordinate**: update `kubedge-operator-ecds`'s `examples/*.yaml` image refs to
      `hack4easy/ecds-<component>:v<ver>` (drop `-arm64v8` etc.), so the operator deploys these images.
