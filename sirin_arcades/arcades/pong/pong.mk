$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> Pong:\n"
HELP_MESSAGE += "\t\t* arcades_pong_clean: clean Sirin Arcades Pong Arcade\n"
HELP_MESSAGE += "\t\t* arcades_pong_build: build Sirin Arcades Pong Arcade\n"
HELP_MESSAGE += "\n"

.PHONY:                  \
	arcades_pong_cleanup \
	arcades_pong_clean   \
	arcades_pong_build


arcades_pong_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/pong $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.arcades_pong: $(STAMP_DIR)/.build_env $(STAMP_DIR)/.sdk
	$(MAKE) arcades_pong_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/pong $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DSIRINARCADESDK_INCLUDE=../../sdk/out/include \
			-DSIRINARCADESDK_LIB_DIR=../../sdk/out/sirin_arcade_sdk \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/pong $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/pong $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/pong/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/libpong_arcade.so

	@echo "Sirin Arcades Pong Arcade ready! 🚀"

	$(call create_stamp,$@)


arcades_pong_clean: arcades_pong_cleanup
	$(call remove_stamp,.arcades_pong)


arcades_pong_build: $(STAMP_DIR)/.arcades_pong


arcades_pong_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/out/arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../pong/out/libpong_arcade.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/out/resources $(IMAGE) $(BUILDER_USER) \
		mkdir pong
