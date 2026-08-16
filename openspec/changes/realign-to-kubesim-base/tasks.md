# Tasks — realign-to-kubesim-base

- [x] kubesim_base has published the new tag: **v0.1.25** (config/connected/grpc/go all at v0.1.25).
- [ ] `go get github.com/kubedge/kubesim_base/config@v0.1.25 github.com/kubedge/kubesim_base/connected@v0.1.25 github.com/kubedge/kubesim_base/grpc/go@v0.1.25`
- [ ] `go mod tidy`; confirm all three requires moved to v0.1.25.
- [ ] `go build ./... && go vet ./... && go test ./... -race` green.
- [ ] Rebuild the five component binaries (`go build -tags=<c> ./cmd/<c>/...`) to confirm they still build against v0.1.25.
