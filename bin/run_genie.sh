# ! /usr/bin/env bash

# Directories
B=/annie/app/users/neverett/bin
C=/annie/app/users/neverett/config
G=/annie/app/users/neverett/geometry
F=/annie/data/flux/bnb

main() {
for i in "$@"; do
  case $i in
    -r=*                   ) export RUN="${i#*=}"          shift ;;
    -n=*                   ) export NEVENTS="${i#*=}"      shift ;;
    -g=*                   ) export GEOMETRY="${i#*=}"     shift ;;
    -t=*                   ) export TOPVOL="${i#*=}"       shift ;;
    -f=*                   ) export FLUXFILENUM="${i#*=}"  shift ;;
    -m=*                   ) export MAXPL="${i#*=}"        shift ;;
    -o=*                   ) export OUTDIR="${i#*=}"       shift ;;
    -S=*                   ) export NPART="${i#*=}"        shift ;; 
    --message-thresholds=* ) export MESTHRE="${i#*=}"      shift ;;
    -h*        ) usage;                        return 1 ;;
    -*                     ) echo "unknown option \"$i\""; return 1 ;;
  esac
done

if [ -z "$FLUXFILE" ]; then export FLUXFILE="0000"               ; fi;
if [ -z "$ZMIN"     ]; then export ZMIN="-2000"                  ; fi;
if [ -z "$GEOMETRY" ]; then export GEOMETRY="annie_v02.gdml"     ; fi; export GEOMETRY="${G}/${GEOMETRY}"
if [ -z "$MESTHRE"  ]; then export MESTHRE=""                    ;
                       else export MESTHRE="${C}/${MESTHRE}"     ; fi;
if [ -z "$TOPVOL"   ]; then export TOPVOL="TARGON_LV"            ; fi;
if [ -z "$OUTDIR"   ]; then export OUDIR=$PWD                    ; fi;
if [ -z "$NPART"    ]; then export NPART="0"                     ; fi;
mkdir ${OUTDIR} >> /dev/null

export MAXPL=${G}/${MAXPL}
export RUN=${RUNBASE}${PROCESS}
export SEED=${RUN}
export FLXPSET="ANNIE-tank"
export FLUX="${F}/bnb_annie_${FLUXFILENUM}.root,${FLXPSET}"
export GENIEXSEC=/cvmfs/larsoft.opensciencegrid.org/products/genie_xsec/v3_00_04_ub2/NULL/G1810a0211a-k250-e1000/data/gxspl-FNALsmall.xml
export UNITS="-L cm -D g_cm3"
export XYZHALL=( -393.70 -213.36   0.0  307.34 1021.08 487.68 )
export XYZBLDG=( -434.34 -259.08 -40.64 347.98 1066.80 528.32 )
export GXMLPATH=${C}

source ${B}/setup_genie3_00_06.sh

echo gevgen_fnal \
-r ${RUN} \
--seed ${SEED} \
-t ${TOPVOL} \
-f ${FLUX} \
-g ${GEOMETRY} \
${UNITS} \
--cross-sections ${GENIEXSEC} \
--tune g18_10a_02_11a \
-n ${NEVENTS} \
-z ${ZMIN} \
-m ${MAXPL} \
-o ${OUTDIR} \
-s ${NPART} \
--message-thresholds ${MESTHRE}

gevgen_fnal \
-r ${RUN} \
--seed ${SEED} \
-t ${TOPVOL} \
-f ${FLUX} \
-g ${GEOMETRY} \
${UNITS} \
--cross-sections ${GENIEXSEC} \
--tune g18_10a_02_11a \
-n ${NEVENTS} \
-z ${ZMIN} \
-m ${MAXPL} \
-o ${OUTDIR} \
-s ${NPART} \
--message-thresholds ${MESTHRE}
}

usage() {
cat >&2 <<EOF
run_genie.sh -r=#                 (run number)
             -n=#                 (limit by number of events)
             -g=abc.gdml          (geometry file (in $G))
             -t=ABC_LV            (geometry top volume)
             -f=123*              (flux file number (in $F))
             -m=abc.maxpl.xml     (max path length file (in $G))
             -o=/path/to/out/dir  (ouput directory)
             -S=(+|-)#            (geometry scan config)
             -h                   (print script usage statement (this output))
EOF
}

main "$@"