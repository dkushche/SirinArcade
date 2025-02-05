.PHONY: \
	build_env                              \
	env_shell                              \
	run_arcade                             \
	clean                                  \
	help

IMAGE := sirin-arcade-env-img
RUN_IN_CONTAINER := docker run -i -v ./sirin_arcade:/sirin_arcade
ENABLE_SOUND_DEVICE := --device=/dev/snd:/dev/snd
BUILDER_USER := gosu ubuntu
ROOT_USER :=

all: help

build_env:
ifeq ($(strip $(SIRIN_AUDIO_CARD)),)
	@echo "Audio card is not set"
	@exit 1
endif

ifeq ($(strip $(SIRIN_AUDIO_SUBDEVICE)),)
	@echo "Audio subdevice is not set"
	@exit 1
endif

	docker build \
		--build-arg SIRIN_AUDIO_CARD=$(SIRIN_AUDIO_CARD) \
		--build-arg SIRIN_AUDIO_SUBDEVICE=$(SIRIN_AUDIO_SUBDEVICE) \
		-t $(IMAGE) .
	@echo "Environment ready to work"

env_shell:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(ENABLE_SOUND_DEVICE) $(IMAGE) $(BUILDER_ROOT) bash

run_arcade: build_core
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(ENABLE_SOUND_DEVICE) $(IMAGE) $(BUILDER_ROOT) \
		bash -c "SirinArcade 2> /sirin_arcade/runtime_error_logs/`date +"%Y-%m-%d-%H-%M-%S"`.log"

build_sdk:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake -DDESTDIR_PATH=/sirin_arcade/sdk/cmake_build/sysroot -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake --install cmake_build

build_core: build_sdk
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/core $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DDESTDIR_PATH=/sirin_arcade/sdk/cmake_build/sysroot \
			-DSIRINARCADESDK_LIBRARIES=/sirin_arcade/sdk/cmake_build/sysroot/usr/lib/libSirinarcadeSDK.so \
			-DSIRINARCADESDK_INCLUDE_DIRS=/sirin_arcade/sdk/cmake_build/sysroot/usr/include \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/core $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/core $(IMAGE) $(BUILDER_USER) \
		cmake --install cmake_build

clean:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(BUILDER_USER) \
		rm -rf core/cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(BUILDER_USER) \
		rm -rf sdk/cmake_build

help:
	@echo "Usage: make COMMAND"
	@echo "Commands:"

	@echo "> Build Environment:"
	@echo -e "\tbuild_env SIRIN_AUDIO_CARD=0 SIRIN_AUDIO_SUBDEVICE=0: \
build image which then will be used to build and run everything"

	@echo "> Development:"
	@echo -e "\tenv_shell: shell to test staff manually"
	@echo -e "\trun_arcade: run SirinArcade"

	@echo "> Build:"
	@echo -e "\tbuild_sdk: build arcade console SDK"
	@echo -e "\tbuild_core: build arcade console core"

	@echo "> Clean:"
	@echo -e "\tclean: clean build artifacts to build again"
