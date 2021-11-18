#!/bin/bash

GPROOT=$HOME/install/gpdb
GPDATA=/data/dengxy/gpdata

SEG_PREFIX=tripNode
CN_DIR=$GPDATA/qddir
CN_PORT=7000

Cwd=$(pwd | tr -d '\n\r')

function usage
{
    echo "Usage:"
    echo "    $0 -h"
    echo "        show this message"
    echo "    $0 -t [build|init]"
    echo "        build: build and install gpdb"
    echo "        init: initialize a 3-segment cluster"
}

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
    build_libevent
    build_libyaml
    build_xercesc
    echo "External libraries have been installed."
}

function build_master
{
    cd $Cwd/
    make distclean -sj
    export LD_LIBRARY_PATH=$GPROOT/ext/lib:$LD_LIBRARY_PATH
    ./configure --prefix=$GPROOT/core --with-perl --with-python --with-libxml --with-gssapi \
        --without-zstd --disable-pxf \
        CFLAGS="-I$GPROOT/ext/include -fPIC" CXXFLAGS="-I$GPROOT/ext/include -fPIC" LDFLAGS="-L$GPROOT/ext/lib"
    make -sj
    make install
}

function setup_env
{
    cat <<__END__ > $HOME/gpdb_macro
source $GPROOT/core/greenplum_path.sh
export LD_LIBRARY_PATH=$GPROOT/ext/lib:$GPROOT/core/lib:$LD_LIBRARY_PATH
export PATH=$GPROOT/core/bin:$PATH
export PGPORT=${CN_PORT}
export COORDINATOR_DATA_DIRECTORY=${CN_DIR}/${SEG_PREFIX}-1
export MASTER_DATA_DIRECTORY=${CN_DIR}/${SEG_PREFIX}-1
__END__

    source $HOME/gpdb_macro
}

function init_cluster
{
    rm -f config_init
    rm -f config_post
    rm -fr $GPDATA/*

    hostname > $Cwd/hostfile

    # kill all existing postgres instances
    ps -ef | grep 'postgres -D' | grep -v grep  | awk '{print "kill",  $2}' | bash

    cat <<__END__ > config_init

SEG_PREFIX=${SEG_PREFIX}

COORDINATOR_PORT=${CN_PORT}
COORDINATOR_HOSTNAME=dengxuyue-opengauss
COORDINATOR_DIRECTORY=${CN_DIR}

PORT_BASE=7100
MACHINE_LIST_FILE=$Cwd/hostfile
declare -a DATA_DIRECTORY=($GPDATA/dbfast1 $GPDATA/dbfast2 $GPDATA/dbfast3)

MIRROR_PORT_BASE=7200
declare -a MIRROR_DATA_DIRECTORY=($GPDATA/dbfast_mirror1 $GPDATA/dbfast_mirror2 $GPDATA/dbfast_mirror3)

# Shell to use to execute commands on all hosts
TRUSTED_SHELL="/home/dengxy/gpdb/gpAux/gpdemo/lalshell"
ENCODING=UNICODE
DEFAULT_QD_MAX_CONNECT=150
QE_CONNECT_FACTOR=5

__END__

    cat <<__END2__ > config_post

fsync = on

__END2__

    test -d $GPDATA/gpadminlog || mkdir -p $GPDATA/gpadminlog
    test -d $GPDATA/qddir || mkdir -p $GPDATA/qddir
    for i in {1..3}; do
        test -d $GPDATA/dbfast$i || mkdir -p $GPDATA/dbfast$i
        test -d $GPDATA/dbfast_mirror$i || mkdir -p $GPDATA/dbfast_mirror$i
    done

    setup_env

    gpinitsystem -a -c config_init -l $GPDATA/gpadminlog -p config_post

    echo "The cluster is ready."
    rm -f config_init
    rm -f config_post
    rm -f hostfile
}

[ $# -eq 0 ] && (usage; exit 1)

action="build"
while getopts "ht:" arg; do
  case $arg in
    t)
        action=${OPTARG}
        ;;
    h | *)
        usage
        exit 0
        ;;
  esac
done

if [ x"${action}" = x"build" ]; then
    build_ext
    build_master
elif [ x"${action}" = x"init" ]; then
    init_cluster
else
    echo "ERROR: unknown action "$action"."
    exit 1
fi
