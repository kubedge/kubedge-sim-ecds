
# Image URL to use all building/pushing image targets
VERSION                     ?= 0.2.24

# Arch-independent image tags — one multi-arch manifest list per component,
# produced by the `docker-buildx` path below. These are the tags the paired
# kubedge-operator-ecds ECDSCluster CR references.
IMG_BUSINESSLOGIC           ?= hack4easy/ecds-businesslogic:v${VERSION}
IMG_ENRICHMENT              ?= hack4easy/ecds-enrichment:v${VERSION}
IMG_FRONTEND                ?= hack4easy/ecds-frontend:v${VERSION}
IMG_LOADBALANCER            ?= hack4easy/ecds-loadbalancer:v${VERSION}
IMG_PLATFORM                ?= hack4easy/ecds-platform:v${VERSION}

# RETIRED: superseded by docker-buildx — the arch-suffixed (-dev/-amd64/
# -arm64v8/-arm32v7) image tags are replaced by the single arch-independent
# IMG_<C> above (buildx emits one multi-arch manifest list per component).
# IMG_BUSINESSLOGIC_DEV       ?= hack4easy/ecds-businesslogic-dev:v${VERSION}
# IMG_ENRICHMENT_DEV          ?= hack4easy/ecds-enrichment-dev:v${VERSION}
# IMG_FRONTEND_DEV            ?= hack4easy/ecds-frontend-dev:v${VERSION}
# IMG_LOADBALANCER_DEV        ?= hack4easy/ecds-loadbalancer-dev:v${VERSION}
# IMG_PLATFORM_DEV            ?= hack4easy/ecds-platform-dev:v${VERSION}
#
# IMG_BUSINESSLOGIC_AMD64     ?= hack4easy/ecds-businesslogic-amd64:v${VERSION}
# IMG_ENRICHMENT_AMD64        ?= hack4easy/ecds-enrichment-amd64:v${VERSION}
# IMG_FRONTEND_AMD64          ?= hack4easy/ecds-frontend-amd64:v${VERSION}
# IMG_LOADBALANCER_AMD64      ?= hack4easy/ecds-loadbalancer-amd64:v${VERSION}
# IMG_PLATFORM_AMD64          ?= hack4easy/ecds-platform-amd64:v${VERSION}
#
# IMG_BUSINESSLOGIC_ARM64V8   ?= hack4easy/ecds-businesslogic-arm64v8:v${VERSION}
# IMG_ENRICHMENT_ARM64V8      ?= hack4easy/ecds-enrichment-arm64v8:v${VERSION}
# IMG_FRONTEND_ARM64V8        ?= hack4easy/ecds-frontend-arm64v8:v${VERSION}
# IMG_LOADBALANCER_ARM64V8    ?= hack4easy/ecds-loadbalancer-arm64v8:v${VERSION}
# IMG_PLATFORM_ARM64V8        ?= hack4easy/ecds-platform-arm64v8:v${VERSION}
#
# IMG_BUSINESSLOGIC_ARM32V7   ?= hack4easy/ecds-businesslogic-arm32v7:v${VERSION}
# IMG_ENRICHMENT_ARM32V7      ?= hack4easy/ecds-enrichment-arm32v7:v${VERSION}
# IMG_FRONTEND_ARM32V7        ?= hack4easy/ecds-frontend-arm32v7:v${VERSION}
# IMG_LOADBALANCER_ARM32V7    ?= hack4easy/ecds-loadbalancer-arm32v7:v${VERSION}
# IMG_PLATFORM_ARM32V7        ?= hack4easy/ecds-platform-arm32v7:v${VERSION}

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

# docker-buildx is the sole go-forward image path: one multi-arch manifest
# list per component, built from build/Dockerfile.ecds-<c>.buildkit (which
# pins `FROM --platform=$$BUILDPLATFORM` and cross-compiles via GOARCH).
all: docker-buildx

setup:
ifndef GOPATH
	$(error GOPATH not defined, please define GOPATH. Run "go help gopath" to learn more about GOPATH)
endif
	# dep ensure

clean:
	rm -fr vendor
	rm -fr cover.out
	rm -fr build/_output
	rm -fr go.sum

unittest: setup fmt vet
	go test ./pkg/... ./cmd/... -coverprofile cover.out

# Run go fmt against code
fmt: setup
	go fmt ./pkg/... ./cmd/...

vet: fmt
	go vet -composites=false ./pkg/... ./cmd/...

# ---------------------------------------------------------------------------
# Cross-platform multi-arch images (buildx) — THE go-forward path.
# Each target drives the existing build/Dockerfile.ecds-<c>.buildkit directly.
# The Dockerfile already pins the builder to $$BUILDPLATFORM and cross-compiles
# (CGO_ENABLED=0, GOARCH=$$TARGETARCH), so no per-arch emulation is needed.
# Requires a live buildx builder (e.g. `colima start` on Apple Silicon).
# NOTE: buildx pushes multi-arch manifests directly (can't --load a manifest
# list), so these targets --push. arm/v7 retired from the default PLATFORMS
# (validated on arm64+amd64); re-add `,linux/arm/v7` if a target needs it.
# ---------------------------------------------------------------------------
PLATFORMS ?= linux/arm64,linux/amd64

