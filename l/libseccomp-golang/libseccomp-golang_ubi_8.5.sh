#!/bin/bash -e

# ----------------------------------------------------------------------------
#
# Package       : libseccomp-golang
# Version       : PACKAGE_VERSION=${1:-main}
# Source repo   : https://github.com/seccomp/libseccomp-golang.git
# Tested on     : UBI 8.5
# Language      : GO
# Travis-Check  : true
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

PACKAGE_NAME=${2:-libseccomp-golang}
PACKAGE_URL=https://github.com/seccomp/libseccomp-golang/

# Install dependencies
yum install -y git tar make wget libseccomp-devel gcc

#install go 
cd /root
wget https://golang.org/dl/go1.19.linux-ppc64le.tar.gz 
tar -C /bin -xf go1.19.linux-ppc64le.tar.gz 
mkdir -p /home/tester/go/src /home/tester/go/bin /home/tester/go/pkg
rm -rf go1.19.linux-ppc64le.tar.gz
export PATH=$PATH:/bin/go/bin
export GOPATH=/home/tester/go
export PATH=$GOPATH/bin:$PATH
export GO111MODULE=on

#Download source for libseccomp-golang 
cd /root
git clone $PACKAGE_URL
cd $PACKAGE_NAME

if ! go test -v ./... --outputdir /tmp ; then
    echo "------------------$PACKAGE_NAME:test_fails---------------------"
	echo "$PACKAGE_NAME  | $OS_NAME | GitHub | Fail |  Test_Fails"
	exit 1
else
	echo "------------------$PACKAGE_NAME:install_and_test_success-------------------------"
	echo "$PACKAGE_NAME | $OS_NAME | GitHub | Pass |  Install_and_Test_Success"
	exit 0
fi

