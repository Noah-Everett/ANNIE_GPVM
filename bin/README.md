# Usage Statements for Scripts in `$B` (this dir)

### Note:
- As of now, these scripts have not been made to be the most user-friendly. They lack things like error messages and option/argument checking. These may or may not be added in the future.
- These scripts where made to make my life more convenient, thus they include shortcuts to directories in `$NE` which is of little use to others. However, this should be fairly easy to change in each script.
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
- Using original ANNIE geometry (`annie_v01.gdml`) and its precomputed `.maxpl.xml` file (`annie_v01.maxpl.xml`)
- Events generated in `TWATER_LV`
- Using flux files [`bnb_annie_0000.root`,`bnb_annie_0009.root`] (10 flux files)
- A copy of the program output will be saved to `./run_0.out`

#### Generating `.maxpl.xml` file: 
```
$ nohup $B/run_genie.sh -r=1 -n=1 -g=annie_v02_sphere_vacuum/annie_v02_1.gdml -t=EXP_HALL_LV -f=* -m=+annie_v02_sphere_vacuum/annie_v02_1.maxpl.xml -S=30000 --message-thresholds=Messenger_warn.xml -o=. | tee /dev/null
```
- Run 1
- 1 Event (small to take less time)
- `$G/annie_v02_sphere_vacuum/annie_v02_1.gdml` geometry file
- NOTE: `+` at the beginning of `-m=` tells GENIE to create a new `.maxpl.xml` file
- NOTE: `-S=30000` tells GENIE to use 30,000 flux particles to approximate the max path length of materials in the geometry
- All message thresholds will be set to warn
- The program output will not be saved

## **run_genie_grid.sh**

### About
`run_genie_grid.sh` is used to run the GENIE Generator on the grid.
Currently, this script (and `$GR/run_grid_genie.sh`, which is called by this script) is specialized to my directory (`$NE`), though, with moderately minor modifications, this script (and `$GR/run_grid_genie.sh`) could be modified to work in any user directory.
As stated above in the About section of run_genie.sh, this script can (and should) be used to run large groups of GENIE Generator runs as opposed to running them on the ANNIE gpvm.

This script requires you to give the amount of memory, disk, cpus, and run time for your grid run. 
It can be tricky to know the appropriate values for each (I myself am still finding the right amounts). 
However, note that we want to use the least amount of each we can. 
This will allow our fellow collaborators to run their grid jobs faster as well as allow other collaboration to run their jobs faster as more resources will be available.

Please look through the following to learn more about the grid and how to properly use it:
- [Storage Spaces](https://dune.github.io/computing-training-202105/02-storage-spaces/index.html)
- [Grid Job Sumbission and Common Errors](https://dune.github.io/computing-training-202105/07-grid-job-submission/index.html)
- Any other sessions will also probably be of use: [DUNE Computing Training May 2021 edition](https://dune.github.io/computing-training-202105/index.html)

### Usage
```
source $B/run_genie_grid.sh -r=<run base number>
                            -n=<number of events (in each run)>
                            -g=<geometry file name (in $G)>.gdml
                            -t=<top volume name>_LV
                            -f=<flux file number (or numbers using '*') (in $FLUX)>
                            -m=<max path length file (in $G)>.maxpl.xml
          --message-thresholds=Messenger_<name (in $C) (default = "")>.xml
                            -N=<number of identical runs>
                      --memory=<amount of ram in MB>MB
                        --disk=<amount of disk space in MB>MB
                         --cpu=<number of cpus>
           --expected-lifetime=<number of hours>h
                     -h|--help
```

### **Example Usage**

#### Fast to Run Example:
```
$ source $B/run_genie_grid.sh -r=0 -n=100 -g=annie_v02.gdml -t=TWATER_LV -f=000* -m=annie_v02.maxpl.xml --message-thresholds=Messenger_warn.xml -N=2 --memory=2000MB --disk=1000MB --cpu=1 --expected-lifetime=1h
```
- Run base = 0
- 100 events in each run
- `$G/annie_v02.gdml` geometry file, with events in TWATER_LV (and its sub volumes), using its max path length file (`$G/annie_v02.maxpl.xml`)
- Using flux files [`bnb_annie_0000.root`,`bnb_annie_0009.root`] (10 flux files)
- Set all message thresholds to warn
- 2 identical runs
- 2GB of memory
- 1GB of disk space
- 1 cpu
- Expected lifetime of 1hr

#### Realistic Run:
```
$ source $B/run_genie_grid.sh -r=0 -n=1000 -g=annie_v02_sphere_argon_gas_20atm/annie_v02_4.gdml -t=TWATER_LV -f=* -m=annie_v02_sphere_argon_gas_20atm/annie_v02_4.maxpl.xml --message-thresholds=Messenger_warn.xml -N=20 --memory=8000MB --disk=5000MB --cpu=4 --expected-lifetime=9h
```
- Run base = 0
- 1000 events in each run (20 runs --> 20,000 total events)
- `$G/annie_v02_sphere_argon_gas_20atm/annie_v02_4.gdml` geometry file, with events in TWATER_LV (and its sub volumes), using its max path length file (`$G/annie_v02_sphere_argon_gas_20atm/annie_v02_4.maxpl.xml`)
- Using all flux files ([`bnb_annie_0000.root`,`bnb_annie_4999.root`] (5000 flux files))
- Set all message thresholds to warn (decrease run time and lower disk usage)
- 20 identical runs (each with different run number and seed)
- 8GB of memory
- 5GB of disk space
- 4 cpu
- Expected lifetime of 9hr