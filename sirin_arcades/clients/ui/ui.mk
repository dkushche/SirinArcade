$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> UI:\n"
HELP_MESSAGE += "\t\t* clients_ui_clean: clean Sirin Arcades UI Client\n"
HELP_MESSAGE += "\t\t* clients_ui_build: build Sirin Arcades UI Client\n"
HELP_MESSAGE += "\n"

.PHONY:                \
	clients_ui_cleanup \
	clients_ui_clean   \
	clients_ui_build


clients_ui_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/ui $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.clients_ui: $(STAMP_DIR)/.build_env $(STAMP_DIR)/.sdk
	$(MAKE) clients_ui_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/ui $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DSIRINARCADESDK_INCLUDE=../../sdk/out/include \
			-DSIRINARCADESDK_LIB_DIR=../../sdk/out/sirin_arcade_sdk \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/ui $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/ui $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/ui/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/SirinArcadeClient

	@echo "Sirin Arcades UI Client ready! 🚀"

	$(call create_stamp,$@)


clients_ui_clean: clients_ui_cleanup
	$(call remove_stamp,.clients_ui)


clients_ui_build: $(STAMP_DIR)/.clients_ui


clients_ui_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/out/clients $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../ui/out/SirinArcadeClient

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/out/resources $(IMAGE) $(BUILDER_USER) \
		mkdir ui
