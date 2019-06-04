import Plots, SearchBall
const sb = SearchBall
const pl = Plots

pl.gr()

function end_pos(elapsed::Number, v = 1.0, ω = π/16.0, maximumtime::Number=2π/ω)
    init = [1, 0]
    rot = elapsed*ω
    end_pos = (maximumtime - elapsed).*v .* sb.rotate2d(init, rot)
    end_pos
end

path = end_pos.(0:0.01:32)

x = getindex.(path, 1)
y = getindex.(path, 2)

pl.plot(x, y, aspect_ratio=:equal)

function spiral(θ::Number, a::Number=1, b::Number=1)
    a + b*θ
end

θ = 0:0.01:2π
pl.plot(θ, spiral.(θ, 0, 2.0), proj = :polar)

function spiral_param(φ::Number, a::Number=1)
    [a*φ*cos(φ), a*φ*sin(φ)]
end

φ = 0:0.01:2π
vals = spiral_param.(φ)
x_spiral = getindex.(vals, 1)
y_spiral = getindex.(vals, 2)
pl.plot(x_spiral, y_spiral, aspect_ratio=:equal)
