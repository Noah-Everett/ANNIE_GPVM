#!/bin/bash
mkdir wcsim
cd wcsim/
#cp /annie/app/users/moflaher/wcsim/setupenvs.sh ./
mkdir build
git clone https://github.com/anniesoft/WCSim.git source
cd source/
git remote rename origin anniesoft
git checkout -b annie anniesoft/annie
# TODO remove this and update the repository version of primaries_directory.mac
cp /annie/app/users/moflaher/wcsim/primaries_directory.mac ./macros/
cp /annie/app/users/moflaher/wcsim/wcsim/CMakeLists.txt ./

cp /annie/app/users/neverett/WCSim/modified_code/GdNeutronHPCaptureFS.hh /annie/app/users/neverett/WCSim/wcsim/source/include
cp /annie/app/users/neverett/WCSim/modified_code/GdNeutronHPCaptureFS.cc /annie/app/users/neverett/WCSim/wcsim/source/src
cp /annie/app/users/neverett/WCSim/modified_code/GdNeutronHPCaptureFSANNRI.hh /annie/app/users/neverett/WCSim/wcsim/source/include
cp /annie/app/users/neverett/WCSim/modified_code/GdNeutronHPCaptureFSANNRI.cc /annie/app/users/neverett/WCSim/wcsim/source/src
cp /annie/app/users/neverett/WCSim/modified_code/GdNeutronHPCapture.hh /annie/app/users/neverett/WCSim/wcsim/source/include
cp /annie/app/users/neverett/WCSim/modified_code/GdNeutronHPCapture.cc /annie/app/users/neverett/WCSim/wcsim/source/src
cp /annie/app/users/neverett/WCSim/modified_code/WCSimConstructPMT.cc /annie/app/users/neverett/WCSim/wcsim/source/src
cp /annie/app/users/neverett/WCSim/modified_code/WCSimWCSD.cc /annie/app/users/neverett/WCSim/wcsim/source/src

#source ../setupenvs.sh
source ../../setupenvs.sh
make clean
make rootcint
make
#git add -A
#git commit -m "first wcsim annie commit"
cd ../build/
cmake ../source/
#NUMCPUS = $(nproc)
make -j 4

cp /annie/app/users/neverett/WCSim/geniedirectory.txt /annie/app/users/neverett/WCSim/wcsim/build
cp /annie/app/users/neverett/WCSim/primaries_directory.mac /annie/app/users/neverett/WCSim/wcsim/build/macros
cp /annie/app/users/neverett/WCSim/WCSim.mac /annie/app/users/neverett/WCSim/wcsim/build
