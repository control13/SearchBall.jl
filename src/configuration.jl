using ArgParse
import Reactive, GeometryTypes, Chipmunk, LinearAlgebra
const re = Reactive
const gt = GeometryTypes
const Cp = Chipmunk
const la = LinearAlgebra

"""
    Config

Saves all data, that is need through the whole programm. Will be initialized at
startup.
"""
mutable struct Config{WS<:WorldState, T<:Number}
    ws::WS
    """
    Field:

    Rectangular, (0,0) is lower left corner
    (9,6) is the right upper corner
    all in meters
    """
    field_size::Vector{T}
    field_corners::Vector{<:gt.Point2{T}}
    active_strategy::String
    strategies_table::Dict{String, Module}
    maximum_player_per_side::Int
    space::Cp.Space
    # set_progress_bar::Function
"""
    printables

For values that shall be visible in the gui. The name will be a first label and the value will be second label, as a signal. If it changes, the value in the second label will also be updated.
"""
    printables::Dict{String, re.Signal}

"""
    drawables

A dictionary for drawing something on tha canvas in the gui (where the field is displayed).
The name uses the folling conventions for the drawing:
- if the name beginns with '_' it will be drawn befor anything on the field is drawn and it will be assumed, that it is an image (matrix), the position is the top left corner and the botel right corner
- in all other cases it must be a element from Graphics2D, as function, that recives the first argument (the position). In the gui the posiiton will be transformed from world coordinates to screen coordinates
"""
    drawables::Dict{String, <:Tuple{<:AbstractVector{<:AbstractVector{<:Real}}, Function}} # the tuples saves the coordinate in the first place and a drawable function in the second

"""
    manipulators

Saves Gtk gui-elements. The name will be printed in a label above the elemente.
Name conventions:
- if the name starts with a D: instead of a widget as the element a tuple with a widget and a function is assumed. The function will be added as "button-pressed" event of the widget and after the execution of the function, the canvas will be redrawn.
- if the name starts with DN: the same as D, but the widget will not be shown in the widget area
- if the widget is a Gtk.GtkRadioButtonGroupLeaf and the are less than two RadioButtons in it, it will not be shown
- all others are names+widgets and the widget will be shown
"""
    manipulators::Dict{String, <:Tuple}

    global_communication::Dict{String, Any}
end
Config(ws::WorldState, field_size::Vector{<:AbstractFloat},
    field_corners::Vector{<:gt.Point2{<:Number}},
    active_strategy::String, space::Cp.Space) = Config(ws, field_size, field_corners,
    active_strategy, Dict{String, Module}(), 6, space,
    Dict{String, re.Signal}(),
    Dict{String, Tuple{Vector{Vector{Float64}}, Function}}(),
    Dict{String, Tuple}(),
    Dict{String, Any}())
function Config(config::Config)
    ws = WorldState(config.ws)
    space = createspace(ws)

    config = Config(ws, config.field_size, config.field_corners, config.active_strategy, space)

    setstrategies!(config)

    config
end

"""
    ArgParse.parse_item(::Type{Robot{Float64}}, x::AbstractString)

A Robot has its own Arguments. A string `x` containing the arguments are parsed to a `Robot` object.
"""
function ArgParse.parse_item(::Type{Robot{Float64}}, x::AbstractString)
    vec = [substring for substring in split(x[2:end-1], [' ']) if substring != ""]
    default = Nao([0.0, 0.0], 0.0)
    s = ArgParseSettings(commands_are_required = false)
    @add_arg_table s begin
        "--position"
            required = true
            help = "Position in world coordinate system (metric)."
            # range_tester = x -> x > 0
            nargs = 2
            arg_type = Float64
        "--body_orientation"
            help = "Robot orientation relative to the x-axis in rad."
            range_tester = x -> -π ≤ x ≤ π
            arg_type = Float64
            default = default.body_orientation
        "--head_orientation"
            help = "Head orientation relative to the `body_orientation` in rad."
            range_tester = x -> deg2rad(-119.5) ≤ x ≤ deg2rad(119.5)
            arg_type = Float64
            default = default.head_orientation
        "--velocity"
            help = "The current velocity of the robot in m/s."
            # range_tester = x -> -π ≤ x ≤ π
            nargs = 2
            arg_type = Float64
            default = get_velocity(default)
        "--angularvelocity"
            help = "The current angular velocity of the robot rad/s."
            # range_tester = x -> x ≥ 0
            arg_type = Float64
            default = get_angularvelocity(default)
        "--size"
            help = "Robot size in m."
            range_tester = x -> x > 0
            arg_type = Float64
            default = get_size(default)
        "--mass"
            help = "Robot mass in kg."
            range_tester = x -> x ≥ 0
            arg_type = Float64
            default = get_mass(default)
        "--hfov"
            help = "Horizontal field of view in rad."
            range_tester = x -> x ≤ 2π
            arg_type = Float64
            default = default.hfov
        "--max_velocity"
            help = "The maximum velocity of the robot in m/s."
            range_tester = x -> x ≥ 0
            arg_type = Float64
            default = default.max_velocity
        "--max_angularvelocity"
            help = "The maximum angular velocity of the robot in rad/s."
            range_tester = x -> x ≥ 0
            arg_type = Float64
            default = default.max_angularvelocity
        # "--shape"
        #     help = "Shape of the robot."
        #     arg_type = Symbol
        #     default = default.shape
    end
    res = parse_args(vec, s, as_symbols=true)
    val = Robot(;res...)
    return val
