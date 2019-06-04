import Chipmunk
const Cp = Chipmunk

abstract type Object{T} <: AbstractVector{T} end
Base.IndexStyle(::Type{<:Object}) = IndexLinear()
Base.size(p::Object) = (2,)
Base.length(p::Object) = 2
function Base.getindex(p::Object, i::Int)
    if i == 1
        return Cp.get_position(p.body).x # TODO: needs too long # TODO: tooks too many memory
    elseif i == 2
        return Cp.get_position(p.body).y # TODO: needs too long # TODO: tooks too many memory
    end
    return 0.0
end
# function Base.setindex!(p::Object, v, i::Int)
#     if i == 1
#         Cp.set_position(p.body, Cp.Vect(v, p[2]))
#     elseif i == 2
#         Cp.set_position(p.body, Cp.Vect(p[1], v))
#     end
# end
get_position(p::Object) = [Cp.get_position(p.body).x, Cp.get_position(p.body).y]
set_position!(p::Object, new_position::AbstractVector{<:Number}) = Cp.set_position(p.body, Cp.Vect(new_position...))
get_velocity(p::Object) = [Cp.get_velocity(p.body).x, Cp.get_velocity(p.body).y]
set_velocity!(p::Object, new_velocity::AbstractVector{<:Number}) = Cp.set_velocity(p.body, Cp.Vect(new_velocity...)) # TODO: tooks too many memory
set_velocity!(p::Object, new_velocity_x::Number, new_velocity_y::Number) = Cp.set_velocity(p.body, Cp.Vect(new_velocity_x, new_velocity_y)) # TODO: tooks too many memory
get_angular_velocity(p::Object) = Cp.get_angular_velocity(p.body)
get_size(p::Object) = Cp.get_radius(p.shape)
get_mass(p::Object) = Cp.get_mass(p.shape)
get_friction(p::Object) = Cp.get_friction(p.shape)

"""
    Robot

The current state of an robot.

# Arguments

position::AbstractVector - 2d Vector with the position in the plane
body_orientation::T      - angle (in radiens) relative to x axis with [-π, π], determined from `atan2`
"""
mutable struct Robot{T<:Number} <: Object{T}
    # position::AbstractVector{T}
    body_orientation::T
    head_orientation::T
    # velocity::T
    # angularvelocity::T
    # size::T
    # mass::T
    hfov::T
    max_velocity::T
    max_angularvelocity::T
    body::Cp.Body
    shape::Cp.Shape
    order::Order
end
function Robot(position::AbstractVector{T}, body_orientation::T, head_orientation::T, velocity::AbstractVector{T}, angularvelocity::T, size::T, mass::T, hfov::T, max_velocity::T, max_angularvelocity::T, order::Order) where T
    body = Cp.Body(0, 0) # TODO: KinematicBody
    shape = Cp.CircleShape(body, size, Cp.Vect(0, 0))
    Cp.set_position(body, Cp.Vect(position...))
    Cp.set_friction(shape, 0.8) #TODO: add command line argument
    Cp.set_elasticity(shape, 0) #TODO: add command line argument
    Cp.set_mass(shape, mass)
    Cp.set_collision_type(shape, 0)
    Cp.set_velocity(body, Cp.Vect(velocity...))
    Cp.set_angular_velocity(body, angularvelocity)
    Robot(body_orientation, head_orientation, hfov, max_velocity, max_angularvelocity, body, shape, order)
end
# http://doc.aldebaran.com/2-1/family/robots/index_robots.html
Robot(;position::AbstractVector{T}=[0.0, 0.0],
       body_orientation::T=0.0,
       head_orientation::T=0.0,
       velocity::AbstractVector{T}=[0.0, 0.0],
       angularvelocity::T=0.0,
       size::T=0.15,
       mass::T=5.305350006,
       hfov::T=deg2rad(60.97),
       max_velocity::T=1.0,
       max_angularvelocity::T=Float64(π/2),
       order::Order=NoOrder()) where T<:Number =
    Robot(position, body_orientation, head_orientation, velocity, angularvelocity, size, mass, hfov, max_velocity, max_angularvelocity, order)
