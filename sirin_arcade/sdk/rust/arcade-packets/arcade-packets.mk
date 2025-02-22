$(SIRIN_ARCADE_BUILD_MODULE)

HELP_MESSAGE += "> Sirin Arcade SDK: Packets:\n"
HELP_MESSAGE += "\t* clean_arcade_packets: clean sirin arcade SDK Packets sublibrary\n"
HELP_MESSAGE += "\t* build_arcade_packets: build sirin arcade SDK Packets sublibrary\n"
HELP_MESSAGE += "\n"

.PHONY:                                        \
	arcade_packets_cleanup                     \
	clean_arcade_packets                       \
	build_arcade_packets                       \
	install_arcade_packets_in_sirin_arcade_out


arcade_packets_cleanup:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/rust/arcade-packets $(IMAGE) $(BUILDER_USER) \
		rm -rf target Cargo.lock out


$(STAMP_DIR)/.acrade_packets: $(STAMP_DIR)/.build_env
	$(MAKE) arcade_packets_cleanup

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/rust/arcade-packets $(IMAGE) $(BUILDER_USER) \
		cargo build

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/rust/arcade-packets $(IMAGE) $(BUILDER_USER) \
		mkdir out

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/rust/arcade-packets/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../target/arcade-packets.h

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/rust/arcade-packets/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../target/debug/libarcade_packets.a

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/rust/arcade-packets/out $(IMAGE) $(BUILDER_USER) \
		ln -sf ../target/debug/libarcade_packets.rlib

	@echo "Arcade Packets sublib ready! 🚀"

	$(call create_stamp,$@)


clean_arcade_packets: arcade_packets_cleanup
	$(call remove_stamp,.acrade_packets)


build_arcade_packets: $(STAMP_DIR)/.acrade_packets


install_arcade_packets_in_sirin_arcade_out:
	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/out/static $(IMAGE) $(BUILDER_USER)   \
		ln -sf ../../rust/arcade-packets/out/libarcade_packets.a

	$(RUN_IN_CONTAINER) -t -w /sirin_arcade/sdk/out/include $(IMAGE) $(BUILDER_USER)   \
		ln -sf ../../rust/arcade-packets/out/arcade-packets.h
