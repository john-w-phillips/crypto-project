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
# clone the original source repo (git clone https://github.com/openssl/openssl.git) when running the container
# then comment out the code shown by john phillips in the repo, and
# run the fuzz tests as described by the README in https://github.com/openssl/openssl/blob/master/fuzz/README.md
