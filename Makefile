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

build_sdk: build_lib_help_for_c
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake -DDESTDIR_PATH=/sirin_arcade/sdk/cmake_build/sysroot -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		cmake --install cmake_build

build_client: # todo а може й не туду, шо тут змінювать, тільки запустить
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

build_server: build_so_logo # але лого він не візьме те, здаєця...
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/server $(IMAGE) $(BUILDER_USER) \
		cargo build --release


build_lib_help_for_c:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/server/help-for-c $(IMAGE) $(BUILDER_USER) \
		cargo build

build_so_logo: build_sdk # todo
	# мабуть не треба бо має бути в сдк + смейк gcc -shared -o libexample.so -fPIC libexample.c ../../../server/help-for-c/target/debug/libhelp_for_c.a

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/assets/system/logo $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DDESTDIR_PATH=/sirin_arcade/sdk/cmake_build/sysroot \
			-DSIRINARCADESDK_LIBRARIES=/sirin_arcade/sdk/cmake_build/sysroot/usr/lib/libSirinarcadeSDK.so \
			-DSIRINARCADESDK_INCLUDE_DIRS=/sirin_arcade/sdk/cmake_build/sysroot/usr/include \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/assets/system/logo $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/assets/system/logo $(IMAGE) $(BUILDER_USER) \
		cmake --install cmake_build

start_example:
# використати і модифікувати білд клієнта і сервера і додати про сошку (не забуть про про статичне дно шо потребує лібекзампл)
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/server $(IMAGE) $(BUILDER_USER) \
		# хз чи має доступ з цього до assets/system/logo/libexample.so
		./target/debug/server

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
	@echo -e "\tbuild_env SIRIN_AUDIO_CARD=0 SIRIN_AUDIO_SUBDEVICE=0: \
build image which then will be used to build and run everything"

	@echo "> Development:"
	@echo -e "\tenv_shell: shell to test staff manually"
	@echo -e "\trun_arcade: run SirinArcade"

	@echo "> Build:"
	@echo -e "\tbuild_sdk: build arcade console SDK"
	@echo -e "\tbuild_client: build arcade console client"
	@echo -e "\tbuild_server: build arcade console server"

	@echo "> Clean:"
	@echo -e "\tclean: clean build artifacts to build again"
