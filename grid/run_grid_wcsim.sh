#!/bin/bash

#=================================================================================================#
#============================================ INIT SCRIPT ========================================#
#=================================================================================================#

export HOMEDIR=${PWD}

#=================================================================================================#
#======================================== GET USER VARIABLES =====================================#
#=================================================================================================#

for i in "$@"; do
  case $i in
    -r=*   ) export RUNBASE="${i#*=}"             shift  ;;
    -p_g=* ) export PRIMARIESDIR_GENIE="${i#*=}"  shift  ;;
    -p_d=* ) export PRIMARIESDIR_G4DIRT="${i#*=}" shift  ;;
    -d=*   ) export NDIRT="${i#*=}"               shift  ;;
    -w=*   ) export NWCSIM="${i#*=}"              shift  ;;
    -g=*   ) export GEOMETRY="${i#*=}"            shift  ;;
    -o=*   ) export OUTDIR="${i#*=}"              shift  ;;
    -*     ) echo "Unknown option \`$i\`.";       exit 1 ;;
  esac
done

export OUTDIR=${OUTDIR}/${RUNBASE}_${CLUSTER}

#=================================================================================================#
#========================================= CALCULATE NUMBERS =====================================#
#=================================================================================================#

export PROCESS=1910 ###TEMPORARY###
let NUM=$(((${PROCESS}*${NWCSIM})/${NDIRT}))
let OFFSET=$(((${PROCESS}*${NWCSIM})-(${NUM}*${NDIRT})))

if [ "${RUNBASE}" == "0" ]; then
  export NUM=${NUM}
else
  export NUM=${RUNBASE}${NUM}
fi

#=================================================================================================#
#============================================= SETUPS ============================================#
#=================================================================================================#

export CODE_BASE=/cvmfs/larsoft.opensciencegrid.org/products
source ${CODE_BASE}/setup
export PRODUCTS=${PRODUCTS}:${CODE_BASE}

setup ifdhc        v2_6_3       -q c7:debug:p392
setup geant4       v4_10_3_p03c -q debug:e15
setup genie        v2_12_10b    -q debug:e15  
setup genie_phyopt v2_12_10     -q dkcharmtau
setup genie_xsec   v2_12_10     -q DefaultPlusMECWithNC
setup xerces_c     v3_2_0a      -q debug:e15
setup root         v6_12_06a    -q debug:e15
setup cmake        v3_10_1

source ${CODE_BASE}/larsoft/root/v6_06_08/Linux64bit+2.6-2.12-e10-nu-debug/bin/thisroot.sh
#source /cvmfs/larsoft.opensciencegrid.org/products/root/v6_12_06a/Linux64bit+2.6-2.12-e15-debug/bin/thisroot.sh
export CXX=$(which g++)
export CC=$(which gcc)
export XERCESROOT=${CODE_BASE}/larsoft/xerces_c/v3_1_3/Linux64bit+2.6-2.12-e10-debug
export G4SYSTEM=Linux-g++
export ROOT_PATH=${CODE_BASE}/larsoft/root/v6_06_08/Linux64bit+2.6-2.12-e10-nu-debug/cmake
#export ROOT_PATH=/cvmfs/larsoft.opensciencegrid.org/products/root/v6_12_06a/Linux64bit+2.6-2.12-e15-debug/cmake
export GEANT4_PATH=${GEANT4_FQ_DIR}/lib64/Geant4-10.1.3
export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${GENIE}/../include/GENIE
export ROOT_LIBRARY_PATH=${ROOT_LIBRARY_PATH}:${GENIE}/../lib

#=================================================================================================#
#========================================= SETUP OUT DIR =========================================#
#=================================================================================================#

ifdh mkdir_p ${OUTDIR}

#=================================================================================================#
#=========================================== MAKE WCSim ==========================================#
#=================================================================================================#

export W=${INPUT_TAR_DIR_LOCAL}/annie/app/users/neverett/WCSim
export WB=${W}/wcsim/build
export WS=${W}/wcsim/WCSim

export HW=${HOMEDIR}/WCSim
export HB=${HW}/wcsim/build
export HS=${HW}/wcsim/WCSim

