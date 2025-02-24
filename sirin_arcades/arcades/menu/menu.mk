$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> Menu:\n"
HELP_MESSAGE += "\t\t* arcades_menu_clean: clean Sirin Arcades Menu Arcade\n"
HELP_MESSAGE += "\t\t* arcades_menu_build: build Sirin Arcades Menu Arcade\n"
HELP_MESSAGE += "\n"

.PHONY:                  \
	arcades_menu_cleanup \
	arcades_menu_clean   \
	arcades_menu_build


arcades_menu_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/menu $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.arcades_menu: $(STAMP_DIR)/.build_env $(STAMP_DIR)/.sdk
	$(MAKE) arcades_menu_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/menu $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DSIRINARCADESDK_INCLUDE=../../sdk/out/include \
			-DSIRINARCADESDK_LIB_DIR=../../sdk/out/sirin_arcade_sdk \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/menu $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/menu $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/menu/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/libmenu_arcade.so

	@echo "Sirin Arcades Menu Arcade ready! 🚀"

	$(call create_stamp,$@)


arcades_menu_clean: arcades_menu_cleanup
	$(call remove_stamp,.arcades_menu)


arcades_menu_build: $(STAMP_DIR)/.arcades_menu


arcades_menu_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/out/arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../menu/out/libmenu_arcade.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/out/resources $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../menu/resources menu
