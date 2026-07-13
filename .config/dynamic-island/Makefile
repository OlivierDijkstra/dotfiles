QS ?= quickshell
QMLLINT ?= /usr/lib/qt6/bin/qmllint
CONFIG_PATH := $(CURDIR)

.PHONY: run run-debug lint

run:
	$(QS) -p "$(CONFIG_PATH)"

run-debug:
	DYNAMIC_ISLAND_DEBUG=1 $(QS) -p "$(CONFIG_PATH)"

lint:
	cd "$(CONFIG_PATH)" && $(QMLLINT) --uncreatable-type disable $$(rg --files -g '*.qml')
