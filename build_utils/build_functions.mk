
define create_stamp
	$(RUN_IN_CONTAINER) -w / $(IMAGE) $(BUILDER_USER) install -D /dev/null $(STAMP_DIR)/$1
endef

define remove_stamp
	$(RUN_IN_CONTAINER) -w / $(IMAGE) $(BUILDER_USER) rm -rf $(STAMP_DIR)/$1
endef
