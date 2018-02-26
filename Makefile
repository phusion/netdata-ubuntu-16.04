PACKAGE_NAME = netdata

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

ORIG_TARBALL_DIRNAME = netdata-1.9.0
DPKG_BUILDPACKAGE_ARGS =

.PHONY: all source-package binary-package dev clean

all: binary-package

binary-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb

source-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc

dev: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	rm -rf $(ORIG_TARBALL_DIRNAME)/debian
	cp -dpR spec $(ORIG_TARBALL_DIRNAME)/debian
	cd $(ORIG_TARBALL_DIRNAME) && dpkg-buildpackage -b -us -uc -jauto $(DPKG_BUILDPACKAGE_ARGS)

clean:
	rm -rf *.tar.gz *.xz *.git *.dsc *.buildinfo *.changes *.deb *.ddeb netdata-*


$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc: $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	test -e $(ORIG_TARBALL_DIRNAME) || tar xJf $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	rm -rf $(ORIG_TARBALL_DIRNAME)/debian
	cp -dpR spec $(ORIG_TARBALL_DIRNAME)/debian
	cd $(ORIG_TARBALL_DIRNAME) && dpkg-buildpackage -S -us -uc -jauto $(DPKG_BUILDPACKAGE_ARGS)

$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	cd $(ORIG_TARBALL_DIRNAME) && dpkg-buildpackage -b -us -uc -jauto $(DPKG_BUILDPACKAGE_ARGS)


$(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz:
	wget http://archive.ubuntu.com/ubuntu/pool/universe/n/netdata/$(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
