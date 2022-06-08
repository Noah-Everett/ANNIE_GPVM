NJOBS="10"
MEMORY="1000MB"
DISK="200MB"
CPU="3"
EXPLT="4h"
NEVT=1000
TOPVOL="TWATER_LV"
FLUXFILE="*"
MESTHRE="Messenger_warn.xml"

for dir in "annie_v02_tube_argon_gas_20atm" "annie_v02_tube_argon_gas_1atm" "annie_v02_tube_argon_liquid" "annie_v02_tube_vacuum" "annie_v02_tube_water"; do

echo source /annie/app/users/neverett/bin/make_maxpl_grid.sh --nGeomFiles=5 --geomDir=${dir} -t=EXP_HALL_LV -f=* --message-thresholds=Messenger_warn.xml --memory=2000MB --disk=4000MB --cpu=1 --expected-lifetime=4h

source /annie/app/users/neverett/bin/make_maxpl_grid.sh --nGeomFiles=5 --geomDir=${dir} -t=EXP_HALL_LV -f=* --message-thresholds=Messenger_warn.xml --memory=2000MB --disk=4000MB --cpu=1 --expected-lifetime=4h

done
