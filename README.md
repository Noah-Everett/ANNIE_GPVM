# ANNIE_gpvm
 
## **My Code**
```
/annie/app/users/neverett/
    /bin/
        run_genie_grid.sh       # runs GENIE generator on the grid
        run_genie.sh            # runs GENIE generator on ANNIE gpvm
        run_gntpc.sh            # runs GENIE gntpc (converts ghep fles to gst files)
        make_tar_genie.sh       # makes tarball for running GENIE on grid
        make_geoms_4D.sh        # makes versions of the ANNIE geometry (4 variables)
        make_geoms_1D.sh        # makes versions of the ANNIE geometry (1 variable)
        setup                   # general user setup
        setup_genie2_12_10.sh   # setup for GENIE v2.12.10
        setup_genie3_00_04.sh   # setup for GENIE v3.0.4
        setup_genie3_00_06.sh   # setup for GENIE v3.0.6
        setup_grid.sh           # setup for grid commands
        setup_shortcuts.sh      # setup for personal shortcuts
        /ROOT_scripts/
            combineTrees.C      # ROOT script to combine GENIE gst trees
            getTgt.C            # ROOT script to output GENIE event target (tgt) 

    /config/
        Messenger_debug.xml     # GENIE messenger config w/ all priorities set to DEBUG
        Messenger_fatal.xml     # GENIE messenger config w/ all priorities set to FATAL
        Messenger_warn.xml      # GENIE messenger config w/ all priorities set to WARN

    /grid/
        run_grid_genie.sh       # grid runnable script for GENIE
```

To use the following commands make sure to run:
```
source /annie/app/users/neverett/bin/setup
```

### **setup_shortcuts.sh**
The remainder of the document will user environmental variables defined in `setup_shortcuts.sh`:
```
# /annie/app/users/
export USERS=/annie/app/users
export NE=$ANNIEUSERS/neverett
export RH=$ANNIEUSERS/rhatcher
export JM=$ANNIEUSERS/jminock
export MO=$ANNIEUSERS/moflaher
export MA=$ANNIEUSERS/mascenci
export FL=$ANNIEUSERS/flemmons

# /annie/app/users/neverett/
export B=$NE/bin
export R=$NE/runs
export G=$NE/geometry
export T=$NE/ToolAnalysis
export C=$NE/config
export GR=$NE/grid

# /pnfs/annie/scratch/users/
export PUSERS=/pnfs/annie/scratch/users

# /pnfs/annie/scratch/users/neverett/
export PNE=$PNFSUSERS/neverett
export PG=$PNE/genie_output
```

<br />

## **GENIE on the ANNIE gpvm**
Use GENIE Generator on the gpvm:
```
source $B/run_genie.sh -r=#                      (run number)
                       -n=#                      (number of events)
                       -g=abc.gdml               (geometry file (in $G))
                       -t=ABC_LV                 (geometry top volume)
                       -f=123*                   (flux file number (in $F))
                       -m=abc.maxpl.xml          (max path length file (in $G))
                       -o=/path/to/out/dir       (ouput directory)
                       -S=(+|-)#                 (geometry scan config)
     --message-thresholds=Messenger_abc.xml      (output type priorities (in $C))
                       -h|--help                 (print script usage statement (this output))
```

### **Example Usage** 
```
$ nohup $B/run_genie.sh -r=0 -n=100 -g=annie_v01.gdml -t=TWATER_LV -f=000* -m=annie_v01.maxpl.xml -o=. | tee -a ./run_0.out
```
```
$ nohup $B/run_genie.sh -r=1 -n=100 -g=annie_v02.gdml -t=TWATER_LV -f=000* -m=annie_v02.maxpl.xml -o=. | tee -a ./run_1.out
```

## **GENIE on the Grid**
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

## **Previous Work by Robert Hatcher**
Previous work by Robert Hatcher has been extremely usefull and can be found [here](https://cdcvs.fnal.gov/redmine/projects/anniesoft/wiki/GENIE_and_Geant4_neutrons_from_rock_propagation), [here](https://cdcvs.fnal.gov/redmine/projects/genie/wiki/Running_gevgen_fnal), and in `$RH`. 