#!/bin/bash

# Build zlib for wasi
mkdir -p zlib/src
mkdir -p zlib/build
cd zlib/src/
wget https://www.zlib.net/zlib-1.2.13.tar.xz
cd ../build
ln -s ../cpython cpython
tar -xf ../src/zlib-1.2.13.tar.xz
set -e
export PATH="/opt/wasi-sdk/bin:$PATH"
cd zlib-1.2.13/
CC=/opt/wasi-sdk/bin/clang RANLIB=/opt/wasi-sdk/bin/ranlib ./configure --prefix=
sudo make install \
	prefix=/opt/wasi-sdk/share/wasi-sysroot \
	libdir=/opt/wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi \
	pkgconfigdir=/opt/wasi-sdk/share/wasi-sysroot/lib/pkgconfig
cd ../../..


# Build cPython
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
make wasm_stdlib
make
make install
cd ../../..

# Build spin-python-cli
make