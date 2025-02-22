$(SIRIN_ARCADE_BUILD_MODULE)

HELP_MESSAGE += "> Build Environment:\n"
HELP_MESSAGE += "\t* rebuild_env: recreate environment for building and running SirinArcade\n"
HELP_MESSAGE += "\t* clean_env: clean SirinArcade environment\n"
HELP_MESSAGE += "\t* env_shell: enter SirinArcade environment; Default Root to run commands as user execute gosu 1000\n"
HELP_MESSAGE += "\n"

.PHONY:         \
	clean_env   \
	rebuild_env \
	env_shell


clean_env:
	$(call remove_stamp,.build_env)


$(STAMP_DIR)/.build_env:
	@echo "Creating build environment"

ifeq ($(strip $(SIRIN_AUDIO_CARD)),)
	@echo "ERROR: Set SIRIN_AUDIO_CARD"
	@exit 1
endif

ifeq ($(strip $(SIRIN_AUDIO_SUBDEVICE)),)
	@echo "ERROR: Set SIRIN_AUDIO_SUBDEVICE"
	@exit 1
endif

	docker build \
		--build-arg SIRIN_AUDIO_CARD=$(SIRIN_AUDIO_CARD) \
		--build-arg SIRIN_AUDIO_SUBDEVICE=$(SIRIN_AUDIO_SUBDEVICE) \
		-t $(IMAGE) .

	$(call create_stamp,$@)


rebuild_env: clean_env $(STAMP_DIR)/.build_env
	@echo "Build Environment Recreated"


env_shell: $(STAMP_DIR)/.build_env
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade $(ENABLE_SOUND_DEVICE) $(IMAGE) $(BUILDER_ROOT) bash
