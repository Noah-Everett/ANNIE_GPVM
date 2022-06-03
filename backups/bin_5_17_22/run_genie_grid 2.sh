#============================COMMAND=============================#
# jobsub_submit -G annie -M -N 1 --memory=1000MB --disk=1GB --cpu=1 --expected-lifetime=1h --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE -l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' --append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' -f /annie/app/users/neverett/bin/setup_genie3_00_04.sh -f /annie/app/users/neverett/flux/GNuMIFlux.xml file:///annie/app/users/neverett/bin/run_genie3_grid.sh
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
# ifdh cp -D bnb_annie_*.root $CONDOR_DIR_INPUT
#======================================================================#



#===================SCRIPT VARIABLES=====================#
export RUNBASE="0"  # starting run number
export SEED=$RUNBASE #"0" # random # seed
export NEVENTS=10 #1000
export OUTDIR=/annie/users/neverett/runs/run_${RUNBASE}/
export TOPVOL="TARGON_LV"  
export FLXPSET="ANNIE-tank"
export GEOMETRY=$CONDOR_DIR_INPUT/annie_v02.gdml
export FLUX=/pnfs/annie/persistent/users/neverett/bnb_annie_*.root,${FLXPSET} #$INPUT_TAR_DIR_LOCAL/bnb_annie_*.root,${FLXPSET} #$CONDOR_DIR_INPUT/bnb_annie_*.root,${FLXPSET}
export MAXPL=$CONDOR_DIR_INPUT/annie_v02_23.maxpl.xml
export GENIEXSEC=/cvmfs/larsoft.opensciencegrid.org/products/genie_xsec/v3_00_04_ub2/NULL/G1810a0211a-k250-e1000/data/gxspl-FNALsmall.xml
export UNITS="-L cm -D g_cm3"
export XYZHALL=( -393.70 -213.36   0.0  307.34 1021.08 487.68 )
export XYZBLDG=( -434.34 -259.08 -40.64 347.98 1066.80 528.32 )
#======================================================================#



#===========================GENIE SETUP=======================#
source $CONDOR_DIR_INPUT/setup_genie3_00_06.sh
export GXMLPATH=$CONDOR_DIR_INPUT:${GXMLPATH}
#======================================================================#



#===============================RUN GENIE=============================#
/cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_06k/Linux64bit+3.10-2.17-e20-debug/bin/gevgen_fnal \
-r ${RUNBASE} \
--seed ${SEED} \
-t ${TOPVOL} \
-f ${FLUX} \
-g ${GEOMETRY} \
${UNITS} \
--cross-sections ${GENIEXSEC} \
--tune G18_10a_02_11a \
-n ${NEVENTS} \
-z -2000 \
-m $MAXPL
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
    ifdh cp -D $IFDH_OPTION job_output_${CLUSTER}.${PROCESS}.log ${SCRATCH_DIR}/${GRID_USER}/job_output
    ifdh cp -D $IFDH_OPTION gntp.${RUNBASE}.ghep.root ${SCRATCH_DIR}/${GRID_USER}/genie_output
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
