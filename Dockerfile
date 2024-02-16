# Use the same base image as your target environment
FROM centos:7

# Set environment variable
ENV container docker

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


#docker build --platform linux/arm64 -t my-rpm-test-image .
#docker run -it my-rpm-test-image