cp -r ${W} ${HOMEDIR}
mkdir ${HB}
cp ${HW}/modified_code/GdNeutronHPCaptureFS.hh      ${HS}/include
cp ${HW}/modified_code/GdNeutronHPCaptureFS.cc      ${HS}/src
cp ${HW}/modified_code/GdNeutronHPCaptureFSANNRI.hh ${HS}/include
cp ${HW}/modified_code/GdNeutronHPCaptureFSANNRI.cc ${HS}/src
cp ${HW}/modified_code/GdNeutronHPCapture.hh        ${HS}/include
cp ${HW}/modified_code/GdNeutronHPCapture.cc        ${HS}/src
rm ${HS}/CMakeCache.txt

cd ${HS}
make clean    > ${HOMEDIR}/WCSim_source_make_clean.log    2>&1
make rootcint > ${HOMEDIR}/WCSim_source_make_rootcint.log 2>&1
make          > ${HOMEDIR}/WCSim_source_make.log          2>&1

cd ${HB}
cmake ${HS} > ${HOMEDIR}/WCSim_build_cmake.log 2>&1
make        > ${HOMEDIR}/WCSim_build_make.log  2>&1

#=================================================================================================#
#======================================= GET GEOMETRY FILE =======================================#
#=================================================================================================#

ifdh cp ${GEOMETRY} ${HS}/annie_v04.gdml  # Geometry may not be `annie_v04.gdml` (probably isnt); 
                                          # however, this name is in the code (easier to give into the code than change it).

#=================================================================================================#
#========================================== GET PRIMARIES ========================================#
#=================================================================================================#

ifdh cp -D ${PRIMARIESDIR_GENIE}/gntp.${NUM}.ghep.root ${HB}
ifdh cp -D ${PRIMARIESDIR_G4DIRT}/annie_tank_flux.${NUM}.root ${HB}

#=================================================================================================#
#======================================= MAKE RUN MACRO ==========================================#
#=================================================================================================#

cat <<EOF > ${HB}/WCSim_${CLUSTER}_${PROCESS}.mac
#!/bin/sh 

/run/verbose 0
/tracking/verbose 0
/hits/verbose 0
/process/em/verbose 0
/process/had/cascade/verbose 0
/process/verbose 0
/process/setVerbose 0
/run/initialize
/vis/disable

/WCSim/PMTQEMethod   Multi_Tank_Types
/WCSim/LAPPDQEMethod Multi_Tank_Types

/WCSim/PMTCollEff on

/WCSim/SavePi0 true

/control/execute macros/annie_daq.mac

/DarkRate/SetDetectorElement tank
/DarkRate/SetDarkMode 1
/DarkRate/SetDarkHigh 100000
/DarkRate/SetDarkLow 0
/DarkRate/SetDarkWindow 4000

/DarkRate/SetDetectorElement mrd
/DarkRate/SetDarkMode 1
/DarkRate/SetDarkHigh 100000
/DarkRate/SetDarkLow 0
/DarkRate/SetDarkWindow 4000

/DarkRate/SetDetectorElement facc
/DarkRate/SetDarkMode 1
/DarkRate/SetDarkHigh 100000
/DarkRate/SetDarkLow 0
/DarkRate/SetDarkWindow 4000

/mygen/generator beam

/control/execute macros/setRandomParameters.mac

/WCSimIO/RootFile WCSim_${CLUSTER}_${PROCESS}

/run/beamOn ${NWCSIM}
EOF

#=================================================================================================#
#================================= MAKE primaries_directory.mac ==================================#
#=================================================================================================#

rm ${HB}/macros/primaries_directory.mac
cat <<EOF > ${HB}/macros/primaries_directory.mac
/mygen/neutrinosdirectory ${HB}/gntp.*.ghep.root
/mygen/primariesdirectory ${HB}/annie_tank_flux.*.root
/mygen/primariesoffset ${OFFSET}
EOF

#=================================================================================================#
#================================= MOVE WCSimRootDict_rdict.pcm ==================================#
#=================================================================================================#

