
# Image URL to use all building/pushing image targets
VERSION_V1          ?= 0.1.0
IMG_BUSINESSLOGIC   ?= hack4easy/ecds-businesslogic-dev:v${VERSION_V1}
IMG_ENRICHMENT      ?= hack4easy/ecds-enrichment-dev:v${VERSION_V1}
IMG_FRONTEND        ?= hack4easy/ecds-frontend-dev:v${VERSION_V1}
IMG_LOADBALANCER    ?= hack4easy/ecds-loadbalancer-dev:v${VERSION_V1}
IMG_PLATFORM        ?= hack4easy/ecds-platform-dev:v${VERSION_V1}

all: docker-build

setup:
ifndef GOPATH
	$(error GOPATH not defined, please define GOPATH. Run "go help gopath" to learn more about GOPATH)
endif
	# dep ensure

clean:
	rm -fr vendor
	rm -fr cover.out
	rm -fr build/_output

unittest: setup fmt vet-v1
	go test ./pkg/... ./cmd/... -coverprofile cover.out

# Run go fmt against code
fmt: setup
	go fmt ./pkg/... ./cmd/...

vet: fmt
	go vet -composites=false -tags=businesslogic ./pkg/... ./cmd/...

docker-build-businesslogic: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-businesslogic -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=businesslogic ./cmd/businesslogic/...
	docker build . -f build/Dockerfile.ecds-businesslogic -t ${IMG_BUSINESSLOGIC}

docker-push-businesslogic:
	docker push ${IMG_BUSINESSLOGIC}

docker-build-enrichment: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-enrichment -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=enrichment ./cmd/enrichment/...
	docker build . -f build/Dockerfile.ecds-enrichment -t ${IMG_ENRICHMENT}

docker-push-enrichment:
	docker push ${IMG_ENRICHMENT}

docker-build-frontend: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-frontend -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=frontend ./cmd/frontend/...
	docker build . -f build/Dockerfile.ecds-frontend -t ${IMG_FRONTEND}

docker-push-frontend:
	docker push ${IMG_FRONTEND}

docker-build-loadbalancer: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-loadbalancer -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=loadbalancer ./cmd/loadbalancer/...
	docker build . -f build/Dockerfile.ecds-loadbalancer -t ${IMG_LOADBALANCER}

docker-push-loadbalancer:
	docker push ${IMG_LOADBALANCER}

docker-build-platform: vet
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/ecds-platform -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=platform ./cmd/platform/...
	docker build . -f build/Dockerfile.ecds-platform -t ${IMG_PLATFORM}

docker-push-platform:
	docker push ${IMG_PLATFORM}

# Build the docker image
docker-build: fmt docker-build-businesslogic docker-build-enrichment docker-build-frontend docker-build-loadbalancer docker-build-platform

# Push the docker image
docker-push: docker-push-businesslogic docker-push-enrichment docker-push-frontend docker-push-loadbalancer docker-push-platform
