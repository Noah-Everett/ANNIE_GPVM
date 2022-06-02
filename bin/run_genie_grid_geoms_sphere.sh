NJOBS="10"
MEMORY="1000MB"
DISK="200MB"
CPU="3"
EXPLT="4h"
NEVT=1000
TOPVOL="TWATER_LV"
FLUXFILE="*"
MESTHRE="Messenger_warn.xml"

for dir in "annie_v02_sphere_argon_gas_20atm" "annie_v02_sphere_argon_gas_atm" "annie_v02_sphere_argon_liquid" "annie_v02_sphere_vacuum" "annie_v02_sphere_water"; do
  for nFile in "0" "1" "2" "3" "4"; do

echo jobsub_submit \
-G annie \
-M \
-N $NJOBS \
--memory=$MEMORY \
--disk=$DISK \
--cpu=$CPU \
--expected-lifetime=$EXPLT \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_genie.tar.gz \
file:///annie/app/users/neverett/grid/run_grid_genie.sh \
-r=${nFile} \
-n=$NEVT \
-g=${dir}/annie_v02_${nFile}.gdml \
-t=$TOPVOL \
-f=$FLUXFILE \
-m=${dir}/annie_v02_${nFile}.maxpl.xml \
--message-thresholds=$MESTHRE

jobsub_submit \
-G annie \
-M \
-N $NJOBS \
--memory=$MEMORY \
--disk=$DISK \
--cpu=$CPU \
--expected-lifetime=$EXPLT \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_genie.tar.gz \
file:///annie/app/users/neverett/grid/run_grid_genie.sh \
-r=${nFile} \
-n=$NEVT \
-g=${dir}/annie_v02_${nFile}.gdml \
-t=$TOPVOL \
-f=$FLUXFILE \
-m=${dir}/annie_v02_${nFile}.maxpl.xml \
--message-thresholds=$MESTHRE

  done
done
