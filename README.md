# Compute Canada
## Loading and listing modules
Search for a module:
```bash
$ module avail <name>
```
Search, typically list more:
```bash
$ module spider <name>
```
Show currently loaded  modules:\
```bash
$ module list
```
Loading and unloading modules:
```bash
$ module load moduleName 
$ module unload moduleName
```
For example loading python and create virtual env:
```bash
$ module load python/3.8.10
$ virtualenv env
```
## Jobs
Submitting a job:
```bash
$ sbatch [--account=def-razoumov-ac, other flags] simpleScript.sh
```
The flag --account=... is needed only if you’ve been added to more than one CPU allocation (RAS
/ RAC / reservations)

For listing current jobs (either pending or running):
```bash
$ squeue -u yourUsername [-t RUNNING] [-t PENDING] 
```
Cancelling a job:
```bash
$ scancel jobID
```
Cancel all your jobs:
```bash
$ scancel -r yourUsername
```

The following is an example of submitting a job for running `test` using a .sh file:
```bash
#!/bin/bash
#SBATCH --time=00:05:00 # walltime in d-hh:mm or hh:mm:ss format
#SBATCH --job-name="quick test"
#SBATCH --mem=100 # 100M
#SBATCH --account=def-zaiane
./test
```
Memory may be requested with `--mem-per-cpu` (memory per core) or `--mem` (memory per node).
You can also specify the name of the output result of a job using `--output`.  For job arrays,
the default file name is "slurm-%A_%a.out", "%A" is replaced by the job ID and "%a" with the 
array index. For other jobs, the default file name is "slurm-%j.out", where the "%j" is replaced
by the job ID.

You can ask to be notified by email of certain job conditions by supplying options to sbatch:
```bash
#SBATCH --mail-user=your.email@example.com
#SBATCH --mail-type=ALL
```
Valid type values are NONE, BEGIN, END, FAIL, REQUEUE, ALL (equivalent to BEGIN, END, FAIL, INVALID_DEPEND, REQUEUE, and STAGE_OUT), 
INVALID_DEPEND (dependency never satisfied), STAGE_OUT (burst buffer stage out and teardown completed), TIME_LIMIT, TIME_LIMIT_90 
(reached 90 percent of time limit), TIME_LIMIT_80 (reached 80 percent of time limit), TIME_LIMIT_50 (reached 50 percent of time limit) 
and ARRAY_TASKS (send emails for each array task). Multiple type values may be specified in a comma separated list. The user to be notified
is indicated with --mail-user. Unless the ARRAY_TASKS option is specified, mail notifications on job BEGIN, END and FAIL apply to a job array 
as a whole rather than generating individual email messages for each task in the job array.

You can show detailed information for a specific job with `scontrol`
```bash
$ scontrol show job -dd <jobid>
```

Get a short summary of the CPU- and memory-efficiency of a job with `seff`:
```bash
$ seff 12345678
Job ID: 12345678
Cluster: cedar
User/Group: jsmith/jsmith
State: COMPLETED (exit code 0)
Cores: 1
CPU Utilized: 02:48:58
CPU Efficiency: 99.72% of 02:49:26 core-walltime
Job Wall-clock time: 02:49:26
Memory Utilized: 213.85 MB
Memory Efficiency: 0.17% of 125.00 GB
```

Find more detailed information about a completed job with sacct, and optionally, control what it prints using --format:
```bash
$ sacct -j <jobid>
$ sacct -j <jobid> --format=JobID,JobName,MaxRSS,Elapsed
```
### Array jobs
Job arrays are a handy tool for submitting many serial jobs that have the same executable and might
differ only by the input they are receiving through a file. Job arrays are preferred as they don’t require as much computation by the scheduling system to
schedule, since they are evaluated as a group instead of individually.
In the example below we want to run 30 times the executable “myprogram” that requires an input file;
these files are called input1.dat, input2.dat, ..., input30.dat, respectively
```bash
#!/bin/bash
#SBATCH --array=1-30 # 30 jobs
#SBATCH --job-name=myprog # single job name for the array
#SBATCH --time=02:00:00 # maximum walltime per job
#SBATCH --mem=100 # maximum 100M per job
#SBATCH --account=def-razoumov-ac
#SBATCH --output=myprog%A%a.out # standard output
#SBATCH --error=myprog%A%a.err # standard error
# in the previous two lines %A" is replaced by jobID and "%a" with the array index
./myprogram input$SLURM_ARRAY_TASK_ID.dat
```

### Parallel jobs
Submitting OpenMP jobs:
```bash
#!/bin/bash
#SBATCH --cpus-per-task=4 # number of cores
#SBATCH --time=0-00:05 # walltime in d-hh:mm or hh:mm:ss format
#SBATCH --mem=100 # 100M for the whole job (all threads)
#SBATCH --account=def-razoumov-ac
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK # passed to the program
echo running on $SLURM_CPUS_PER_TASK cores
./openmp
```

