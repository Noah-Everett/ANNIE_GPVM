main() {
export RECURSIVE=false
export OTHER=""

for i in "$@"; do
  case $i in
    -r*                    ) export RECURSIVE=true        shift    ;;
    --message-thresholds=* ) export MESTHRE="${i#*=}"    	shift    ;;
    -h*|--help*            ) usage;                       return 1 ;;
    -*                     ) echo "Unknown option \"$i\"."; usage return 1 ;;
    *                      ) export OTHER="${OTHER} $i"   shift    ;;
  esac
done

if [ -z "${OTHER}" ]; then
  echo "Set the number (or numbers by using \`'*'\`) of the files to convert. Ex: \`make_gst.sh '4*'\`"
  return 1
fi

if [ -n "$MESTHRE" ]; then MESTHRE="/annie/app/users/neverett/config/${MESTHRE}"; fi

source $B/setup_genie3_00_04.sh
if [ $RECURSIVE == true ]; then
  for folder in */; do
    echo cd ${folder}
    cd ${folder}
    for file in gntp.${OTHER}.ghep.root; do
      if [ -f "$file" ]; then
        echo /cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_04_ub3/Linux64bit+3.10-2.17-e17-prof/bin/gntpc -i ${file} -f gst --message-thresholds ${MESTHRE}
        /cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_04_ub3/Linux64bit+3.10-2.17-e17-prof/bin/gntpc -i ${file} -f gst --message-thresholds ${MESTHRE}
      fi
    done
    echo cd -
    cd -
  done
else
  for file in gntp.${OTHER}.ghep.root; do
    if [ -f "$file" ]; then
      echo /cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_04_ub3/Linux64bit+3.10-2.17-e17-prof/bin/gntpc -i ${file} -f gst --message-thresholds ${MESTHRE}
      /cvmfs/larsoft.opensciencegrid.org/products/genie/v3_00_04_ub3/Linux64bit+3.10-2.17-e17-prof/bin/gntpc -i ${file} -f gst --message-thresholds ${MESTHRE}
    fi
  done
fi
}

usage() {
cat >&2 <<EOF
make_genie_gst.sh -r                 (recursive (directories))
                  -h|--help          (display the usage statement (this output))
                  <ghep file number> (number (numbers with '*') of the ghep file to convert to gst)
If your usage of this command did not work, use "source $B/make_genie_gst.sh '##*'
EOF
}

usage() {
cat >&2 <<EOF
make_gst.sh -r (recursive (directories))
            --message-thresholds=</path/to/maxpl/file.xml (Recommended \`$C/Messenger_warn.xml\`>
            -h|--help
EOF
}

main "$@"
