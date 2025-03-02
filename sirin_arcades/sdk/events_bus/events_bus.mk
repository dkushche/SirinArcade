include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval PREFIX := $(5))

$(eval NAME := Events Bus)

$(eval WORKDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR) $(IMAGE) $(BUILDER_USER))
$(eval OUTDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR)/out $(IMAGE) $(BUILDER_USER))

handler_$(PARENT_ID)_$(ID)_build:
	$(WORKDIR_RUN) cargo build


handler_$(PARENT_ID)_$(ID)_out:
	$(WORKDIR_RUN) mkdir out
	$(OUTDIR_RUN) ln -sf ../target/$(ID).h
	$(OUTDIR_RUN) ln -sf ../target/debug/lib$(ID).so


handler_$(PARENT_ID)_$(ID)_clean:
	$(WORKDIR_RUN) rm -rf target Cargo.lock out


handler_$(PARENT_ID)_$(ID)_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/sirin_arcade_sdk $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../$(ID)/out/lib$(ID).so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/include $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../$(ID)/out/$(ID).h

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/rust $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../$(ID)

$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME),,$(PREFIX)))

endef

