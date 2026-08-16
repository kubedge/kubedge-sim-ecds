# Tasks — buildx-multiarch-components

- [ ] Confirm buildx + a running builder (colima on Apple-Silicon).
- [ ] For each of platform/frontend/enrichment/businesslogic/loadbalancer: add a buildx target `docker buildx build --platform linux/arm64 -t hack4easy/ecds-<component>:<tag>` (add `,linux/amd64` only if still needed).
- [ ] Ensure each component Dockerfile is multi-stage (compiles per TARGETOS/TARGETARCH) rather than copying a prebuilt amd64 binary.
- [ ] Remove the `_AMD64/_ARM64V8/_ARM32V7` image-name variables.
- [ ] `docker buildx imagetools inspect` each image → manifest list incl. linux/arm64.
- [ ] Update the paired operator-ecds example CR(s) to the arch-independent image names.
