main() {
for i in "$@"; do
  case $i in
    --nGeomFiles=*         ) export NGEOMFILES="${i#*=}"  shift    ;;
    --geomDir=*            ) export GEOMDIR="${i#*=}"     shift    ;;
    -t=*                   ) export TOPVOL="${i#*=}"      shift    ;;
    -f=*                   ) export FLUXFILE="${i#*=}"    shift    ;;
    --message-thresholds=* ) export MESTHRE="${i#*=}"     shift    ;;
    --memory=*             ) export MEMORY="${i#*=}"      shift    ;;
    --disk=*               ) export DISK="${i#*=}"        shift    ;;
    --cpu=*                ) export CPU="${i#*=}"         shift    ;;
    --expected-lifetime=*  ) export EXPLT="${i#*=}"       shift    ;;
    -h*|--help*            ) usage;                       return 1 ;;
    -*                     ) echo "unknown option \"$i\"" return 1 ;;
  esac
done

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
--message-thresholds=$MESTHRE

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
--message-thresholds=$MESTHRE
}

usage() {
cat >&2 <<EOF
run_genie_grid.sh --nGeomFiles=#               (number of gdml files in geomDir)
                     --geomDir=/path/to/geoms/ (geometry files location (in $G))
                            -t=ABC_LV          (geometry top volume)
                            -f=123*            (flux file number (in $F))
--message-thresholds=Messenger_abc.xml         (output type priorities (in $C))
                      --memory=#MB             (amount of memory)
                        --disk=#MB             (amount of disk space)
                         --cpu=#               (number of cpus)
           --expected-lifetime=#h              (maximum run time)
                     -h|--help                 (print script usage statement (this output))
EOF
}

main "$@"
