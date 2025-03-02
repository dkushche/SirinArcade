include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval PREFIX := $(5))

$(eval NAME := Servers)

handler_$(PARENT_ID)$(ID)_build:


handler_$(PARENT_ID)$(ID)_out:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/servers out/resources


handler_$(PARENT_ID)$(ID)_clean:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers $(IMAGE) $(BUILDER_USER) \
		rm -rf out


handler_$(PARENT_ID)$(ID)_export:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/bin $(IMAGE) $(BUILDER_USER) \
		rln ../../servers/out/servers .

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/etc/sirin_arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../../servers/out/resources servers_resources


$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME),,$(PREFIX)))

endef
