$(SIRIN_ARCADE_BUILD_MODULE)

HELP_MESSAGE += "> Sirin Arcade SDK: ALSA PLAYER:\n"
HELP_MESSAGE += "\t* clean_arcade_alsa_player: clean sirin arcade SDK ALSA Player sublibrary\n"
HELP_MESSAGE += "\t* build_arcade_alsa_player: build sirin arcade SDK ALSA Player sublibrary\n"
HELP_MESSAGE += "\n"

.PHONY:                                            \
	arcade_alsa_player_cleanup                     \
	clean_arcade_alsa_player                       \
	build_arcade_alsa_player                       \
	install_arcade_alsa_player_in_sirin_arcade_out


arcade_alsa_player_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-alsa-player $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.acrade_alsa_player: $(STAMP_DIR)/.build_env
	$(MAKE) arcade_alsa_player_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-alsa-player $(IMAGE) $(BUILDER_USER) \
		cmake -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-alsa-player $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-alsa-player $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-alsa-player/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/libarcade_alsa_player.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-alsa-player/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../inc/alsa-player.h

	@echo "Arcade Alsa Player sublib ready! 🚀"

	$(call create_stamp,$@)


clean_arcade_alsa_player: arcade_alsa_player_cleanup
	$(call remove_stamp,.acrade_alsa_player)


build_arcade_alsa_player: $(STAMP_DIR)/.acrade_alsa_player


install_arcade_alsa_player_in_sirin_arcade_out:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/out/sublibs $(IMAGE) $(BUILDER_USER)   \
		ln -sf ../../clang/arcade-alsa-player/out/libarcade_alsa_player.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/out/include $(IMAGE) $(BUILDER_USER)   \
		ln -sf ../../clang/arcade-alsa-player/out/alsa-player.h
