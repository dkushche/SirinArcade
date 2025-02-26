$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "> Sirin Arcades SDK:\n"
HELP_MESSAGE += "\t* sdk_clean: clean Sirin Arcades SDK result dir\n"
HELP_MESSAGE += "\t* sdk_build: build Sirin Arcades SDK result dir\n"
HELP_MESSAGE += "\t* sdk_fclean: clean Sirin Arcades SDK result dir and all sublibraries\n"
HELP_MESSAGE += "\n"

include sirin_arcades/sdk/clang/sound-player/sound-player.mk
include sirin_arcades/sdk/clang/terminal-drawer/terminal-drawer.mk
include sirin_arcades/sdk/clang/controller/controller.mk
include sirin_arcades/sdk/rust/events-bus/events-bus.mk

HELP_MESSAGE += "\n"


.PHONY:         \
	sdk_cleanup \
	sdk_clean   \
	sdk_build   \
	sdk_fclean  \
	sdk_install


sdk_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk $(IMAGE) $(BUILDER_USER) \
		rm -rf out


$(STAMP_DIR)/.sdk: $(STAMP_DIR)/.sdk_terminal_drawer \
				   $(STAMP_DIR)/.sdk_sound_player    \
				   $(STAMP_DIR)/.sdk_controller      \
				   $(STAMP_DIR)/.sdk_events_bus

	$(MAKE) sdk_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk $(IMAGE) $(BUILDER_USER) \
		mkdir -p out/sirin_arcade_sdk out/include out/rust

	$(MAKE) sdk_sound_player_install
	$(MAKE) sdk_terminal_drawer_install
	$(MAKE) sdk_controller_install
	$(MAKE) sdk_events_bus_install

	@echo "Sirin Arcades SDK ready! 🚀"

	$(call create_stamp,$@)


sdk_clean: sdk_cleanup
	$(call remove_stamp,.sdk)


sdk_build: $(STAMP_DIR)/.sdk


sdk_fclean:                   \
	sdk_clean                 \
	sdk_terminal_drawer_clean \
	sdk_sound_player_clean    \
	sdk_controller_clean      \
	sdk_events_bus_clean


sdk_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/out/lib $(IMAGE) $(BUILDER_USER) \
		rln ../../sdk/out/sirin_arcade_sdk .
