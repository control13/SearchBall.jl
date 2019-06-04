import SearchBall, Flux, Plots
const sb = SearchBall
import Flux
const fl = Flux
const pl = Plots
pl.gr()

config = sb.get_config(["-f", "/home/tobias/doc/SearchBall/SearchBall.jl/configs/1dlinNN.config"])

x = -2:0.001:2
pl.plot(x, fl.sigmoid.(x))
pl.plot!(x, tanh.(x))

W = fl.param(rand(1, 3)) # 2.0 (tracked)
b = fl.param(rand(1)) # 3.0 (tracked)

outlayer(x::AbstractVector) = tanh.(W*x .+ b)

stupidloss(x, y) = abs(outlayer(x) .- y)

loss(config) = sb.PushballNN.objective(config)

opt = fl.SGD([W, b])

fl.train!(loss, [[config]], opt)
