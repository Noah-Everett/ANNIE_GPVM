# Information on The Grid

## About
The Fermi Grid is a great tool to run programs that would otherwise need to be run on a local machine or on the gpvm. Using the Grid has several benefits: minimize pressure on gpvm, use save effort by using ups, and being able to concurrently run numerous identical programs to save wait time.

## Tarball Usage
To run programs on the Grid, we need to be able to pass files to the worker node. 
To pass files like flux, geometry, and maxpl to the Grid node, we use tarballs, specifically `$GR/grid_genie.tar.gz` for GENIE Generator and `$GR/grid_wcsim.tar.gz` for WCSim.
For more information on these files and how their generated, visit the [`make_tar_genie.sh` section](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/bin#make_tar_geniesh) and [`make_tar_wcsim.sh` section](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/bin#make_tar_wcsimsh) respectfully.

## User Required Inputs
Scripts (in [`$B`](https://github.com/Noah-Everett/ANNIE_gpvm/tree/main/bin)) that run programs on the Grid also (for now) require the user to provide the amount of memory, disk, cpus, and run time for the Grid run. 
It can be tricky to know the appropriate values for each (I myself am still finding the right amounts, and plan to automate this in the future). 
However, note that we want to use the least amount of each we can, because all experiments have a quota on the Grid.
Staying under our quota will allow our fellow collaborators to run their Grid jobs faster, as well as allow other collaborations to run their jobs faster as more resources will be available.

## Additional Resources
Please look through the following to learn more about the Grid and how to properly use it:
- [Storage Spaces](https://dune.github.io/computing-training-202105/02-storage-spaces/index.html)
- [Grid Job Sumbission and Common Errors](https://dune.github.io/computing-training-202105/07-grid-job-submission/index.html)
- Any other sessions will also probably be of use: [DUNE Computing Training May 2021 edition](https://dune.github.io/computing-training-202105/index.html)

## Usefull Links
- [Fifemon](https://fifemon.fnal.gov/monitor/d/000000185/fifemon-home?orgId=1) (Information on the Grid and user run batches)
- [ANNIE Overview](https://fifemon.fnal.gov/monitor/d/000000004/experiment-overview?orgId=1&var-experiment=annie) (Overview of ANNIEs usage)
- [User Batch Details](https://fifemon.fnal.gov/monitor/d/000000116/user-batch-details?orgId=1) (Overview of your Grid activity (select yourself under `user` in the top left))


## Fun Facts
Did you know that the Grid has:
- 27,200 cpus
- 82.3 TiB of memory
- 1.820 PiB of disk space