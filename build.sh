#!/bin/bash

PREFIX=$HOME/dune-test
DUNE_VER=2.6.0

OPM_VER=2018.04

function build() {
  mkdir build
  cd build
  cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX
  make -j `nproc`
  make install
}

for dune_repo in dune-common dune-geometry dune-istl dune-localfunctions dune-grid
do
  test -f $dune_repo-$DUNE_VER.tar.gz || wget https://dune-project.org/download/$DUNE_VER/$dune_repo-$DUNE_VER.tar.gz
  test -d $dune_repo-$DUNE_VER || tar zxvf $dune_repo-$DUNE_VER.tar.gz
  pushd $dune_repo-$DUNE_VER
  build
  cd ..
  rm -rf build
  popd
done

# libecl
test -f libecl_$OPM_VER.tar.gz || wget -O libecl_$OPM_VER.tar.gz https://github.com/Statoil/libecl/archive/release/2018.04/final.tar.gz
test -d libecl-release-$OPM_VER-final || tar zxvf libecl_$OPM_VER.tar.gz
pushd libecl-release-$OPM_VER-final
build
cd ..
rm -rf build
popd

for opm_repo in opm-common opm-material opm-grid
do
  test -f $opm_repo-$OPM_VER.tar.gz || wget -O $opm_repo-$OPM_VER.tar.gz https://github.com/OPM/$opm_repo/archive/release/$OPM_VER/final.tar.gz
  test -d $opm_repo-release-$OPM_VER-final || tar zxvf $opm_repo-$OPM_VER.tar.gz
  if [ "$opm_repo" == "opm-grid" ]
  then
    patch -p0 < 01-opm-grid-assert.patch
  fi
  pushd $opm_repo-release-$OPM_VER-final
  build
  cd ..
  rm -rf build
  popd
done  
