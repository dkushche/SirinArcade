$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> Terminal Drawer:\n"
HELP_MESSAGE += "\t\t* sdk_terminal_drawer_clean: clean Sirin Arcades SDK Terminal Drawer sublibrary\n"
HELP_MESSAGE += "\t\t* sdk_terminal_drawer_build: build Sirin Arcades SDK Terminal Drawer sublibrary\n"
HELP_MESSAGE += "\n"

.PHONY:                         \
	sdk_terminal_drawer_cleanup \
	sdk_terminal_drawer_clean   \
	sdk_terminal_drawer_build   \
	sdk_terminal_drawer_install


sdk_terminal_drawer_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/terminal-drawer $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.sdk_terminal_drawer: $(STAMP_DIR)/.build_env
	$(MAKE) sdk_terminal_drawer_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/terminal-drawer $(IMAGE) $(BUILDER_USER) \
		cmake -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/terminal-drawer $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/terminal-drawer $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/terminal-drawer/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/libterminal_drawer.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/terminal-drawer/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../inc/public/terminal-drawer.h

	@echo "Sirin Arcades SDK Terminal Drawer sublib ready! 🚀"

	$(call create_stamp,$@)


sdk_terminal_drawer_clean: sdk_terminal_drawer_cleanup
	$(call remove_stamp,.sdk_terminal_drawer)


sdk_terminal_drawer_build: $(STAMP_DIR)/.sdk_terminal_drawer


sdk_terminal_drawer_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/sirin_arcade_sdk $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/terminal-drawer/out/libterminal_drawer.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/include $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/terminal-drawer/out/terminal-drawer.h
