# source /cvmfs/sbnd.opensciencegrid.org/products/sbnd/setup_sbnd.sh
# #source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setups
# source /cvmfs/larsoft.opensciencegrid.org/products/setups
# setup genie v3_00_06 -q e17:prof
# setup genie_phyopt v3_00_06 -q dkcharmtau:resfixfix
# setup genie_xsec v3_00_06 -q G1810a0211a:e1000:k250
# export XERCESROOT=$XERCESCROOT
# export ROOT_INCLUDE_PATH=${ROOT_INCLUDE_PATH}:${GENIE}/../include/GENIE:${GENIE}/../include/GENIE/Framework
# export ROOT_LIBRARY_PATH=${ROOT_LIBRARY_PATH}:${GENIE}/../lib
# 
# #setup dk2nugenie v01_08_00_ub3 -q e17:prof
# setup boost  v1_66_0a -q e17:prof
# setup cetlib v3_05_01 -q e17:prof
# setup cetlib_except v1_03_00 -q e17:prof
# setup fhiclcpp v4_08_01 -q e17:prof
# setup cmake v3_3_2
# #setup ifdhc
# 
# export LD_LIBRARY_PATH=./:`pwd`/lib:${GENIE}/../lib:${LD_LIBRARY_PATH}
# export FW_SEARCH_PATH=${FW_SEARCH_PATH:+${FW_SEARCH_PATH}:}`pwd`

# Setup from Robert Hatcher:
# bootstrap many UPS areas for GENIE related products
source /cvmfs/fermilab.opensciencegrid.org/products/genie/bootstrap_genie_ups.sh
setup dk2nugenie  v01_10_00 -q debug:e20
# this sets up GENIE, ala: setup genie v3_00_06k -q debug:e20
setup genie_phyopt v3_00_04 -q dkcharmtau
setup genie_xsec   v3_00_06 -q G1810a0211a:e1000:k250
# genie_xsec sets ${GENIEXSECFILE} and ${GENIE_XSEC_TUNE}

# my own area for testing purposes
# cd /annie/app/users/rhatcher/neverett

# allow GNuMIFlux driver to find config file for ANNIE BNB flux
# copied to my own area for testing purposes
# export GXMLPATH=/annie/app/users/rhatcher/neverett/flux:${GXMLPATH}
export GXMLPATH=/annie/app/users/neverett/flux:${GXMLPATH}
