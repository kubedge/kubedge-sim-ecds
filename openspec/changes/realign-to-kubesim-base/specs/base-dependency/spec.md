## ADDED Requirements

### Requirement: The simulator pins kubesim_base v0.1.25 across all sub-modules

This simulator SHALL require `github.com/kubedge/kubesim_base/config`,
`.../connected`, and `.../grpc/go` all at **v0.1.25** (realigned from v0.1.24), consistent
after `go mod tidy`.

#### Scenario: all three sub-module pins are v0.1.25
- **WHEN** `go.mod` is inspected after realign
- **THEN** config, connected, and grpc/go all require v0.1.25 and `go build ./...` is green
