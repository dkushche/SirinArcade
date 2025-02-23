$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t > Sound Player:\n"
HELP_MESSAGE += "\t\t* sdk_sound_player_clean: clean Sirin Arcades SDK Sound Player sublibrary\n"
HELP_MESSAGE += "\t\t* sdk_sound_player_build: build Sirin Arcades SDK Sound Player sublibrary\n"
HELP_MESSAGE += "\n"

.PHONY:                                    \
	sdk_sound_player_cleanup               \
	sdk_sound_player_clean                 \
	sdk_sound_player_build                 \
	sdk_sound_player_install


sdk_sound_player_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/sound-player $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.sdk_sound_player: $(STAMP_DIR)/.build_env
	$(MAKE) sdk_sound_player_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/sound-player $(IMAGE) $(BUILDER_USER) \
		cmake -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/sound-player $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/sound-player $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/sound-player/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/libsound_player.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/sound-player/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../inc/sound-player.h

	@echo "Sirin Arcades SDK Sound Player sublib ready! 🚀"

	$(call create_stamp,$@)


sdk_sound_player_clean: sdk_sound_player_cleanup
	$(call remove_stamp,.sdk_sound_player)


sdk_sound_player_build: $(STAMP_DIR)/.sdk_sound_player


sdk_sound_player_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/sirin_arcade_sdk $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/sound-player/out/libsound_player.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/include $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/sound-player/out/sound-player.h
