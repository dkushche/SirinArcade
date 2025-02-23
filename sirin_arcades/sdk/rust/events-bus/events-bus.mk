$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t> Events Bus:\n"
HELP_MESSAGE += "\t\t* sdk_events_bus_clean: clean Sirin Arcades SDK Events Bus sublibrary\n"
HELP_MESSAGE += "\t\t* sdk_events_bus_build: build Sirin Arcades SDK Events Bus sublibrary\n"
HELP_MESSAGE += "\n"

.PHONY:                    \
	sdk_events_bus_cleanup \
	sdk_events_bus_clean   \
	sdk_events_bus_build   \
	sdk_events_bus_install


sdk_events_bus_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/rust/events-bus $(IMAGE) $(BUILDER_USER) \
		rm -rf target Cargo.lock out


$(STAMP_DIR)/.sdk_events_bus: $(STAMP_DIR)/.build_env
	$(MAKE) sdk_events_bus_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/rust/events-bus $(IMAGE) $(BUILDER_USER) \
		cargo build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/rust/events-bus $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/rust/events-bus/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../target/events-bus.h

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/rust/events-bus/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../target/debug/libevents_bus.so

	@echo "Sirin Arcades SDK Events Bus sublib ready! 🚀"

	$(call create_stamp,$@)


sdk_events_bus_clean: sdk_events_bus_cleanup
	$(call remove_stamp,.sdk_events_bus)


sdk_events_bus_build: $(STAMP_DIR)/.sdk_events_bus


sdk_events_bus_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/sirin_arcade_sdk $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../rust/events-bus/out/libevents_bus.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/include $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../rust/events-bus/out/events-bus.h

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/rust $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../rust/events-bus
