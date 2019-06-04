addprocs(4)
@everywhere include("src/SearchBall.jl")
include("src/other/MyUtils.jl")

using GeometryTypes, Plots, MyUtils, Statistics
plotly()
sb = SearchBall

const dims = 2

# ws = sb.WorldState([[4.5, 3.0]], [[1.0, 1.0], [5.0, 8.0]], [-1.0, -1.0])
ws(myPlayers) = sb.WorldState([[-1.0, -1.0]], myPlayers, [-1.0, -1.0])
res = [90, 60]
n_opps = 5
runs = 10000
fields = SharedMatrix{Float64}[]

# TODO: parallelisieren
@time for r in 1:runs

    new_pos = rand(n_opps, dims)
    @inbounds new_pos[:, 1] .= project.(new_pos[:, 1], 0.0, 1.0, 0.0, 9.0)
    @inbounds new_pos[:, 2] .= project.(new_pos[:, 2], 0.0, 1.0, 0.0, 6.0)

    # TODO: move player away, if they are to close

    field_corners = [Point2(0.0, 0.0), Point2(9.0, 0.0), Point2(9.0, 6.0), Point2(0.0, 6.0)]
    scalar_field, insides = sb.sample(ws([@view(new_pos[i, :]) for i in 1:n_opps]), 1, field_corners, resolution=res) # FIXME: needs config instead of ws
    @inbounds mean_val = median(scalar_field[insides])
    @inbounds scalar_field[.!insides] = mean_val

    push!(fields, scalar_field)
end

scalar_field = mean(fields)'

using JLD
save(string("r", runs,"opps", n_opps,"_", res[1], "x", res[2], ".jld"), "scalar_field", scalar_field)
heatmap(scalar_field, color=:inferno_r, aspect_ratio=:equal)
