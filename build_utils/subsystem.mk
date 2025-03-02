define print_help
	PARENT_NAME := $(1)
	NAME := $(2)

	PARENT_ID := $(3)
	ID := $(4)

	PREFIX := $(5)

	HELP_MESSAGE += "$(PREFIX)> $(PARENT_NAME) $(NAME):\n"
	HELP_MESSAGE += "$(PREFIX)\t* $(PARENT_ID)$(ID)_clean: clean $(PARENT_NAME) $(NAME) result dir\n"
	HELP_MESSAGE += "$(PREFIX)\t* $(PARENT_ID)$(ID)_build: build $(PARENT_NAME) $(NAME) result dir\n"
	HELP_MESSAGE += "$(PREFIX)\t* $(PARENT_ID)$(ID)_rclean: clean $(PARENT_NAME) $(NAME) and all children\n"
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
		$(STAMP_DIR)/.$(PARENT_ID)$(ID)_$(module_name) \
	)

	MODULE_EXPORT_CMDS := $(foreach module_name, $(1), \
		$(PARENT_ID)$(ID)_$(module_name)_export        \
	)

	MODULE_CLEAN_CMDS := $(foreach module_name, $(1), \
		$(PARENT_ID)$(ID)_$(module_name)_clean       \
	)

	MODULE_RCLEAN_CMDS := $(foreach module_name, $(1), \
		$(PARENT_ID)$(ID)_$(module_name)_rclean        \
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
	$(PARENT_ID)$(ID)_cleanup \
	$(PARENT_ID)$(ID)_clean   \
	$(PARENT_ID)$(ID)_build   \
	$(PARENT_ID)$(ID)_rclean  \
	$(PARENT_ID)$(ID)_export


$(PARENT_ID)$(ID)_cleanup:
	$(MAKE) handler_$(PARENT_ID)$(ID)_clean


$(STAMP_DIR)/.$(PARENT_ID)$(ID): $(MODULE_STAMPS) $(DEPS)
	$(MAKE) $(PARENT_ID)$(ID)_cleanup

	$(MAKE) handler_$(PARENT_ID)$(ID)_build
	$(MAKE) handler_$(PARENT_ID)$(ID)_out

ifneq ($(strip $(MODULE_EXPORT_CMDS)),)
	$(MAKE) $(MODULE_EXPORT_CMDS)
endif

	@echo "$(PARENT_NAME) $(NAME) ready! 🚀"

	$(call create_stamp,.$(PARENT_ID)$(ID))


$(PARENT_ID)$(ID)_clean: $(PARENT_ID)$(ID)_cleanup $(MODULE_CLEAN_CMDS)
	$(call remove_stamp,.$(PARENT_ID)$(ID))


$(PARENT_ID)$(ID)_build: $(STAMP_DIR)/.$(PARENT_ID)$(ID)


$(PARENT_ID)$(ID)_rclean:   \
	$(PARENT_ID)$(ID)_clean \
	$(MODULE_RCLEAN_CMDS)


$(PARENT_ID)$(ID)_export:
	$(MAKE) handler_$(PARENT_ID)$(ID)_export

$(eval $(call import_child_subsystems,$(MODULES),$(PARENT_ID)$(ID)_,$(PARENT_NAME) $(NAME),$(WORKDIR),$(PREFIX)))

endef
