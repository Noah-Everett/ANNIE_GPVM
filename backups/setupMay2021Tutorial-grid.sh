#!/bin/bash

DIRECTORY=may2021tutorial
# we cannot rely on "whoami" in a grid job. We have no idea what the local username will be. 
# Use the GRID_USER environment variable instead (set automatically by jobsub).
USERNAME=${GRID_USER}    
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
export WORKDIR=${_CONDOR_JOB_IWD} # if we use the RCDS the our tarball will be placed in $INPUT_TAR_DIR_LOCAL.
if [ ! -d "$WORKDIR" ]; then
  export WORKDIR=`echo .`
fi

source ${INPUT_TAR_DIR_LOCAL}/${DIRECTORY}/localProducts*/setup-grid

mrbslp
