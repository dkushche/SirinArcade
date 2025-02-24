$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> Lobby:\n"
HELP_MESSAGE += "\t\t* arcades_lobby_clean: clean Sirin Arcades Lobby Arcade\n"
HELP_MESSAGE += "\t\t* arcades_lobby_build: build Sirin Arcades Lobby Arcade\n"
HELP_MESSAGE += "\n"

.PHONY:                   \
	arcades_lobby_cleanup \
	arcades_lobby_clean   \
	arcades_lobby_build


arcades_lobby_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/lobby $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.arcades_lobby: $(STAMP_DIR)/.build_env $(STAMP_DIR)/.sdk
	$(MAKE) arcades_lobby_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/lobby $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DSIRINARCADESDK_INCLUDE=../../sdk/out/include \
			-DSIRINARCADESDK_LIB_DIR=../../sdk/out/sirin_arcade_sdk \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/lobby $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/lobby $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/lobby/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/liblobby_arcade.so

	@echo "Sirin Arcades Lobby Arcade ready! 🚀"

	$(call create_stamp,$@)


arcades_lobby_clean: arcades_lobby_cleanup
	$(call remove_stamp,.arcades_lobby)


arcades_lobby_build: $(STAMP_DIR)/.arcades_lobby


arcades_lobby_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/out/arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../lobby/out/liblobby_arcade.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/out/resources $(IMAGE) $(BUILDER_USER) \
		mkdir lobby
