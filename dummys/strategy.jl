module Strategy

import SearchBall, GeometryTypes
const sb = SearchBall
const gt = GeometryTypes

function init_strategies(config; kwargs...)
    # sb.init_text!(config, "distance", 0.0)
    return
end

function calc_myPlayers(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    # do stuff

    return
end

function calc_opponend(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    # do stuff

    return
end

function run_strategies(config::sb.Config, dt::Number=0, set_type::Symbol=:default, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    calc_myPlayers(config, dt, set_type, moved_object),
    calc_opponend(config, dt, set_type, moved_object)
    return
end

end