.PHONY: docker-businesslogic-buildx
docker-businesslogic-buildx: ## Build and push the multi-arch businesslogic image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_BUSINESSLOGIC} -f build/Dockerfile.ecds-businesslogic.buildkit .

.PHONY: docker-loadbalancer-buildx
docker-loadbalancer-buildx: ## Build and push the multi-arch loadbalancer image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_LOADBALANCER} -f build/Dockerfile.ecds-loadbalancer.buildkit .

.PHONY: docker-frontend-buildx
docker-frontend-buildx: ## Build and push the multi-arch frontend image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_FRONTEND} -f build/Dockerfile.ecds-frontend.buildkit .

.PHONY: docker-enrichment-buildx
docker-enrichment-buildx: ## Build and push the multi-arch enrichment image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_ENRICHMENT} -f build/Dockerfile.ecds-enrichment.buildkit .

.PHONY: docker-platform-buildx
docker-platform-buildx: ## Build and push the multi-arch platform image
	$(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) -t ${IMG_PLATFORM} -f build/Dockerfile.ecds-platform.buildkit .

# Cross compilation — build + push all five multi-arch images
docker-buildx: fmt vet docker-businesslogic-buildx docker-loadbalancer-buildx docker-frontend-buildx docker-enrichment-buildx docker-platform-buildx

