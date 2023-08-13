SRC_DIR := src
INSTALL_DIR := $(HOME)
SRC_FILES := $(shell find $(SRC_DIR)/ -type f)
ZSH_FILES := $(wildcard $(SRC_DIR)/.z*)

# Use only native versions on macOS as GNU utils are not installed on clean Mac
INSTALL := /usr/bin/install
FIND := /usr/bin/find


.PHONY: all zsh subdirs
all: zsh subdirs

zsh:
	$(INSTALL) -v -C -b -B \~ -m 600 $(ZSH_FILES) $(INSTALL_DIR)

subdirs:
	for f in $$(cd $(SRC_DIR); $(FIND) . -mindepth 1 -type d); do $(INSTALL) -v -m 700 -d $(INSTALL_DIR)/$${f}; done
	for f in $$(cd $(SRC_DIR); $(FIND) . -mindepth 2 -type f); do $(INSTALL) -v -C -b -B \~ -m 600 $(SRC_DIR)/$${f} $(INSTALL_DIR)/$${f}; done

all: zsh subdirs
