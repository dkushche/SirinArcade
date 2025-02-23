include build.cfg
include build_utils/build_functions.mk

.PHONY: all help

SIRIN_ARCADES_BUILD_MODULE := all: help
HELP_MESSAGE = ""

include build_env/build_env.mk
include sirin_arcades/sirin_arcades.mk

all: help

help:
	@echo "Usage: make COMMAND"
	@echo "Commands:"

	@echo -ne $(HELP_MESSAGE)
