include build_utils/subsystem.mk

define main

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval PREFIX := $(5))

$(eval NAME := UI Client)
$(eval DEPS := $(STAMP_DIR)/.sirin_arcades_sdk)

$(eval WORKDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR) $(IMAGE) $(BUILDER_USER))
$(eval OUTDIR_RUN = $(RUN_IN_CONTAINER) -t -w /$(WORKDIR)/out $(IMAGE) $(BUILDER_USER))


handler_$(PARENT_ID)_$(ID)_build:
	$(WORKDIR_RUN) cmake -DSIRINARCADESDK_INCLUDE=../../sdk/out/include \
			             -DSIRINARCADESDK_LIB_DIR=../../sdk/out/sirin_arcade_sdk \
			             -B cmake_build
	$(WORKDIR_RUN) cmake --build cmake_build


handler_$(PARENT_ID)_$(ID)_out:
	$(WORKDIR_RUN) mkdir out
	$(OUTDIR_RUN) ln -sf ../cmake_build/SirinArcadeClient


handler_$(PARENT_ID)_$(ID)_clean:
	$(WORKDIR_RUN) rm -rf cmake_build out


handler_$(PARENT_ID)_$(ID)_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/out/clients $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../ui/out/SirinArcadeClient

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/clients/out/resources $(IMAGE) $(BUILDER_USER) \
		mkdir ui


$(eval $(call register_subsystem,$(ID),$(PARENT_ID),$(PARENT_NAME),$(WORKDIR),$(NAME),$(DEPS),$(PREFIX)))

endef
