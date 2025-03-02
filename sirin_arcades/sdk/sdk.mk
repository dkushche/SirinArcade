include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval PREFIX := $(5))

$(eval NAME := SDK)

handler_$(PARENT_ID)_$(ID)_build:
	@echo "Nothing done for stage build"


handler_$(PARENT_ID)_$(ID)_out:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/sirin_arcade_sdk out/include out/rust


handler_$(PARENT_ID)_$(ID)_clean:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk $(IMAGE) $(BUILDER_USER) \
		rm -rf out


handler_$(PARENT_ID)_$(ID)_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/lib $(IMAGE) $(BUILDER_USER) \
		rln ../../sdk/out/sirin_arcade_sdk .


$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME),,$(PREFIX)))

endef
