HELP_MESSAGE += "> Sirin Arcades Arcades:\n"
HELP_MESSAGE += "\t* arcades_clean: clean Sirin Arcades Arcades result dir\n"
HELP_MESSAGE += "\t* arcades_build: build Sirin Arcades Arcades result dir\n"
HELP_MESSAGE += "\t* arcades_fclean: clean Sirin Arcades Arcades result dir and all arcades\n"
HELP_MESSAGE += "\n"

include sirin_arcades/arcades/logo/logo.mk
include sirin_arcades/arcades/menu/menu.mk
include sirin_arcades/arcades/lobby/lobby.mk
include sirin_arcades/arcades/pong/pong.mk

HELP_MESSAGE += "\n"


.PHONY:             \
	arcades_cleanup \
	arcades_clean   \
	arcades_build   \
	arcades_fclean  \
	arcades_install


arcades_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades $(IMAGE) $(BUILDER_USER) \
		rm -rf out


$(STAMP_DIR)/.arcades: $(STAMP_DIR)/.arcades_lobby \
				   	   $(STAMP_DIR)/.arcades_logo  \
				   	   $(STAMP_DIR)/.arcades_menu  \
				   	   $(STAMP_DIR)/.arcades_pong

	$(MAKE) arcades_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/arcades $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/arcades out/resources

	$(MAKE) arcades_lobby_install
	$(MAKE) arcades_logo_install
	$(MAKE) arcades_menu_install
	$(MAKE) arcades_pong_install

	@echo "Sirin Arcades Arcades ready! 🚀"

	$(call create_stamp,$@)


arcades_clean: arcades_cleanup
	$(call remove_stamp,.arcades)


arcades_build: $(STAMP_DIR)/.arcades


arcades_fclean:         \
	arcades_clean       \
	arcades_lobby_clean \
	arcades_logo_clean  \
	arcades_menu_clean  \
	arcades_pong_clean


arcades_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/etc/sirin_arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../../arcades/out/arcades

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/etc/sirin_arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../../arcades/out/resources arcades_resources
