#!/bin/bash

GPROOT=$HOME/install/gpdb
Cwd=$(pwd | tr -d '\n\r')

function build_libevent
{
    cd $Cwd/ext/libevent-2.1.12
    ./configure --prefix=$GPROOT/ext
    make
    make install
}

function build_libyaml
{
    cd $Cwd/ext/yaml-0.2.5
    ./configure --prefix=$GPROOT/ext
    make
    make install
}

function build_xercesc
{
    cd $Cwd/ext/xerces-c-3.2.3/
    ./configure --prefix=$GPROOT/ext
    make
    make install
}


function build_ext
{
#   build_libevent
#   build_libyaml
#   build_xercesc
    echo "External libraries have been installed."
}

function build_master
{
    cd $Cwd/
    export LD_LIBRARY_PATH=$GPROOT/ext/lib:$LD_LIBRARY_PATH
    ./configure --prefix=$GPROOT/core --with-perl --with-python --with-libxml --with-gssapi \
        --without-zstd \
        CFLAGS="-I$GPROOT/ext/include -fPIC" CXXFLAGS="-I$GPROOT/ext/include -fPIC" LDFLAGS="-L$GPROOT/ext/lib"
    make -sj
    make install
}


build_ext
build_master
