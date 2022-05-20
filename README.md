# ANNIE_gpvm
 
## **My Code**
```
/annie/app/users/neverett/
    /bin/
        run_genie_grid.sh                 # runs GENIE on the grid
        run_genie.sh                      # runs GENIE on ANNIE gpvm
        setup                             # general user setup
        setup_genie2_12_10.sh             # setup for GENIE v2.12.10
        setup_genie3_00_04.sh             # setup for GENIE v3.0.4
        setup_genie3_00_06.sh             # setup for GENIE v3.0.6
        setup_grid.sh                     # setup for grid commands
        setup_shortcuts.sh                # setup for personal shortcuts
        /ROOT_scripts/
            combineTrees.C                # ROOT script to combine gst trees
            getTgt.C                      # ROOT script to output genie tgt
    
    /WCSim/
        getwcsim.sh                       # installs WCSim
        setupenvs.sh                      # used by getwcsim.sh
```

To use the following commands make sure to run:
```
source /annie/app/users/neverett/bin/setup
```

### **setup_shortcuts.sh**
The remainder of the document will user environmental variables defined in `setup_shortcuts.sh`:

```
# /annie/app/users/
export ANNIEUSERS=/annie/app/users
export NE=$ANNIEUSERS/neverett
export RH=$ANNIEUSERS/rhatcher
export JM=$ANNIEUSERS/jminock
export MO=$ANNIEUSERS/moflaher

# /pnfs/annie/scratch/users/
export PNFSUSERS=/pnfs/annie/scratch/users
export PNE=$PNFSUSERS/neverett

# personal
export B=$NE/bin
export R=$NE/runs
export W=$NE/WCSim    
```

<br />

## **GENIE**
General template:

```
$ cd <output dir>
$ nohup $B/run_genie3.sh -r <run number> -n <number of events> -g annie_v0<1 or 2>.gdml -t <TWATER_LV or TARGON_LV> -o <output dir> -z -2000
```

Used to produce current results for water target:

```
$ cd $R/run_103
$ nohup $B/run_genie3.sh -r 103 -n 1000 -g annie_v01.gdml -t TWATER_LV -o . -z -2000
```

Attempting to use for argon target:

```
$ cd $R/run_10
$ nohup $B/run_genie3.sh -r 10 -n 1000 -g annie_v02.gdml -t TARGON_LV -o . -z -2000
```

To run GENIE on the grid, we use `jobsub_submit`. To modify the simulation, simply edit `$B/run_genie3_grid.sh`. Output will be in `$PNE/genie_output` and `$PNE/job_output`. NOTE: I have not successfully completed a GENIE run on the grid, though this command should work (at least in theory):

```
$ jobsub_submit -G annie -M -N 1 --memory=2000MB --disk=2GB --cpu=1 --expected-lifetime=24h --resource-provides=usage_model=DEDICATED,OPPORTUNISTIC,OFFSITE -l '+SingularityImage=\"/cvmfs/singularity.opensciencegrid.org/fermilab/fnal-wn-sl7:latest\"' --append_condor_requirements='(TARGET.HAS_Singularity==true&&TARGET.HAS_CVMFS_larsoft_opensciencegrid_org==true)' -f dropbox:///annie/app/users/neverett/bin/setup_genie3_00_04.sh -f dropbox:///annie/app/users/neverett/geometry/annie_v02.gdml -f dropbox:///annie/app/users/neverett/flux/GNuMIFlux.xml -f dropbox:///annie/app/users/neverett/flux/bnb_annie_0030.root file:///annie/app/users/neverett/bin/run_genie3_grid.sh
```

<br />
<br />
<br />
<br />

## **WCSim**
All WCSim work was done using existing code by Marcus O'Flaherty. First, I did as Franklin recommended and tried to use Marcus' `getwcsim.sh` script (`$MO/wcsim/getwcsim.sh`).

```
$ cd $NE
$ mkdir WCSim && cd WCSim
$ cp $MO/wcsim/getwcsim.sh
$ ./getwcsim.sh
```

This did not work and resulted in multiple errors (`$W/getwcsim.out.~0~`). Because the resulting errors seemed to be a result of WCSim's dependencies (GENIE, ROOT, and Geant4), I tried to update the sourcing of dependencies, specifically of GENIE. However, because ROOT relies on GENIE to be setup, there was an issue when using a different setup of GENIE. Upon realization of this issue, I decided it would be better to ask Marcus for help. The modified `getwcsim.sh` and `setupenvs.sh` can be found in `$W`. To use the updated WCSim installation procedure, simply copy `$W/getwcsim.sh` into any directory and run it. NOTE: errors have not been resolved, so it shouldn't work.

## **Previous Work (by Robert Hatcher)**
Previous work by Robert Hatcher can be found [here](https://cdcvs.fnal.gov/redmine/projects/anniesoft/wiki/GENIE_and_Geant4_neutrons_from_rock_propagation). All of the scripts that run GENIE (both mine and James Minock's) are just modified versions of Robert Hatcher's work).