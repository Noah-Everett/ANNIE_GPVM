# Information on Scripts in `$B` (this dir)

### Note:
- As of now, these scripts have not been made to be the most user-friendly. They lack things like error messages and option/argument checking. These may or may not be added in the future.
- These scripts where made to make my life more convenient, thus they include shortcuts to directories in `$NE` which is of little use to others. However, this should be fairly easy to change in each script.
- To use the following commands make sure to run: `source /annie/app/users/neverett/bin/setup`
- `<>` denotes required option or argument, `[]` denotes optional option or argument.

## Table of Contents
- [run_genie.sh](#run_geniesh)
- [run_genie_grid.sh](#run_genie_gridsh)
- [make_maxpl_grid.sh](#make_maxpl_gridsh)
- [make_gst.sh](#make_gstsh)
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

## `run_genie.sh`

### About
`run_genie.sh` is used to run the GENIE Generator on the GPVM. 
Currently, the script is specialized to my directory (`$NE`); though, with moderately minor modifications, the script could be modified to work for any user.
In general, this script (or any GENIE usage on the GPVM) should be limited to relatively small or experimental runs. 
Any larger batches of runs should be run on the Grid both to save the user time and also so ensure that the GPVM remains usable for all other collaboration members.

### Usage
```
run_genie.sh      -r=<run number>
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

### Example Usage

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
- All message thresholds will be set to `warn`
- The program output will not be saved

## `run_genie_grid.sh`

### About
`run_genie_grid.sh` is used to run the GENIE Generator on the Grid.
Currently, this script (and `$GR/run_grid_genie.sh`, which is called by this script) is specialized to my directory (`$NE`); though, with moderately minor modifications, this script (and `$GR/run_grid_genie.sh`) could be modified to work for any user.
As stated above in the About section of run_genie.sh, this script can (and should) be used to run large groups of GENIE Generator runs as opposed to running them on the ANNIE GPVM. 

For additional information on the Grid, look at [`$GR/README.md`](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/grid#readme).

### Usage
```
run_genie_grid.sh -r=<run base number>
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

### Example Usage

#### Fast to Run Example:
```
$ source $B/run_genie_grid.sh -r=0 -n=100 -g=annie_v02.gdml -t=TWATER_LV -f=000* -m=annie_v02.maxpl.xml --message-thresholds=Messenger_warn.xml -N=2 --memory=2GB --disk=1GB --cpu=1 --expected-lifetime=1h
```
- Run base = 0
- 100 events in each run
- `$G/annie_v02.gdml` geometry file, with events in TWATER_LV (and its sub volumes), using its max path length file (`$G/annie_v02.maxpl.xml`)
- Using flux files [`bnb_annie_0000.root`,`bnb_annie_0009.root`] (10 flux files)
- Set all message thresholds to `warn`
- 2 identical runs
- 2GB of memory
- 1GB of disk space
- 1 cpu
- Expected lifetime of 1hr

#### Realistic Run:
```
$ source $B/run_genie_grid.sh -r=0 -n=1000 -g=annie_v02_sphere_argon_gas_20atm/annie_v02_4.gdml -t=TWATER_LV -f=* -m=annie_v02_sphere_argon_gas_20atm/annie_v02_4.maxpl.xml --message-thresholds=Messenger_warn.xml -N=20 --memory=8000MB --disk=5GB --cpu=4 --expected-lifetime=9h
```
- Run base = 0
- 1000 events in each run (20 runs --> 20,000 total events)
- `$G/annie_v02_sphere_argon_gas_20atm/annie_v02_4.gdml` geometry file, with events in TWATER_LV (and its sub volumes), using its max path length file (`$G/annie_v02_sphere_argon_gas_20atm/annie_v02_4.maxpl.xml`)
- Using all flux files ([`bnb_annie_0000.root`,`bnb_annie_4999.root`] (5000 flux files))
- Set all message thresholds to `warn` (decrease run time and lower disk usage)
- 20 identical runs (each with different run number and seed)
- 8GB of memory
- 5GB of disk space
- 4 cpu
- Expected lifetime of 9hr

## `make_maxpl_grid.sh`
### About
`make_maxpl_grid.sh` is used to generate `.maxpl.xml` files using the Grid. 
`.maxpl.xml` files, while not nessecary to use the GENIE Generator, do decrease its runtime significantly. 
Currently, this script is specialized to my directory (`$NE`); though, with moderately minor modifications, this script could be modified to work for any user. 
As stated previously, the Grid should be used to decrease pressure on the annie GPVM. 
Thus, when generating `.maxpl.xml` files for multiple `gdml` geometry files, it is highly recommended to use the Grid via this script.

For additional information on the Grid, look at [`$GR/README.md`](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/grid#readme).

### Usage
```
 run_genie_grid.sh   --geomDir=</path/to/geoms (geometry files location (in $G))>
                  --nGeomFiles=<number of gdml files in geomDir)>
                            -t=<top volume name>_LV
                            -f=<flux file number (or numbers using '*') (in $FLUX)>
          --message-thresholds=Messenger_<name (in $C) (default = "")>.xml
                      --memory=<amount of ram in MB or GB><MB || GB>
                        --disk=<amount of disk space in MB or GB><MB || GB>
                         --cpu=<number of cpus>
           --expected-lifetime=<number of hours>h
                     -h|--help
```
### Example Usage
Usage to generate `$G/annie_v02_tube_argon_liquid/*.maxpl.xml`:
```
$ source $B/make_maxpl_grid.sh --geomDir=annie_v02_tube_argon_liquid --nGeomFiles=5 -t=EXP_HALL_LV -f=* --message-thresholds=Messenger_warn.xml --memory=2GB --disk=3GB --cup=1 --expected-lifetime=4h
```

## `make_gst.sh`

### About
`make_gst.sh` runs `gntpc` which is a GENIE executable. 
Specifically, this script runs `gntpc` to convert `gntp.<#>.ghep.root` files to `gntp.<#>.gst.root` files which are then able to be used in analysis scripts in my [Analysis repository](https://github.com/Noah-Everett/ANNIE_Analysis) (specifically in [`Scripts/`](https://github.com/Noah-Everett/ANNIE_Analysis/tree/main/Scripts)).

### Usage
```
make_genie_gst.sh -r                 (recursive (directories))
                  --message-thresholds=Messenger_<name (in $C) (default = "")>.xml
                  -h|--help          (display the usage statement (this output))
                  <ghep file number> (number (numbers with '*') of the ghep file to convert to gst)
If your usage of this command did not work, use "source $B/make_genie_gst.sh '##*'"
```

### Example Usage

This will convert all files in the current directory of the form `gntp.3<#>.ghep.root` to files of the form `gntp.3<#>.gst.root`.
```
$ source $B/make_genie_gst.sh '3*'
```

This is my most common use case. It will convert all files of the form `gntp.<#>.ghep.root` to files of the form `gntp.<#>.gst.root` in the directories down one level (child directories). It will also change GENIE message thresholds to `warn`.
```
$ source $B/make_genie_gst.sh -r '*' --message-thresholds=Messenger_warn.xml
```

## `make_tar_genie.sh`

### About
`make_tar_genie.sh` is used to create a tarball that contains all the files needed to run the GENIE Generator on the Grid. All scripts that run the GENIE Generator on the Grid require `$GR/grid_genie.tar.gz`, which is created by running this script. `$GR/grid_genie.tar.gz` contains the following files:
- `$G/*`
- `$C/*`
- `$B/setup_genie3_00_06.sh`
- `$FLUX/*`

If any of these files have been changed, and you wish to use the new versions, make sure to rerun `$B/make_tar_genie.sh` to produce an up to date `$GR/grid_genie.tar.gz`.

### Usage
`$ source $B/make_tar_genie.sh`

## `make_geoms_1D.sh`
### About
### Usage
### Example Usage
## `make_geoms_4D.sh`
### About
### Usage
### Example Usage
## `setup`
### About
### Usage
### Example Usage
## `setup_genie3_00_06.sh`
### About
### Usage
### Example Usage
## `setup_genie3_00_04.sh`
### About
### Usage
### Example Usage
## `setup_genie2_12_10.sh`
### About
### Usage
### Example Usage
## `setup_grid.sh`
### About
### Usage
### Example Usage
## `setup_shortcuts.sh`
### About
### Usage
### Example Usage
## `setup_singularity.sh`
### About
### Usage
### Example Usage