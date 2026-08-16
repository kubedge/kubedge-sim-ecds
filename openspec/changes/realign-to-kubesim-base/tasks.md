# Tasks — realign-to-kubesim-base

- [ ] Wait for `kubesim_base` to publish the new tag (its multimodule-tag-realign change).
- [ ] `go get github.com/kubedge/kubesim_base/config@<tag> github.com/kubedge/kubesim_base/connected@<tag> github.com/kubedge/kubesim_base/grpc/go@<tag>`
- [ ] `go mod tidy`; confirm all three requires moved to `<tag>`.
- [ ] `go build ./... && go vet ./... && go test ./... -race` green.
- [ ] Rebuild the five component binaries (`cmd/*`) to confirm they still build.
