PACKAGE_NAME = netdata

# The Git commit of netdata you want to package.
NETDATA_GIT_REF = v1.9.0

# The Ubuntu package's version number, as appears in spec/changelog.
PACKAGE_VERSION = 1.9.0+dfsg

# If -- upon releasing a new package -- you had bumped `PACKAGE_VERSION`
# compared to the previous package, then reset this number to 1.
#
# Otherwise (you made other changes to the package), then bump this number by 1.
#
# Only modify the number before the `~` part. Don't touch the text after
# the `~` part. For example, if you want to bump `1~xenial1` then
# change it to `2~xenial1`.
#
# Also, be sure to edit spec/control and add a changelog entry there
# with `$(PACKAGE_VERSION)-$(PACKAGE_REVISION)` as version number.
PACKAGE_REVISION = 0~xenial1

ORIG_TARBALL_DIRNAME = netdata-$(NETDATA_GIT_REF)
DPKG_BUILDPACKAGE_ARGS =

.PHONY: all source-package binary-package dev clean

all: binary-package

binary-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb

source-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc

dev: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	rm -rf $(ORIG_TARBALL_DIRNAME)/debian
	cp -dpR spec $(ORIG_TARBALL_DIRNAME)/debian
	cd $(ORIG_TARBALL_DIRNAME) && dpkg-buildpackage -b -us -jauto $(DPKG_BUILDPACKAGE_ARGS)

clean:
	rm -rf *.tar.gz *.xz *.git *.dsc *.buildinfo *.changes *.deb *.ddeb netdata-*


$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc: $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	test -e $(ORIG_TARBALL_DIRNAME) || tar xJf $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	rm -rf $(ORIG_TARBALL_DIRNAME)/debian
	cp -dpR spec $(ORIG_TARBALL_DIRNAME)/debian
	cd $(ORIG_TARBALL_DIRNAME) && dpkg-buildpackage -S -us -jauto $(DPKG_BUILDPACKAGE_ARGS)

$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	cd $(ORIG_TARBALL_DIRNAME) && dpkg-buildpackage -b -us -jauto $(DPKG_BUILDPACKAGE_ARGS)


$(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz: $(ORIG_TARBALL_DIRNAME).tar.gz
	mkdir -p $(ORIG_TARBALL_DIRNAME)
	tar -C $(ORIG_TARBALL_DIRNAME) --strip-components=1 -xzf $(ORIG_TARBALL_DIRNAME).tar.gz
	tar -c $(ORIG_TARBALL_DIRNAME) | xz -zT 0 - > $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	rm -rf $(ORIG_TARBALL_DIRNAME)
	@echo Written $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz

$(ORIG_TARBALL_DIRNAME).tar.gz:
	wget --output-document=$(ORIG_TARBALL_DIRNAME).tar.gz \
		https://github.com/firehol/netdata/archive/$(NETDATA_GIT_REF).tar.gz
