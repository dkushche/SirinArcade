$(SIRIN_ARCADES_BUILD_MODULE)

HELP_MESSAGE += "\t > Resource loader:\n"
HELP_MESSAGE += "\t\t* sdk_resource_loader_clean: clean Sirin Arcades SDK Resource loader sublibrary\n"
HELP_MESSAGE += "\t\t* sdk_resource_loader_build: build Sirin Arcades SDK Resource loader sublibrary\n"
HELP_MESSAGE += "\n"

.PHONY:                                  \
	sdk_resource_loader_cleanup               \
	sdk_resource_loader_clean                 \
	sdk_resource_loader_build                 \
	sdk_resource_loader_install


sdk_resource_loader_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/resource-loader $(IMAGE) $(BUILDER_USER) \
		rm -rf cmake_build out


$(STAMP_DIR)/.sdk_resource_loader: $(STAMP_DIR)/.build_env
	$(MAKE) sdk_resource_loader_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/resource-loader $(IMAGE) $(BUILDER_USER) \
		cmake -B cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/resource-loader $(IMAGE) $(BUILDER_USER) \
		cmake --build cmake_build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/resource-loader $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/resource-loader/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../cmake_build/libresource_loader.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/clang/resource-loader/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../inc/resource-loader.h

	@echo "Sirin Arcades SDK Resource loader sublib ready! 🚀"

	$(call create_stamp,$@)


sdk_resource_loader_clean: sdk_resource_loader_cleanup
	$(call remove_stamp,.sdk_resource_loader)


sdk_resource_loader_build: $(STAMP_DIR)/.sdk_resource_loader


sdk_resource_loader_install:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/sirin_arcade_sdk $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/resource_loader/out/libresource_loader.so

	$(RUN_IN_CONTAINER) -t -w /sirin_arcades/sdk/out/include $(IMAGE) $(BUILDER_USER) \
		ln -sf ../../clang/resource_loader/out/resource-loader.h