Submitting MPI jobs:
```bash
#!/bin/bash
#SBATCH --ntasks=4 # number of MPI processes
#SBATCH --time=0-00:05 # walltime in d-hh:mm or hh:mm:ss format
#SBATCH --mem-per-cpu=100 # in MB
#SBATCH --account=def-razoumov-ac
srun ./mpi
```

Submitting GPU jobs:
```bash
#!/bin/bash
#SBATCH --nodes=3 # number of nodes
#SBATCH --gres=gpu:1 # GPUs per node
#SBATCH --mem=4000M # memory per node
#SBATCH --time=0-05:00 # walltime in d-hh:mm or hh:mm:ss format
#SBATCH --output=%N-%j.out # %N for node name, %j for jobID
#SBATCH --account=def-razoumov-ac
srun ./gpu_program
```
To request one or more GPUs for a Slurm job, use this form:
```bash
--gpus-per-node=[type:]number
```
The square-bracket notation means that you must specify the number of GPUs, and you may optionally specify the GPU type.
Choose a type from the "Available hardware" table below. Here are two examples:
```bash
--gpus-per-node=2
--gpus-per-node=v100:1
```
The following form can also be used:
```bash
--gres=gpu[[:type]:number]
```
This is older, and we expect it will no longer be supported in some future release of Slurm. We recommend that you 
replace it in your scripts with the above --gpus-per-node form.

If you need only a single CPU core and one GPU:
```bash
#!/bin/bash
#SBATCH --account=def-someuser
#SBATCH --gpus-per-node=1
#SBATCH --mem=4000M               # memory per node
#SBATCH --time=0-03:00
./program                         # you can use 'nvidia-smi' for a test
```
For a GPU job which needs multiple CPUs in a single node:
```bash
#!/bin/bash
#SBATCH --account=def-someuser
#SBATCH --gpus-per-node=1         # Number of GPU(s) per node
#SBATCH --cpus-per-task=6         # CPU cores/threads
#SBATCH --mem=4000M               # memory per node
#SBATCH --time=0-03:00
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
./program
```

### Requesting a GPU node on Graham
If your application can efficiently use an entire node and its associated GPUs, you will probably experience shorter 
wait times if you ask Slurm for a whole node. Use one of the following job scripts as a template.
For example on Graham, one type of node contains 2 p100 gpus with 32 cpu cores. Therefore, we request
an entire node as follows:
```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gpus-per-node=p100:2
#SBATCH --ntasks-per-node=32
#SBATCH --mem=127000M
#SBATCH --time=3:00
#SBATCH --account=def-someuser
nvidia-smi
```

### Requesting a P100 GPU node on Cedar
```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --gpus-per-node=p100:4
#SBATCH --ntasks-per-node=24
#SBATCH --exclusive
#SBATCH --mem=125G
#SBATCH --time=3:00
#SBATCH --account=def-someuser
nvidia-smi
```
`--exclusive[={user|mcs}]`
The job allocation can not share nodes with other running jobs (or just other users with the "=user" option or with the 
"=mcs" option). If user/mcs are not specified (i.e. the job allocation can not share nodes with other running jobs), the 
job is allocated all CPUs and GRES on all nodes in the allocation, but is only allocated as much memory as it requested. 
This is by design to support gang scheduling, because suspended jobs still reside in memory. To request all the memory 
on a node, use --mem=0. The default shared/exclusive behavior depends on system configuration and the partition's OverSubscribe
option takes precedence over the job's option.

For a specification of clusters and nodes with their gpu types and number of cpus and gpus, 
and also how to occupy whole node, visit:
https://docs.computecanada.ca/wiki/Using_GPUs_with_Slurm


### Interactive jobs
Submitting interactive jobs (jobs that are not running in the background. 
Instead, you can interact with the system having specifications of the submitted job)

```bash
$ salloc --time=1:0:0 --ntasks=2 # submit a 2-core interactive job for 1h
$ echo $SLURM_... # can check out Slurm environment variables
$ ./serial # this would be a waste: we have allocated 2 cores
$ srun ./mpi # run an MPI code, could also use mpirun/mpiexec
$ exit # terminate the job
```
Make sure to only run the job on the processors assigned to your job – this will
happen automatically if you use srun, but not if you just ssh from the headnode

### Slurm jobs and memory
Can use either `#SBATCH --mem=4000` or `#SBATCH --mem-per-cpu=2000`

What’s the best way to find your code’s memory usage?
Second-best way: use Slurm command to estimate your completed code’s memory
usage
```bash
$ sacct -j jobID [--format=jobid,maxrss,elapsed]
# list resources used by a completed job
```
