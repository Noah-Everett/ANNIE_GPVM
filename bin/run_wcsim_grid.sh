main() {
for i in "$@"; do
  case $i in
    -r=*                   ) export RUNBASE="${i#*=}"      shift    ;;
    -p=*                   ) export PRIMARIES="${i#*=}"    shift    ;;
    -d=*                   ) export NDIRT="${i#*=}"        shift    ;;
    -w=*                   ) export NWCSIM="${i#*=}"       shift    ;;
    -g=*                   ) export GEOMETRY="${i#*=}"     shift    ;;
    -o=*                   ) export OUTDIR="${i#*=}"       shift    ;;
    -N=*                   ) export NFILES="${i#*=}"       shift    ;;
    -h*|--help*            ) usage;                        return 1 ;;
    -*                     ) echo "unknown option \"$i\""; return 1 ;;
  esac
done

if [ -z "${RUNBASE}" ]; then
  echo "Use \`-r=\` to set the run base number."
  return 1
fi

if [ -z "${PRIMARIES}" ]; then
  echo "Use \`-p=\` to set the primaries directory (ex: -p=/pnfs/annie/persistent/users/...)."
  return 2
fi

if [ -z "${NDIRT}" ]; then
  echo "Use \`-d=\` to set the number of events per annie_dirt_flux file to propigate."
  return 3
fi

if [ -z "${NWCSIM}" ]; then
  echo "Use \`-w=\` to set the number of events per WCSim output file."
  return 4
fi

if [ -z "${GEOMETRY}" ]; then
  echo "Use \`-g=\` to set the annie geometry (ex: -g=/pnfs/annie/persistent/users/.../name.gdml)"
  return 5
fi

if [ -z "${OUTDIR}" ]; then
  echo "Use \`-o=\` to set the output directory (Use \`-o=\` to set the output geometry (Note: a directory will be created in this folder. That directory will contain outputs)."
  return 6
fi

if [ -z "${NFILES}" ]; then
  echo "Use \`-N=\` to set the number of genie files to propagate."
  return 7
fi

let NJOBS=${NFILES}
let MEMORY=1536
let DISK=512
let CPU=1
let EXPLT=${NWCSIM}/80
let EXPLT=${EXPLT}+1

echo jobsub_submit \
-G annie \
-M \
-N $NJOBS \
--memory=${MEMORY}MB \
--disk=${DISK}MB \
--cpu=$CPU \
--expected-lifetime=${EXPLT}h \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_wcsim.tar.gz \
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
file:///annie/app/users/neverett/grid/run_grid_wcsim.sh \
-r=${RUNBASE} \
-p=${PRIMARIES} \
-d=${NDIRT} \
-w=${NWCSIM} \
-g=${GEOMETRY} \
-o=${OUTDIR}

jobsub_submit \
-G annie \
-M \
-N $NJOBS \
--memory=${MEMORY}MB \
--disk=${DISK}MB \
--cpu=$CPU \
--expected-lifetime=${EXPLT}h \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_wcsim.tar.gz \
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
file:///annie/app/users/neverett/grid/run_grid_wcsim.sh \
-r=${RUNBASE} \
-p=${PRIMARIES} \
-d=${NDIRT} \
-w=${NWCSIM} \
-g=${GEOMETRY} \
-o=${OUTDIR}
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
