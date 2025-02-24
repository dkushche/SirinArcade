HELP_MESSAGE += "> Sirin Arcades Servers:\n"
HELP_MESSAGE += "\t* servers_clean: clean Sirin Arcades Servers result dir\n"
HELP_MESSAGE += "\t* servers_build: build Sirin Arcades Servers result dir\n"
HELP_MESSAGE += "\t* servers_fclean: clean Sirin Arcades Servers result dir and all servers\n"
HELP_MESSAGE += "\n"

include sirin_arcades/servers/referee/referee.mk
include sirin_arcades/servers/supplier/supplier.mk

HELP_MESSAGE += "\n"


.PHONY:             \
	servers_cleanup \
	servers_clean   \
	servers_build   \
	servers_fclean  \
	servers_install


servers_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers $(IMAGE) $(BUILDER_USER) \
		rm -rf out


$(STAMP_DIR)/.servers: $(STAMP_DIR)/.servers_referee \
					   $(STAMP_DIR)/.servers_supplier

	$(MAKE) servers_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/servers out/resources

	$(MAKE) servers_referee_install
	$(MAKE) servers_supplier_install

	@echo "Sirin Arcades Servers ready! 🚀"

	$(call create_stamp,$@)


servers_clean: servers_cleanup
	$(call remove_stamp,.servers)


servers_build: $(STAMP_DIR)/.servers


servers_fclean:            \
	servers_clean          \
	servers_referee_clean  \
	servers_supplier_clean


servers_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/bin $(IMAGE) $(BUILDER_USER) \
		rln ../../servers/out/servers .

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/etc/sirin_arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../../servers/out/resources servers_resources
