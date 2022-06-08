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
#============================================SETUP IFDH===========================================#
source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setup
setup ifdhc # ifdh is used to interact with gpvm from grid node
#==========================================SETUP OUT DIR==========================================#
export SNE=/pnfs/annie/scratch/users/neverett/
export SW=${SNE}/wcsim_output

ifdh mkdir_p ${SW}/wcsim_output/${RUNBASE}_${CLUSTER}

export OUTDIR=${SW}/wcsim_output/${RUNBASE}_${CLUSTER}
#============================================MAKE WCSim===========================================#

export WB=
export WS=
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

ifdh cp -D WCSim_${CLUSTER}_${PROCESS}.mac ${OUTDIR}
if [ $? -ne 0 ]; then 
  echo "Something went wrong when copying \`WCSim_${CLUSTER}_${PROCESS}.mac\` to \`${OUTDIR}\`."
  return 5
fi
#====================================MAKE primaries_directory.mac=================================#
rm ${WB}/macros/primaries_directory.mac
cat <<EOF > ${WB}/macros/primaries_directory.mac
/mygen/neutrinosdirectory ${PRIMARIES}
/mygen/primariesdirectory ${INPUT_TAR_DIR_LOCAL}/pnfs/annie/persistent/users/moflaher/g4dirt_vincentsgenie/BNB_Water_10k_22-05-17/annie_tank_flux.*.root
EOF

#=============================================RUN WCSim===========================================#
cd ${WB}
./WCSim WCSim_${CLUSTER}_${PROCESS}.mac

#===========================GRID INIT========================#
SCRATCH_DIR=/pnfs/annie/scratch/users


#======================================================================#


#=============================MAKE LOG========================#
ifdh mkdir_p ${SCRATCH_DIR}/${GRID_USER}/genie_output/${RUNBASE}_${CLUSTER}
cat <<EOF > ${RUN}.log
            Program: /cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_06k/Linux64bit+3.10-2.17-e20-debug/bin/gevgen_fnal
                Run: ${RUN}
               Seed: ${SEED}
            Top Vol: ${TOPVOL}
               Flux: ${FLUX}
           Geometry: ${GEOMETRY}
              Units: ${UNITS}
     Cross Sections: ${GENIEXSEC}
               Tune: G18_10a_02_11a
   Number of Events: ${NEVENTS}
Maximum Path Length: ${MAXPL}
 Message Thresholds: ${MESTHRE}
EOF
ifdh cp -D $IFDH_OPTION ${RUN}.log ${SCRATCH_DIR}/${GRID_USER}/genie_output/${RUNBASE}_${CLUSTER}
#          Z Minimum: ${ZMIN}
#======================================================================#



#===============================RUN GENIE=============================#
/cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_06k/Linux64bit+3.10-2.17-e20-debug/bin/gevgen_fnal \
-r ${RUN} \
--seed ${SEED} \
-t ${TOPVOL} \
-f ${FLUX} \
-g ${GEOMETRY} \
${UNITS} \
--cross-sections ${GENIEXSEC} \
--tune G18_10a_02_11a \
-n ${NEVENTS} \
-m $MAXPL \
--message-thresholds $MESTHRE
#-z $ZMIN \
#======================================================================#



#=================================END GRID================================#
echo "Here is the your environment in this job: " > job_output_${CLUSTER}.${PROCESS}.log
env >> job_output_${CLUSTER}.${PROCESS}.log
echo "group = $GROUP"
# If GRID_USER is not set for some reason, try to get it from the proxy
if [ -z ${GRID_USER} ]; then
GRID_USER=`basename $X509_USER_PROXY | cut -d "_" -f 2`
fi
echo "GRID_USER = `echo $GRID_USER`"
export GLIDEIN_ToDie=`condor_config_val GLIDEIN_ToDie`
echo "GLIDEIN_ToDie = $GLIDEIN_ToDie"
# let's try an ldd on ifdh
ldd `which ifdh`
sleeptime=$RANDOM
if [ -z "${sleeptime}" ] ; then sleeptime=4 ; fi
sleeptime=$(( (($sleeptime % 10) + 1)*60 ))
sleep $sleeptime
umask 002
if [ -z "$SCRATCH_DIR" ]; then
    echo "Invalid scratch directory, not copying back."
    echo "I am going to dump the log file to the main job stdout in this case."
    cat job_output_${CLUSTER}.${PROCESS}.log
else
# Very useful for debugging problems with copies
export IFDH_DEBUG=1
export IFDH_CP_MAXRETRIES=2
export IFDH_GRIDFTP_EXTRA="-st 1000"
    # first do lfdh ls to check if directory exists. We put a zero on the end because we only want 
    # to check that the directory exists; we don't care what's in it (i.e recursion depth of 0).
    ifdh ls ${SCRATCH_DIR}/$GRID_USER 0
    # A non-zero exit value probably means it doesn't exist yet, or does not have group write permission, 
    # so send a useful message saying that is probably the issue
    if [ $? -ne 0 ] && [ -z "$IFDH_OPTION" ] ; then 
    echo "Unable to read ${SCRATCH_DIR}/$GRID_USER. Make sure that you have created this directory and given it group write permission (chmod g+w ${SCRATCH_DIR}/$GRID_USER)."
    exit 74
    else
        # directory already exists, so let's copy
#   ifdh cp -D $IFDH_OPTION job_output_${CLUSTER}.${PROCESS}.log ${SCRATCH_DIR}/${GRID_USER}/job_output
    ifdh cp -D $IFDH_OPTION *.root ${SCRATCH_DIR}/${GRID_USER}/genie_output/${RUNBASE}_${CLUSTER}
      if [ $? -ne 0 ]; then
          echo "Error $? when copying to dCache scratch area!"
          echo "If you created ${SCRATCH_DIR}/${GRID_USER} yourself,"
          echo "make sure that it has group write permission."
          echo "Also make sure that you are copying the correct file."
          exit 73
      fi
#    if [ ${RUNBASE} -eq 0 ]; then
#      ifdh cp -D $IFDH_OPTION gntp.${PROCESS}.ghep.root ${SCRATCH_DIR}/${GRID_USER}/genie_output/${RUNBASE}_${CLUSTER}
#      if [ $? -ne 0 ]; then
#          echo "Error $? when copying to dCache scratch area!"
#          echo "If you created ${SCRATCH_DIR}/${GRID_USER} yourself,"
#          echo "make sure that it has group write permission."
#          echo "Also make sure that you are copying the correct file."
#          exit 73
#      fi
#    else
#      ifdh cp -D $IFDH_OPTION gntp.${RUN}.ghep.root ${SCRATCH_DIR}/${GRID_USER}/genie_output/${RUNBASE}_${CLUSTER}
#      if [ $? -ne 0 ]; then
#        echo "Error $? when copying to dCache scratch area!"
#        echo "If you created ${SCRATCH_DIR}/${GRID_USER} yourself,"
#        echo "make sure that it has group write permission."
#        echo "Also make sure that you are copying the correct file."
#        exit 73
#      fi
#    fi
    fi
fi
echo "End `date`"
exit 0
#======================================================================#
