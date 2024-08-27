main() {
for i in "$@"; do
  case $i in
    -r=*                   ) export RUNBASE="${i#*=}"      shift    ;;
    -n=*                   ) export NEVT="${i#*=}"         shift    ;;
    -e=*                   ) export NPOT="${i#*=}"         shift    ;;
    -g=*                   ) export GDML="${i#*=}"         shift    ;;
    -t=*                   ) export TOPVOL="${i#*=}"       shift    ;;
    -f=*                   ) export FLUXFILE="${i#*=}"     shift    ;;
    -m=*                   ) export MAXPL="${i#*=}"        shift    ;;
    -i=*                   ) export INDIR="${i#*=}"        shift    ;;
    -o=*                   ) export OUTDIR="${i#*=}"       shift    ;;
    -T=*                   ) export EXPLT="${i#*=}"        shift    ;;
    --message-thresholds=* ) export MESTHRE="${i#*=}"      shift    ;;
    -N=*                   ) export NJOBS="${i#*=}"        shift    ;;
    -h*|--help*            ) usage;                        return 1 ;;
    -*                     ) echo "unknown option \"$i\""; return 1 ;;
  esac
done

if [ -z ${RUNBASE} ]; then
  echo "Use \`-r=\` to set the run base number."
  return 1
fi

if [ -z ${NEVT} ] && [ -z ${NPOT} ]; then
  echo "Use \`-n=\` to set the number of events or \`-e=\` to set the number of POT."
  return 1
fi

if [ -z ${GDML} ]; then
  echo "Use \`-g=\` to set the path to the gdml geometry file."
  return 1
fi

if [ -z ${TOPVOL} ]; then
  echo "Use \`-t=\` to set top volume (volume where events occur)."
  return 1
fi

if [ -z "${FLUXFILE}" ]; then
  echo "Use \`-f=\` to set flux file(s) numer (or numbers using *) (path from \`/annie/data/flux/bnb/\`)."
  return 1
fi

if [ -z ${MAXPL} ]; then
  echo "Use \`-m=\` to set the path to the max pathlength file."
  return 1
fi

if [ -z ${MESTHRE} ]; then
  echo "Use \`--message-thresholds=\` to set the path to the message thresholds file (typically a file in \`$C\`)."
  return 1
fi

if [ -z "${INDIR}" ]; then
  echo "Use \`-i=\` to set the path to the input tar file."
  return 1
fi

if [ -z "${OUTDIR}" ]; then
  echo "Use \`-o=\` to set the output directory. (Note: a directory will be created in specified directory. The new directory will contain the output files.)"
  return 1
fi

if [ -z ${NJOBS} ]; then
  echo "Use \`-N=\` to set the number of identical jobs."
  return 1
fi

if [ -z ${EXPLT} ]; then
  echo "Use \`-T\` to set the lifetime of each job."
  return 1
fi

export CPU="1"
#export MEMORY="1500MB"
export MEMORY="3000MB"
export DISK="2700MB"
#export EVTPERHR=100
#export POTPERHR=15
#if [ -z ${NEVT}  ]; then
#  let EXPLT=$((NEVT / EVTPERHR))
#  if [ "$EXPLT" == "0" ]; then
#    EXPLT=2
#  fi
#else
#  let EXPLT=$((NPOT / POTPERHR))
#  if [ "$EXPLT" == "0" ]; then
#    EXPLT=2
#  fi
#fi

if [ -z ${NEVT} ]; then
  export EXP="-e=${NPOT}"
else
  export EXP="-n=${NEVT}"
fi

echo jobsub_submit \
-G annie \
--onsite-only \
--mail_always \
-N $NJOBS \
--memory $MEMORY \
--disk $DISK \
--cpu $CPU \
--expected-lifetime ${EXPLT}h \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
--tar_file_name dropbox:///exp/annie/app/users/neverett/grid/grid_genie.tar.gz \
file:///exp/annie/app/users/neverett/grid/run_grid_genie.sh \
-r=$RUNBASE \
${EXP} \
-g=$GDML \
-t=$TOPVOL \
-f=$FLUXFILE \
-m=$MAXPL \
--message-thresholds=$MESTHRE \
-i=$INDIR \
-o=$OUTDIR

jobsub_submit \
-G annie \
--onsite-only \
--mail_always \
-N $NJOBS \
--memory $MEMORY \
--disk $DISK \
--cpu $CPU \
--expected-lifetime ${EXPLT}h \
--resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE \
-l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' \
--append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' \
--lines '+FERMIHTC_AutoRelease=True' \
--lines '+FERMIHTC_GraceMemory=2048' \
--lines '+FERMIHTC_GraceLifetime=7200' \
file:///exp/annie/app/users/neverett/grid/run_grid_genie.sh \
-r=$RUNBASE \
${EXP} \
-g=$GDML \
-t=$TOPVOL \
-f=$FLUXFILE \
-m=$MAXPL \
--message-thresholds=$MESTHRE \
-i=$INDIR \
-o=$OUTDIR
#--tar_file_name dropbox:/${INDIR} \
#
}

usage() {
cat >&2 <<EOF
run_genie_grid.sh -r=<run base number>
                 <-n=<number of events> or -e=<number of POT>>
                  -g=</path/to/geometry/file.gdml>
                  -t=<top volume name>_LV
                  -f=<flux file number (or numbers using '*') (in /annie/data/flux/redecay_bnb/)>
                  -m=</path/to/max/path/length/file.maxpl.xml>
                  -i=</path/to/input/tar/file.tar.gz>
                  -o=</path/to/output/directory> (note: a directory will be created in the specified directory and will contain the output files)
                  -T=<expected lifetime of each job in hours>
                  --message-thresholds=</path/to/message/thresholds/Messenger_<name>.xml (typically a file in /exp/annie/app/users/neverett/config/)>
                  -N=<number of jobs>
                  -h|--help
EOF
}

main "$@"
