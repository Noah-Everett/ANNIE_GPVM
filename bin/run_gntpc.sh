source $B/setup_genie3_00_04.sh
for file in gntp.${1}.ghep.root
do
  /cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_04_ub3/Linux64bit+3.10-2.17-e17-prof/bin/gntpc -i ${file} -f gst
done