end

"""
    ArgParse.parse_item(::Type{Obstacle{Float64}}, x::AbstractString)

A Robot has its own Arguments. A string `x` containing the arguments are parsed to a `Robot` object.
"""
function ArgParse.parse_item(::Type{Obstacle{Float64}}, x::AbstractString)
    vec = [substring for substring in split(x[2:end-1], [' ']) if substring != ""]
    default = Ball([0.0, 0.0])
    s = ArgParseSettings(commands_are_required = false)
    @add_arg_table s begin
        "--position"
            required = true
            help = "Position in world coordinate system (metric)."
            # range_tester = x -> x > 0
            nargs = 2
            arg_type = Float64
        "--velocity"
            help = "The current velocity of the robot in m/s."
            # range_tester = x -> -π ≤ x ≤ π
            nargs = 2
            arg_type = Float64
            default = get_velocity(default)
        "--size"
            help = "Obstacle size in m."
            range_tester = x -> x > 0
            arg_type = Float64
            default = get_size(default)
        "--mass"
            help = "Obstacle mass in kg."
            range_tester = x -> x ≥ 0
            arg_type = Float64
            default = get_mass(default)
        "--max_velocity"
            help = "The maximum velocity of the robot in m/s."
            range_tester = x -> x ≥ 0
            arg_type = Float64
            default = default.max_velocity
        "--friction"
            help = "Friction depending on the ground."
            range_tester = x -> x ≥ 0
            arg_type = Float64
            default = get_friction(default)
        "--fixed"
            help = "If the obstacle can't be moved."
            nargs = 0
            action = :store_true
        # "--shape"
        #     help = "Shape of the robot. Allowed is circle, poly, box and segment.0"
        #     arg_type = Symbol
        #     default = default.shape
        "--color"
            help = "Color of the object."
            range_tester = x -> 0 ≤ x ≤ 1
            nargs = 4
            arg_type = Float64
            default = default.color
    end
    res = parse_args(vec, s, as_symbols=true)
    val = Obstacle(;res...)
    return val
end


"""
    parse_commandline(args::AbstractVector{<:AbstractString})

Parses a string to a list with all command line arguments. If the command line
argument --file is given, the file at this location is parsed with this
function. All other command line arguments in the first place are rejected.
"""
function parse_commandline(args::AbstractVector{<:AbstractString})
    s = ArgParseSettings(commands_are_required = false)

    @add_arg_table s begin
        "--field_size"
            help = "Defines the width and height of the field in meters."
            nargs = 2
            arg_type = Float64
            default = [9.0, 6.0]
        "--add_obstacle"
            help = "Add as many obstacles as you want."
            action = :append_arg
            arg_type = Obstacle{Float64}
            default = Obstacle[]
        "--add_myPlayer", "-p"
            help = "Add as many myPlayers as you want."
            action = :append_arg
            arg_type = Robot{Float64}
            default = Robot[]
        "--add_opponent", "-o"
            help = "Add as many opponents as you want."
            action = :append_arg
            arg_type = Robot{Float64}
            default = Robot[]
        "--gravity"
            help = "Gravity for your location. Default should match for the most areas on earth."
            # range_tester = x -> x ≥ 0
            arg_type = Float64
            default = 9.81
        "--strategy", "-s"
            help = "The strategy, which shall be used."
            arg_type = String
            default = "ShowShadow"
        "--file", "-f"
            help = "Path to a file with all parameters."
            arg_type = String
    end
    arguments = parse_args(args, s)
    if haskey(arguments, "file") && arguments["file"] != nothing
        arguments = parse_args(collect(eachline(open(arguments["file"]))), s)
    end
    return arguments
end