# ===========================================================================
# RETIRED: superseded by docker-buildx.
# The per-variant (dev / amd64 / arm32v7 / arm64v8) single-arch build + push
# targets below drove the plain + per-arch Dockerfiles (build/Dockerfile.ecds-*
# and *.amd64 / *.arm32v7 / *.arm64v8). They are kept commented (not deleted)
# for reference and rollback. The go-forward path is the buildx section above.
# ===========================================================================
#
# docker-build-businesslogic-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-businesslogic -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=businesslogic ./cmd/businesslogic/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-businesslogic -t ${IMG_BUSINESSLOGIC_DEV}
# docker-push-businesslogic-dev:
# 	docker push ${IMG_BUSINESSLOGIC_DEV}
# docker-build-enrichment-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-enrichment -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=enrichment ./cmd/enrichment/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-enrichment -t ${IMG_ENRICHMENT_DEV}
# docker-push-enrichment-dev:
# 	docker push ${IMG_ENRICHMENT_DEV}
# docker-build-frontend-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-frontend -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=frontend ./cmd/frontend/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-frontend -t ${IMG_FRONTEND_DEV}
# docker-push-frontend-dev:
# 	docker push ${IMG_FRONTEND_DEV}
# docker-build-loadbalancer-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-loadbalancer -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=loadbalancer ./cmd/loadbalancer/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-loadbalancer -t ${IMG_LOADBALANCER_DEV}
# docker-push-loadbalancer-dev:
# 	docker push ${IMG_LOADBALANCER_DEV}
# docker-build-platform-dev: vet
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-platform -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=platform ./cmd/platform/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-platform -t ${IMG_PLATFORM_DEV}
# docker-push-platform-dev:
# 	docker push ${IMG_PLATFORM_DEV}
#
# --- AMD64 production ---
# docker-build-businesslogic-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/ecds-businesslogic -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=businesslogic ./cmd/businesslogic/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-businesslogic.amd64 -t ${IMG_BUSINESSLOGIC_AMD64}
# docker-push-businesslogic-amd64:
# 	docker push ${IMG_BUSINESSLOGIC_AMD64}
# docker-build-enrichment-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/ecds-enrichment -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=enrichment ./cmd/enrichment/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-enrichment.amd64 -t ${IMG_ENRICHMENT_AMD64}
# docker-push-enrichment-amd64:
# 	docker push ${IMG_ENRICHMENT_AMD64}
# docker-build-frontend-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/ecds-frontend -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=frontend ./cmd/frontend/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-frontend.amd64 -t ${IMG_FRONTEND_AMD64}
# docker-push-frontend-amd64:
# 	docker push ${IMG_FRONTEND_AMD64}
# docker-build-loadbalancer-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/ecds-loadbalancer -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=loadbalancer ./cmd/loadbalancer/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-loadbalancer.amd64 -t ${IMG_LOADBALANCER_AMD64}
# docker-push-loadbalancer-amd64:
# 	docker push ${IMG_LOADBALANCER_AMD64}
# docker-build-platform-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/ecds-platform -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=platform ./cmd/platform/...
# 	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.ecds-platform.amd64 -t ${IMG_PLATFORM_AMD64}
# docker-push-platform-amd64:
# 	docker push ${IMG_PLATFORM_AMD64}
#
# --- ARM32V7 ---
# docker-build-businesslogic-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/ecds-businesslogic -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=businesslogic ./cmd/businesslogic/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.ecds-businesslogic.arm32v7 -t ${IMG_BUSINESSLOGIC_ARM32V7}
# docker-push-businesslogic-arm32v7:
# 	docker push ${IMG_BUSINESSLOGIC_ARM32V7}
# docker-build-enrichment-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/ecds-enrichment -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=enrichment ./cmd/enrichment/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.ecds-enrichment.arm32v7 -t ${IMG_ENRICHMENT_ARM32V7}
# docker-push-enrichment-arm32v7:
# 	docker push ${IMG_ENRICHMENT_ARM32V7}
# docker-build-frontend-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/ecds-frontend -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=frontend ./cmd/frontend/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.ecds-frontend.arm32v7 -t ${IMG_FRONTEND_ARM32V7}
# docker-push-frontend-arm32v7:
# 	docker push ${IMG_FRONTEND_ARM32V7}
# docker-build-loadbalancer-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/ecds-loadbalancer -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=loadbalancer ./cmd/loadbalancer/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.ecds-loadbalancer.arm32v7 -t ${IMG_LOADBALANCER_ARM32V7}
# docker-push-loadbalancer-arm32v7:
# 	docker push ${IMG_LOADBALANCER_ARM32V7}
# docker-build-platform-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/ecds-platform -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=platform ./cmd/platform/...
# 	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.ecds-platform.arm32v7 -t ${IMG_PLATFORM_ARM32V7}
# docker-push-platform-arm32v7:
# 	docker push ${IMG_PLATFORM_ARM32V7}
#
# --- ARM64V8 ---
# docker-build-businesslogic-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/ecds-businesslogic -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=businesslogic ./cmd/businesslogic/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.ecds-businesslogic.arm64v8 -t ${IMG_BUSINESSLOGIC_ARM64V8}
# docker-push-businesslogic-arm64v8:
# 	docker push ${IMG_BUSINESSLOGIC_ARM64V8}
# docker-build-enrichment-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/ecds-enrichment -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=enrichment ./cmd/enrichment/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.ecds-enrichment.arm64v8 -t ${IMG_ENRICHMENT_ARM64V8}
# docker-push-enrichment-arm64v8:
# 	docker push ${IMG_ENRICHMENT_ARM64V8}
# docker-build-frontend-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/ecds-frontend -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=frontend ./cmd/frontend/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.ecds-frontend.arm64v8 -t ${IMG_FRONTEND_ARM64V8}
# docker-push-frontend-arm64v8:
# 	docker push ${IMG_FRONTEND_ARM64V8}
# docker-build-loadbalancer-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/ecds-loadbalancer -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=loadbalancer ./cmd/loadbalancer/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.ecds-loadbalancer.arm64v8 -t ${IMG_LOADBALANCER_ARM64V8}
# docker-push-loadbalancer-arm64v8:
# 	docker push ${IMG_LOADBALANCER_ARM64V8}
# docker-build-platform-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/ecds-platform -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=platform ./cmd/platform/...
# 	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.ecds-platform.arm64v8 -t ${IMG_PLATFORM_ARM64V8}
# docker-push-platform-arm64v8:
# 	docker push ${IMG_PLATFORM_ARM64V8}
#
# --- Retired aggregates ---
# docker-build-dev: docker-build-businesslogic-dev docker-build-enrichment-dev docker-build-frontend-dev docker-build-loadbalancer-dev docker-build-platform-dev
# docker-build-amd64: docker-build-businesslogic-amd64 docker-build-enrichment-amd64 docker-build-frontend-amd64 docker-build-loadbalancer-amd64 docker-build-platform-amd64
# docker-build-arm32v7: docker-build-businesslogic-arm32v7 docker-build-enrichment-arm32v7 docker-build-frontend-arm32v7 docker-build-loadbalancer-arm32v7 docker-build-platform-arm32v7
# docker-build-arm64v8: docker-build-businesslogic-arm64v8 docker-build-enrichment-arm64v8 docker-build-frontend-arm64v8 docker-build-loadbalancer-arm64v8 docker-build-platform-arm64v8
# docker-build: fmt vet docker-build-dev docker-build-amd64 docker-build-arm32v7 docker-build-arm64v8
# docker-push-dev: docker-push-businesslogic-dev docker-push-enrichment-dev docker-push-frontend-dev docker-push-loadbalancer-dev docker-push-platform-dev
# docker-push-amd64: docker-push-businesslogic-amd64 docker-push-enrichment-amd64 docker-push-frontend-amd64 docker-push-loadbalancer-amd64 docker-push-platform-amd64
# docker-push-arm32v7: docker-push-businesslogic-arm32v7 docker-push-enrichment-arm32v7 docker-push-frontend-arm32v7 docker-push-loadbalancer-arm32v7 docker-push-platform-arm32v7
# docker-push-arm64v8: docker-push-businesslogic-arm64v8 docker-push-enrichment-arm64v8 docker-push-frontend-arm64v8 docker-push-loadbalancer-arm64v8 docker-push-platform-arm64v8
# docker-push: docker-push-dev docker-push-amd64 docker-push-arm32v7 docker-push-arm64v8
