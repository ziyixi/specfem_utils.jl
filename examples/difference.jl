include("../src/utils/readfiles.jl")

function get_difference_1(tag::String)
    me_basedir = "/work/05880/tg851791/stampede2/model/model_interp/debug/test_me"
    s362ani_basedir = "/work/05880/tg851791/stampede2/specfem/20190115/tao_h_files/DATABASES_MPI"

    nproc = 336
    nspec = 4960
    me_gll = zeros(Float64, NGLLX, NGLLY, NGLLZ, nspec, nproc)
    s362ani_gll = zeros(Float64, NGLLX, NGLLY, NGLLZ, nspec, nproc)
    dummy = zeros(Float64, NGLLX, NGLLY, NGLLZ, nspec)

    for iproc in 0:nproc - 1
        sem_io_read_gll_file_1!(me_basedir, iproc, tag, dummy)
        me_gll[:,:,:,:,iproc + 1] = dummy
        sem_io_read_gll_file_1!(s362ani_basedir, iproc, tag, dummy)
        s362ani_gll[:,:,:,:,iproc + 1] = dummy
        # @info all(tao_gll[:,:,:,:,iproc + 1] .== 0), all(s362ani_gll[:,:,:,:,iproc + 1] .== 0)
    end
    return s362ani_gll - me_gll
end
