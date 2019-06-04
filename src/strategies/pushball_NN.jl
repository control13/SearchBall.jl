module PushballNN

import SearchBall, GeometryTypes, Chipmunk, LinearAlgebra
const sb = SearchBall
const gt = GeometryTypes
const Cp = Chipmunk
const la = LinearAlgebra

# function init_strategies(config, w=rand(2,5).*2.-1, b=rand(2).*2.-1)
function init_strategies(config; kwargs...)
    x = haskey(kwargs, :x) ? kwargs[:x] : rand(12).*2 .- 1
    issimulation = haskey(kwargs, :issimulation) ? kwargs[:issimulation] : false

    w = reshape(@view(x[1:10]), (2, 5))
    b = @view x[11:12]
    # right goal
    rightgoalbody = Cp.StaticBody()
    rightgoalbackshape = Cp.SegmentShape(rightgoalbody, Cp.Vect(9.7, 2.25), Cp.Vect(9.7, 3.75), 0.15)
    Cp.set_friction(rightgoalbackshape, 1)
    # Cp.set_collision_type(rightgoalbackshape, 2)
    Cp.add_shape(config.space, rightgoalbackshape)
    upperrightgoalshape = Cp.SegmentShape(rightgoalbody, Cp.Vect(9.0, 2.25), Cp.Vect(9.7, 2.25), 0.05)
    Cp.set_friction(upperrightgoalshape, 1)
    # Cp.set_collision_type(upperrightgoalshape, 2)
    Cp.add_shape(config.space, upperrightgoalshape)
    lowerrightgoalshape = Cp.SegmentShape(rightgoalbody, Cp.Vect(9.0, 3.75), Cp.Vect(9.7, 3.75), 0.05)
    Cp.set_friction(lowerrightgoalshape, 1)
    # Cp.set_collision_type(lowerrightgoalshape, 2)
    Cp.add_shape(config.space, lowerrightgoalshape)
    Cp.add_body(config.space, rightgoalbody)
    # rightgoalline
    rightgoallinebody = Cp.StaticBody()
    rightgoallineshape = Cp.SegmentShape(rightgoallinebody, Cp.Vect(9.1, 2.25), Cp.Vect(9.1, 3.75), 0.0)
    Cp.set_sensor(rightgoallineshape, true)
    Cp.set_collision_type(rightgoallineshape, 3)
    Cp.add_shape(config.space, rightgoallineshape)
    Cp.add_body(config.space, rightgoallinebody)

    # left goal
    leftgoal_body = Cp.StaticBody()
    leftgoalbackshape = Cp.SegmentShape(leftgoal_body, Cp.Vect(-0.7, 2.25), Cp.Vect(-0.7, 3.75), 0.15)
    Cp.set_friction(leftgoalbackshape, 1)
    # Cp.set_collision_type(leftgoalbackshape, 2)
    Cp.add_shape(config.space, leftgoalbackshape)
    upperleftgoalshape = Cp.SegmentShape(leftgoal_body, Cp.Vect(0.0, 2.25), Cp.Vect(-0.7, 2.25), 0.05)
    Cp.set_friction(upperleftgoalshape, 1)
    # Cp.set_collision_type(upperleftgoalshape, 2)
    Cp.add_shape(config.space, upperleftgoalshape)
    lowerleftgoalshape = Cp.SegmentShape(leftgoal_body, Cp.Vect(0.0, 3.75), Cp.Vect(-0.7, 3.75), 0.05)
    Cp.set_friction(lowerleftgoalshape, 1)
    # Cp.set_collision_type(lowerleftgoalshape, 2)
    Cp.add_shape(config.space, lowerleftgoalshape)
    Cp.add_body(config.space, leftgoal_body)
    # leftgoalline
    leftgoallinebody = Cp.StaticBody()
    leftgoallineshape = Cp.SegmentShape(leftgoallinebody, Cp.Vect(-0.1, 2.25), Cp.Vect(-0.1, 3.75), 0.0)
    Cp.set_sensor(leftgoallineshape, true)
    Cp.set_collision_type(leftgoallineshape, 3)
    Cp.add_shape(config.space, leftgoallineshape)
    Cp.add_body(config.space, leftgoallinebody)

    if !issimulation
        sb.show_graphic!(config, "rightgoal1", [[9.7, 2.25], [9.7, 3.75]], sb.GraphicLine(linewidth=10.0, color=[0.0, 0.0, 0.0, 1.0]))
        sb.show_graphic!(config, "rightgoal2", [[9.0, 2.25], [9.7, 2.25]], sb.GraphicLine(linewidth=10.0, color=[0.0, 0.0, 0.0, 1.0]))
        sb.show_graphic!(config, "rightgoal3", [[9.0, 3.75], [9.7, 3.75]], sb.GraphicLine(linewidth=10.0, color=[0.0, 0.0, 0.0, 1.0]))
        sb.show_graphic!(config, "leftgoal1", [[-0.7, 2.25], [-0.7, 3.75]], sb.GraphicLine(linewidth=10.0, color=[0.0, 0.0, 0.0, 1.0]))
        sb.show_graphic!(config, "leftgoal2", [[0.0, 2.25], [-0.7, 2.25]], sb.GraphicLine(linewidth=10.0, color=[0.0, 0.0, 0.0, 1.0]))
        sb.show_graphic!(config, "leftgoal3", [[0.0, 3.75], [-0.7, 3.75]], sb.GraphicLine(linewidth=10.0, color=[0.0, 0.0, 0.0, 1.0]))

        sb.init_text!(config, "score", 0.0)
        sb.init_text!(config, "goal", false)
        sb.init_text!(config, "antigoal", false)
        sb.init_text!(config, "out", false)

        # button for show vectorfield
        sb.add_check_button!(config, "show Vectorfield", "show Vectorfield") do widget
            run_strategies(config)
        end
    end

    outlinebody = Cp.StaticBody()
    upoutlineshape = Cp.SegmentShape(outlinebody, Cp.Vect(-0.1, 6.1), Cp.Vect(9.1, 6.1), 0.0)
    Cp.set_sensor(upoutlineshape, true)
    Cp.set_collision_type(upoutlineshape, 4)
    Cp.add_shape(config.space, upoutlineshape)
    lowoutlineshape = Cp.SegmentShape(outlinebody, Cp.Vect(-0.1, -0.1), Cp.Vect(9.1, -0.1), 0.0)
    Cp.set_sensor(lowoutlineshape, true)
    Cp.set_collision_type(lowoutlineshape, 4)
    Cp.add_shape(config.space, lowoutlineshape)
    Cp.add_body(config.space, outlinebody)

    goaloutlinebody = Cp.StaticBody()
    upgoaloutlineshape_left = Cp.SegmentShape(goaloutlinebody, Cp.Vect(-0.1, 6.1), Cp.Vect(-0.1, 3.75), 0.0)
    Cp.set_sensor(upgoaloutlineshape_left, true)
    Cp.set_collision_type(upgoaloutlineshape_left, 5)
    Cp.add_shape(config.space, upgoaloutlineshape_left)
    lowgoaloutlineshape_left = Cp.SegmentShape(goaloutlinebody, Cp.Vect(-0.1, 2.25), Cp.Vect(-0.1, -0.1), 0.0)
    Cp.set_sensor(lowgoaloutlineshape_left, true)
    Cp.set_collision_type(lowgoaloutlineshape_left, 5)
    Cp.add_shape(config.space, lowgoaloutlineshape_left)
    upgoaloutlineshape_right = Cp.SegmentShape(goaloutlinebody, Cp.Vect(9.1, 6.1), Cp.Vect(9.1, 3.75), 0.0)
    Cp.set_sensor(upgoaloutlineshape_right, true)
    Cp.set_collision_type(upgoaloutlineshape_right, 5)
    Cp.add_shape(config.space, upgoaloutlineshape_right)
    lowgoaloutlineshape_right = Cp.SegmentShape(goaloutlinebody, Cp.Vect(9.1, 2.25), Cp.Vect(9.1, -0.1), 0.0)
    Cp.set_sensor(lowgoaloutlineshape_right, true)
    Cp.set_collision_type(lowgoaloutlineshape_right, 5)
    Cp.add_shape(config.space, lowgoaloutlineshape_right)
    Cp.add_body(config.space, goaloutlinebody)

    function mycollisionhandler(arbiter_ptr::Ptr{Nothing}, space_ptr::Ptr{Nothing}, data_ptr::Ptr{Nothing})
        arbiter = Cp.Arbiter(arbiter_ptr)
        my_config = unsafe_pointer_to_objref(data_ptr)
        if my_config.ws.obstacles[1][1] > 9.0
            my_config.global_communication["goal"] = true
            if !my_config.global_communication["issimulation"]
                sb.show_text!(my_config, "goal", true)
            end
        elseif my_config.ws.obstacles[1][1] < 0.0
            my_config.global_communication["antigoal"] = true
            if !my_config.global_communication["issimulation"]
                sb.show_text!(my_config, "antigoal", true)
            end
        end
        return true
    end
    function ballout(arbiter_ptr::Ptr{Nothing}, space_ptr::Ptr{Nothing}, data_ptr::Ptr{Nothing})
        arbiter = Cp.Arbiter(arbiter_ptr)
        space = Cp.Space(space_ptr)
        my_config = unsafe_pointer_to_objref(data_ptr)
        my_config.global_communication["out"] = true
        if !my_config.global_communication["issimulation"]
            sb.show_text!(my_config, "out", true)
        end
        return true
    end

    Cp.cpSetCollisionHandler(config.space, 1, 3, mycollisionhandler, nothing, nothing, nothing, config)
    Cp.cpSetCollisionHandler(config.space, 1, 4, ballout, nothing, nothing, nothing, config)
    Cp.cpSetCollisionHandler(config.space, 1, 5, ballout, nothing, nothing, nothing, config)

    # @show w,b
    config.global_communication["neuralnetwork"] = (dat, pos, x, y, z, m) ->predict!(dat, pos, x, y, z, m, w, b)
    config.global_communication["goal"] = false
    config.global_communication["antigoal"] = false
    config.global_communication["out"] = false
    config.global_communication["issimulation"] = issimulation
    config.global_communication["vel"] = Vector{Float64}(undef, 2)
    config.global_communication["pos"] = Vector{Float64}(undef, 5)
    config.global_communication["matprod"] = Vector{Float64}(undef, 2)

    return
