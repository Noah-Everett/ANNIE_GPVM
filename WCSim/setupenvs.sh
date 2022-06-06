setup_genie_2_12(){
  if [ -z "$GVERS"    ]; then export GVERS="v2_12_10b"             ; fi
  if [ -z "$GQAUL"    ]; then export GQUAL="debug:e15"         ; fi
 #if [ -z "$GQAUL"    ]; then export GQUAL="debug:e9:r5"         ; fi
  if [ -z "$XSECQUAL" ]; then export XSECQUAL="DefaultPlusMECWithNC" ; fi
#  setup genie        ${GVERS}a -q ${GQUAL}
  setup genie        v2_12_10b -q debug:e15
 # setup genie        v2_12_10b -q debug:e15:r5
  setup genie_phyopt v2_12_10 -q dkcharmtau
 # setup genie_phyopt v2_12_10 -q dkcharmtau
  # do phyopt before xsec in case xsec has its own UserPhysicsOptions.xml
  setup genie_xsec   v2_12_10 -q ${XSECQUAL}
 # setup genie_xsec   v2_12_10 -q ${XSECQUAL}
  if [ $? -ne 0 ]; then
    # echo "$b0: looking for genie_xec ${GVERS}a -q ${XSECQUAL}"
    # might have a letter beyond GENIE code's
    setup genie_xsec   ${GVERS}a -q ${XSECQUAL}
  fi
#source /annie/app/users/neverett/bin/setup_genie3_00_06.sh
  
  setup ifdhc   # for copying geometry & flux files
  export IFDH_CP_MAXRETRIES=2  # default 8 tries is silly
  
  setup -q debug:e15 xerces_c v3_2_0a  # xerces needed for gdml parsing? (needed for geant4 gdml...)
  export XERCESROOT=$XERCESCROOT
  export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${GENIE}/../include/GENIE
  export ROOT_LIBRARY_PATH=${ROOT_LIBRARY_PATH}:${GENIE}/../lib
}

# cadmesh is used for converting stl to gdml. built into WCSim but not normally required.
setup_cadmesh(){
  echo "setting up CADMESH"
  export LD_LIBRARY_PATH=/annie/app/users/moflaher/cadmesh/install_sl7/lib:$LD_LIBRARY_PATH
  export ENABLE_CADMESH=1  ## enable this to add CADMESH libraries to WCSim build (re-run CMAKE)
  export CADMESH_CMAKE_DIR=/annie/app/users/moflaher/cadmesh/install_sl7/lib/cmake/cadmesh-1.1.0
  export CADMESH_INCLUDE_DIR=/annie/app/users/moflaher/cadmesh/install_sl7/include
  setup qt v5_4_2a -q e9
}


setup_wcsim(){
  echo "setting up Geant"
#  setup geant4 v4_10_1_p03 -q e9:debug
  setup geant4 v4_10_3_p03c -q debug:e15
  export GEANT4_PATH=$(ls -d ${GEANT4_FQ_DIR}/lib64/*/)
#  export GEANT4_MAKEFULL_PATH=/grid/fermiapp/products/larsoft/geant4/v4_10_1_p03/source/geant4.10.01.p03
  export GEANT4_MAKEFULL_PATH=/grid/fermiapp/products/nova/externals/geant4/v4_10_3_p03c/source/geant4.10.03.p03
  export G4SYSTEM=Linux-g++
  echo "setting up GENIE"
  setup_genie_2_12                            # genie isn't normally needed, but if you want to enable it
  echo "setting up ROOT"
  setup -q debug:e15 root v6_12_06a        # call setup_genie before setup root, so we get the right
  source $ROOTSYS/bin/thisroot.sh             # version of ROOT at the end
  export ROOT_PATH=$ROOTSYS/cmake
  echo "setting up clhep"
  setup -q debug:e15 clhep v2_3_4_6
  echo "setting up cmake"
  setup cmake v3_10_1
  
  # this is important for handling neutrons
  source $WCSIMDIR/envHadronic.sh  # must be called at the start of each new shell session
  
  # export the path to a rootdict and library and corresponding headers to be able to read wcsim files
  # without having to manually load the class definitions first
  export LD_LIBRARY_PATH=${WCSIMDIR}:$LD_LIBRARY_PATH
  export ROOT_INCLUDE_PATH=${WCSIMDIR}/include:$ROOT_INCLUDE_PATH
}

# setup access to ups products
source /grid/fermiapp/products/common/etc/setup
export PRODUCTS=${PRODUCTS}:/grid/fermiapp/products/larsoft:/grid/fermiapp/products/nova/externals:/grid/fermiapp/products/minerva/db

# if you want to import stl files to wcsim, run this to enable linking against cadmesh
# note this isn't a ups product! You should make your own copy and update the paths above.
#setup_cadmesh

# setup the products we need to build wcsim
THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export WCSIMDIR=${THIS_SCRIPT_DIR}/wcsim/source     # path to wcsim source files
setup_wcsim

# setup the products we need to submit jobs to the grid
echo "setting up fife_utils"
setup fife_utils
