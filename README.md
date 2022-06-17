# ANNIE_GPVM

## Repository Contents
```
/annie/app/users/neverett/
    backups/                    # miscellaneous backup folders and files
        tank_flux_new/              # source code and built code for g4annie_dirt_flux (by Robert Hatcher)
    bin/                        # user runnable scripts
        run_genie.sh                 # runs GENIE Generator on ANNIE GPVM
        run_genie_grid.sh            # runs GENIE Generator on the Grid
        run_wcsim.sh                 # runs WCSim on ANNIE GPVM
        run_wcsim_grid.sh            # runs WCSim on the Grid
        make_maxpl_grid.sh           # runs GENIE Generator on the Grid to produce maxpl.xml files
        make_gst.sh                  # runs GENIE gntpc to convert ghep files to gst files
        make_tar_genie.sh            # makes tarball for running GENIE on Grid
        make_tar_g4dirt.sh           # makes tarball for running GENIE on Grid
        make_tar_wcsim.sh            # makes tarball for running GENIE on Grid
        make_geoms_1D.sh             # makes versions of the ANNIE geometry (1 variable)
        make_geoms_4D.sh             # makes versions of the ANNIE geometry (4 variables) (depreciated)
        setup                        # general user setup
        setup_genie3_00_06.sh        # setup for GENIE v3.0.6
        setup_genie3_00_04.sh        # setup for GENIE v3.0.4 (depreciated)
        setup_genie2_12_10.sh        # setup for GENIE v2.12.10 (depreciated)
        setup_grid.sh                # setup for Grid commands
        setup_shortcuts.sh           # setup for personal shortcuts
        setup_singularity.sh         # setup for ToolAnalysis singularity
        g4annie_dirt_flux            # executable for primary propagation (run by run_g4dirt.sh) (by Robert Hatcher)
    config/                     # contains GENIE config files
        Messenger_debug.xml          # GENIE messenger config w/ all priorities set to DEBUG
        Messenger_warn.xml           # GENIE messenger config w/ all priorities set to WARN
        Messenger_fatal.xml          # GENIE messenger config w/ all priorities set to FATAL
        GNuMIFlux.xml                # normal GNuMIFlux.xml with minor modifications
    geometry/                   # contains gdml geometry files
        annie_v02_<specifiers>/      # multiple directories containing variations of proposed ANNIE geometry
        depreciated/                 # depreciated versions of ANNIE geometry
        other/                       # misc geometries
    grid/                       # contains grid runable scripts (and their required files)
        run_grid_genie.sh            # grid runnable script for GENIE (ran by $B/run_genie_grid.sh)
        run_grid_genie_maxpl.sh      # grid runnable script for GENIE (ran by $B/make_maxpl_grid.sh)
        run_grid_wcsim.sh            # grid runnable script for WCSim (ran by $B/run_wcsim_grid.sh)
    runs/                       # directory that contains program outputs (GENIE, WCSim, and/or ToolAnalysis) (before analysis)
```

To use more easily follow the contents of all README.md files in this repository make sure to run:
```
source /annie/app/users/neverett/bin/setup
```

### `setup_shortcuts.sh`
All `README.md` files in this repository use environmental variables defined in [`setup_shortcuts.sh`](https://github.com/Noah-Everett/ANNIE_gpvm/blob/main/bin/setup_shortcuts.sh):
```sh
export ANNIE=/annie
# /annie/
    # app/
    export USERS=$ANNIE/app/users
        # users/
        export NE=$USERS/neverett
        export RH=$USERS/rhatcher
        export JM=$USERS/jminock
        export MO=$USERS/moflaher
        export MA=$USERS/mascenci
        export FL=$USERS/flemmons
            # neverett/
            export B=$NE/bin
            export R=$NE/runs
            export G=$NE/geometry
            export C=$NE/config
            export GR=$NE/grid
            export BA=$NE/backups
            export T=$NE/ToolAnalysis
            # ToolAnalysis
                export TU=$T/UserTools
                export TC=$T/configfiles
            export W=$NE/WCSim
            # WCSim
                export WB=$W/wcsim/build
                export WS=$W/wcsim/WCSim
    # data/flux/
    export FLUX=$ANNIE/data/flux/bnb
export PANNIE=/pnfs/annie
# /pnfs/annie
    # persistent/
    export PUSERS=$PANNIE/persistent/users
        # users/
        export PNE=$PUSERS/neverett
    # scratch/
    export SUSERS=$PANNIE/scratch/users
        # users/
        export SNE=$SUSERS/neverett
            # neverett/
            export SG=$SNE/genie_output
            export SW=$SNE/wcsim_output
```

## Information on Scripts

Usage statements for user runnable scripts in [`$B`](https://github.com/Noah-Everett/ANNIE_GPVM/tree/main/bin) can be found in [`$B/README.md`](https://github.com/Noah-Everett/ANNIE_GPVM/tree/main/bin#readme).

Information on the Grid can be found in [`$GR/README.md`](https://github.com/Noah-Everett/ANNIE_GPVM/tree/main/grid#readme).

## Previous Work by Robert Hatcher
Previous work by Robert Hatcher has been extremely usefull and can be found [here](https://cdcvs.fnal.gov/redmine/projects/anniesoft/wiki/GENIE_and_Geant4_neutrons_from_rock_propagation), [here](https://cdcvs.fnal.gov/redmine/projects/genie/wiki/Running_gevgen_fnal), and in `$RH`. 
