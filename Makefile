ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := help

# custom variables
repository ?= https://github.com/openedx/edx-analytics-data-api.git
branch ?= master

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

clean: ## Clean checkout analyticsapi code
	rm -rf analyticsapi
.PHONY: clean

clone: | clean ## Clone code, to custom repo and branch `make repository=https://github.com/fccn/edx-analytics-data-api.git branch=nau/lilac.master clone`
	git clone $(repository) --branch $(branch) --depth 1 analyticsapi
.PHONY: clone

build: ## Build docker image
	docker build . -t build:openedx-analyticsapi
.PHONY: build
