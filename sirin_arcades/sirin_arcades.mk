$(SIRIN_ARCADES_BUILD_MODULE)

SUBSYSTEM = sirin_arcade
SUBSYSTEM_NAME = Sirin Arcades
SUBSYSTEM_WORKDIR = sirin_arcades

HELP_MESSAGE += "🚀🚀🚀🚀 Sirin Arcades 🚀🚀🚀🚀\n"
HELP_MESSAGE += "\n"
HELP_MESSAGE += "* clean: clean Sirin Arcades result dir\n"
HELP_MESSAGE += "* build: build Sirin Arcades Arcades result dir\n"
HELP_MESSAGE += "* fclean: full clean\n"
HELP_MESSAGE += "\n"

include sirin_arcades/sdk/sdk.mk
$(eval $(call main,sdk,sirin_arcades,Sirin Arcades,sirin_arcades/sdk))

include sirin_arcades/servers/servers.mk
$(eval $(call main,servers,sirin_arcades,Sirin Arcades,sirin_arcades/servers))

# include sirin_arcades/clients/clients.mk
# include sirin_arcades/arcades/arcades.mk

.PHONY:     \
	cleanup \
	clean   \
	build   \
	fclean


cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades $(IMAGE) $(BUILDER_USER) \
		rm -rf out


$(STAMP_DIR)/.sirin_arcades: $(STAMP_DIR)/.sdk     \
				             $(STAMP_DIR)/.clients \
				             $(STAMP_DIR)/.arcades \
							 $(STAMP_DIR)/.servers

	$(MAKE) cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/bin out/lib out/etc/sirin_arcades

	$(MAKE) sdk_install
	$(MAKE) clients_install
	$(MAKE) arcades_install
	$(MAKE) servers_install

	@echo "🚀 !Sirin Arcades ready! 🚀"

	$(call create_stamp,$@)


clean: cleanup
	$(call remove_stamp,.sirin_arcades)


build: $(STAMP_DIR)/.sirin_arcades


fclean:            \
	clean          \
	sdk_fclean     \
	clients_fclean \
	arcades_fclean \
	servers_fclean
