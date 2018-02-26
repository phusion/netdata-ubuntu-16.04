FROM ubuntu:16.04
ADD . /netdata_ubuntu_build
RUN /netdata_ubuntu_build/install.sh
ENTRYPOINT ["/sbin/inithostmount"]
