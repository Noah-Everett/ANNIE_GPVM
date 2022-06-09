#!/bin/bash

#=========================================GET USER VARIABLES======================================#

for i in "$@"; do
  case $i in
    -r=*                   ) export RUNBASE="${i#*=}"   shift  ;;
    -p=*                   ) export PRIMARIES="${i#*=}" shift  ;;
    -n=*                   ) export NEVENTS="${i#*=}"   shift  ;;
    -g=*                   ) export GEOMETRY="${i#*=}"  shift  ;;
    -*                     ) echo "Unknown option \`$i\`.";  exit 1 ;;
  esac
done

#=========================================PROCESS VARIABLES=======================================#

R=$INPUT_TAR_DIR_LOCAL/annie/app/users/neverett/runs
G=$INPUT_TAR_DIR_LOCAL/annie/app/users/neverett/geometry

if [ -z "${RUNBASE}" ]; then
  echo "Use \`-r=\` to set the run base number."
  return 1
fi

if [ -z "${PRIMARIES}" ]; then
  echo "Use \`-p=\` to set the primaries directory (in \`$R\`)."
  return 2
fi
export PRIMARIES=${R}/${PRIMARIES}

if [ -z "${NEVENTS}" ]; then
  echo "Use \`-n=\` to set the number of events to propigate."
  return 3
fi

if [ -z "${GEOMETRY}" ]; then
  echo "Use \`-g=\` to set the annie geometry (in \`$G\`)."
  return 4
fi
export GEOMETRY=${G}/${GEOMETRY}

#======================================CALCULATE EVENT NUMBERS====================================#

let PRIMARIES_OFFSET=$((${PROCESS}*${NEVENTS}))

#============================================SETUP IFDH===========================================#

source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setup
setup ifdhc # ifdh is used to interact with gpvm from grid node

#==========================================SETUP OUT DIR==========================================#

export SNE=/pnfs/annie/scratch/users/neverett/
export SW=${SNE}/wcsim_output

ifdh mkdir_p ${SW}/wcsim_output/${RUNBASE}_${CLUSTER}

export OUTDIR=${SW}/wcsim_output/${RUNBASE}_${CLUSTER}

#============================================MAKE WCSim===========================================#

export W=${INPUT_TAR_DIR_LOCAL}/annie/app/users/neverett/bin/WCSim/
export WB=${W}/wcsim/build
export WS=${W}/wcsim/WCSim

#========================================MOVE GEOMETRY FILE=======================================#

cp ${INPUT_TAR_DIR_LOCAL}/${GEOMETRY} ${WS}/annie_v04.gdml  # Geometry may not be `annie_v04.gdml` (probably isnt); 
                                                            # however, this name is in the code (easier to give into the code than change it).

#==========================================MAKE MAC FILE==========================================#

cat <<EOF > ${WB}/WCSim_${CLUSTER}_${PROCESS}.mac
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

/run/beamOn ${NEVENTS}
EOF

ifdh cp -D ${WB}/WCSim_${CLUSTER}_${PROCESS}.mac ${OUTDIR}
if [ $? -ne 0 ]; then 
  echo "Something went wrong when copying \`${WB}/WCSim_${CLUSTER}_${PROCESS}.mac\` to \`${OUTDIR}\`."
  return 5
fi

#====================================MAKE primaries_directory.mac=================================#

rm ${WB}/macros/primaries_directory.mac
cat <<EOF > ${WB}/macros/primaries_directory.mac
/mygen/neutrinosdirectory ${PRIMARIES}
/mygen/primariesdirectory ${INPUT_TAR_DIR_LOCAL}/pnfs/annie/persistent/users/moflaher/g4dirt_vincentsgenie/BNB_Water_10k_22-05-17/annie_tank_flux.*.root
/mygen/primariesoffset ${PRIMARIES_OFFSET}
EOF
ifdh cp -D ${WB}/macros/primaries_directory.mac ${OUTDIR}
if [ $? -ne 0 ]; then 
  echo "Something went wrong when copying \`${WB}/macros/primaries_directory.mac\` to \`${OUTDIR}\`."
  return 6
fi

#=============================================MAKE LOG============================================#

cat <<EOF > ${RUNBASE}_${CLUSTER}_${PROCESS}.log
            Cluster: ${CLUSTER}
            Process: ${PROCESS}
            Program: WCSim
           Run base: ${RUNBASE}
          Primaries: ${PRIMARIES}
           Geometry: ${GEOMETRY}
   Number of Events: ${NEVENTS}
   Primaries Offset: ${PRIMARIES_OFFSET}
EOF
ifdh cp -D ${RUNBASE}_${CLUSTER}_${PROCESS}.log ${OUTDIR}
if [ $? -ne 0 ]; then 
  echo "Something went wrong when copying \`${PWD}/${RUNBASE}_${CLUSTER}_${PROCESS}.log\` to \`${OUTDIR}\`."
  return 7
fi

#=============================================RUN WCSim===========================================#

cd ${WB}
./WCSim WCSim_${CLUSTER}_${PROCESS}.mac 2>&1 | tee WCSim_${CLUSTER}_${PROCESS}.log

#=============================================END GRID============================================#

ifdh cp -D WCSim_${CLUSTER}_${PROCESS}* ${OUTDIR}
if [ $? -ne 0 ]; then 
  echo "Something went wrong when copying \`${PWD}/WCSim_${CLUSTER}_${PROCESS}*\` to \`${OUTDIR}\`."
  return 7
fi

echo "End `date`"
exit 0

#=================================================================================================#
