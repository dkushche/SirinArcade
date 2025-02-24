$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> Logo:\n"
HELP_MESSAGE += "\t\t* arcades_logo_clean: clean Sirin Arcades Logo Arcade\n"
HELP_MESSAGE += "\t\t* arcades_logo_build: build Sirin Arcades Logo Arcade\n"
HELP_MESSAGE += "\n"

.PHONY:                  \
	arcades_logo_cleanup \
	arcades_logo_clean   \
	arcades_logo_build


arcades_logo_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/logo $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.arcades_logo: $(STAMP_DIR)/.build_env $(STAMP_DIR)/.sdk
	$(MAKE) arcades_logo_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/logo $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DSIRINARCADESDK_INCLUDE=../../sdk/out/include \
			-DSIRINARCADESDK_LIB_DIR=../../sdk/out/sirin_arcade_sdk \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/logo $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/logo $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/logo/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/liblogo_arcade.so

	@echo "Sirin Arcades Logo Arcade ready! 🚀"

	$(call create_stamp,$@)


arcades_logo_clean: arcades_logo_cleanup
	$(call remove_stamp,.arcades_logo)


arcades_logo_build: $(STAMP_DIR)/.arcades_logo


arcades_logo_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/out/arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../logo/out/liblogo_arcade.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades/out/resources $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../logo/resources logo
