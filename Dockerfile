# Use the same base image as your target environment
FROM centos:7

# Set environment variable
ENV container docker

# This line is critical for systemd to work properly
STOPSIGNAL SIGRTMIN+3

# Install systemd -- See https://hub.docker.com/_/centos/ under "Systemd integration"
RUN yum -y update; yum clean all
RUN yum -y install systemd systemd-libs dbus; yum clean all; \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN mkdir -p /run/dbus
# Volume for systemd
VOLUME [ "/sys/fs/cgroup", "/run", "/tmp" ]
# Set init system
CMD ["/usr/sbin/init"]

# Update and install necessary packages
# (You may adjust these depending on what your RPM requires for testing)
# Update and upgrade existing packages
RUN yum -y update && yum -y upgrade; yum clean all

# Install necessary build tools and dependencies
RUN yum -y install \
    wget \
    gcc \
    make \
    rpm-build \
    autoconf \
    libtool \
    doxygen \
    apr-util-devel \
    openssl-devel \
    libuuid-devel \
    lua-devel \
    libxml2-devel
    # Any other dependencies your RPM or tests might require

COPY bash.sh /bash.sh
RUN chmod +x /bash.sh

# Set a working directory (optional)
WORKDIR /test

COPY httpd-2.4.58-1.el7.x86_64.rpm /test/
COPY bash.sh /test/
RUN chmod +x /test/bash.sh

# Set the default command to run your test script
CMD ["/test/bash.sh"]


#docker build --platform linux/amd64 -t my-rpm-test-image-system .
#docker run -it my-rpm-test-image-system
