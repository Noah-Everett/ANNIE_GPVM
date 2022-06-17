source /cvmfs/sbnd.opensciencegrid.org/products/sbnd/setup_sbnd.sh
#source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setups
source /cvmfs/larsoft.opensciencegrid.org/products/setups
setup genie v3_00_04_ub3 -q e17:prof
setup genie_phyopt v3_00_04 -q dkcharmtau
setup genie_xsec v3_00_04_ub2 -q G1810a0211a:e1000:k250
export XERCESROOT=$XERCESCROOT
export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${GENIE}/../include/GENIE:${GENIE}/../include/GENIE/Framework
export ROOT_LIBRARY_PATH=${ROOT_LIBRARY_PATH}:${GENIE}/../lib

#setup dk2nugenie v01_08_00_ub3 -q e17:prof
setup boost  v1_66_0a -q e17:prof
setup cetlib v3_05_01 -q e17:prof
setup cetlib_except v1_03_00 -q e17:prof
setup fhiclcpp v4_08_01 -q e17:prof
setup cmake v3_3_2
#setup ifdhc

export LD_LIBRARY_PATH=./:`pwd`/lib:${GENIE}/../lib:${LD_LIBRARY_PATH}
export FW_SEARCH_PATH=${FW_SEARCH_PATH:+${FW_SEARCH_PATH}:}`pwd`
