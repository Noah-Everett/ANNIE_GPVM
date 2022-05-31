# Usage Statements for Scripts in `$B` (this dir)

### Note:
- To use the following commands make sure to run: `source /annie/app/users/neverett/bin/setup`

- `<>` denotes required option or argument, `[]` denotes optional option or argument.

## Table of Contents
- [run_genie.sh](#run_geniesh)
- [run_genie_grid.sh](#run_genie_gridsh)
- [make_genie_gst.sh](#make_genie_gstsh)
- [make_tar_genie.sh](#make_tar_geniesh)
- [make_geoms_1D.sh](#make_geoms_1Dsh)
- [make_geoms_4D.sh](#make_geoms_4Dsh)
- [setup](#setup)
- [setup_genie3_00_06.sh](#setup_genie3_00_06sh)
- [setup_genie3_00_04.sh](#setup_genie3_00_04sh)
- [setup_genie2_12_10.sh](#setup_genie2_12_10sh)
- [setup_grid.sh](#setup_gridsh)
- [setup_shortcuts.sh](#setup_shortcutssh)
- [setup_singularity.sh](#setup_singularitysh)

## **run_genie.sh**

### About
`run_genie.sh` is used to run the GENIE Generator on the gpvm. 
Currently, the script is specialized to my directory (`$NE`), though, with moderately minor modifications, the script could be modified to work in any user directory. 
In general, this script (or any GENIE usage on the gpvm) should be limited to relatively small or experimental runs. 
Any larger batches of runs should be run on the grid both to save the user time and also so ensure that the gpvm remains usable for all other collaboration members.

### Usage
```
source $B/run_genie.sh -r=<run number>
                       -n=<number of events>
                       -g=<geometry file name (in $G)>.gdml
                       -t=<top volume name>_LV
                       -f=<flux file number (or numbers using '*') (in $FLUX)>
                       -m=[+]<max path length file (in $G)>.maxpl.xml
                       -o=</path/to/output/dir>
                       -S=[-]<number of particles used to scan geometry (default = 0)>
     --message-thresholds=Messenger_<name (in $C) (default = "")>.xml
                       -h|--help
```

### **Example Usage**

#### Typical GENIE Run (modified slightly to make the run time lower):
```
$ nohup $B/run_genie.sh -r=0 -n=100 -g=annie_v01.gdml -t=TWATER_LV -f=000* -m=annie_v01.maxpl.xml -o=. | tee -a ./run_0.out
```
- Run 0
- 100 events
- Using original ANNIE geometry (`annie_v01.gdml`) and its precomputed `.maxpl.xml` file
- Events generated in `TWATER_LV`
- Using flux files [`bnb_annie_0000.root`,`bnb_annie_0009.root`] (10 flux files)
- A copy of the program output will be saved to `./run_0.out`

#### Generating `.maxpl.xml` file: 
```
$ nohup $B/run_genie.sh -r=1 -n=1 -g=annie_v02.gdml -t=EXP_HALL_LV -f=* -m=+$G/annie_v02.maxpl.xml -S=30000 --message-thresholds=Messenger_warn.xml -o=. | tee /dev/null
```
- Run 1
- 1 Event (small to take less time)
- Updated ANNIE geometry (`annie_v02.gdml`)
- NOTE: `+` at the beginning of `-m` tells GENIE to create a new `.maxpl.xml` file
- NOTE: `-S=30000` tells GENIE to use 30,000 flux particles to approximate the max path length of materials in the geometry
- All message thresholds will be set to warn
- The program output will not be saved

## **run_genie_grid.sh**
Use GENIE Generator on the grid:
```
source $B/make_tar_genie.sh
```
```
source $B/run_genie_grid.sh -r=#                 (run base number)
                            -n=#                 (number of events)
                            -g=abc.gdml          (geometry file (in $G))
                            -t=ABC_LV            (geometry top volume)
                            -f=123*              (flux file number (in $F))
                            -m=abc.maxpl.xml     (max path length file (in $G))
          --message-thresholds=Messenger_abc.xml (output type priorities (in $C))
                            -N=#                 (number of identical jobs)
                      --memory=#MB               (amount of memory)
                        --disk=#MB               (amount of disk space)
                         --cpu=#                 (number of cpus)
           --expected-lifetime=#h                (maximum run time)
                     -h|--help                   (print script usage statement (this output))
```

### **Example Usage**
```
$ source $B/run_genie_grid.sh -r=0 -n=100 -g=annie_v02.gdml -t=TWATER_LV -f=000* -m=annie_v02.maxpl.xml --message-thresholds=Messenger_warn.xml -N=2 --memory=2000MB --disk=1000MB --cpu=1 --expected-lifetime=1h
```

## **setup_singularity.sh**

## **Previous Work by Robert Hatcher**
Previous work by Robert Hatcher has been extremely usefull and can be found [here](https://cdcvs.fnal.gov/redmine/projects/anniesoft/wiki/GENIE_and_Geant4_neutrons_from_rock_propagation), [here](https://cdcvs.fnal.gov/redmine/projects/genie/wiki/Running_gevgen_fnal), and in `$RH`. 