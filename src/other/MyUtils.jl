module MyUtils

export subtype_tree, project

function subtype_tree_rekursive(t::Type, depth::Int = 0)
    println(string("     "^depth, "|--> ", t))
    subs = subtypes(t)
    for t in subs
        subtype_tree_rekursive(t, depth+1)
    end
end

"""
    subtype_tree(t::Type)

Show for a given type `t` the supertype in the first line,
this type in the second line and all derived types below.

# Examples

```jldoctest
julia> subtype_tree(AbstractFloat)
Real
|--> AbstractFloat
     |--> BigFloat
     |--> Float16
     |--> Float32
     |--> Float64
```
"""
function subtype_tree(t::Type)
    println(supertype(t))
    subtype_tree_rekursive(t, 0)
end

"""
    project(x::Real, x1::Real, y1::Real, x2::Real, y2::Real)

Calculate for a `x` from the range `[x1,y1]` its value in the range `[x2,y2]`.

This includes `x`s outside of the input range and reverse.
See the Examples section below.

# Examples

```jldoctest
julia> project(5.0,4.0,6.0,3.0,8.0)
5.5
julia> project(2.0,0.0,1.0,0.0,1.0)
2.0
julia> project(0.3,1.0,0.0,0.0,1.0)
0.7
```
"""
@inline function project(x::Real, x1::Real, y1::Real, x2::Real, y2::Real)
    return (x-x1)/(y1-x1)*(y2-x2)+x2
end

end
