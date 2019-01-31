include("../src/utils/readfiles.jl")

function get_perterbation_1(tag::String)
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
        # @info all(tao_gll[:,:,:,:,iproc + 1] .== 0), all(s362ani_gll[:,:,:,:,iproc + 1] .== 0)
    end
    return (tao_gll .- s362ani_gll) ./ s362ani_gll
end

function plot()

end