## ADDED Requirements

### Requirement: The ECDS simulator components are unit-tested

Each ECDS component (platform, frontend, enrichment, businesslogic, loadbalancer) SHALL
have unit tests covering its core message-handling / simulation logic, run under
`go test ./... -race`.

#### Scenario: components have passing tests
- **WHEN** `go test ./... -race` runs
- **THEN** the component packages have passing tests (no longer 0 coverage)
