# ! /usr/bin/env bash

# Directories
B=/annie/app/users/neverett/bin
C=/annie/app/users/neverett/config
G=/annie/app/users/neverett/geometry
F=/annie/data/flux/bnb

main() {
for i in "$@"; do
  case $i in
    -r=*                   ) export RUN="${i#*=}"                 shift    ;;
    -n=*                   ) export NEVENTS="${i#*=}"             shift    ;;
    -g=*                   ) export GEOMETRY="${i#*=}"            shift    ;;
    -t=*                   ) export TOPVOL="${i#*=}"              shift    ;;
    -f=*                   ) export FLUXFILENUM="${i#*=}"         shift    ;;
    -m=*                   ) export MAXPLFILE="${i#*=}"           shift    ;;
    -o=*                   ) export OUTDIR="${i#*=}"              shift    ;;
    -S=*                   ) export NPART="${i#*=}"               shift    ;; 
    --message-thresholds=* ) export MESTHRE="${i#*=}"             shift    ;;
    -h*|--help*            ) usage;                               return 1 ;;
    -*                     ) echo "unknown option \"$i\""; usage; return 1 ;;
  esac
done

if [ -z "$FLUXFILENUM" ]; then 
  echo "Use \`-f=\` to set the number (or numbers using \`-f=*\`) (in $FLUX)."
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
  echo "Use \`-m=\` to set the path to the max path length file. Use \`-m=+</path/to/file.maxpl.xml> to generate a max path length file."
  return 1
elif [ ${MAXPLFILE:0:1} == "+" ]; then 
  export MAKEMAXPL="+" 
  export MAXPLFILE="${MAXPLFILE:1}"
  export MAXPL=${MAKEMAXPL}${MAXPLFILE}
fi

mkdir ${OUTDIR}

export SEED=${RUN}
export FLXPSET="ANNIE-tank"
export FLUX="${F}/bnb_annie_${FLUXFILENUM}.root,${FLXPSET}"
export GENIEXSEC=/cvmfs/larsoft.opensciencegrid.org/products/genie_xsec/v3_00_04_ub2/NULL/G1810a0211a-k250-e1000/data/gxspl-FNALsmall.xml # using FNALsmall may cause issues. Ill leave it for now. run_genie_grid uses FNALbig.
export UNITS="-L cm -D g_cm3"
export XYZHALL=( -393.70 -213.36   0.0  307.34 1021.08 487.68 )
export XYZBLDG=( -434.34 -259.08 -40.64 347.98 1066.80 528.32 )

source ${B}/setup_genie3_00_06.sh ""

echo gevgen_fnal \
-r ${RUN} \
--seed ${SEED} \
-t ${TOPVOL} \
-f ${FLUX} \
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
-f ${FLUX} \
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
run_genie.sh -r=<run number>
             -n=<number of events>
             -g=</path/to/geometry/file>.gdml
             -t=<top volume name>_LV
             -f=<flux file number (or numbers using '*') (in $FLUX)>
             -m=[+]<max path length file (in $G)>.maxpl.xml
             -o=</path/to/output/dir>
             -S=[-]<number of particles used to scan geometry (default = 0)>
             --message-thresholds=Messenger_<name (in $C) (default = "")>.xml
             -h|--help
EOF
}

main "$@"
