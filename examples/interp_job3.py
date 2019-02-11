from slurmpy import Slurm

# * background -> background+tao/crust1.0
# Some parameters
print("start job 3")

nproc_old = 144
old_mesh_dir = "/work/05880/tg851791/stampede2/specfem/20190115/min_h_files/DATABASES_MPI"
old_model_dir = "/scratch/05880/tg851791/binfile/perturbation/min_perturbation"
nproc_new = 441
new_mesh_dir = "/work/05880/tg851791/stampede2/specfem/20190115/simulation_taoreg/DATABASES_MPI"
new_model_dir = "/scratch/05880/tg851791/binfile/perturbation/background_perturbation"
model_tags = ",".join(["vph", "vpv", "vsh", "vsv", "eta", "qmu", "rho"])
output_dir = "/scratch/05880/tg851791/binfile/interp/s362ani_addmin-pert"

command3 = f"ibrun julia src/program/xsem_interp_mesh2.jl --nproc_old {nproc_old} --old_mesh_dir {old_mesh_dir} --old_model_dir {old_model_dir} --nproc_new {nproc_new} --new_mesh_dir {new_mesh_dir} --new_model_dir {new_model_dir} --model_tags {model_tags} --output_dir {output_dir}"
s3 = Slurm("bg+tao", {"partition": "skx-normal",
                      "nodes": 10, "ntasks": 441, "time": "00:60:00"})
jobid_s3 = s3.run(command3)
