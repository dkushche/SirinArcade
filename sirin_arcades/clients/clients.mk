HELP_MESSAGE += "> Sirin Arcades Clients:\n"
HELP_MESSAGE += "\t* clients_clean: clean Sirin Arcades Clients result dir\n"
HELP_MESSAGE += "\t* clients_build: build Sirin Arcades Clients result dir\n"
HELP_MESSAGE += "\t* clients_fclean: clean Sirin Arcades Clients result dir and all clients\n"
HELP_MESSAGE += "\n"

include sirin_arcades/clients/ui/ui.mk

HELP_MESSAGE += "\n"


.PHONY:             \
	clients_cleanup \
	clients_clean   \
	clients_build   \
	clients_fclean  \
	clients_install


clients_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients $(IMAGE) $(BUILDER_USER) \
		rm -rf out


$(STAMP_DIR)/.clients: $(STAMP_DIR)/.clients_ui

	$(MAKE) clients_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/clients out/resources

	$(MAKE) clients_ui_install

	@echo "Sirin Arcades Clients ready! 🚀"

	$(call create_stamp,$@)


clients_clean: clients_cleanup
	$(call remove_stamp,.clients)


clients_build: $(STAMP_DIR)/.clients


clients_fclean:      \
	clients_clean    \
	clients_ui_clean


clients_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/bin $(IMAGE) $(BUILDER_USER) \
		rln ../../clients/out/clients .

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/etc/sirin_arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../../clients/out/resources clients_resources
