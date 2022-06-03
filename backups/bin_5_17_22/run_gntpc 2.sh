source $B/setup_genie3_00_04.sh
/cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_04_ub3/Linux64bit+3.10-2.17-e17-prof/bin/gntpc -i gntp."$1".ghep.root -f gst | tee gntpc."$1".out
