include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval PREFIX := $(5))

$(eval NAME := Sirin Arcades)

handler_$(PARENT_ID)$(ID)_build:


handler_$(PARENT_ID)$(ID)_out:
	$(RUN_IN_CONTAINER) -t -w /$(WORKDIR) $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/bin out/lib out/etc/sirin_arcades

handler_$(PARENT_ID)$(ID)_clean:
	$(RUN_IN_CONTAINER) -t -w /$(WORKDIR) $(IMAGE) $(BUILDER_USER) \
		rm -rf out


handler_$(PARENT_ID)$(ID)_handler:


$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME),,$(PREFIX)))

endef
