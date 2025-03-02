include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval PREFIX := $(5))

$(eval NAME := Referee)
$(eval DEPS := $(STAMP_DIR)/.sirin_arcades_sdk)

$(eval WORKDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR) $(IMAGE) $(BUILDER_USER))
$(eval OUTDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR)/out $(IMAGE) $(BUILDER_USER))


handler_$(PARENT_ID)_$(ID)_build:
	$(WORKDIR_RUN) cargo build


handler_$(PARENT_ID)_$(ID)_out:
	$(WORKDIR_RUN) mkdir out
	$(OUTDIR_RUN) ln -sf ../target/debug/SirinArcadeReferee


handler_$(PARENT_ID)_$(ID)_clean:
	$(WORKDIR_RUN) rm -rf target Cargo.lock out


handler_$(PARENT_ID)_$(ID)_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/out/servers $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../referee/out/SirinArcadeReferee

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/servers/out/resources $(IMAGE) $(BUILDER_USER) \
		mkdir referee


$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME),$(DEPS),$(PREFIX)))

endef
