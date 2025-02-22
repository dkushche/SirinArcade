include build.cfg
include build_functions.mk

.PHONY: all help

SIRIN_ARCADE_BUILD_MODULE := all: help
HELP_MESSAGE = ""

include build_env.mk

include sirin_arcade/sdk/clang/arcade-alsa-player/arcade-alsa-player.mk
include sirin_arcade/sdk/clang/arcade-ncurses-drawer/arcade-ncurses-drawer.mk
include sirin_arcade/sdk/rust/arcade-packets/arcade-packets.mk

include sirin_arcade/sdk/sdk.mk

all: help

#########################################################################

run_arcade:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(ENABLE_SOUND_DEVICE) $(IMAGE) $(BUILDER_ROOT) \
		bash -c "SirinArcade 2> /sirin_arcade/runtime_error_logs/`date +"%Y-%m-%d-%H-%M-%S"`.log"

build_client: build_sdk # todo а може й не туду, шо тут змінювать, тільки запустить
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
		cargo build --release

build_so_logo: build_sdk
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

start_example: build_server build_client # todo запустити обидва, писати в файли, вбити за 10 секунд; readme (схема, проверка что все сбилдить все)
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(IMAGE) $(BUILDER_USER) \
		bash -c " \
		mkdir -p /sirin_arcade/logs && \
        touch /sirin_arcade/logs/server.log /sirin_arcade/logs/client.log &&\
		./server/target/release/server > /sirin_arcade/logs/server.log & \
		./client/cmake_build/SirinArcade > /sirin_arcade/logs/client.log &  \
		sleep 10"

help:
	@echo "Usage: make COMMAND"
	@echo "Commands:"

	@echo -ne $(HELP_MESSAGE)
