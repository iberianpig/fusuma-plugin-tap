.PHONY: all test clean

all: help

build: ## build libinput with LIBINPUT_VERSION
	cd $(LIBINPUT_REPO) && \
		git fetch && \
		git checkout $(LIBINPUT_VERSION) && \
		mkdir -p builddir/$(LIBINPUT_VERSION)/ && \
		meson --prefix=/usr builddir/$(LIBINPUT_VERSION)/ -Dlibwacom=false -Ddebug-gui=false -Dtests=false -Ddocumentation=false && \
		ninja -C builddir/$(LIBINPUT_VERSION)/
	$(LIBINPUT_REPO)/builddir/$(LIBINPUT_VERSION)/libinput-list-devices --version

version: ## libinput list-devces --version
	$(LIBINPUT_REPO)/builddir/$(LIBINPUT_VERSION)/libinput-list-devices --version

list-devices: ## libinput list-devices
	$(LIBINPUT_REPO)/builddir/$(LIBINPUT_VERSION)/libinput-list-devices

debug-events: ## libinput debug-events
	$(LIBINPUT_REPO)/builddir/$(LIBINPUT_VERSION)/libinput-debug-events --enable-tap --verbose

help: ## show help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | uniq | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

