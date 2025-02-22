$(SIRIN_ARCADE_BUILD_MODULE)

HELP_MESSAGE += "> Sirin Arcade SDK: NCURSES DRAWER:\n"
HELP_MESSAGE += "\t* clean_arcade_ncurses_drawer: clean sirin arcade SDK Ncurses Drawer sublibrary\n"
HELP_MESSAGE += "\t* build_arcade_ncurses_drawer: build sirin arcade SDK Ncurses Drawer sublibrary\n"
HELP_MESSAGE += "\n"

.PHONY:                                               \
	arcade_ncurses_drawer_cleanup                     \
	clean_arcade_ncurses_drawer                       \
	build_arcade_ncurses_drawer                       \
	install_arcade_ncurses_drawer_in_sirin_arcade_out


arcade_ncurses_drawer_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-ncurses-drawer $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.acrade_ncurses_drawer: $(STAMP_DIR)/.build_env
	$(MAKE) arcade_ncurses_drawer_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-ncurses-drawer $(IMAGE) $(BUILDER_USER) \
		cmake -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-ncurses-drawer $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-ncurses-drawer $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-ncurses-drawer/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/libarcade_ncurses_drawer.a

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/clang/arcade-ncurses-drawer/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../inc/public/ncurses-drawer.h

	@echo "Arcade Alsa Drawer sublib ready! 🚀"

	$(call create_stamp,$@)


clean_arcade_ncurses_drawer: arcade_ncurses_drawer_cleanup
	$(call remove_stamp,.acrade_ncurses_drawer)


build_arcade_ncurses_drawer: $(STAMP_DIR)/.acrade_ncurses_drawer


install_arcade_ncurses_drawer_in_sirin_arcade_out:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/out/static $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/arcade-ncurses-drawer/out/libarcade_ncurses_drawer.a

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/out/include $(IMAGE) $(BUILDER_USER)   \
		ln -sf ../../clang/arcade-ncurses-drawer/out/ncurses-drawer.h
