# Information on Scripts in `$B` (this directory)

### Note:
- As of now, these scripts have not been made to be the most user-friendly. They lack things like error messages and option/argument checking. These may or may not be added in the future.
- To use the following commands run `source /annie/app/users/neverett/bin/setup` to setup shortcut environmental variables.
- `<>` denotes required option or argument, `[]` denotes optional option or argument.

## Table of Contents
- [run_genie.sh](#run_geniesh)
- [run_genie_grid.sh](#run_genie_gridsh)
- [run_g4dirt.sh](#run_g4dirtsh)
- [run_wcsim.sh](#run_wcsimsh)
- [run_wcsim_grid.sh](#run_wcsim_gridsh)
- [make_maxpl_grid.sh](#make_maxpl_gridsh)
- [make_gst.sh](#make_gstsh)
- [make_tar_genie.sh](#make_tar_geniesh)
- [make_tar_wcsim.sh](#make_tar_wcsimsh)
- [make_geoms.sh](#make_geomssh)
- [setup](#setup)
- [setup_genie3_00_06.sh](#setup_genie3_00_06sh)
- [setup_grid.sh](#setup_gridsh)
- [setup_shortcuts.sh](#setup_shortcutssh)
- [setup_singularity.sh](#setup_singularitysh)
- [setup_wcsim.sh](#setup_wcsimsh)

## `run_genie.sh`

### About
`run_genie.sh` is used to run the GENIE Generator on the GPVM. 
It requires input flux files (from `/annie/data/flux/<bnb, gsimple, or redecay>`) and a GDML geometry file. 
Optionally, the script can also use or generate max path length files (`.maxpl.xml`). 
Using a pregenerated file will save time and also allows for more events to be generated in a single run.

In general, this script (or any GENIE usage on the GPVM) should be limited to relatively small or experimental runs. 
Any larger batches of runs should be run on the Grid both to save the user time and also so ensure that the GPVM remains usable for all other collaboration members.
For additional information on the Grid, consult [`$GR/README.md`](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/grid#readme).

### Usage
```
run_genie.sh -r=<run number>
             -n=<number of events>
             -g=</path/to/geometry/file>.gdml
             -t=<top volume name>_LV
             -f=<flux file number or pattern>
             -m=[[+]</path/to/max/path/length/file>.maxpl.xml]
             -o=</path/to/output/dir>
             -S=[-]<number of particles used to scan geometry (default = 0)>
             --message-thresholds=</path/to/Messenger_<name>.xml>
             -h|--help
```

### Example Usage

#### Typical GENIE Run (modified slightly to make the run time lower):
```
$B/run_genie.sh -r=0 -n=20 -g=$G/other/annie_v01.gdml -t=TWATER_LV -f=000* -m=$G/other/annie_v01.maxpl.xml -o=. | tee -a run_0.out
```
- Run 0
- 20 events
- Using original ANNIE geometry (`annie_v01.gdml`) and its precomputed max path length file (`annie_v01.maxpl.xml`)
- Events generated in `TWATER_LV`
- Using flux files [`bnb_annie_0000.root`,`bnb_annie_0009.root`] (10 flux files)
- A copy of the program output will be saved to `run_0.out`

#### Generating `.maxpl.xml` file: 
```
$B/run_genie.sh -r=1 -n=1 -g=$G/other/annie_v01.gdml -t=EXP_HALL_LV -f=* -m=+annie_v01.maxpl.xml -S=30000 --message-thresholds=Messenger_warn.xml -o=.
```
- Run 1
- 1 Event (doesnt matter so small to take less time)
- `$G/other/annie_v01.gdml` geometry file
- Create a new `.maxpl.xml` file for `annie_v01.gdml`
- 30,000 flux particles will be used to approximate the max path length of materials in the geometry
- All message thresholds will be set to `warn`
- The program's messaging output will not be saved

## `run_genie_grid.sh`

### About
`run_genie_grid.sh` is used to run the GENIE Generator on the Grid.
It requires the use of a tarball (`.tar.gz` file) to provide the needed input files to each Grid node. 
The input tar file should include desired flux files from `/annie/data/flux/gsimple_bnb/`, geometry file and the corresponding max path length file, and `$B/setup_genie3_00_06.sh`.
Use [`$B/make_tar_genie.sh`](#make_tar_geniesh) as a template for the generation of the input tarball.

Any larger batches of runs should be run on the Grid both to save the user time and also so ensure that the GPVM remains usable for all other collaboration members.
For additional information on the Grid, consult [`$GR/README.md`](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/grid#readme).

### Usage
```
run_genie_grid.sh -r=<run base number>
                 <-n=<number of events> or -e=<number of POT>>
                  -g=</path/to/geometry/file.gdml>
                  -t=<top volume name>_LV
                  -f=<flux file number or pattern>
                  -m=</path/to/max/path/length/file.maxpl.xml>
                  -i=</path/to/input/tar/file.tar.gz>
                  -o=</path/to/output/directory>
                  -T=<expected lifetime of each job in hours>
                  --message-thresholds=</path/to/message/thresholds/Messenger_<name>.xml>
                  -N=<number of jobs>
                  -h|--help
```

### Example Usage

#### Fast to Run Example:
```
$B/run_genie_grid.sh -r=0 -n=100 -g=$G/other/annie_v02.gdml -t=TWATER_LV -f=000* -m=$G/other/annie_v02.maxpl.xml -i=$GR/grid_genie.tar.gz -T=2 --message-thresholds=$C/Messenger_warn.xml -N=2
```
- Run base = 0
- 100 events in each job
- Geometry file is `$G/other/annie_v02.gdml` with events in TWATER_LV (and its sub volumes), using its max path length file (`$G/other/annie_v02.maxpl.xml`)
- Using flux files [`bnb_annie_0000.root`,`bnb_annie_0009.root`] (10 flux files)
- Set all message thresholds to `warn`
- 2 jobs --> 200 events total
- Expected lifetime of 2 hrs

#### Realistic Run:
```
$B/run_genie_grid.sh -r=0 -n=1000 -g=$G/other/annie_v02.gdml -t=TWATER_LV -f=* -m=$G/other/annie_v02.maxpl.xml -i=$GR/grid_genie.tar.gz -T=7h --message-thresholds=$C/Messenger_warn.xml -N=20
```
- Run base = 0
- 1000 events in each run (20 runs --> 20,000 total events)
- `$G/other/annie_v02.gdml` geometry file, with events in TWATER_LV (and its sub volumes), using its max path length file (`$G/other/annie_v02.maxpl.xml`)
- Using all flux files ([`bnb_annie_0000.root`,`bnb_annie_4999.root`] (5000 flux files))
- Set all message thresholds to `warn` (decrease run time and lower disk usage)
- 20 jobs (each with different run number and seed)
- Expected lifetime of 7 hrs

## `make_maxpl_grid.sh`
### About
`make_maxpl_grid.sh` is used to generate `.maxpl.xml` files using the Grid. 
`.maxpl.xml` files, while not nessecary to use the GENIE Generator, decrease its runtime and (depending on the flux file format) allow more events to be generated per run. 
Currently, this script is specialized to my directory (`$NE`); though, with moderately minor modifications, this script could be modified to work for any user. 
This script also requires the use of a tarball; however, this script requirest that to be `$GR/grid_genie.tar.gz`.
This can be easily changed to be an inupt variable like `run_genie_grid.sh`.

When generating `.maxpl.xml` files for multiple GDML geometry files, it is recommended to use the Grid.
For additional information on the Grid, consult [`$GR/README.md`](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/grid#readme).

NOTE: This scipt will likely need modifications to be used. I have not used or updated it in some time.

### Usage
```
 run_genie_grid.sh --geomDir=</path/to/geoms (geometry files location (in $G))>
                   --nGeomFiles=<number of gdml files in geomDir)>
                   -t=<top volume name>_LV
                   -f=<flux file number (or numbers using '*') (in $FLUX)>
                   --message-thresholds=Messenger_<name (in $C) (default = "")>.xml
                   --memory=<amount of ram in MB or GB><MB || GB>
                   --disk=<amount of disk space in MB or GB><MB || GB>
                   --cpu=<number of CPUs>
                   --expected-lifetime=<number of hours>h
                   -h|--help
```
### Example Usage
Usage to generate `$G/annie_v02_tube_argon_liquid/*.maxpl.xml`:
```
$B/make_maxpl_grid.sh --geomDir=annie_v02_tube_argon_liquid --nGeomFiles=5 -t=EXP_HALL_LV -f=* --message-thresholds=Messenger_warn.xml --memory=2GB --disk=3GB --cup=1 --expected-lifetime=4h
```

## `make_gst.sh`

### About
`make_gst.sh` runs `gntpc` which is a GENIE executable. 
Specifically, this script runs `gntpc` to convert `gntp.<#>.ghep.root` files to `gntp.<#>.gst.root` files which are easier to use for analysis.

### Usage
```
make_genie_gst.sh -r (run in all directories one level down)
                  --message-thresholds=Messenger_<name (in $C) (default = "")>.xml
                  -h|--help
                  <file number or number pattern>
```

### Example Usage

This will convert all files in the current directory of the form `gntp.3<#>.ghep.root` to files of the form `gntp.3<#>.gst.root`:
```
$B/make_genie_gst.sh '3*'
```

Most common use case:
```
$B/make_genie_gst.sh -r '*' --message-thresholds=Messenger_warn.xml
```
- Converts all files of the form `gntp.<#>.ghep.root` to files of the form `gntp.<#>.gst.root` in the directories down one level (child directories). 
- Changes the GENIE message thresholds to `warn` to reduce run time.

## `make_tar_genie.sh`

### About
`make_tar_genie.sh` is used to create a tarball that contains all the files needed to run the GENIE Generator on the Grid. All scripts that run the GENIE Generator on the Grid require an input tarball, which can be created by running this script. `$GR/grid_genie.tar.gz` contains the following files:
- `$G/*`
- `$C/*`
- `$B/setup_genie3_00_06.sh`
- `$FLUX/*`

If any of these files have been changed, and you wish to use the new versions, make sure to rerun `$B/make_tar_genie.sh` to produce an up to date `$GR/grid_genie.tar.gz`.

NOTE: For other users, use this script as a template to create your tarball.

### Usage
```
$B/make_tar_genie.sh
```

<!-- ## `make_geoms_1D.sh`

### About
`make_geoms_1D.sh` is used to produce variations of the ANNIE geometry (in `gdml`). 
It can be used to vary the size and position of the container, the shape of the container, the and the material in the container.
The script varies size and position of the container based on the number of files generated (set by `--nFiles=`).
If the user wants two files, one will have a very small (radius = 50mm) container at the very front of the fiducial volume, and the other will be the largest container volume (radius ~ 607mm), taking up roughly the whole fiducial volume.
Similarly, if the user wants ten geometry files, the script will produce ten files with container sizes in a spectrum from smallest (radius = 50mm) to largest (radius ~ 607mm).

### Usage
```
make_geoms_1D.sh --outDir=</path/to/output/directory>
                 [--containerThickness=<thickness of the container in mm (default is 4.76, same as ANNIE tank walls)>]
                 --material=<argon || water || vacuum>
                 --shape=<tube || sphere>
                 --state<gas or liquid (only needed if using argon)>
                 --density<number times atm (ex: 20 ==> 20atm in geom)>
                 --nFiles<number of geometry files produced>
```

### Example Usage
Create `$G/annie_v02_tube_argon_gas_20atm/*`:
```
$ make_geoms_1D.sh --outDir=$G/annie_v02_tube_argon_gas_20atm --material=argon --shape=tube --state=gas --density=20 --nFiles=5
``` -->

## `setup`

### About
`setup` is a script that runs other scripts that setup environmental variables and aliases to make using the GPVM easier and faster. 
These are the scripts sourced by `setup`:
- `$B/setup_shortcuts.sh`
- `$B/setup_grid.sh`
- `$B/setup_singularity.sh`
- `$B/setup_wcsim.sh`

### Usage
```
$ source /annie/app/users/neverett/bin/setup
```

## `setup_genie3_00_06.sh`

### About
`setup_genie3_00_06.sh` sets up GENIE v3_00_06 through ups on the GPVM. 
The user should almost never have to directly run this script, as it is mainly intended and used by other scripts that run GENIE products.

### Usage
```
$ source $B/setup_genie3_00_06.sh
```

## `setup_grid.sh`

### About
`setup_grid.sh` sets up the Grid. 
This script is ran by `$B/setup`.

### Usage
```
$ source $B/setup_grid.sh
```


## `setup_shortcuts.sh`

### About
`setup_shortcuts.sh` sets up environmental variables which act as shortcuts to make navigation of the GPVM faster.

### Usage
```
$ source $B/setup_shortcuts.sh
```


## `setup_singularity.sh`

### About
`setup_singularity.sh` does in fact *not* setup singularity (used by ToolAnalysis), however it does create a couple aliases to make using the singularity easier.

### Usage
```
$ source $B/setup_singularity.sh
```
