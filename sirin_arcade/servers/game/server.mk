$(SIRIN_ARCADE_BUILD_MODULE)

HELP_MESSAGE += "> Sirin Arcade Game Server:\n"
HELP_MESSAGE += "\t* clean_arcade_server: clean sirin arcade server\n"
HELP_MESSAGE += "\t* build_arcade_server: build sirin arcade server\n"
HELP_MESSAGE += "\n"

.PHONY:                   \
	arcade_server_cleanup \
	clean_arcade_server   \
	build_arcade_server


arcade_server_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/server $(IMAGE) $(BUILDER_USER) \
		rm -rf target Cargo.lock out


$(STAMP_DIR)/.acrade_server: $(STAMP_DIR)/.build_env $(STAMP_DIR)/.arcade_sdk
	$(MAKE) arcade_server_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/server $(IMAGE) $(BUILDER_USER) \
		cargo build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/server $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/server/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../target/debug/server

	@echo "Arcade Server ready! 🚀"

	$(call create_stamp,$@)


clean_arcade_server: arcade_server_cleanup
	$(call remove_stamp,.acrade_server)


build_arcade_server: $(STAMP_DIR)/.acrade_server
