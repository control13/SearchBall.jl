# include("src/other/MyUtils.jl")

using GeometryTypes, Plots, JLD, Printf
plotlyjs()
# gr()

"""
robot lies in (0,0,0)
0 Rad -> orientation in positive x direction
"""
v = 200.0
ω = π/16.0
function duration(x::Number, y::Number, start::Tuple{<:Number, <:Number, <:Number}=(0.0, 0.0, 0.0); velocitiy::Number=v, angular_velocity::Number=ω)
    (xi, yi, ai) = start
    a = mod(atan(x-xi, y-yi) - ai + π, 2π) - π
    sqrt((x-xi)^2 + (y-yi)^2)/velocitiy + abs(a)/angular_velocity
end

xs = -500:500
ys = -500:500
hmap1 = zeros(Float64, length(xs), length(ys))
hmap2 = zeros(Float64, length(xs), length(ys))
hmap3 = zeros(Float64, length(xs), length(ys))

init1 = (250, 0, -π/2.0)
init2 = (-250, 0, π/2.0)
for (ix, x) in enumerate(xs), (iy, y) in enumerate(ys)
    hmap1[iy, ix] = duration(x, y, init1)
    hmap2[iy, ix] = duration(x, y, init2)
    hmap3[iy, ix] = hmap1[iy, ix] < hmap2[iy, ix] ? 0.0 : 1.0
end

hmap1[3.5.<hmap1.<3.6] .= maximum(hmap1)
hmap2[3.5.<hmap2.<3.6] .= maximum(hmap2)
heatmap(hmap1, color=:ice_r, aspect_ratio=:equal, title=@sprintf("v=%.1fm/s ω=%.0f°/s", v/100.0, rad2deg(ω)))
heatmap(hmap2, color=:ice_r, aspect_ratio=:equal, title=@sprintf("v=%.1fm/s ω=%.0f°/s", v/100.0, rad2deg(ω)))
heatmap(hmap3, color=:ice, aspect_ratio=:equal, title=@sprintf("v=%.1fm/s ω=%.0f°/s", v/100.0, rad2deg(ω)))

# hmap3 = zeros(Float64, length(xs), length(ys))

hmapWinner = fill(0.5, length(xs), length(ys))
start_1 = init1[1:2].+501
start_2 = init2[1:2].+501
hmapWinner[start_1...] = 0.0
hmapWinner[start_2...] = 1.0

function all_coordinates_on_line(my_pos::Tuple{Int, Int}, init_pos::Tuple{Int, Int})

end

function is_neighbour(coordinate::Tuple{Int, Int}, init_pos::Tuple{Int, Int}, winner_val::Float64, xmax::Int=1000, ymax::Int=1000)
    x, y = coordinate
    if !(0 < x ≤ xmax) || !(0 < y ≤ ymax)
        return false
    end
    if hmapWinner[coordinate...] ∈ [0.0, 1.0] # is visited
        return false
    end
    # straight line to the initial - belong all cells to me?
    return true
end

function neighbourhood(coordinate::Tuple{Int, Int})
    x, y = coordinate
    [(x+1, y+1),(x, y+1),(x+1, y),(x+1, y-1),
     (x-1, y-1),(x, y-1),(x-1, y),(x-1, y+1)]
end

get_neighbours(coordinate::Tuple{Int, Int}, current_neigs::AbstractVector{<:Tuple{Int, Int}}=Tuple{Int, Int}[]) = [neig for neig in neighbourhood(coordinate) if is_neighbour(neig) && neig ∉ current_neigs]

hmap1_flat = reshape(hmap1, :)
hmap2_flat = reshape(hmap2, :)
append!(hmap1_flat, hmap2_flat)
timeline = sort(unique(hmap1_flat))

function update_winner!(negs, hmapWinner, t::Float64, hmap, winner_val::Float64)
    min_index = reduce((x,y)-> hmap[x...] < hmap[y...] ? x : y, negs)
    if hmap[min_index...] > t
        return
    end
    filter!(e -> e!=min_index, negs)
    hmapWinner[min_index...] = winner_val
    append!(negs, get_neighbours(min_index, negs))
end

neigs_1 = get_neighbours(start_1)
neigs_2 = get_neighbours(start_2)
@time for t in timeline
    !isempty(neigs_1) && update_winner!(neigs_1, hmapWinner, t, hmap1, 0.0)
    !isempty(neigs_2) && update_winner!(neigs_2, hmapWinner, t, hmap2, 1.0)
end

heatmap(hmapWinner, color=:ice, aspect_ratio=:equal, title=@sprintf("v=%.1fm/s ω=%.0f°/s", v/100.0, rad2deg(ω)))
