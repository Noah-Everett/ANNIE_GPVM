# Usage Statements for Scripts in `$B` (this dir)

### Note:
- To use the following commands make sure to run: `source /annie/app/users/neverett/bin/setup`

- `<>` denotes required option or argument, `[]` denotes optional option or argument.

## Table of Contents
- [run_genie.sh](#run_genie.sh)
- [run_genie_grid.sh](#run_genie_grid.sh)
- [make_genie_gst.sh](#make_genie_gst.sh)
- [make_tar_genie.sh](#make_tar_genie.sh)
- [make_geoms_1D.sh](#make_geoms_1D.sh)
- [make_geoms_4D.sh](#make_geoms_4D.sh)
- [setup](#setup)
- [setup_genie3_00_06.sh](#setup_genie3_00_06.sh)
- [setup_genie3_00_04.sh](#setup_genie3_00_04.sh)
- [setup_genie2_12_10.sh](#setup_genie2_12_10.sh)
- [setup_grid.sh](#setup_grid.sh)
- [setup_shortcuts.sh](#setup_shortcuts.sh)
- [setup_singularity.sh](#setup_singularity.sh)

## **run_genie.sh**
Use GENIE Generator on the gpvm:
```
source $B/run_genie.sh -r=#                      (run number)
                       -n=#                      (number of events)
                       -g=abc.gdml               (geometry file (in $G))
                       -t=ABC_LV                 (geometry top volume)
                       -f=123*                   (flux file number (in $F))
                       -m=abc.maxpl.xml          (max path length file (in $G))
                       -o=/path/to/out/dir       (ouput directory)
                       -S=(+|-)#                 (geometry scan config (default = 0)
     --message-thresholds=Messenger_abc.xml      (output type priorities (in $C) (default = ""))
                       -h|--help                 (print script usage statement (this output))
```

### **Example Usage**
```
$ nohup $B/run_genie.sh -r=0 -n=100 -g=annie_v01.gdml -t=TWATER_LV -f=000* -m=annie_v01.maxpl.xml -o=. | tee -a ./run_0.out
```
```
$ nohup $B/run_genie.sh -r=1 -n=100 -g=annie_v02.gdml -t=TWATER_LV -f=000* -m=annie_v02.maxpl.xml --message-thresholds=Messenger_warn.xml -o=. | tee -a ./run_1.out
```

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

## **setup_singularity**

## **Previous Work by Robert Hatcher**
Previous work by Robert Hatcher has been extremely usefull and can be found [here](https://cdcvs.fnal.gov/redmine/projects/anniesoft/wiki/GENIE_and_Geant4_neutrons_from_rock_propagation), [here](https://cdcvs.fnal.gov/redmine/projects/genie/wiki/Running_gevgen_fnal), and in `$RH`. 