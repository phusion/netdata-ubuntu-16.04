# Ubuntu 16.04 package for netdata

This project contains the packaging specifications of [the netdata server monitoring tool](https://github.com/firehol/netdata) for Ubuntu 16.04. It is a backport of the packaging work found in Ubuntu 18.04.

**Table of contents:**

<!-- MarkdownTOC depth=3 autolink="true" bracket="round" -->

- [Installation through PPA](#installation-through-ppa)
- [Building the package](#building-the-package)
	- [On Ubuntu 16.04](#on-ubuntu-1604)
	- [On other Linux distros, other Ubuntu versions or other OSes](#on-other-linux-distros-other-ubuntu-versions-or-other-oses)
- [Development](#development)
	- [Anatomy](#anatomy)
	- [Workflow](#workflow)
	- [Shortening the development cycle](#shortening-the-development-cycle)
- [Releasing a package update](#releasing-a-package-update)

<!-- /MarkdownTOC -->

## Installation through PPA

A prebuilt package is available through [the phusion.nl/misc PPA](https://launchpad.net/~phusion.nl/+archive/ubuntu/misc).

~~~
sudo add-apt-repository ppa:phusion.nl/misc
sudo apt update
sudo apt install netdata
~~~

## Building the package

You can build a package either on Ubuntu 16.04, or on any system that supports Docker Linux containers.

### On Ubuntu 16.04

 1. Install Debian package building tools: `apt install devscripts eatmydata wget git`
 2. Run: `make`

If building succeeds then this will output the files `netdata_xxxx.deb` and `netdata-data_xxx.deb`.

If building fails then that is likely because you need to have some libraries installed. Look at the error message, install libraries as appropriate, then try again.

### On other Linux distros, other Ubuntu versions or other OSes

 1. Enter our Ubuntu 16.04 build environment Docker container: `./enter-docker.sh`
 2. Inside the container, run: `make`

This will output the files `netdata_xxxx.deb` and `netdata-data_xxx.deb`.

## Development

This section describes how you should approach making changes to the packaging specifications. Just like when building a package, you can do development either on Ubuntu 16.04, or on any system that supports Docker Linux containers.

### Anatomy

 * The `spec/` directory contains the Debian packaging specifications (that is, the files that are usually found within the `debian/` directory).
 * The `Makefile` is used to download the netdata source tarball and build the package.
 * `build-docker.sh`, `enter-docker.sh` and `docker-env/` are related to the Docker-based build environment.

### Workflow

The development workflow involves the use of `make`. You do not have to use Debian packaging tools (like dpkg-buildpackage) directly. Here is how a typical workflow looks like:

 1. Make changes in the Makefile or the `spec/` directory.
 2. Run `make dev`.
 3. Check whether the resulting .deb file is satisfactory. Go back to step 1 if not.

`make dev` performs the following actions:

 * It downloads the netdata source tarball and changes it into a Debian-packaging-style orig tarball, compressed with xz. This is only done once.
 * It extracts the orig tarball into netdata-x.x.x and copies the spec/ directory into netdata-x.x.x/debian/.
 * It runs `dpkg-buildpackage` on the netdata-x.x.x directory in order to build the .deb package.

### Shortening the development cycle

`dpkg-buildpackage` can take quite a while, which is very annoying when you want to changes. There are two ways to make `dpkg-buildpackage` faster and thus shorten the development cycle:

 1. By using ccache.
 2. By invoking Make with `DPKG_BUILDPACKAGE_ARGS=-nc`: `make dev DPKG_BUILDPACKAGE_ARGS=-nc`

If you are using our Docker container, then ccache is already set up for you (though the ccache directory will be wiped when you exit the container).

With regard to `DPKG_BUILDPACKAGE_ARGS=-nc`: as you may know, by default `dpkg-buildpackage` cleans existing build products during the beginning of each invocation. If you did not make any changes to the compilation instructions then this means that all the source files are being recompiled on every `dpkg-buildpackage` invocation. Even though ccache makes recompilations faster, ideally you want to avoid recompiling at all. With `-nc`, you tell `dpkg-buildpackage` not to clean existing build products.

## Releasing a package update

 1. Open the Makefile and either reset `PACKAGE_REVISION` to 1 or bump or by 1. See the comments for instructions.
 2. Edit spec/changelog and add a new changelog entry. You *must* do this because the Debian packaging tools extract the version number from the changelog file. The changelog entry's version number must correspond to the value of `$(PACKAGE_VERSION)-$(PACKAGE_REVISION)` as specified in the Makefile.
 3. Rebuild the package from scratch: `make clean && make`

You are then ready to upload the package to your preferred APT repository. The exact instructions depends on your repository. Here are instructions for uploading to the Phusion PPA on Launchpad:

 1. If using Docker, import your GPG private key into the Docker container:

     1. On your host OS, export your GPG private key to a file, located inside the same directory as enter-docker.sh.
     2. Inside the container, run: `gpg --import yourkeyfile.asc`
     3. Inside the container, run: `gpg --edit-key yourkeyemail@host.com`
     4. Inside the GPG prompt, run: `trust`. Select "ultimate". Then run: `quit`.

 2. Sign the source package: `debsign *source.changes`

 3. Upload to the Phusion PPA using dput: `dput ppa:phusion.nl/misc *source.changes`

 4. If using Docker, delete the private key file that you exported in step 1.
