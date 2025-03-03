
define create_stamp
	$(RUN_IN_CONTAINER) -w /sirin_arcades $(IMAGE) $(BUILDER_USER) install -D /dev/null .stamps/$1
endef

define remove_stamp
	$(RUN_IN_CONTAINER) -w /sirin_arcades $(IMAGE) $(BUILDER_USER) rm -rf .stamps/$1
endef
