include("readfiles.jl")
include("constants.jl")
include("types.jl")

function get_difference_tao(tag::String)
    tao_basedir = "/work/05880/tg851791/stampede2/model/FWEA18_smooth"
    s362ani_basedir = "/work/05880/tg851791/stampede2/specfem/20190115/tao_h_files/DATABASES_MPI"

    nproc = 336
    nspec = 4960
    tao_gll = zeros(Float64, NGLLX, NGLLY, NGLLZ, nspec, nproc)
    s362ani_gll = zeros(Float64, NGLLX, NGLLY, NGLLZ, nspec, nproc)
    dummy = zeros(Float64, NGLLX, NGLLY, NGLLZ, nspec)

    for iproc in 0:nproc - 1
        sem_io_read_gll_file_1!(tao_basedir, Int32(iproc), tag, dummy)
        tao_gll[:,:,:,:,iproc + 1] = dummy
        sem_io_read_gll_file_1!(s362ani_basedir, Int32(iproc), tag, dummy)
        s362ani_gll[:,:,:,:,iproc + 1] = dummy
    end
    return tao_gll .- s362ani_gll
end

function find_abnormal_number(tag::String)
    tao_basedir = "/work/05880/tg851791/stampede2/model/FWEA18_smooth"

    nproc = 336
    nspec = 4960
    tao_gll = zeros(Float64, NGLLX, NGLLY, NGLLZ, nspec, nproc)
    dummy = zeros(Float64, NGLLX, NGLLY, NGLLZ, nspec)

    for iproc in 0:nproc - 1
        sem_io_read_gll_file_1!(tao_basedir, Int32(iproc), tag, dummy)
        tao_gll[:,:,:,:,iproc + 1] = dummy
    end

    diff_gll = zeros(Float64, NGLLX, NGLLY, NGLLZ - 1, nspec, nproc)
    for i in 1:4
        diff_gll[:,:,i,:,:] = tao_gll[:,:,i + 1,:,:] - tao_gll[:,:,i,:,:]
    end

    thecount = 0
    for iproc in 1:nproc
        for ispec in 1:nspec
            for iglly in 1:NGLLY
                for igllx in 1:NGLLX
                    test = diff_gll[igllx,iglly,:,ispec,iproc]
                    if (count(test .>= 0) != NGLLZ - 1) && (maximum(abs.(test)) > 1) && (count(test .>= 0) != 0)
                        thecount += 1
                    end
                end
            end
        end
    end
    return thecount
end

# ibrun julia src/program/xsem_interp_mesh2.jl --nproc_old 336 --old_mesh_dir /work/05880/tg851791/stampede2/model/FWEA18_ref --old_model_dir /work/05880/tg851791/stampede2/model/FWEA18_smooth --nproc_new 441 --new_mesh_dir /work/05880/tg851791/stampede2/specfem/20190115/simulation_taoreg/DATABASES_MPI --new_model_dir /work/05880/tg851791/stampede2/specfem/20190115/simulation_taoreg/DATABASES_MPI --model_tags eta,rho,vph,vpv,vsh,vsv --output_dir /work/05880/tg851791/stampede2/model/model_interp/debug/test_me