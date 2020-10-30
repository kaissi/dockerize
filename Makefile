.SILENT :
.PHONY : dockerize clean fmt

TAG:=`git describe --abbrev=0 --tags`
LDFLAGS_ALPINE:="-w -s -X 'main.buildVersion=$(TAG)'" -a -tags netgo -installsuffix netgo
LDFLAGS:="-w -s -X 'main.buildVersion=$(TAG)'" -a -installsuffix cgo
OPTS:=CGO_ENABLED=0

all: dockerize

deps:
	go get github.com/robfig/glock
	glock sync -n < GLOCKFILE

dockerize:
	echo "Building dockerize"
	go install -ldflags "$(LDFLAGS)"

dist-clean:
	rm -rf dist
	rm -f dockerize-*.tar.gz

dist: deps dist-clean
	mkdir -p dist/alpine-linux/amd64 && $(OPTS) GOOS=linux GOARCH=amd64 go build -ldflags $(LDFLAGS_ALPINE) -o dist/alpine-linux/amd64/dockerize
	mkdir -p dist/linux/amd64 && $(OPTS) GOOS=linux GOARCH=amd64 go build -ldflags $(LDFLAGS) -o dist/linux/amd64/dockerize
	mkdir -p dist/linux/386 && $(OPTS) GOOS=linux GOARCH=386 go build -ldflags $(LDFLAGS) -o dist/linux/386/dockerize
	mkdir -p dist/linux/armel && $(OPTS) GOOS=linux GOARCH=arm GOARM=5 go build -ldflags $(LDFLAGS) -o dist/linux/armel/dockerize
	mkdir -p dist/linux/armhf && $(OPTS) GOOS=linux GOARCH=arm GOARM=6 go build -ldflags $(LDFLAGS) -o dist/linux/armhf/dockerize
	mkdir -p dist/linux/arm64 && $(OPTS) GOOS=linux GOARCH=arm64 go build -ldflags $(LDFLAGS) -o dist/linux/arm64/dockerize
	mkdir -p dist/darwin/amd64 && $(OPTS) GOOS=darwin GOARCH=amd64 go build -ldflags $(LDFLAGS) -o dist/darwin/amd64/dockerize

release: dist
	tar -cvzf dockerize-alpine-linux-amd64-$(TAG).tar.gz -C dist/alpine-linux/amd64 dockerize
	tar -cvzf dockerize-linux-amd64-$(TAG).tar.gz -C dist/linux/amd64 dockerize
	tar -cvzf dockerize-linux-386-$(TAG).tar.gz -C dist/linux/386 dockerize
	tar -cvzf dockerize-linux-armel-$(TAG).tar.gz -C dist/linux/armel dockerize
	tar -cvzf dockerize-linux-armhf-$(TAG).tar.gz -C dist/linux/armhf dockerize
	tar -cvzf dockerize-linux-arm64-$(TAG).tar.gz -C dist/linux/arm64 dockerize
	tar -cvzf dockerize-darwin-amd64-$(TAG).tar.gz -C dist/darwin/amd64 dockerize
