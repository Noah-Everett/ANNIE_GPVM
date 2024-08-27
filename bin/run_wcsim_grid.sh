main() {
for i in "$@"; do
  case $i in
    -r=*                   ) export RUNBASE="${i#*=}"            shift    ;;
    -p_g=*                 ) export PRIMARIES_GENIE="${i#*=}"    shift    ;;
    -p_d=*                 ) export PRIMARIES_G4DIRT="${i#*=}"   shift    ;;
    -d=*                   ) export NDIRT="${i#*=}"              shift    ;;
    -w=*                   ) export NWCSIM="${i#*=}"             shift    ;;
    -g=*                   ) export GEOMETRY="${i#*=}"           shift    ;;
    -o=*                   ) export OUTDIR="${i#*=}"             shift    ;;
    -N=*                   ) export NFILES="${i#*=}"             shift    ;;
    -T=*                   ) export EXPLT="${i#*=}"              shift    ;;
    -h*|--help*            ) usage;                              return 1 ;;
    -*                     ) echo "unknown option \"$i\"";       return 1 ;;
  esac
done

if [ -z "${RUNBASE}" ]; then
  echo "Use \`-r=\` to set the run base number."
  return 1
fi

if [ -z "${PRIMARIES_GENIE}" ]; then
  echo "Use \`-p_g=\` to set the genie primaries directory (ex: -p_g=/pnfs/annie/persistent/users/...)."
  return 2
fi

if [ -z "${PRIMARIES_G4DIRT}" ]; then
  echo "Use \`-p_d=\` to set the g4dirt primaries directory (ex: -p_d=/pnfs/annie/persistent/users/...)."
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
  echo "Use \`-N=\` to set the number of jobs to run. Each job will do the number of jobs specified by \`-w\`."
  return 7
fi

if [ -z "${EXPLT}" ]; then
  echo "Use \`-T=\` to set the expected lifetime [hrs]."
  return 8
fi

let NJOBS=${NFILES}
let MEMORY=2560 #12288
let DISK=1024 #24576
let CPU=1
#let EXPLT=${NWCSIM}/80
#let EXPLT=${EXPLT}+1

echo jobsub_submit \
-G annie \
--mail_always \
-N $NJOBS \
--memory=${MEMORY}MB \
--disk=${DISK}MB \
--cpu=$CPU \
--expected-lifetime=${EXPLT}h \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--tar_file_name=dropbox:///exp/annie/app/users/neverett/grid/grid_wcsim.tar.gz \
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
file:///exp/annie/app/users/neverett/grid/run_grid_wcsim.sh \
-r=${RUNBASE} \
-p_g=${PRIMARIES_GENIE} \
-p_d=${PRIMARIES_G4DIRT} \
-d=${NDIRT} \
-w=${NWCSIM} \
-g=${GEOMETRY} \
-o=${OUTDIR}

#--jobsub-server=fnpctest1 \

jobsub_submit \
-G annie \
--mail_always \
-N $NJOBS \
--memory=${MEMORY}MB \
--disk=${DISK}MB \
--cpu=$CPU \
--expected-lifetime=${EXPLT}h \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--tar_file_name=dropbox:///exp/annie/app/users/neverett/grid/grid_wcsim.tar.gz \
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
file:///exp/annie/app/users/neverett/grid/run_grid_wcsim.sh \
-r=${RUNBASE} \
-p_g=${PRIMARIES_GENIE} \
-p_d=${PRIMARIES_G4DIRT} \
-d=${NDIRT} \
-w=${NWCSIM} \
-g=${GEOMETRY} \
-o=${OUTDIR}
}

usage() {
cat >&2 <<EOF
run_wcsim_grid.sh -r=<run base number>
                  -p_g=</path/to/GENIE/primaries (should be in /pnfs/)>
                  -p_d=</path/to/g4dirt/primaries (should be in /pnfs/)>
                  -d=<number of events per g4dirt file (annie_tank_flux.<#>.root)>
                  -w=<number of events per output wcsim file>
                  -g=</path/to/geometry/file (should be in /pnfs/)>
                  -o=</path/to/output/directory (should be in /pnfs/)>
                  -N=<number of files/identical runs>
                  -h|--help
EOF
}

main "$@"
