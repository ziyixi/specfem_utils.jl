import argparse
import sys
from glob import glob
from os.path import join

from slurmpy import Slurm

N_total = 30
N_each = 10
N_iter = 3
nproc = 441


def get_args(args=None):
    parser = argparse.ArgumentParser(
        description='A python script to submit jobs in one sbatch job',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--base',
                        help='the directory to place all the specefem directories',
                        required=True)
    results = parser.parse_args(args)
    return results.base


def get_dirs(base):
    return glob(join(base, "*"))


def get_scripts(thedirs):
    result = ""
    # for xmeshfem3D
    result += f"echo 'start xmeshfem3D'; "
    for iiter in range(N_iter):
        result += f"echo 'start iteration {iiter}'; "
        for ieach in range(N_each):
            # ievent
            ievent = iiter*N_each+ieach
            ievent_dir = thedirs[ievent]
            # cd
            result += f"cd {ievent_dir}; "
            # if N_each-1
            if(ieach == N_each-1):
                inc = ieach*nproc
                result += f"ibrun -n {nproc} -o {inc} ./bin/xmeshfem3D; "
            else:
                inc = ieach*nproc
                result += f"ibrun -n {nproc} -o {inc} ./bin/xmeshfem3D & "
        result += f"wait; "
        result += f"echo 'end iteration {iiter}'; "

    # for xspecfem3D
    result += f"echo 'start xspecfem3D'; "
    for iiter in range(N_iter):
        result += f"echo 'start iteration {iiter}'; "
        for ieach in range(N_each):
            # ievent
            ievent = iiter*N_each+ieach
            ievent_dir = thedirs[ievent]
            # cd
            result += f"cd {ievent_dir}; "
            # if N_each-1
            if(ieach == N_each-1):
                inc = ieach*nproc
                result += f"ibrun -n {nproc} -o {inc} ./bin/xspecfem3D; "
            else:
                inc = ieach*nproc
                result += f"ibrun -n {nproc} -o {inc} ./bin/xspecfem3D & "
        result += f"wait; "
        result += f"echo 'end iteration {iiter}'; "

    return result


def submit_job(thecommand):
    s = Slurm("sync", {"nodes": 92, "ntasks": 4416,
                       "partition": 'skx-normal', "time": "06:00:00"})
    s.run(thecommand)


if __name__ == "__main__":
    base = get_args(sys.argv[1:])
    thedirs = get_dirs(base)
    thecommand = get_scripts(thedirs)
    submit_job(thecommand)
