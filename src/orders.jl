abstract type Order end

struct GoToAbsPosition{T<:AbstractVector{<:Number}} <: Order
    position::T
    GoToAbsPosition(position::T) where T<:AbstractVector{<:Number} = length(position) != 2 ? error("Position must be a 2d vector.") : new{T}(position)
end

struct RotateBodyBy <: Order
    angle::Number
end

struct RotateHeadBy <: Order
    angle::Number
end

struct SetVelocity{T<:Number} <: Order
    x::T
    y::T
end
Base.eltype(::SetVelocity{T}) where T = T

struct NoOrder <: Order
end
