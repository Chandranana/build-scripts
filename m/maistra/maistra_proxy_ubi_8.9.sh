#!/bin/bash -ex
# ----------------------------------------------------------------------------
#
# Package       : envoy-proxy
# Version       : 2.5
# Source repo   : https://github.com/maistra/proxy
# Tested on     : UBI 8.
# Language      : C++
# Travis-Check  : False
# Script License: Apache License, Version 2 or later
# Maintainer    : Chandranana Naik <Naik.Chandranana@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=proxy
PACKAGE_ORG=maistra
SCRIPT_PACKAGE_VERSION=2.5
PACKAGE_VERSION=${1:-${SCRIPT_PACKAGE_VERSION}}
PACKAGE_URL=https://github.com/${PACKAGE_ORG}/${PACKAGE_NAME}
SCRIPT_PACKAGE_VERSION_WO_LEADING_V="${SCRIPT_PACKAGE_VERSION:1}"
PATH=$PATH:/usr/local/go/bin
GOPATH=/root/go
GOBIN=/usr/local/go/bin
SOURCE_ROOT=$HOME

yum update -y
yum install -y git wget python3 libtool automake curl gcc vim cmake openssl-devel java-11-openjdk-devel openssl clang perl lld patch java-11-openjdk-devel python3 ninja-build
ln -s /usr/bin/python3 /usr/bin/python

cd $SOURCE_ROOT
mkdir bazel
cd bazel/
wget https://github.com/bazelbuild/bazel/releases/download/6.3.2/bazel-6.3.2-dist.zip
unzip bazel-6.3.2-dist.zip
rm -rf bazel-6.3.2-dist.zip
./compile.sh
export PATH=$PATH:$(pwd)/output

#
# Install llvm
#
cd $SOURCE_ROOT
git clone https://github.com/llvm/llvm-project.git
cd llvm-project
git checkout llvmorg-13.0.1
cd $SOURCE_ROOT
mkdir -p llvm_build
cd llvm_build
cmake3 -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="PowerPC" -DLLVM_ENABLE_PROJECTS="clang;lld" -G "Ninja" ../llvm-project/llvm
ninja -j$(nproc)
export PATH=$SOURCE_ROOT/llvm_build/bin:$PATH
export CC=$SOURCE_ROOT/llvm_build/bin/clang
export CXX=$SOURCE_ROOT/llvm_build/bin/clang++

# Install go
if echo $(go version) | grep -q '1.20'; then
	echo "=======================Go $(go version) is already installed====================="
	log.info "===Go is already installed==="
else
	echo "=======================Installing Go v1.20.13====================="
	log.info "===Go v1.20.13 is already installed==="
	cd $SOURCE_ROOT
	wget https://go.dev/dl/go1.20.13.linux-ppc64le.tar.gz
	tar -C /usr/local -xzf go1.20.13.linux-ppc64le.tar.gz
	which go
	go version
fi

#
# Build proxy
#
cd $SOURCE_ROOT
git clone https://github.com/maistra/proxy
cd proxy/
git checkout maistra-2.5
# Below commit is tested -  26/26 tests passed
# git checkout 04b70a395411958c9f140eb013ff44a047c36119

if ! ./maistra/ci/pre-submit.sh; then
	echo "Build Fails"
	exit 1
else
	echo "Build Success"
fi


