main() {
for i in "$@"; do
  case $i in
    --nGeomFiles=*         ) export NGEOMFILES="${i#*=}"  shift    ;;
    --geomDir=*            ) export GEOMDIR="${i#*=}"     shift    ;;
    --message-thresholds=* ) export MESTHRE="${i#*=}"     shift    ;;
    -o=*                   ) export OUTDIR="${i#*=}"      shift    ;;
    -h*|--help*            ) usage;                       return 1 ;;
    -*                     ) echo "unknown option \"$i\"" return 1 ;;
  esac
done

if [ -z $NGEOMFILES ]; then
  echo "Use \`--nGeomFiles=\` to set the number of geometry files to generate maxpl.xml files for."
fi

if [ -z $GEOMDIR ]; then
  echo "Use \`--geomDir=\` to set the directory that contains the geometry files used to generate maxpl.xml files for. Note, these files must be in $GR/grid_genie.tar.gz."
fi

if [ -z $MESTHRE ]; then 
  echo "Use \`--message-thresholds=\` to set the message threshold file."
fi

MEMORY="1500MB"
DISK="2700MB"
CPU="1"
EXPLT="3h"
TOPVOL="EXP_HALL_LV"
FLUXFILE="*"

echo jobsub_submit \
-G annie \
-M \
-N $NGEOMFILES \
--memory=$MEMORY \
--disk=$DISK \
--cpu=$CPU \
--expected-lifetime=$EXPLT \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_genie.tar.gz \
file:///annie/app/users/neverett/grid/run_grid_genie_maxpl.sh \
--geomDir=$GEOMDIR \
-t=$TOPVOL \
-f=$FLUXFILE \
--message-thresholds=$MESTHRE \
-o=$OUTDIR

jobsub_submit \
-G annie \
-M \
-N $NGEOMFILES \
--memory=$MEMORY \
--disk=$DISK \
--cpu=$CPU \
--expected-lifetime=$EXPLT \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_genie.tar.gz \
file:///annie/app/users/neverett/grid/run_grid_genie_maxpl.sh \
--geomDir=$GEOMDIR \
-t=$TOPVOL \
-f=$FLUXFILE \
--message-thresholds=$MESTHRE \
-o=$OUTDIR
}

usage() {
cat >&2 <<EOF
run_genie_grid.sh --nGeomFiles=<#>                (number of gdml files in geomDir)
                  --geomDir=</path/to/geoms/>     (geometry files location (in $G))
--message-thresholds=<Messenger_abc>.xml (in \$C) (output type priorities (in $C))
                  -o=</path/to/output/dir>
                  -h|--help                       (print script usage statement (this output))
EOF
}

main "$@"
