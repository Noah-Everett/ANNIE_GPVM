for i in "$@"; do
  case $i in
    -r=*                   ) export RUNBASE="${i#*=}"   shift ;;
    -n=*                   ) export NEVT="${i#*=}"      shift ;;
    -g=*                   ) export GDML="${i#*=}"      shift ;;
    -t=*                   ) export TOPVOL="${i#*=}"    shift ;;
    -f=*                   ) export FLUXFILE="${i#*=}"  shift ;;
    -m=*                   ) export MAXPL="${i#*=}"     shift ;;
    --message-thresholds=* ) export MESTHRE="${i#*=}"   shift ;;
    -N=*                   ) export NJOBS="${i#*=}"     shift ;;
    --memory=*             ) export MEMORY="${i#*=}"    shift ;;
    --disk=*               ) export DISK="${i#*=}"      shift ;;
    --cpu=*                ) export CPU="${i#*=}"       shift ;;
    --expected-lifetime=*  ) export EXPLT="${i#*=}"     shift ;;
    -*                     ) echo "unknown option $i" exit 1 ;;
   esac
done

echo jobsub_submit -G annie -M -N $NJOBS --memory=$MEMORY --disk=$DISK --cpu=$CPU --expected-lifetime=$EXPLT --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE -l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' --append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' --tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_genie.tar.gz file:///annie/app/users/neverett/grid/run_grid_genie.sh -r=$RUNBASE -n=$NEVT -g=$GDML -t=$TOPVOL -f=$FLUXFILE -m=$MAXPL --message-thresholds=$MESTHRE
     jobsub_submit -G annie -M -N $NJOBS --memory=$MEMORY --disk=$DISK --cpu=$CPU --expected-lifetime=$EXPLT --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE -l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' --append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' --tar_file_name=dropbox:///annie/app/users/neverett/grid/grid_genie.tar.gz file:///annie/app/users/neverett/grid/run_grid_genie.sh -r=$RUNBASE -n=$NEVT -g=$GDML -t=$TOPVOL -f=$FLUXFILE -m=$MAXPL --message-thresholds=$MESTHRE
