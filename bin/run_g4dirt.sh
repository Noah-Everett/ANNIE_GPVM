#! /usr/bin/env bash

main() {
export INDIR=""
export OUTDIR=""
export VERBOSE=0
export RWHNODE=0
export RUNNUM=""  # starting run number
export BATCH=""

for i in "$@"; do
  case $i in
    -r=*        ) export RUNNUM="${i#*=}"               shift    ;;
    -i=*        ) export INDIR="${i#*=}"                shift    ;;
    -n=*        ) export NEVENTS="${i#*=}"              shift    ;;
    -g=*        ) export GEOMETRY="${i#*=}"             shift    ;;
    -o=*        ) export OUTDIR="${i#*=}"               shift    ;;
    -h*|--help* ) usage;                                return 1 ;;
    -*          ) echo "Unknown option \`$i\`."; usage; return 1 ;;
  esac
done

if [ -z "${RUNNUM}" ]; then
  echo "Use \`-r=\` to set the run number (or numbers using \`*\`. Ex: \`-r='4*'\`)."
  return 1
fi

if [ -z "${INDIR}" ]; then
  echo "Use \`-i=\` to set the input directory (ex: -p=/pnfs/annie/persistent/users/...)."
  return 2
fi

if [ -z "${NEVENTS}" ]; then
  echo "Use \`-n=\` to set the number of events per input file to propigate."
  return 3
fi

if [ -z "${GEOMETRY}" ]; then
  echo "Use \`-g=\` to set the annie geometry (ex: -g=/pnfs/annie/persistent/users/.../name.gdml)"
  return 4
fi

if [ -z "${OUTDIR}" ]; then
  echo "Use \`-o=\` to set the output directory (will create a new file if needed)."
  return 5
fi

export USEPHYLIST="FTFP_BERT_HP"

mkdir ${OUTDIR}

source /grid/fermiapp/products/common/etc/setup
export PRODUCTS=${PRODUCTS}:/grid/fermiapp/products/larsoft:/grid/fermiapp/products/nova/externals:/grid/fermiapp/products/minerva/db
  
echo "Setting up geant4"
    setup geant4 v4_10_3_p03c -q e15:debug
echo "Setting up genie"
    setup genie v2_12_10b -q debug:e15
echo "Setting up genie_phyopt"
    setup genie_phyopt v2_12_10 -q dkcharmtau
echo "Setting up genie_xsec"
    setup genie_xsec v2_12_10 -q DefaultPlusMECWithNC

cd ${INDIR}
export INDIR=${PWD}
cd -
cd ${OUTDIR}

for INFILE in ${INDIR}/gntp.${RUNNUM}.ghep.root; do 
  if [ -f "${INFILE}" ]; then
    export CURRUNNUM=$(basename ${INFILE})
    export CURRUNNUM=${CURRUNNUM#gntp.}
    export CURRUNNUM=${CURRUNNUM%.ghep.root}
    export OUTFILE=annie_tank_flux.${CURRUNNUM}.root
    export OUTFILELOG=annie_tank_flux.${CURRUNNUM}.log

cat <<EOF > ${OUTFILELOG}
#=============== RUN SETTINGS ===============#
     GENIE file: ${INFILE}
    g4dirt file: ${OUTFILE}
g4dirt file log: annie_tank_flux.${CURRUNNUM}.log

#=============== RUN LOG ===============#
EOF

echo $B/g4annie_dirt_flux --batch -n $NEVENTS -g $GEOMETRY --physics=${USEPHYLIST} -i ${INFILE} -o $(basename ${OUTFILE})
     $B/g4annie_dirt_flux --batch -n $NEVENTS -g $GEOMETRY --physics=${USEPHYLIST} -i ${INFILE} -o $(basename ${OUTFILE})

rm currentEvent.rndm
rm currentRun.rndm
  fi
done

cd -
}

usage() {
cat >&2 <<EOF
run_g4dirt.sh -r=<run number (or numbers using `*`. Ex: \`-r='4*'\`)>
              -i=</path/to/input/genie/files/dir>
              -n=<number of events per genie file to propigate>
              -g=</path/to/geometry/file.gdml>
              -o=</path/to/output/dir>
              -h|--help
EOF
}

main "$@"
