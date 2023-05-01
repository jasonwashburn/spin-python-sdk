#!/bin/bash

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
make install \
	prefix=/opt/wasi-sdk/share/wasi-sysroot \
	libdir=/opt/wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi \
	pkgconfigdir=/opt/wasi-sdk/share/wasi-sysroot/lib/pkgconfig
cd ../cpython
# ./Tools/wasm/wasm_build.py wasi
# /opt/wasi-sdk/bin/llvm-strip /build/cpython-3.11.1/builddir/wasi/python.wasm
# cd builddir/wasi
# make wasm_stdlib