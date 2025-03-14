include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval PREFIX := $(5))

$(eval NAME := Supplier)

handler_$(PARENT_ID)$(ID)_build:


handler_$(PARENT_ID)$(ID)_out:


handler_$(PARENT_ID)$(ID)_clean:


handler_$(PARENT_ID)$(ID)_export:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/out/servers $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../supplier/supplier.sh

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/out/resources $(IMAGE) $(BUILDER_USER) \
		mkdir supplier


$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME),,$(PREFIX)))

endef
