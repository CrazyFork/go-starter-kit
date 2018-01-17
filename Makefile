BIN           = $(GOPATH)/bin
ON            = $(BIN)/on
GO_BINDATA    = $(BIN)/go-bindata
NODE_BIN      = $(shell npm bin) # return current pwd + node_modules/.bin
PID           = .pid
# :todo, no filter-out, wildcard
GO_FILES      = $(filter-out ./server/bindata.go, $(shell find ./server  -type f -name "*.go"))
TEMPLATES     = $(wildcard server/data/templates/*.html)
BINDATA       = server/bindata.go
# -prefix, strip prefix
# -pkg, target pkg path. in this case is the `main` package
BINDATA_FLAGS = -pkg=main -prefix=server/data
BUNDLE        = server/data/static/build/bundle.js
APP           = $(shell find client -type f)
IMPORT_PATH   = $(shell pwd | sed "s|^$(GOPATH)/src/||g")
APP_NAME      = $(shell pwd | sed 's:.*/::')
TARGET        = $(BIN)/$(APP_NAME)
GIT_HASH      = $(shell git rev-parse HEAD)

# :bm,
# LDFLAGS, link flags, https://golang.org/cmd/link/
# -x, 删除元信息, https://zhuanlan.zhihu.com/p/26733683
# -X main.commitHash=$(GIT_HASH), set main packge 下面的commitHash variable 的值为 git hash.
LDFLAGS       = -w -X main.commitHash=$(GIT_HASH)
GLIDE         := $(shell command -v glide 2> /dev/null)

build: $(ON) $(GO_BINDATA) clean $(TARGET)

clean:
	@rm -rf server/data/static/build/*
	@rm -rf server/data/bundle.server.js
	@rm -rf $(BINDATA)

$(ON):
	go install $(IMPORT_PATH)/vendor/github.com/olebedev/on

$(GO_BINDATA):
	go install $(IMPORT_PATH)/vendor/github.com/jteeuwen/go-bindata/...

$(BUNDLE): $(APP)
	@$(NODE_BIN)/webpack --progress --colors --bail

$(TARGET): $(BUNDLE) $(BINDATA)
	# $@ symbol: https://stackoverflow.com/questions/3220277/what-do-the-makefile-symbols-and-mean
	@go build -ldflags '$(LDFLAGS)' -o $@ $(IMPORT_PATH)/server

kill:
	@kill `cat $(PID)` || true

serve: $(ON) $(GO_BINDATA) clean $(BUNDLE) restart
	@BABEL_ENV=dev node hot.proxy &
	@$(NODE_BIN)/webpack --watch &
	@$(ON) -m 2 $(GO_FILES) $(TEMPLATES) | xargs -n1 -I{} make restart || make kill

# :todo, what's the meaning of these three restart rules mean ?
restart: BINDATA_FLAGS += -debug
restart: LDFLAGS += -X main.debug=true
restart: $(BINDATA) kill $(TARGET)
	@echo restart the app...
	# $$是当前bash进程的pid 等同于 $BASHPID
	@$(TARGET) run & echo $$! > $(PID)  #todo, what this `!` means?

# this rule would read all files under server/data and put it into generated go source code
# (in this case, is the server/bindata.go file) so when compiled, it could be merge into the 
# final binary code.
$(BINDATA):
	$(GO_BINDATA) $(BINDATA_FLAGS) -o=$@ server/data/...

lint:
	@yarn run eslint || true
	@golint $(GO_FILES) || true

install:
	@yarn install

ifdef GLIDE		# :todo, this ifdef directive
	@glide install
else
	$(warning "Skipping installation of Go dependencies: glide is not installed")
endif