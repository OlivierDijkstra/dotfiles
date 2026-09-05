QS ?= quickshell
QMLLINT ?= /usr/lib/qt6/bin/qmllint
QMLTESTRUNNER ?= /usr/lib/qt6/bin/qmltestrunner
CONFIG_PATH := $(CURDIR)

.PHONY: run run-debug lint test

run:
	$(QS) -p "$(CONFIG_PATH)"

run-debug:
	DYNAMIC_ISLAND_DEBUG=1 $(QS) -p "$(CONFIG_PATH)"

lint:
	cd "$(CONFIG_PATH)" && $(QMLLINT) --uncreatable-type disable $$(rg --files -g '*.qml')

test:
	QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=rhi QSG_RHI_BACKEND=opengl $(QMLTESTRUNNER) -input "$(CONFIG_PATH)/tests"
