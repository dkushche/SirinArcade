$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t > Controller:\n"
HELP_MESSAGE += "\t\t* sdk_controller_clean: clean Sirin Arcades SDK Controller sublibrary\n"
HELP_MESSAGE += "\t\t* sdk_controller_build: build Sirin Arcades SDK Controller sublibrary\n"
HELP_MESSAGE += "\n"

.PHONY:                                  \
	sdk_controller_cleanup               \
	sdk_controller_clean                 \
	sdk_controller_build                 \
	sdk_controller_install


sdk_controller_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/controller $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.sdk_controller: $(STAMP_DIR)/.build_env
	$(MAKE) sdk_controller_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/controller $(IMAGE) $(BUILDER_USER) \
		cmake -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/controller $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/controller $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/controller/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/libcontroller.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/controller/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../inc/controller.h

	@echo "Sirin Arcades SDK Controller sublib ready! 🚀"

	$(call create_stamp,$@)


sdk_controller_clean: sdk_controller_cleanup
	$(call remove_stamp,.sdk_controller)


sdk_controller_build: $(STAMP_DIR)/.sdk_controller


sdk_controller_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/sirin_arcade_sdk $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/controller/out/libcontroller.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/include $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/controller/out/controller.h
