$(SIRIN_ARCADE_BUILD_MODULE)

HELP_MESSAGE += "> Sirin Arcade SDK:\n"
HELP_MESSAGE += "\t* clean_arcade_sdk: clean sirin arcade SDK shared library\n"
HELP_MESSAGE += "\t* build_arcade_sdk: build sirin arcade SDK shared library\n"
HELP_MESSAGE += "\t* fclean_sdk: clean sirin arcade SDK shared library and all sublibraries\n"
HELP_MESSAGE += "\n"

.PHONY:                \
	arcade_sdk_cleanup \
	clean_arcade_sdk   \
	build_arcade_sdk   \
	fclean_sdk


arcade_sdk_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/ $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.arcade_sdk: $(STAMP_DIR)/.build_env             \
						  $(STAMP_DIR)/.acrade_ncurses_drawer \
						  $(STAMP_DIR)/.acrade_alsa_player   \
						  $(STAMP_DIR)/.acrade_packets

	$(MAKE) arcade_sdk_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/shared out/static out/include

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk $(IMAGE) $(BUILDER_USER)   \
		$(CC)                                                              \
			-fPIC -shared -o out/shared/libsirin_arcade_sdk.so             \
			-Wl,--whole-archive                                            \
				clang/arcade-ncurses-drawer/out/libarcade_ncurses_drawer.a \
				clang/arcade-alsa-player/out/libarcade_alsa_player.a       \
				rust/arcade-packets/out/libarcade_packets.a                \
			-Wl,--no-whole-archive

	$(MAKE) install_arcade_ncurses_drawer_in_sirin_arcade_out
	$(MAKE) install_arcade_alsa_player_in_sirin_arcade_out
	$(MAKE) install_arcade_packets_in_sirin_arcade_out

	@echo "Sirin Arcade ready! 🚀"

	$(call create_stamp,$@)


clean_arcade_sdk: arcade_sdk_cleanup
	$(call remove_stamp,.arcade_sdk)


build_arcade_sdk: $(STAMP_DIR)/.arcade_sdk


fclean_sdk: \
	clean_arcade_sdk \
	clean_arcade_packets \
	clean_arcade_alsa_player \
	clean_arcade_ncurses_drawer
