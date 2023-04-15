#!/bin/bash

SPIN_VERSION=v1.1.0

set -x -e
# Install dependencies

# Installing Python Build Dependencies
echo "\nINSTALLING PYTHON BUILD DEPENDENCIES\n"
sudo sed -i 's/# deb-src /deb-src /g' /etc/apt/sources.list
sudo apt update
sudo apt-get -y build-dep python3
sudo apt-get -y install pkg-config

# Install rust wasm32-wasi target
echo "\nINSTALLING RUST WASI TARGET\n"
rustup target add wasm32-wasi
echo "\nRUST WASI TARGET INSTALLED\n"

# Setup WASI-SDK
echo "\nINSTALLING WASI-SDK\n"
cd /tmp
wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-16/wasi-sdk-16.0-linux.tar.gz
tar -xf wasi-sdk-16.0-linux.tar.gz
sudo cp -r wasi-sdk-16.0 /opt/wasi-sdk
echo "\nWASI-SDK INSTALLED\n"
cd -
# Build CPython
echo "\nBUILDING CPYTHON\n"

git submodule update --init --recursive
mkdir -p cpython/builddir/wasi
mkdir -p cpython/builddir/build
cd cpython/builddir/build
../../configure --prefix=$(pwd)/install --enable-optimizations
make
cd ../wasi
CONFIG_SITE=../../Tools/wasm/config.site-wasm32-wasi ../../Tools/wasm/wasi-env \
    ../../configure -C --host=wasm32-unknown-wasi --build=$(../../config.guess) \
        --with-build-python=$(pwd)/../build/python --prefix=$(pwd)/install --disable-test-modules
make
make install
cd ../../..
echo "\nCPYTHON BUILD COMPLETE\n"

# Install Spin
echo "\nINSTALLING SPIN\n"
cd /tmp
curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash -s -- -v $SPIN_VERSION
sudo mv spin /usr/local/bin/
cd -
echo "\nSPIN INSTALLED\n"