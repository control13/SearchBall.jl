import SearchBall, ParticleSwarmOptimizer, DelimitedFiles, Profile, ProfileView
const sb = SearchBall
const pso = ParticleSwarmOptimizer
const df = DelimitedFiles

import Random
Random.seed!(1234);

myconfig = sb.get_config(["-f", "/home/tobias/doc/SearchBall/SearchBall.jl/configs/2dlinNN.config"])
sb.get_strategy(myconfig).init_strategies(myconfig)
@code_warntype sb.get_strategy(myconfig).calc_myPlayers(myconfig, 0.1, :default, nothing)
@code_warntype sb.update_game!(myconfig.ws, 0.1, myconfig)
