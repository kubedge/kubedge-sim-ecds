# Realign to the current kubesim_base

## Why

This simulator pins `kubesim_base` sub-modules at `v0.1.24` (config, connected, grpc/go)
and sits on `go 1.20`. Once `kubesim_base` cuts its next multi-module tag, this consumer
must realign all three requires together — the sim-family analog of the operator realign.

## What Changes

- `go get` all three sub-modules to the new sim-base tag in one move:
  `github.com/kubedge/kubesim_base/config@<tag>`,
  `.../connected@<tag>`, `.../grpc/go@<tag>`; then `go mod tidy`.
- Fix any breakage from the bump; keep `go build ./... && go vet ./... && go test ./...` green.

## Capabilities

### Modified Capabilities
- base-dependency: the pinned kubesim_base sub-module versions.
