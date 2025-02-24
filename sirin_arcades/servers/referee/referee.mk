$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> Referee\n"
HELP_MESSAGE += "\t\t* servers_referee_clean: clean Sirin Arcades Referee Server\n"
HELP_MESSAGE += "\t\t* servers_referee_build: build Sirin Arcades Referee Server\n"
HELP_MESSAGE += "\n"

.PHONY:                     \
	servers_referee_cleanup \
	servers_referee_clean   \
	servers_referee_build   \
	servers_referee_install


servers_referee_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/referee $(IMAGE) $(BUILDER_USER) \
		rm -rf target Cargo.lock out


$(STAMP_DIR)/.servers_referee: $(STAMP_DIR)/.build_env $(STAMP_DIR)/.sdk
	$(MAKE) servers_referee_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/referee $(IMAGE) $(BUILDER_USER) \
		cargo build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/referee $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/referee/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../target/debug/SirinArcadeReferee

	@echo "Sirin Arcades Referee Server ready! 🚀"

	$(call create_stamp,$@)


servers_referee_clean: servers_referee_cleanup
	$(call remove_stamp,.servers_referee)


servers_referee_build: $(STAMP_DIR)/.servers_referee


servers_referee_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/out/servers $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../referee/out/SirinArcadeReferee

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/out/resources $(IMAGE) $(BUILDER_USER) \
		mkdir referee
