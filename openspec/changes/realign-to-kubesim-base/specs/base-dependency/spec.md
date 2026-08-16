## ADDED Requirements

### Requirement: The simulator pins the current kubesim_base tag across all sub-modules

This simulator SHALL require `github.com/kubedge/kubesim_base/config`,
`.../connected`, and `.../grpc/go` all at the same current sim-base tag (realigned
from `v0.1.24`), consistent after `go mod tidy`.

#### Scenario: all three sub-module pins are consistent
- **WHEN** `go.mod` is inspected after realign
- **THEN** config, connected, and grpc/go all require the same new tag and `go build ./...` is green
