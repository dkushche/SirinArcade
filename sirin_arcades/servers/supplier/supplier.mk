$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> Supplier\n"
HELP_MESSAGE += "\n"

.PHONY:                      \
	servers_supplier_clean   \
	servers_supplier_install


$(STAMP_DIR)/.servers_supplier:
	$(call create_stamp,$@)


servers_supplier_clean:
	$(call remove_stamp,.servers_supplier)


servers_supplier_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/out/servers $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../supplier/supplier.sh

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/out/resources $(IMAGE) $(BUILDER_USER) \
		mkdir supplier
