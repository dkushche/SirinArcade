define print_help
	PARENT_NAME := $(1)
	NAME := $(2)

	PARENT_ID := $(3)
	ID := $(4)

	PREFIX := $(5)

	HELP_MESSAGE += "$(PREFIX)> $(PARENT_NAME) $(NAME):\n"
	HELP_MESSAGE += "$(PREFIX)\t* $(PARENT_ID)_$(ID)_clean: clean $(PARENT_NAME) $(NAME) result dir\n"
	HELP_MESSAGE += "$(PREFIX)\t* $(PARENT_ID)_$(ID)_build: build $(PARENT_NAME) $(NAME) result dir\n"
	HELP_MESSAGE += "$(PREFIX)\t* $(PARENT_ID)_$(ID)_rclean: clean $(PARENT_NAME) $(NAME) and all children\n"
	HELP_MESSAGE += "\n"
endef


define discover_modules
	$(eval MODULES := $(wildcard $(1)/*/*.mk))
endef


define get_module_names
	MODULE_NAMES := $(basename $(notdir $(1)))
endef


define get_module_interfaces
	MODULE_STAMPS := $(foreach module_name, $(1),       \
		$(STAMP_DIR)/.$(PARENT_ID)_$(ID)_$(module_name) \
	)

	MODULE_INSTALL_CMDS := $(foreach module_name, $(1), \
		$(PARENT_ID)_$(ID)_$(module_name)_install       \
	)

	MODULE_CLEAN_CMDS := $(foreach module_name, $(1), \
		$(PARENT_ID)_$(ID)_$(module_name)_clean       \
	)
endef


define import_child_subsystems
	$(foreach module, $(1),                                                  \
		$(eval include $(module))                                            \
		$(eval MODULE_ID := $(basename $(notdir $(module))))                 \
		$(eval $(call main,$(MODULE_ID),$(2),$(3),$(4)/$(MODULE_ID),$(5)\t)) \
	)
endef

define register_subsystem

$(eval ID := $(1))
$(eval PARENT_ID := $(2))
$(eval PARENT_NAME := $(3))
$(eval WORKDIR := $(4))
$(eval NAME := $(5))
$(eval DEPS := $(6))
$(eval PREFIX := $(7))

$(eval $(call print_help,$(PARENT_NAME),$(NAME),$(PARENT_ID),$(ID),$(PREFIX)))
$(eval $(call discover_modules,$(WORKDIR)))
$(eval $(call get_module_names,$(MODULES)))
$(eval $(call get_module_interfaces,$(MODULE_NAMES)))

$(SIRIN_ARCADES_BUILD_MODULE)

.PHONY:                        \
	$(PARENT_ID)_$(ID)_cleanup \
	$(PARENT_ID)_$(ID)_clean   \
	$(PARENT_ID)_$(ID)_build   \
	$(PARENT_ID)_$(ID)_rclean  \
	$(PARENT_ID)_$(ID)_install


$(PARENT_ID)_$(ID)_cleanup:
	$(MAKE) handler_$(PARENT_ID)_$(ID)_clean


$(STAMP_DIR)/.$(PARENT_ID)_$(ID): $(MODULE_STAMPS) $(DEPS)
	$(MAKE) $(PARENT_ID)_$(ID)_cleanup

	$(MAKE) handler_$(PARENT_ID)_$(ID)_build
	$(MAKE) handler_$(PARENT_ID)_$(ID)_out

ifneq ($(strip $(MODULE_INSTALL_CMDS)),)
	$(MAKE) $(MODULE_INSTALL_CMDS)
endif

	@echo "$(PARENT_NAME) $(NAME) ready! 🚀"

	$(call create_stamp,.$(PARENT_ID)_$(ID))


$(PARENT_ID)_$(ID)_clean: $(PARENT_ID)_$(ID)_cleanup
	$(call remove_stamp,.$(PARENT_ID)_$(ID))


$(PARENT_ID)_$(ID)_build: $(STAMP_DIR)/.$(PARENT_ID)_$(ID)


$(PARENT_ID)_$(ID)_rclean:   \
	$(PARENT_ID)_$(ID)_clean \
	$(MODULE_CLEAN_CMDS)


$(PARENT_ID)_$(ID)_install:
	$(MAKE) handler_$(PARENT_ID)_$(ID)_install

$(eval $(call import_child_subsystems,$(MODULES),$(PARENT_ID)_$(ID),$(PARENT_NAME) $(NAME),$(WORKDIR),$(PREFIX)))

endef
