#!/bin/bash

main() 
{
export RUNBASE=""
export PRIMARIESDIR=""
export NEVENTS=""
export GEOMETRY=""
export OUTDIR=""
export BATCH=""

export W=/annie/app/users/neverett/WCSim
export WB=${W}/wcsim/build
export WS=${W}/wcsim/WCSim

for i in "$@"; do
  case $i in
    -r=*                   ) export RUNNUM="${i#*=}"        shift    ;;
    -p=*                   ) export PRIMARIESDIR="${i#*=}"  shift    ;;
    -n=*                   ) export NEVENTS="${i#*=}"       shift    ;;
    -g=*                   ) export GEOMETRY="${i#*=}"      shift    ;;
    -o=*                   ) export OUTDIR="${i#*=}"        shift    ;;
    -*                     ) echo "Unknown option \`$i\`."; return 1 ;;
  esac
done

if [ -z "${RUNNUM}" ]; then
  echo "Use \`-r=\` to set the run number (or numbers using \`*\`. Ex: \`-r='4*'\`)."
  return 1
fi

if [ -z "${PRIMARIESDIR}" ]; then
  echo "Use \`-p=\` to set the primaries directory (ex: -p=/pnfs/annie/persistent/users/...)."
  return 2
fi

if [ -z "${NEVENTS}" ]; then
  echo "Use \`-n=\` to set the number of events per primary file to propigate."
  return 3
fi

if [ -z "${GEOMETRY}" ]; then
  echo "Use \`-g=\` to set the annie geometry (ex: -g=/pnfs/annie/persistent/users/.../name.gdml)"
  return 4
fi

if [ -z "${OUTDIR}" ]; then
  echo "Use \`-o=\` to set the output directory."
  return 5
fi

mkdir ${OUTDIR}

cat <<EOF > ${OUTDIR}/${RUNNUM}.log
            Program: WCSim
         Run number: ${RUNNUM}
          Primaries: ${PRIMARIESDIR}
           Geometry: ${GEOMETRY}
   Number of Events: ${NEVENTS}
EOF

cp ${GEOMETRY} ${WS}/annie_v04.gdml  # Geometry may not be `annie_v04.gdml` (probably isnt); 
                                     # however, this name is in the code (easier to give into the code than change it).

source ${W}/setupenvs.sh

for GENIEFILE in ${PRIMARIESDIR}/gntp.${RUNNUM}.ghep.root; do 
  if [ -f "${GENIEFILE}" ]; then
    export CURRUNNUM=$(basename ${GENIEFILE})
    export CURRUNNUM=${CURRUNNUM#gntp.}
    export CURRUNNUM=${CURRUNNUM%.ghep.root}
    export G4DIRTFILE=${PRIMARIESDIR}/annie_tank_flux.${CURRUNNUM}.root

echo "GENIE file: ${GENIEFILE}"
echo "g4dirt file: ${G4DIRTFILE}"

rm ${WB}/WCSim_${CURRUNNUM}.mac
cat <<EOF > ${WB}/WCSim_${CURRUNNUM}.mac
#!/bin/sh 

/run/verbose 0
/tracking/verbose 0
/hits/verbose 0
/process/em/verbose 0
/process/had/cascade/verbose 0
/process/verbose 0
/process/setVerbose 0
/run/initialize
/vis/disable

/WCSim/PMTQEMethod   Multi_Tank_Types
/WCSim/LAPPDQEMethod Multi_Tank_Types

/WCSim/PMTCollEff on

/WCSim/SavePi0 true

/control/execute macros/annie_daq.mac

/DarkRate/SetDetectorElement tank
/DarkRate/SetDarkMode 1
/DarkRate/SetDarkHigh 100000
/DarkRate/SetDarkLow 0
/DarkRate/SetDarkWindow 4000

/DarkRate/SetDetectorElement mrd
/DarkRate/SetDarkMode 1
/DarkRate/SetDarkHigh 100000
/DarkRate/SetDarkLow 0
/DarkRate/SetDarkWindow 4000

/DarkRate/SetDetectorElement facc
/DarkRate/SetDarkMode 1
/DarkRate/SetDarkHigh 100000
/DarkRate/SetDarkLow 0
/DarkRate/SetDarkWindow 4000

/mygen/generator beam

/control/execute macros/setRandomParameters.mac

/WCSimIO/RootFile WCSim_${CURRUNNUM}

/run/beamOn ${NEVENTS}
EOF

rm ${WB}/macros/primaries_directory.mac
cat <<EOF > ${WB}/macros/primaries_directory.mac
/mygen/neutrinosdirectory ${PRIMARIESDIR}/gntp.${CURRUNNUM}.ghep.root
/mygen/primariesdirectory ${PRIMARIESDIR}/annie_tank_flux.${CURRUNNUM}.root
/mygen/primariesoffset 0
EOF

cd ${WB}
./WCSim ./WCSim_${CURRUNNUM}.mac | tee ${OUTDIR}/WCSim_${CURRUNNUM}.log
mv WCSim_${CURRUNNUM}.mac          ${OUTDIR}
mv WCSim_${CURRUNNUM}.log          ${OUTDIR}/WCSim_${CURRUNNUM}.log
mv WCSim_${CURRUNNUM}_0.root       ${OUTDIR}/WCSim_${CURRUNNUM}.root
mv WCSim_${CURRUNNUM}_lappd_0.root ${OUTDIR}/WCSim_${CURRUNNUM}_lappd.root
cd -
    
  fi
done
}

usage()
{
cat >&2 <<EOF
run_wcsim.sh -r=<run number (or numbers using `*`. Ex: \`-r='4*'\`)>
             -p=</path/to/primaries/dir>
             -n=<number of events per primary file to propigate>
             -g=</path/to/geometry/file.gdml>
             -o=</path/to/output/dir>
             -h|--help
EOF
}

main "$@"
