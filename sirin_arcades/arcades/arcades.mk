include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval PREFIX := $(5))

$(eval NAME := Arcades)

$(eval WORKDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR) $(IMAGE) $(BUILDER_USER))
$(eval OUTDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR)/out $(IMAGE) $(BUILDER_USER))


handler_$(PARENT_ID)$(ID)_build:


handler_$(PARENT_ID)$(ID)_out:
	$(WORKDIR_RUN) mkdir -p out/arcades out/resources


handler_$(PARENT_ID)$(ID)_clean:
	$(WORKDIR_RUN) rm -rf out


handler_$(PARENT_ID)$(ID)_export:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/etc/sirin_arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../../arcades/out/arcades

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/etc/sirin_arcades $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../../arcades/out/resources arcades_resources


$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME),,$(PREFIX)))

endef
