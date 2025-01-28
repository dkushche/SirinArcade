.PHONY: \
	build_env                              \
	env_shell                              \
	help

IMAGE := sirin-arcade-env-img
RUN_IN_CONTAINER := docker run -i -v ./sirin_arcade:/sirin_arcade
BUILDER_USER := gosu ubuntu
ROOT_USER :=

all: help

build_env:
	docker build -t $(IMAGE) .
	@echo "Environment ready to work"

env_shell:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(BUILDER_ROOT) bash

build_sdk:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(BUILDER_USER) make -C sdk

build_core:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(ROOT_USER) \
		bash -c "make INSTALL_DIR=/ -C sdk install && make -C core"

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(ROOT_USER) \
		chown -R ubuntu:ubuntu core

help:
	@echo "Usage: make COMMAND"
	@echo "Commands:"

	@echo "> Build Environment:"
	@echo -e "\tbuild_env: build image which then will be used to build everything"

	@echo "> Development:"
	@echo -e "\tenv_shell: shell to test staff manually"

	@echo "> Build:"
	@echo -e "\tbuild_sdk: build arcade console SDK"
	@echo -e "\tbuild_core: build arcade console core"
