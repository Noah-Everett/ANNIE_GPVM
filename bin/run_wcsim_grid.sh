main() {
for i in "$@"; do
  case $i in
    -r=*                   ) export RUNBASE="${i#*=}"      shift    ;;
    -p=*                   ) export PRIMARIES="${i#*=}"    shift    ;;
    -n=*                   ) export NEVENTS="${i#*=}"      shift    ;;
    -g=*                   ) export GEOMETRY="${i#*=}"     shift    ;;
    -N=*                   ) export NJOBS="${i#*=}"        shift    ;;
    --memory=*             ) export MEMORY="${i#*=}"       shift    ;;
    --disk=*               ) export DISK="${i#*=}"         shift    ;;
    --cpu=*                ) export CPU="${i#*=}"          shift    ;;
    --expected-lifetime=*  ) export EXPLT="${i#*=}"        shift    ;;
    -h*|--help*            ) usage;                        return 1 ;;
    -*                     ) echo "unknown option \"$i\""; return 1 ;;
  esac
done

if [ -z "${RUNBASE}" ]; then
  echo "Use \`-r=\` to set the run base number."
  return 1
fi

if [ -z "${PRIMARIES}" ]; then
  echo "Use \`-p=\` to set the primaries directory (in \`$R\`)."
  return 2
fi

if [ -z "${NEVENTS}" ]; then
  echo "Use \`-n=\` to set the number of events to propigate."
  return 3
fi

if [ -z "${GEOMETRY}" ]; then
  echo "Use \`-g=\` to set the annie geometry (in \`$G\`)."
  return 4
fi

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
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
file:///annie/app/users/neverett/grid/run_grid_wcsim.sh \
-r=$RUNBASE \
-p=$PRIMARIES \
-n=$NEVT \
-g=$GEOMETRY \

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
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
file:///annie/app/users/neverett/grid/run_grid_wcsim.sh \
-r=$RUNBASE \
-p=$PRIMARIES \
-n=$NEVT \
-g=$GEOMETRY \
}

usage() {
cat >&2 <<EOF
run_genie_grid.sh -r=#                 (run base number)
                  -n=#                 (number of events)
                  -g=abc.gdml          (geometry file (in $G))
                  -t=ABC_LV            (geometry top volume)
                  -f=123*              (flux file number (in $F))
                  -m=abc.maxpl.xml     (max path length file (in $G))
--message-thresholds=Messenger_abc.xml (output type priorities (in $C))
                  -N=#                 (number of identical jobs)
            --memory=#MB               (amount of memory)
              --disk=#MB               (amount of disk space)
               --cpu=#                 (number of cpus)
 --expected-lifetime=#h                (maximum run time)
           -h|--help                   (print script usage statement (this output))
EOF
}

main "$@"
