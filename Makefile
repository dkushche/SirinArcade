.PHONY: \
	build_env                              \
	env_shell                              \
	clean                                  \
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
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake -DDESTDIR_PATH=/sirin_arcade/sdk/cmake_build/sysroot -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake --install cmake_build

build_client:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/client $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DDESTDIR_PATH=/sirin_arcade/sdk/cmake_build/sysroot \
			-DSIRINARCADESDK_LIBRARIES=/sirin_arcade/sdk/cmake_build/sysroot/usr/lib/libSirinarcadeSDK.so \
			-DSIRINARCADESDK_INCLUDE_DIRS=/sirin_arcade/sdk/cmake_build/sysroot/usr/include \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/client $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/client $(IMAGE) $(BUILDER_USER) \
		cmake --install cmake_build

build_server:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/server $(IMAGE) $(BUILDER_USER) \
		cargo build

clean:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(BUILDER_USER) \
		rm -rf client/cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(BUILDER_USER) \
		rm -rf sdk/cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(BUILDER_USER) \
		rm -rf server/target

help:
	@echo "Usage: make COMMAND"
	@echo "Commands:"

	@echo "> Build Environment:"
	@echo -e "\tbuild_env: build image which then will be used to build everything"

	@echo "> Development:"
	@echo -e "\tenv_shell: shell to test staff manually"

	@echo "> Build:"
	@echo -e "\tbuild_sdk: build arcade console SDK"
	@echo -e "\tbuild_client: build arcade console client"
	@echo -e "\tbuild_client: build arcade console server"

	@echo "> Clean:"
	@echo -e "\tclean: clean build artifacts to build again"
