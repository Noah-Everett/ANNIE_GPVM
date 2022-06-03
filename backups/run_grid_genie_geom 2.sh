#============================COMMAND=============================#
#jobsub_submit -G annie -M -N 5 --memory=2000MB --disk=2GB --cpu=2 --expected-lifetime=24h --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE -l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' --append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' --tar_file_name=dropbox:///annie/app/users/neverett/grid/genie_grid.tar.gz file:///annie/app/users/neverett/grid/run_grid_genie.sh
#======================================================================#



#===========================GRID INIT========================#
set -x
echo Start `date`
echo Site:${GLIDIEN_ResourceName}
echo "the worker node is " `hostname` "OS: " `uname -a`
echo "You are running as user `whoami`"
IFDH_OPTION=""
GROUP=$EXPERIMENT
if [ -z $GROUP ]; then
GROUP=`id -gn`
fi
SCRATCH_DIR=/pnfs/annie/scratch/users
if [ -z $X509_CERT_DIR ] && [ ! -d /etc/grid-security/certificates ]; then
    if [ -f /cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el7-x86_64/setup.sh ]; then
    source /cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el7-x86_64/setup.sh || echo "Failure to run OASIS software setup script!"
    else
    echo "X509_CERT_DIR is not set, and the /etc/grid-security/certificates directory is not present. No guarantees ifdh, etc. will work!"
    fi
fi
if [ -z "`which globus-url-copy`" ] || [ -z "`which uberftp`" ]; then
 if [ -f /cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el7-x86_64/setup.sh ]; then
     source /cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el7-x86_64/setup.sh || echo "Failure to run OASIS software setup script!"
 else
     echo "globus-url-copy or uberftp (or both) is not in PATH, and the oasis CVMFS software repo does not appear to be present. No guarantees ifdh, etc. will work!"
 fi
fi
# A few commands to lookk around to see what kind of environment we are in. Should match the requested container.
voms-proxy-info --all
lsb_release -a
cat /etc/redhat-release
ps -ef
source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setup
setup ifdhc -z /cvmfs/fermilab.opensciencegrid.org/products/common/db || { echo "error setting up ifdhc!" ; sleep 300 ; exit 69; }
#======================================================================#



#===================SCRIPT VARIABLES=====================#
# Directories
B=$INPUT_TAR_DIR_LOCAL/annie/app/users/neverett/bin
C=$INPUT_TAR_DIR_LOCAL/annie/app/users/neverett/config
G=$INPUT_TAR_DIR_LOCAL/annie/app/users/neverett/geometry
F=$INPUT_TAR_DIR_LOCAL/annie/data/flux/bnb

for i in "$@"; do
  case $i in
    -r=*                   ) export RUNBASE="${i#*=}"   shift ;;
    -n=*                   ) export NEVENTS="${i#*=}"   shift ;;
    -g=*                   ) export GDML="${i#*=}"      shift ;;
    -t=*                   ) export TOPVOL="${i#*=}"    shift ;;
    -f=*                   ) export FLUXFILE="${i#*=}"  shift ;;
    -m=*                   ) export MAXPL="${i#*=}"     shift ;;
    --message-thresholds=* ) export MESTHRE="${i#*=}"   shift ;;
    -x=*                   ) export X="${i#*=}"         shift ;;
    -y=*                   ) export Y="${i#*=}"         shift ;;
    -z=*                   ) export Z="${i#*=}"         shift ;;
    -r=*                   ) export R="${i#*=}"         shift ;;
    -*                     ) echo "unknown option $i" exit 1 ;;
   esac
done

if [ -z "$FLUXFILE" ]; then
  export FLUXFILE="bnb_annie_0000.root"
fi

if [ -z "$ZMIN" ]; then
  export ZMIN="-2000"
fi

#if [ -z "$GEOMETRY" ]; then
#  export GEOMETRY="annie_v02.gdml"
#fi
export GEOMETRY=annie_v02_${PROCESS}.gdml
export GEOMETRY="${G}/annie_v02_5/${GEOMETRY}"

if [-z "$MESTHRE" ]; then
  export MESTHRE=""
else
  export MESTHRE="${C}/${MESTHRE}"
fi

if [ -z "$TOPVOL" ]; then
  export $TOPVOL="TARGON_LV"
fi

export GENIEXSEC=/cvmfs/larsoft.opensciencegrid.org/products/genie_xsec/v3_00_04_ub2/NULL/G1810a0211a-k250-e1000/data/gxspl-FNALsmall.xml
export MAXPL=${G}/${MAXPL}
export RUN=${RUNBASE}${PROCESS} #"0"  # starting run number
export SEED=$RUN #"0" # random # seed
export FLXPSET="ANNIE-tank"
export FLUX="${F}/${FLUXFILE},${FLXPSET}"
export GENIEXSEC=/cvmfs/larsoft.opensciencegrid.org/products/genie_xsec/v3_00_04_ub2/NULL/G1810a0211a-k250-e1000/data/gxspl-FNALsmall.xml
export UNITS="-L cm -D g_cm3"
export XYZHALL=( -393.70 -213.36   0.0  307.34 1021.08 487.68 )
export XYZBLDG=( -434.34 -259.08 -40.64 347.98 1066.80 528.32 )
#======================================================================#



#===========================GENIE SETUP=======================#
source ${B}/setup_genie3_00_06.sh #$CONDOR_DIR_INPUT/setup_genie3_00_06.sh
export GXMLPATH=${C}:${GXMLPATH} #$CONDOR_DIR_INPUT:${GXMLPATH}
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
-z $ZMIN \
-S 10000 \
--message-thresholds $MESTHRE
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
    ifdh mkdir_p ${SCRATCH_DIR}/${GRID_USER}/genie_output/${RUNBASE}_${CLUSTER}
#   ifdh cp -D $IFDH_OPTION job_output_${CLUSTER}.${PROCESS}.log ${SCRATCH_DIR}/${GRID_USER}/job_output
    ifdh cp -D $IFDH_OPTION gntp.${RUN}.ghep.root ${SCRATCH_DIR}/${GRID_USER}/genie_output/${RUNBASE}_${CLUSTER}
    if [ $? -ne 0 ]; then
        echo "Error $? when copying to dCache scratch area!"
        echo "If you created ${SCRATCH_DIR}/${GRID_USER} yourself,"
        echo " make sure that it has group write permission."
        exit 73
    fi
    fi
fi
echo "End `date`"
exit 0
#======================================================================#
