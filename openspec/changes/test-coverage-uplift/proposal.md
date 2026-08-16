# Uplift test coverage

## Why

The ECDS simulator ships five components (platform, frontend, enrichment, businesslogic,
loadbalancer) with little/no test coverage — a legacy of the "compile + start" bar. Since
these run as the workload the operator deploys, their core logic should be tested.

## What Changes

- Add unit tests for each component's core logic (message handling / the sim behavior in
  each `cmd/*` package and any shared internal packages).
- Run `go test ./... -race` and wire it into CI.

## Capabilities

### New Capabilities
- test-coverage: the ECDS components are protected by tests.