end

const goal_line = [9.1, 3.0]
function objective(config::sb.Config)
    ws = config.ws
    obs = ws.obstacles[1]
    player_ball = sb.distance(ws.myPlayers[1], obs)
    ball_goal = sb.distance(obs, goal_line)
    return player_ball + 3*ball_goal
end

function predict!(res::AbstractVector{<:Number}, pos::AbstractVector{<:Number}, pos_player::AbstractVector{<:Number}, pos_ball::AbstractVector{<:Number}, x_goal::Number, matprod::AbstractVector{<:Number}, w::AbstractMatrix{<:Number}, b::AbstractVector{<:Number})
    # pos = Vector{typeof(x_goal)}(undef, 5)
    @inbounds pos[1] = (pos_player[1] - 4.5)/9.0
    @inbounds pos[2] = (pos_player[2] - 3.0)/6.0
    @inbounds pos[3] = (pos_ball[1] - 4.5)/9.0
    @inbounds pos[4] = (pos_ball[2] - 3.0)/6.0
    @inbounds pos[5] = (x_goal - 4.5)/9.0
    la.mul!(matprod, w, pos)
    res .= tanh.(matprod .+ b).*0.22 # TODO: tooks too much memory
    return
end

function calc_myPlayers(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    pos_p = ws.myPlayers[1]
    pos_b = ws.obstacles[1]

    neuralnet! = config.global_communication["neuralnetwork"]::Function
    x_g = 9.0

    vel = config.global_communication["vel"]::Vector{Float64}
    pos = config.global_communication["pos"]::Vector{Float64}
    matprod = config.global_communication["matprod"]::Vector{Float64}
    neuralnet!(vel, pos, pos_p, pos_b, x_g, matprod)

    if !config.global_communication["issimulation"]
        score = objective(config)
        sb.show_text!(config, "score", score)
        if sb.get_manip_value(config, "show Vectorfield")
            for x in sb.raster(-config.field_size[1]/2, config.field_size[1]/2, 18), y in sb.raster(-config.field_size[2]/2, config.field_size[2]/2, 12)
                veltemp = Vector{Float64}(undef, 2)
                postemp = [x, y]
                neuralnet!(veltemp, pos, postemp, pos_b, x_g)
                sb.show_graphic!(config, "arrow"*string(x, y), [postemp, postemp.+veltemp], sb.GraphicArrow(arrowloc=1.0, color=[0.0, 0.8, 0.2, 0.6], linewidth=3.0, arrowsize=0.35))
            end
        else
            sb.remove_graphics_filter!(config) do s
                startswith(s, "arrow")
            end
        end
    end

    sb.send_order!(ws.myPlayers[1], sb.SetVelocity(vel[1], vel[2])) # TODO: tooks too many memory
    # ws.myPlayers[1]
    # vell = sqrt(vel[1]^2 + vel[2]^2)
    # vell = pythag(vel)
    # z = zero(ws.myPlayers[1].max_velocity)
    # v = clamp(vell, 0.0, ws.myPlayers[1].max_velocity)/vell
    # v = clamp(vell, 0.0, 0.3)/vell
    # sb.set_velocity!(ws.myPlayers[1], v*vel[1], v*vel[2]) # TODO: tooks too many memory

    return
end

function pythag(arr::AbstractVector{T})::T where T<:Number
    return sqrt(arr[1]^2 + arr[2]^2)
end
function calc_opponend(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    # do stuff

    return
end

function run_strategies(config::sb.Config, dt::Number=0, set_type::Symbol=:default, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    calc_myPlayers(config, dt, set_type, moved_object)
    calc_opponend(config, dt, set_type, moved_object)
    return
end

end
