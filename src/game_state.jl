import GeometryTypes, Chipmunk, LinearAlgebra
const gt = GeometryTypes
const Cp = Chipmunk
const la = LinearAlgebra

"""
    physic(ws::WorldState, what::Symbol, index::Int,
        new_pos::AbstractVector{<:AbstractFloat})

Handle physic. Objects can't overlapp.

returns the adjusted position.

# ToDo
- maybe: prevent from leaving the field? - No, thats not physic
- currently object can go through objects if the they are not touching each
  other at the new position
- handle collisions
- trigger ball movements
- replace by an physic engine (maybe https://github.com/klowrey/MuJoCo.jl)
"""
function physic(ws::WorldState, player::Object{<:Number}, new_pos::AbstractVector{<:Number})
    # initialization

    current_player = gt.Circle(gt.Point2(new_pos), get_size(player))

    other_player = [gt.Circle(gt.Point2(ps), get_size(ps)) for ps in vcat(ws.myPlayers, ws.opponents, ws.obstacles) if ps!=player]

    # handling
    touching_player = map(x -> is_touching(current_player, x), other_player)
    if !any(touching_player)
        return new_pos
    elseif sum(touching_player) == 1
        # REMINDER: at least two robots are touching - handle collisions here
        touchers = other_player[touching_player]
        toucher = touchers[1]
        return toucher.center .+ la.normalize(vector(toucher.center, new_pos)).*(toucher.r + current_player.r)
    elseif sum(touching_player) == 2
        touchers = other_player[touching_player]
        t1, t2 = touchers[1:2]
        t12 = vector(t1.center, t2.center)./2
        t12_n = normal2d(t12)
        d = t1.center'*t12_n
        if new_pos'*t12_n - d <= 0
            t12_n .*= -1
        end
        return t1.center .+ t12 .+ la.normalize(t12_n).*sqrt(4*max(t1.r, t2.r)^2 - distance(t1.center, t2.center)^2/4)
    else
        @warn "physic - There are more than 2 ($(other_player[touching_player])) obstacles touching a player at new position $(new_pos)"
    end
    return new_pos
end

"""
    update_game!(ws::WorldState, dt::Number, config::Config)

Update procedure for the world `ws` after the time `dt`.
"""
function update_game!(ws::WorldState, dt::Number, config::Config)

    # for player in vcat(ws.myPlayers::Vector{Robot{Float64}}, ws.opponents::Vector{Robot{Float64}})::Vector{Robot{Float64}} # TODO: tooks too many memory
    #     apply_order!(player)
    # end
    for myPlayer in ws.myPlayers::Vector{Robot{Float64}}
        apply_order!(myPlayer)
    end
    for opponent in ws.opponents::Vector{Robot{Float64}}
        apply_order!(opponent)
    end
    # apply_order!.(ws.myPlayers)
    # apply_order!.(ws.opponents)
    Cp.step(config.space, dt)
    get_strategy(config).run_strategies(config, dt, :step)
    return
end

# function physic_step(config::Config, dt::Number)
#     Cp.step(config.space, dt)
#     return
# end

"""
    getvalid_playerpos(config::Config)

Searches for a position for a new player to be inserted in the arena.
"""
function getvalid_playerpos(config::Config, player_size::Number)
    start_pos = [player_size - config.field_size[1]/2, config.field_size[2]/2 - player_size]
    while any([distance(start_pos, pos) <= 2*player_size for pos in vcat(config.ws.myPlayers, config.ws.opponents, config.ws.obstacles)])
        start_pos[1] += 3*player_size
    end
    start_pos
end

"""
    add_myPlayer!(config::Config)

Adds an player (myPlayer) with default values to the arena.
"""
function add_myPlayer!(config::Config)
    new_robot = Robot(getvalid_playerpos(config, get_size(NaoV5([0.0, 0.0], 0.0))), 0.0)
    add_object!(config, new_robot)
    push!(config.ws.myPlayers, new_robot) # HACK: adds a NaoV5
    # config.ws.all = vcat(config.ws.myPlayers,config.ws.opponents,config.ws.obstacles)
    # config.ws.player = vcat(config.ws.myPlayers, config.ws.opponents)
end

"""
    add_opponent!(config::Config)

Adds an player (opponent) with default values to the arena.
"""
function add_opponent!(config::Config)
    new_robot = Robot(getvalid_playerpos(config, get_size(NaoV5([0.0, 0.0], 0.0))), Float64(π))
    add_object!(config, new_robot)
    push!(config.ws.opponents, new_robot)  # HACK: adds a NaoV5
    # config.ws.all = vcat(config.ws.myPlayers,config.ws.opponents,config.ws.obstacles)
    # config.ws.player = vcat(config.ws.myPlayers, config.ws.opponents)
end
