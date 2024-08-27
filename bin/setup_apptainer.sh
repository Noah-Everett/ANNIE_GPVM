alias START_APPTAINER='/cvmfs/oasis.opensciencegrid.org/mis/apptainer/current/bin/apptainer shell \
	--shell=/bin/bash \
	-B /cvmfs,/grid/fermiapp,/nashome,/opt,/run/user,/etc/hostname,/etc/hosts,/etc/krb5.conf,/exp/annie \
	--ipc \
	--pid /cvmfs/singularity.opensciencegrid.org/fermilab/fnal-dev-sl7:latest'
echo "  START_APPTAINER"

if [ -n "$SINGULARITY_NAME" ]; then
  # make sure UPS uses SL7 as the architecture rather than the underlying AL9
  export UPS_OVERRIDE="-H Linux64bit+3.10-2.17"
fi 
