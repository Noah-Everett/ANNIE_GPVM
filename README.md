# ANNIE_gpvm

## Repository Contents
```
/annie/app/users/neverett/
    /backups/                    # miscilanious backup folders and files
    /bin/                        # user runnable scripts
        run_genie.sh                 # runs GENIE Generator on ANNIE gpvm
        run_genie_grid.sh            # runs GENIE Generator on the grid
        make_maxpl_grid.sh           # runs GENIE Generator on the grid to produce maxpl.xml files
        make_gst.sh                  # runs GENIE gntpc to convert ghep files to gst files
        make_tar_genie.sh            # makes tarball for running GENIE on grid
        make_geoms_1D.sh             # makes versions of the ANNIE geometry (1 variable)
        make_geoms_4D.sh             # makes versions of the ANNIE geometry (4 variables)
        setup                        # general user setup
        setup_genie3_00_06.sh        # setup for GENIE v3.0.6
        setup_genie3_00_04.sh        # setup for GENIE v3.0.4
        setup_genie2_12_10.sh        # setup for GENIE v2.12.10
        setup_grid.sh                # setup for grid commands
        setup_shortcuts.sh           # setup for personal shortcuts
        setup_singularity.sh         # setup for ToolAnalysis singularity
    /config/                     # contains GENIE config files
        Messenger_debug.xml          # GENIE messenger config w/ all priorities set to DEBUG
        Messenger_warn.xml           # GENIE messenger config w/ all priorities set to WARN
        Messenger_fatal.xml          # GENIE messenger config w/ all priorities set to FATAL
        GNuMIFlux.xml                # Normal GNuMIFlux.xml with minor modifications
    /geometry/                   # contains gdml geometry files
    /grid/                       # contains grid runable scripts (and their required files)
        run_grid_genie.sh            # grid runnable script for GENIE (ran by $B/run_genie_grid.sh)
        run_grid_genie_maxpl.sh      # grid runnable script for GENIE (ran by $B/make_maxpl_grid.sh)
    /runs/                       # directory that contains GENIE Generator runs output (before analysis)
```

To use more easily follow the contents of all README.md files in this repository make sure to run:
```
source /annie/app/users/neverett/bin/setup
```

### `setup_shortcuts.sh`
All `README.md` files in this repository use environmental variables defined in [`setup_shortcuts.sh`](https://github.com/Noah-Everett/ANNIE_gpvm/blob/main/bin/setup_shortcuts.sh):
```sh
# /annie/app/users/
export USERS=/annie/app/users
export NE=$USERS/neverett
export RH=$USERS/rhatcher
export JM=$USERS/jminock
export MO=$USERS/moflaher
export MA=$USERS/mascenci
export FL=$USERS/flemmons

# /annie/app/users/neverett/
export B=$NE/bin
export R=$NE/runs
export G=$NE/geometry
export T=$NE/ToolAnalysis
export C=$NE/config
export GR=$NE/grid
export BA=$NE/backups

# /pnfs/annie/scratch/users/
export PUSERS=/pnfs/annie/scratch/users

# /pnfs/annie/scratch/users/neverett/
export PNE=$PNFSUSERS/neverett
export PG=$PNE/genie_output
```

## Information on Scripts

Usage statements for scripts in [`$B`](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/bin) can be found in [`$B/README.md`](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/bin#readme)

## Previous Work by Robert Hatcher
Previous work by Robert Hatcher has been extremely usefull and can be found [here](https://cdcvs.fnal.gov/redmine/projects/anniesoft/wiki/GENIE_and_Geant4_neutrons_from_rock_propagation), [here](https://cdcvs.fnal.gov/redmine/projects/genie/wiki/Running_gevgen_fnal), and in `$RH`. 