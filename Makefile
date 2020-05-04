.PHONY: all test clean

all: help

build: ## build libinput with SPEC_LIBINPUT_VERSION
	cd $(LIBINPUT_SOURCE_DIR) && \
		git checkout $(LIBINPUT_VERSION) && \
		meson --prefix=/usr builddir/ -Dlibwacom=false -Ddebug-gui=false -Dtests=false -Ddocumentation=false --reconfigure && \
		ninja -C builddir/
	$(LIBINPUT_LIST_DEVICES) --version

help: ## show help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | uniq | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