Robot(r::Robot) = Robot(get_position(r), r.body_orientation, r.head_orientation, get_velocity(r), get_angular_velocity(r), get_size(r), get_mass(r), r.hfov, r.max_velocity, r.max_angularvelocity, r.order)

Robot(position::AbstractVector{T}, body_orientation::T) where T<:Number =
    Robot(position=position, body_orientation=body_orientation)
NaoV5(position::AbstractVector{T}, body_orientation::T) where T<:Number = Robot(position, body_orientation)
Nao(position::AbstractVector{T}, body_orientation::T) where T<:Number = NaoV5(position, body_orientation)

get_angularvelocity(r::Robot) = Cp.get_angular_velocity(r.body)

apply_order!(robot::Robot) = apply_order!(robot, robot.order)

"""
    Obstacle

The current state of an Obstacle.
"""
mutable struct Obstacle{T<:Number} <: Object{T}
    # position::AbstractVector{T}
    # velocity::T
    # size::T
    # mass::T
    max_velocity::T
    deceleration::T
    friction::T
    fixed::Bool
    body::Cp.Body
    shape::Cp.Shape
    color::AbstractVector{<:Real} # TODO: switch to Color Object
end
function Obstacle(position::AbstractVector{T}, velocity::AbstractVector{T}, size::T, mass::T, max_velocity::T, friction::T, gravity::T, fixed::Bool, color::AbstractVector{<:Real}) where T
    if fixed
        body = Cp.StaticBody()
    else
        body = Cp.Body(0, 0)
        Cp.set_velocity(body, Cp.Vect(velocity...))
    end
    Cp.set_position(body, Cp.Vect(position...))
    Cp.set_velocity(body, Cp.Vect(velocity...))
    shape = Cp.CircleShape(body, size, Cp.Vect(0, 0))
    Cp.set_friction(shape, friction) #TODO: add command line argument
    Cp.set_elasticity(shape, 1.0) #TODO: add command line argument
    Cp.set_collision_type(shape, 1)
    Cp.set_mass(shape, mass)
    Obstacle(max_velocity, friction*gravity, friction, fixed, body, shape, color)
end
Obstacle(;position::AbstractVector{T}=[0.0, 0.0],
          velocity::AbstractVector{T}=[0.0, 0.0],
          size::T=0.05,
          mass::T=0.048,
          max_velocity::T=0.25,
          friction::T=0.1,
          gravity::T=9.81,
          fixed::Bool=false,
          color::AbstractVector{<:Real}=[1.0, 0.1, 0.1, 1.0]) where T<:Number =
    Obstacle(position, velocity, size, mass, max_velocity, friction, gravity, fixed, color)
Obstacle(o::Obstacle) = Obstacle(get_position(o), get_velocity(o), get_size(o), get_mass(o), o.max_velocity, o.friction, o.deceleration/o.friction, o.fixed, o.color)
apply_order!(obstacle::Obstacle) = nothing

Ball(position::AbstractVector{T}) where T<:Number = Obstacle(position=position)

"""
    WorldState

Data clump holding all information about the game.
"""
struct WorldState{R<:AbstractVector{<:Robot{<:Number}}, O<:AbstractVector{<:Obstacle{<:Number}}}
    myPlayers::R # indices of myPlayers
    opponents::R # indices of opponents
    obstacles::O
    # time::Number
    # max_time::Number
    # v_off::Number
    # player::AbstractVector{<:Robot{<:T}}
    # all::AbstractVector{<:Object{<:T}}
end
# WorldState(myPlayers, opponents, obstacles) = WorldState(myPlayers, opponents, obstacles, vcat(myPlayers, opponents), vcat(myPlayers, opponents, obstacles))
function WorldState(ws::WorldState)
    myPlayers = Robot.(ws.myPlayers)
    opponents = Robot.(ws.opponents)
    obstacles = Obstacle.(ws.obstacles)
    return WorldState(myPlayers, opponents, obstacles)
end

# struct WorldStateIter
#     ws::WorldState
#     start::Integer

#     iterate_obstacles::Bool
#     exclude::Object
# end
