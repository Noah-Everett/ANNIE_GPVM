# ! /usr/bin/env bash

#export FLUX_DIR=/annie/data/flux/gsimple_bnb/
export FLUX_DIR=/annie/data/flux/redecay_bnb/
export NPART=0
export RUN=0
export MAXPLFILE=/dev/null

main() {
for i in "$@"; do
  case $i in
    -r=*                   ) export RUN="${i#*=}"                 shift    ;;
    -n=*                   ) export NEVENTS="${i#*=}"             shift    ;;
    -g=*                   ) export GEOMETRY="${i#*=}"            shift    ;;
    -t=*                   ) export TOPVOL="${i#*=}"              shift    ;;
    -f=*                   ) export FLUX_FILE_NUM="${i#*=}"       shift    ;;
    -m=*                   ) export MAXPLFILE="${i#*=}"           shift    ;;
    -o=*                   ) export OUTDIR="${i#*=}"              shift    ;;
    -S=*                   ) export NPART="${i#*=}"               shift    ;; 
    --message-thresholds=* ) export MESTHRE="${i#*=}"             shift    ;;
    -h*|--help*            ) usage;                               return 1 ;;
    -*                     ) echo "unknown option \"$i\""; usage; return 1 ;;
  esac
done

if [ -z "$FLUX_FILE_NUM" ]; then 
  echo "Use \`-f=\` to set the number (or numbers using '*') (in $FLUX_DIR)."
  return 1
fi;
if [ -z "$GEOMETRY" ]; then 
  echo "Use \`-g=\` to set the path to the geometry file."
  return 1
fi; 
if [ -z "$TOPVOL"   ]; then 
  echo "Use \`-t=\` to set the target volume (top volume)."
  return 1
fi
if [ -z "$OUTDIR"   ]; then 
  echo "Use \`-o=\` to set the output directory."
  return 1
fi
if [ -z "$MAXPLFILE" ]; then
  echo "#== run_genie.sh |()| Missing argument |()| Use \`-m=[+]</path/to/file>.maxpl.xml\` to set the path to the max path length file."
  return 1
elif [ ${MAXPLFILE:0:1} == "+" ]; then 
  export MAKEMAXPL="+" 
  export MAXPLFILE="${MAXPLFILE:1}"
  export MAXPL=${MAKEMAXPL}${MAXPLFILE}
fi

mkdir ${OUTDIR}

export SEED=${RUN}
export FLXPSET="ANNIE-tank"
#export FLUX_FILE="${FLUX}/gsimple_beammc_annie_${FLUX_FILE_NUM}.root,${FLXPSET}"
export FLUX_FILE="${FLUX}/beammc_annie_${FLUX_FILE_NUM}.root,${FLXPSET}"
export GENIEXSEC=/cvmfs/larsoft.opensciencegrid.org/products/genie_xsec/v3_00_04_ub2/NULL/G1810a0211a-k250-e1000/data/gxspl-FNALsmall.xml # using FNALsmall may cause issues. Ill leave it for now. run_genie_grid uses FNALbig.
export UNITS="-L cm -D g_cm3"
export XYZHALL=( -393.70 -213.36   0.0  307.34 1021.08 487.68 )
export XYZBLDG=( -434.34 -259.08 -40.64 347.98 1066.80 528.32 )

source ${B}/setup_genie3_00_06.sh ""

echo gevgen_fnal \
-r ${RUN} \
--seed ${SEED} \
-t ${TOPVOL} \
-f ${FLUX_FILE} \
-g ${GEOMETRY} \
${UNITS} \
--cross-sections ${GENIEXSEC} \
--tune G18_10a_02_11a \
-n ${NEVENTS} \
-m ${MAXPL} \
-S ${NPART} \
--message-thresholds ${MESTHRE}

cd ${OUTDIR}
gevgen_fnal \
-r ${RUN} \
--seed ${SEED} \
-t ${TOPVOL} \
-f ${FLUX_FILE} \
-g ${GEOMETRY} \
${UNITS} \
--cross-sections ${GENIEXSEC} \
--tune G18_10a_02_11a \
-n ${NEVENTS} \
-m ${MAXPL} \
-S ${NPART} \
--message-thresholds ${MESTHRE}
cd - 
}

usage() {
cat >&2 <<EOF
run_genie.sh -r=<run number (default = 1000)>
             -n=<number of events>
             -g=</path/to/geometry/file>.gdml
             -t=<top volume name>_LV
             -f=<flux file number (or numbers using '*') (in $FLUX_DIR)>
             -m=[[+]</path/to/maxpl/file>.maxpl.xml]
             -o=</path/to/output/dir>
             -S=[-]<number of particles used to scan geometry (default = 0)>
             --message-thresholds=</path/to/Messenger_<name>.xml>
             -h|--help
EOF
}

main "$@"
