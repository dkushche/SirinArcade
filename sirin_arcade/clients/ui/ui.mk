$(SIRIN_ARCADE_BUILD_MODULE)

HELP_MESSAGE += "> Sirin Arcade Clients: UI:\n"
HELP_MESSAGE += "\t* clean_arcade_client_ui: clean sirin arcade UI Client\n"
HELP_MESSAGE += "\t* build_arcade_client_ui: build sirin arcade UI Client\n"
HELP_MESSAGE += "\n"

.PHONY:                      \
	arcade_client_ui_cleanup \
	clean_arcade_client_ui   \
	build_arcade_client_ui


arcade_client_ui_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/clients/ui $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.acrade_client_ui: $(STAMP_DIR)/.build_env $(STAMP_DIR)/.arcade_sdk
	$(MAKE) arcade_client_ui_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/clients/ui $(IMAGE) $(BUILDER_USER) \
		cmake \
			-DSIRINARCADESDK_INCLUDE=../../sdk/out/include \
			-DSIRINARCADESDK_LIB_DIR=../../sdk/out/sublibs \
			-B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/clients/ui $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/clients/ui $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/clients/ui/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/SirinArcadeClient

	@echo "Arcade UI Client ready! 🚀"

	$(call create_stamp,$@)


clean_arcade_client_ui: arcade_client_ui_cleanup
	$(call remove_stamp,.acrade_client_ui)


build_arcade_client_ui: $(STAMP_DIR)/.acrade_client_ui
