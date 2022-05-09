FROM ubuntu:18.04
# make the test-lab directory
RUN mkdir test-lab
# Install some dependencies to get the container to have pre installed
# items
RUN apt-get update -y && apt-get install -y \
	gcc \
	make \
	perl-base \
	libfindbin-libs-perl \
    git \
    clang
# cd into test lab
WORKDIR /test-lab
# clone the original source repo
# RUN git clone https://github.com/openssl/openssl.git
