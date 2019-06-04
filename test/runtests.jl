using Test
import SearchBall
const sb = SearchBall

@testset "SearchBall" begin

include("configuration.jl")
include("game_state.jl")
include("game_view_gtk.jl")
include("geometry_utils.jl")
include("graphics_2d.jl")
include("orders.jl")
include("strategy_utils.jl")


end
