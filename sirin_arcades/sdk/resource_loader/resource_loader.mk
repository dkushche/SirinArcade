include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))

$(eval NAME := Resource Loader)

$(eval WORKDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR) $(IMAGE) $(BUILDER_USER))
$(eval OUTDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR)/out $(IMAGE) $(BUILDER_USER))

handler_$(PARENT_ID)_$(ID)_build:
	$(WORKDIR_RUN) cmake -B cmake_build
	$(WORKDIR_RUN) cmake --build cmake_build
	$(WORKDIR_RUN) mkdir out


handler_$(PARENT_ID)_$(ID)_out:
	$(OUTDIR_RUN) ln -sf ../cmake_build/lib$(ID).so
	$(OUTDIR_RUN) ln -sf ../inc/$(ID).h


handler_$(PARENT_ID)_$(ID)_clean:
	$(WORKDIR_RUN) rm -rf cmake_build out


handler_$(PARENT_ID)_$(ID)_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/sirin_arcade_sdk $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../$(ID)/out/lib$(ID).so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/include $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../$(ID)/out/$(ID).h


$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME)))

endef