function createspace(ws::WorldState)
    space = Cp.Space()

    for object in vcat(ws.myPlayers, ws.opponents, ws.obstacles)
        Cp.set_userdata(object.body, pointer_from_objref(object))
        Cp.add_body(space, object.body)
        Cp.add_shape(space, object.shape)
    end

    # Cp.set_damping(space, 0.1)

    for player in ws.myPlayers
        Cp.set_velocity_update_func(player.body, (b, g, d, t) -> nothing)
    end
    for obs in ws.obstacles

        # μr = get_friction(obs)
        # g = arguments["gravity"]

        function ball_linear_drag(body_ptr::Ptr{Nothing}, gravity::Cp.Vect, damping::Cdouble, dt::Cdouble) # TODO: needs too long
        # // Skip kinematic bodies.
        # if(cpBodyGetType(body) == CP_BODY_TYPE_KINEMATIC) return;
            # deceleration = 0.09
            body = Cp.Body(body_ptr) # TODO: tooks way too much memory
            # ud = unsafe_pointer_to_objref(Cp.get_userdata(body))
            # μr = get_friction(ud)
            # g = 9.81
            current_vel_vect = Cp.get_velocity(body)
            # current_vel = [current_vel_vect.x, current_vel_vect.y]
            cur_vel_len = sqrt(current_vel_vect.x^2 + current_vel_vect.y^2)
            mul(x::T, y::T) where T<:Number = x*y
            vel_len = cur_vel_len - mul(9.81, dt)
            new_vel_x = vel_len > 0 ? current_vel_vect.x/cur_vel_len*vel_len : 0.0
            new_vel_y = vel_len > 0 ? current_vel_vect.y/cur_vel_len*vel_len : 0.0
            Cp.set_velocity(body, Cp.Vect(new_vel_x, new_vel_y))
            return nothing
        end

        Cp.set_velocity_update_func(obs.body, ball_linear_drag)

    end

    return space
end

function setstrategies!(config::Config)
    config.strategies_table["CompareShadow"] = CompareShadow
    config.strategies_table["ShowShadow"] = ShowShadow
    config.strategies_table["TestStrategy"] = TestStrategy
    config.strategies_table["GlobalComShadow"] = GlobalComShadow
    config.strategies_table["GrowingRegions"] = GrowingRegions
    # config.strategies_table["BaMichelle"] = BaMichelle
    # config.strategies_table["BaJakob"] = BaJakob
    config.strategies_table["BaNicolas"] = BaNicolas
    config.strategies_table["StartPositions01"] = StartPositions01
    config.strategies_table["PushballNN"] = PushballNN
end

"""
    get_config(args::AbstractVector{<:AbstractString})

Wraps the parse_commandline function and creates a `config` from the command
line list.
"""
function get_config(args::AbstractVector{<:AbstractString})
    arguments = parse_commandline(args) #String["--file", config_file_path]

    player = vcat(arguments["add_myPlayer"], arguments["add_opponent"])
    for i in 1:length(player), j in i+1:length(player)
        if distance(player[i], player[j]) < get_size(player[i]) + get_size(player[j]) # HACK: asumes circles
            a, b = player[i], player[j]
            error("Player on position $a and $b are too close.")
        end
    end

    field_size = arguments["field_size"]
    field_corners = [gt.Point2(-field_size[1]/2, -field_size[2]/2), gt.Point2(field_size[1]/2, -field_size[2]/2),
        gt.Point2(field_size[1]/2, field_size[2]/2), gt.Point2(-field_size[1]/2, field_size[2]/2)]
    ws = WorldState(arguments["add_myPlayer"], arguments["add_opponent"],
        arguments["add_obstacle"])
    active_strategy = arguments["strategy"]

    space = createspace(ws)

    config = Config(ws, field_size, field_corners, active_strategy, space)

    setstrategies!(config)

    config
end

function add_object!(config::Config, object::Object)
    Cp.set_userdata(object.body, pointer_from_objref(object))
    Cp.add_body(config.space, object.body)
    Cp.add_shape(config.space, object.shape)
end
function remove_object!(config::Config, object::Object)
    Cp.remove_body(config.space, object.body)
    Cp.remove_shape(config.space, object.shape)
end

"""
    get_strategy(config::Config)

Wrapper for easier access of the current strategy run function in the config.
"""
function get_strategy(config::Config)
    config.strategies_table[config.active_strategy]
end

function free!(config::Config)
    for obj in vcat(config.ws.myPlayers, config.ws.opponents, config.ws.obstacles)
        Cp.free(obj.shape)
        Cp.free(obj.body)
    end
    Cp.free(config.space)
    return
end
