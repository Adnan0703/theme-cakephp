SOURCE_DIR='../cakephp'
BUILD_DIR=./build/api

.PHONY: clean
.PHONY: build-all
.PHONY: build-active-and-missing

# Versions that can be built.
VERSIONS = 1.2 1.3 2.1 2.2 2.3 2.4 2.5 2.6 3.0

# Versions that are actively developed / maintained.
ACTIVE_VERSIONS = 2.6 3.0

clean:
	rm -rf $(BUILD_DIR)

# Make a macro to save re-typing recipes multiple times
define build3x
build-$(VERSION):
	cd $(SOURCE_DIR) && git checkout -f $(TAG)
	# Update the config file, Remove sed crap
	sed -i.bak "s/activeVersion: '[0-9]\.[0-9]'/activeVersion: '$(VERSION)'/" src/config.neon
	rm src/config.neon.bak
	# Make the build output dir
	[ ! -d $(BUILD_DIR) ] && mkdir $(BUILD_DIR) || true
	# Run Apigen
	php apigen.phar generate \
	    --source $(SOURCE_DIR)/src \
		--config ./apigen.neon \
		--destination $(BUILD_DIR)/$(VERSION)
	# Fix rewrites file to have a opening php tag at the start
	sed -i.bak '1i<?php' $(BUILD_DIR)/$(VERSION)/rewrite.php && rm $(BUILD_DIR)/$(VERSION)/rewrite.php.bak
endef

define build2x
build-$(VERSION):
	cd $(SOURCE_DIR) && git checkout -f $(TAG)
	# Update the config file, Remove sed crap
	sed -i.bak "s/activeVersion: '[0-9]\.[0-9]'/activeVersion: '$(VERSION)'/" src/config.neon
	rm src/config.neon.bak
	# Make the build output dir
	[ ! -d $(BUILD_DIR) ] && mkdir $(BUILD_DIR) || true
	# Run Apigen
	php apigen.phar generate \
		--source $(SOURCE_DIR)/lib \
		--source $(SOURCE_DIR)/app \
		--config ./apigen.neon \
		--exclude $(SOURCE_DIR)/app/Config \
		--exclude $(SOURCE_DIR)/lib/Cake/Console/Command/AppShell.php \
		--exclude $(SOURCE_DIR)/lib/Cake/Test \
		--exclude $(SOURCE_DIR)/lib/Cake/Console/Templates \
		--destination $(BUILD_DIR)/$(VERSION)
	# Fix rewrites file to have a opening php tag at the start
	sed -i.bak '1i<?php' $(BUILD_DIR)/$(VERSION)/rewrite.php && rm $(BUILD_DIR)/$(VERSION)/rewrite.php.bak
endef

define build1x
build-$(VERSION):
	cd $(SOURCE_DIR) && git checkout -f $(TAG)
	# Update the config file, Remove sed crap
	sed -i.bak "s/activeVersion: '[0-9]\.[0-9]'/activeVersion: '$(VERSION)'/" src/config.neon
	rm src/config.neon.bak
	# Make the build output dir
	[ ! -d $(BUILD_DIR) ] && mkdir $(BUILD_DIR) || true
	# Run Apigen
	php apigen.phar generate \
		--source $(SOURCE_DIR)/cake/libs \
		--source $(SOURCE_DIR)/cake/console/libs \
		--config ./apigen.neon \
		--exclude $(SOURCE_DIR)/cake/tests \
		--exclude $(SOURCE_DIR)/cake/libs/overloadable_php4.php \
		--exclude $(SOURCE_DIR)/cake/console/templates \
		--destination $(BUILD_DIR)/$(VERSION)
	# Fix rewrites file to have a opening php tag at the start
	sed -i.bak '1i<?php' $(BUILD_DIR)/$(VERSION)/rewrite.php && rm $(BUILD_DIR)/$(VERSION)/rewrite.php.bak
endef

# Build all the versions in a loop.
build-all: $(foreach version, $(VERSIONS), build-$(version))

# Build all active versions in a loop.
build-active: $(foreach version, $(ACTIVE_VERSIONS), build-$(version))

# Build all active and missing versions in a loop.
build-active-and-missing:
	for version in $(VERSIONS); do \
		IS_ACTIVE=$$(echo $(ACTIVE_VERSIONS) | grep "$$version"); \
		if test -n "$$IS_ACTIVE" || ! test -d "$(BUILD_DIR)/$$version"; then \
			$(MAKE) build-$$version; \
		fi \
	done

# Generate build targets for various 2.x versions.
TAG:=2.0.6
VERSION:=2.0
$(eval $(build2x))

TAG:=2.1.5
VERSION:=2.1
$(eval $(build2x))

TAG:=2.2.9
VERSION:=2.2
$(eval $(build2x))

TAG:=2.3.10
VERSION:=2.3
$(eval $(build2x))

TAG:=2.4.10
VERSION:=2.4
$(eval $(build2x))

TAG:=2.5.8
VERSION:=2.5
$(eval $(build2x))

TAG:=origin/2.6
VERSION:=2.6
$(eval $(build2x))

TAG:=origin/master
VERSION:=3.0
$(eval $(build3x))

# Generate build targets for various 1.x versions
TAG:=origin/1.3
VERSION:=1.3
$(eval $(build1x))

TAG:=1.2.12
VERSION:=1.2
$(eval $(build1x))
