using Interact, Distributed
import Plots, Printf, SearchBall
const pl = Plots
const pr = Printf
const sb = SearchBall

pl.gr()
addprocs(8)
@everywhere using SharedArrays

"""
robot lies in (0,0,0)
0 Rad -> orientation in positive x direction
"""
const v = 200.0
const ω = π/16.0
@everywhere function duration(x::Number, y::Number, start::Tuple{<:Number, <:Number, <:Number}=(0.0, 0.0, 0.0); velocity::Number=v, angular_velocity::Number=ω)
    (xi, yi, ai) = start
    a = mod(atan(y-yi, x-xi) - ai + π, 2π) - π
    sqrt((x-xi)^2 + (y-yi)^2)/velocity + abs(a)/angular_velocity
end

@everywhere const xs = -200:200
@everywhere const ys = -200:200
const maxxs = maximum(xs)
const maxys = maximum(ys)
const hmap1 = SharedArray(zeros(Float64, length(xs), length(ys)))
const hmap2 = SharedArray(zeros(Float64, length(xs), length(ys)))
const hmap3 = SharedArray(zeros(Float64, length(xs), length(ys)))

const init1 = (-100, 0, -π/2.0)
const init2 = (100, 0, π/2.0)

function calc_area!(hmap1, hmap2, hmap3, init1, init2, v=v, ω=ω)
    @inbounds @sync @distributed for ix in 1:length(xs)
        for iy in 1:length(ys)
            x = xs[ix]
            y = ys[iy]
            hmap1[iy, ix] = duration(x, y, init1, velocity=v, angular_velocity=ω)
            hmap2[iy, ix] = duration(x, y, init2, velocity=v, angular_velocity=ω)
            hmap3[iy, ix] = hmap1[iy, ix] < hmap2[iy, ix] ? 0.0 : 1.0
        end
    end
    # hmap1[3.5.<hmap1.<3.6] .= maximum(hmap1)
    # hmap2[3.5.<hmap2.<3.6] .= maximum(hmap2)
    return
end

pl.heatmap(hmap1, color=:ice_r, aspect_ratio=:equal, title=pr.@sprintf("v=%.1fm/s ω=%.0f°/s", v/100.0, rad2deg(ω)))
pl.heatmap(hmap2, color=:ice_r, aspect_ratio=:equal, title=pr.@sprintf("v=%.1fm/s ω=%.0f°/s", v/100.0, rad2deg(ω)))
pl.heatmap(hmap3, color=:ice, aspect_ratio=:equal, title=pr.@sprintf("v=%.1fm/s ω=%.0f°/s", v/100.0, rad2deg(ω)))

const mx = [maxxs, maxxs]
const my = [maxys, maxys]
const i11 = [init1[1], init1[1]]
const i12 = [init1[2], init1[2]]
const i21 = [init2[1], init2[1]]
const i22 = [init2[2], init2[2]]
ui = @manipulate for angle_red in -π:π/32:π, angle_blue in -π:π/32:π, vel in 1:400, ang in π/32:π/32:2π, show_field in [:voronoi, :red_player, :blue_player]
    calc_area!(hmap1, hmap2, hmap3, (init1[1], init1[2], angle_red), (init2[1], init2[2], angle_blue), vel, ang)
    if show_field == :voronoi
        myplot = pl.heatmap(hmap3, color=:ice, aspect_ratio=:equal, title=pr.@sprintf("v=%.1fm/s ω=%.0f°/s", vel/100.0, rad2deg(ang)), colorbar=false)
        # myplot = pl.plot(colorview(Gray, hmap3), aspect_ratio=:equal, title=pr.@sprintf("v=%.1fm/s ω=%.0f°/s", vel/100.0, rad2deg(ang)))
        dir1 = sb.rotate2d([30.0, 0.0], angle_red)
        pl.plot!(myplot, [0.0, dir1[1]] .+ mx .+ i11, [0.0, dir1[2]] .+ my .+ i12, lw=3, legend=false, color=:red)
        # pl.scatter!(myplot, init1[1], init1[2], lw=8, col=:white)
        dir2 = sb.rotate2d([30.0, 0.0], angle_blue)
        pl.plot!(myplot, [0.0, dir2[1]] .+ mx .+ i21, [0.0, dir2[2]] .+ my .+ i22, lw=3, legend=false, color=:blue)
        # pl.scatter!(myplot, init2[1], init2[2], lw=8, col=:black)
    elseif show_field == :red_player
        pl.heatmap(hmap1, color=:ice, aspect_ratio=:equal)
    elseif show_field == :blue_player
        pl.heatmap(hmap2, color=:ice, aspect_ratio=:equal)
    end
end
