main() {
for i in "$@"; do
  case $i in
    -r=*                   ) export RUNBASE="${i#*=}"      shift    ;;
    -n=*                   ) export NEVT="${i#*=}"         shift    ;;
    -g=*                   ) export GDML="${i#*=}"         shift    ;;
    -t=*                   ) export TOPVOL="${i#*=}"       shift    ;;
    -f=*                   ) export FLUXFILE="${i#*=}"     shift    ;;
    -m=*                   ) export MAXPL="${i#*=}"        shift    ;;
    --message-thresholds=* ) export MESTHRE="${i#*=}"      shift    ;;
    -N=*                   ) export NJOBS="${i#*=}"        shift    ;;
    --memory=*             ) export MEMORY="${i#*=}"       shift    ;;
    --disk=*               ) export DISK="${i#*=}"         shift    ;;
    --cpu=*                ) export CPU="${i#*=}"          shift    ;;
    --expected-lifetime=*  ) export EXPLT="${i#*=}"        shift    ;;
    -h*|--help*            ) usage;                        return 1 ;;
    -*                     ) echo "unknown option \"$i\""; return 1 ;;
  esac
done

if [ -z ${RUNBASE} ]; then
  echo "Use \`-r=\` to set the run base number."
  return 1
fi

if [ -z ${NEVT} ]; then
  echo "Use \`-n=\` to set the number of events."
  return 1
fi

if [ -z ${GDML} ]; then
  echo "Use \`-g=\` to set the gdml geometry file (path from \`$G\`)."
  return 1
fi

if [ -z ${TOPVOL} ]; then
  echo "Use \`-t=\` to set top volume (volume where events occur)."
  return 1
fi

if [ -z ${FLUXFILE} ]; then
  echo "Use \`-f=\` to set flux file(s) numer (or numbers using *) (path from \`/annie/data/flux/bnb/\`)."
  return 1
fi

if [ -z ${MAXPL} ]; then
  echo "Use \`-m=\` to set max pathlength file (path from \`$G\`)."
  return 1
fi

if [ -z ${MESTHRE} ]; then
  echo "Use \`--message-thresholds=\` to set message thresholds filee (path from \`$C\`)."
  return 1
fi

if [ -z ${NJOBS} ]; then
  echo "Use \`-N=\` to set the number of identical jobs."
  return 1
fi

if [ -z ${MEMORY} ]; then
  echo "Use \`--memory=\` to set the memory allocated."
  return 1
fi

if [ -z ${DISK} ]; then
  echo "Use \`--disk=\` to set disk allocation."
  return 1
fi

if [ -z ${CPU} ]; then
  echo "Use \`--cpu=\` to set number of cpus."
  return 1
fi

if [ -z ${EXPLT} ]; then
  echo "Use \`--expected-lifetime=\` to set the exepected lifetime of each job."
  return 1
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
file:///annie/app/users/neverett/grid/run_grid_genie.sh \
-r=$RUNBASE \
-n=$NEVT \
-g=$GDML \
-t=$TOPVOL \
-f=$FLUXFILE \
-m=$MAXPL \
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
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
--tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_genie.tar.gz \
file:///annie/app/users/neverett/grid/run_grid_genie.sh \
-r=$RUNBASE \
-n=$NEVT \
-g=$GDML \
-t=$TOPVOL \
-f=$FLUXFILE \
-m=$MAXPL \
--message-thresholds=$MESTHRE
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