cp ${HS}/WCSimRootDict_rdict.pcm ${HB}

#=================================================================================================#
#============================================ MAKE LOG ===========================================#
#=================================================================================================#

cat <<EOF > ${HOMEDIR}/WCSim_${CLUSTER}_${PROCESS}.log
##########################################################
#==================== RUN PARAMETERS ====================#
##########################################################
            Cluster: ${CLUSTER}
            Process: ${PROCESS}
            Program: WCSim
           Run base: ${RUNBASE}
    GENIE Primaries: ${PRIMARIESDIR_GENIE}
   G4DIRT Primaries: ${PRIMARIESDIR_G4DIRT}
Primary File Number: ${NUM}
     Primary Offset: ${OFFSET}
           Geometry: ${GEOMETRY}
   Number of Events: ${NEVENTS}
   Primaries Offset: 0

#####################################################
#==================== WCSim.mac ====================#
#####################################################
`cat ${HB}/WCSim_${CLUSTER}_${PROCESS}.mac`

###################################################################
#==================== primaries_directory.mac ====================#
###################################################################
`cat ${HB}/macros/primaries_directory.mac`

####################################################
#==================== ${HB} ls ====================#
####################################################
`ls ${HB}`

#########################################################
#==================== ${HOMEDIR} ls ====================#
#########################################################
`ls ${HOMEDIR}`

#######################################################################
#==================== WCSim_source_make_clean.log ====================#
#######################################################################
`cat ${HOMEDIR}/WCSim_source_make_clean.log`

##########################################################################
#==================== WCSim_source_make_rootcint.log ====================#
##########################################################################
`cat ${HOMEDIR}/WCSim_source_make_rootcint.log`

#################################################################
#==================== WCSim_source_make.log ====================#
#################################################################
`cat ${HOMEDIR}/WCSim_source_make.log`

#################################################################
#==================== WCSim_build_cmake.log ====================#
#################################################################
`cat ${HOMEDIR}/WCSim_build_cmake.log`

#################################################################
#==================== WCSim_build_make.log  ====================#
#################################################################
`cat ${HOMEDIR}/WCSim_build_make.log`

###################################################
#==================== RUN LOG ====================#
###################################################
EOF

#=================================================================================================#
#============================================ RUN WCSim ==========================================#
#=================================================================================================#

cd ${HB}
./WCSim WCSim_${CLUSTER}_${PROCESS}.mac >> ${HOMEDIR}/WCSim_${CLUSTER}_${PROCESS}.log 2>&1

#=================================================================================================#
#========================================= MOVE FILES ============================================#
#=================================================================================================#

ifdh cp -D ${HOMEDIR}/WCSim_${CLUSTER}_${PROCESS}.log ${OUTDIR}
if [ $? -ne 0 ]; then 
  echo "Something went wrong when copying \`${HOMEDIR}/WCSim_${CLUSTER}_${PROCESS}.log\` to \`${OUTDIR}\`."
  exit 1
fi

ifdh cp -D WCSim_${CLUSTER}_${PROCESS}_0.root ${OUTDIR}
if [ $? -ne 0 ]; then 
  echo "Something went wrong when copying \`${PWD}/WCSim_${CLUSTER}_${PROCESS}_0.root\` to \`${OUTDIR}\`."
  exit 2
fi

ifdh cp -D WCSim_${CLUSTER}_${PROCESS}_lappd_0.root ${OUTDIR}
if [ $? -ne 0 ]; then 
  echo "Something went wrong when copying \`${PWD}/WCSim_${CLUSTER}_${PROCESS}_lappd_0.root\` to \`${OUTDIR}\`."
  exit 3
fi

#=================================================================================================#
#========================================== REMOVE FILES =========================================#
#=================================================================================================#

cd ${HOMEDIR}
rm -rf ${INPUT_TAT_DIR_LOCAL}
rm -rf ${HW}

#=================================================================================================#
#============================================ END GRID ===========================================#
#=================================================================================================#

echo "End `date`"
exit 0

#=================================================================================================#
#=================================================================================================#
#=================================================================================================#
