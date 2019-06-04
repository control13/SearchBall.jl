import SearchBall, ParticleSwarmOptimizer, DelimitedFiles, Profile, ProfileView
const sb = SearchBall
const pso = ParticleSwarmOptimizer
const df = DelimitedFiles

import Random
Random.seed!(1234);

myconfig = sb.get_config(["-f", "/home/tobias/doc/SearchBall/SearchBall.jl/configs/2dlinNN.config"])
function objective(x::AbstractVector{<:Number})
    # config = sb.get_config(["-f", "/home/tobias/doc/SearchBall/SearchBall.jl/configs/2dlinNN.config"]) # TODO: needs too long
    config = sb.Config(myconfig)
    strat = sb.get_strategy(config)
    strat.init_strategies(config, x=x, issimulation=true)
    myobjective = strat.objective
    dt = 1/30
    time_accu = 0.0
    while time_accu < 50.0
        sb.update_game!(config.ws, dt, config)
        time_accu += dt
        if config.global_communication["goal"]
            sb.free!(config)
            return time_accu + myobjective(config)
        end
        if config.global_communication["antigoal"] || config.global_communication["out"]
            sb.free!(config)
            return 70.0 + myobjective(config)
        end
    end
    sb.free!(config)
    return time_accu + myobjective(config)
end

objective_obj = pso.Objective(objective, [-7.2, 7.2], 12);

number_particle = 40;
neighbours = pso.LocalNeighbourhood(number_particle);
# neighbours = pso.HierachicalNeighbourhood(number_particle, 4);
# neighbours = pso.GlobalNeighbourhood(number_particle);

optimizer = pso.PSO(objective_obj, neighbours);

pso.optimize!(optimizer, 1);
println("everthing works!")
Profile.clear_malloc_data()
# @time pso.optimize!(optimizer, 300);
pso.optimize!(optimizer, 2900);
# pso.optimize!(optimizer, 600);
# Profile.@profile pso.optimize!(optimizer, 300);
# using Juno
# Juno.profiler()

# params, score = pso.getoptimum(optimizer);
# @show params, score
# df.writedlm("run01.txt", params)

# oldparams = vec(df.readdlm("run01.txt"))
# objective(oldparams)
# @time objective(oldparams)
# Profile.clear_malloc_data()
# Profile.clear()
# Profile.@profile objective(oldparams)

# ProfileView.view(C=true)
