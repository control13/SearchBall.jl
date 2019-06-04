import GeometryTypes, Clipper, LinearAlgebra
const gt = GeometryTypes
const cl = Clipper
const la = LinearAlgebra

"""
    rotate2d _left90(vec::AbstractVector{<:Number})

Rotate a 2d vector `vec` by 90 degree anticlockwise.

# Examples

```jldoctest
julia> rotate2d_left90([1, 0])
2-element Array{Int64,1}:
0
1
```
"""
@inline function rotate2d_left90(vec::AbstractVector{<:Number})
    @assert length(vec)==2 "Only for vectors with length 2!"
    @inbounds return [-vec[2], vec[1]]
end


"""
    rotate2d(vec::AbstractVector{<:Number})

Rotates a vector by an arbitrary angle in counter clockwise direction.

# Examples

```jldoctest
julia> rotate2d([1, 0], 3π/2)
0
-1
```
"""
@inline function rotate2d(vec::AbstractVector{<:Number}, a::Number)
    @assert length(vec)==2 "Only for vectors with length 2!"
    [cos(a) -sin(a); sin(a) cos(a)]*vec
end

"""
    normal2d(vec::AbstractVector{<:Number})

Get the normal of a 2d vector. Results in a rotation 90 degree left.

# Examples

```jldoctest
julia> normal2d([1, 0])
2-element Array{Int64,1}:
0
1
```
"""
@inline normal2d(vec::AbstractVector{<:Number}) = rotate2d_left90(vec)

"""
    vector(a::AbstractVector{<:Number}, b::AbstractVector{<:Number})

Get a vector that points from the point `a` to the tip of `b`.

# Examples

```jldoctest
julia> vector([2, 1], [2,2])
2-element Array{Int64,1}:
0
1
```
"""
@inline vector(a::AbstractVector{<:Number}, b::AbstractVector{<:Number}) = b .- a

"""
    distance(x::AbstractVector{<:Number}, y::AbstractVector{<:Number})

Return the eucledian distance between two vectors `x` and `y`.

# Examples

```jldoctest
julia> distance([1, 2], [2, 1])
1.4142135623730951
```
"""
@inline function distance(x::AbstractVector{T1}, y::AbstractVector{T2}) where {T1 <: Number, T2<:Number}
    # sqrt(sum((x.-y).^2))
    s = zero(promote_type(T1, T2))
    for i in eachindex(x)
        s += (x[i] - y[i])^2
    end
    return sqrt(s)
end

"""
    contained(c1::gt.HyperSphere{N, <:Number}, c2::gt.HyperSphere{N, <:Number}) where {N}

Check if a circle c1 is fully inside of c2.

# Examples

```jldoctest
julia> contained(gt.Circle(gt.Point2(1, 1), 1), gt.Circle(gt.Point2(5, 5), 1))
false
```
"""
@inline function contained(c1::gt.HyperSphere{N, <:Number}, c2::gt.HyperSphere{N, <:Number}) where {N}
    min_r = c2.r - distance(c1.center, c2.center)
    min_r >= 0 && c1.r <= min_r
end

"""
    outer_tangent(c1::gt.Circle{<:Number}, c2::gt.Circle{<:Number}, inverse::Bool=false)

Compute the one outer tangents on two circles. The second one can calculated
with exchanged inputarguments.

# Optional Arguments

- `inverse::Bool=false`: set to `true` if the first and second point in the output gt.LineSegment should be swapped.

# Examples

```jldoctest
julia> outer_tangent(gt.Circle(gt.Point2(0.5, 0.5), 1.5), gt.Circle(Point(5.5, -0.5), 2.0))
2-element GeometryTypes.Simplex{2,GeometryTypes.Point{2,Float64}}:
[0.648526, 1.99263]
[5.69803, 1.49017]
```jldoctest
julia> outer_tangent(gt.Circle(Point(5.5, -0.5), 2.0), gt.Circle(gt.Point2(0.5, 0.5), 1.5))
2-element GeometryTypes.Simplex{2,GeometryTypes.Point{2,Float64}}:
[4.91735, -2.41325]
[0.0630127, -0.934936]
```
"""
function outer_tangent(c1::gt.Circle{<:Number}, c2::gt.Circle{<:Number}, inverse::Bool=false)
    # contains one circle the other?
    (contained(c1, c2) || contained(c2, c1)) && return gt.LineSegment(gt.Point2(0.0), gt.Point2(0.0))

    # initialization
    r = c1.r
    R = c2.r
    x1, y1 = c1.center
    x2, y2 = c2.center

    # algorithm
    γ = atan(y2 - y1,x2 - x1)
    β = asin((R - r)/sqrt((x2 - x1)^2 + (y2 - y1)^2))
    α = -γ - β
    x3 = x1 + r*cos(π/2 - α)
    y3 = y1 + r*sin(π/2 - α)
    x4 = x2 + R*cos(π/2 - α)
    y4 = y2 + R*sin(π/2 - α)

    if inverse
        gt.LineSegment(gt.Point2(x4, y4), gt.Point2(x3, y3))
    else
        gt.LineSegment(gt.Point2(x3, y3), gt.Point2(x4, y4))
    end
end
outer_tangent(p::gt.Point2{<:Number}, c::gt.Circle{<:Number}, inverse::Bool=false) = outer_tangent(gt.Circle(p, zero(eltype(p))), c, inverse)
outer_tangent(c::gt.Circle{<:Number}, p::gt.Point2{<:Number}, inverse::Bool=false) = outer_tangent(c, gt.Circle(p, zero(eltype(p))), inverse)

"""
    intersection(l1::gt.LineSegment{<:gt.Point2{<:Number}}, l2::gt.LineSegment{<:gt.Point2{<:Number}}, only_in_lineSegment::Bool=false)

Calculate the intersection point of two LineSegments (interpreted as Lines).

# Optinal Arguments

- `only_in_lineSegment::Bool = false`: set to true, if only the segments `l1` `l2` are interesting and not the whole line

# Examples

```jldoctest
julia> intersection(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.LineSegment(gt.Point2(3.0, 2.0), gt.Point2(2.0, 3.0)))
(true, [2.5, 2.5])
```
"""
function intersection(l1::gt.LineSegment{<:gt.Point2{<:Number}}, l2::gt.LineSegment{<:gt.Point2{<:Number}}, only_in_lineSegment::Bool=false)
    # initialization
    p1 = l1[1]
    v1 = vector(l1[1], l1[2])
    p2 = l2[1]
    v2 = vector(l2[1], l2[2])

    # point the vectors in the same or in the opposide direction
    (isapprox(la.normalize(v1), la.normalize(v2)) || isapprox(la.normalize(v1), la.normalize(-v2))) && return false, gt.Point2(0.0)

    # calc intersection
    denom = v1[1]*v2[2] - v2[1]*v1[2]
    isec = gt.Point2((-p1[1]*v2[1]*v1[2] + p2[1]*v1[1]*v2[2] + p1[2]*v1[1]*v2[1] - p2[2]*v1[1]*v2[1])/denom, (-p1[1]*v1[2]*v2[2] + p2[1]*v1[2]*v2[2] + p1[2]*v1[1]*v2[2] - p2[2]*v2[1]*v1[2])/denom)

    if only_in_lineSegment && !((distance(p1, isec) + distance(l1[2], isec)) ≈ sqrt(sum(v1.^2)) && (distance(p2, isec) + distance(l2[2], isec)) ≈ sqrt(sum(v2.^2)))
        return false, gt.Point2(0.0)
    end
    return true, isec
end

"""
    intersection(l::gt.LineSegment{<:gt.Point2{<:Real}}, r::gt.HyperRectangle{2,<:Real})

Calculate the intersection point of a Linesegment (ray beginning in the first
argument (point) of the linesegment and going through the second point) and a
Rectangle. Returns (false, gt.Point2(0.0, 0.0)) if there is no intersection point.

# Examples

```jldoctest
julia> intersection(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.HyperRectangle{2,Float64}([0.0, 0.0], [7.0, 4.0]))
(true, [4.0, 4.0])
```
"""
function intersection(l::gt.LineSegment{<:gt.Point2{<:Real}}, r::gt.HyperRectangle{2,<:Real})
    # initialization
    x1, x2 = r.origin[1], r.origin[1] + r.widths[1]
    y1, y2 = r.origin[2], r.origin[2] + r.widths[2]
    a_x, a_y = l[1]
    b_x, b_y = l[2]

    # intersection lambda's
    λ_x1 = (x1 - a_x)/(b_x - a_x)
    λ_x2 = (x2 - a_x)/(b_x - a_x)
    λ_y1 = (y1 - a_y)/(b_y - a_y)
    λ_y2 = (y2 - a_y)/(b_y - a_y)

    # look for the smallest positive lambda
    λ = Inf
    @inbounds for lowest in [λ_x1, λ_x2, λ_y1, λ_y2]
        λ = lowest >= 0 && lowest < λ ? lowest : λ
    end

    λ == Inf && return false, gt.Point2(0.0)
    true, gt.Point2(a_x + λ*(b_x - a_x), a_y + λ*(b_y - a_y))
end

"""
    intersection(l::gt.LineSegment{<:gt.Point2{<:Real}}, c::gt.Circle{<:Real}; only_in_lineSegment::Bool = false)

Calculate the intersection points of a Line and a gt.Circle. Returns
(false, [0.0, 0.0], false, [0.0, 0.0]) if there is no intersection point.
If the line touches the circle both output points are the same.

Algorithm from [http://mathworld.wolfram.com/gt.Circle-LineIntersection.html](http://mathworld.wolfram.com/gt.Circle-LineIntersection.html)

# Optinal Arguments

- `only_in_lineSegment::Bool = false`: set to true, if only the segment `l` is interesting and not the whole line. So it's possible, that only one of the output points is true.

# Examples

```jldoctest
julia> intersection(gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(2.0, 2.0)), gt.Circle(gt.Point2(1.0, 1.0), 0.5))
(true, [0.646447, 0.646447], true, [1.35355, 1.35355])
```
"""
function intersection(l::gt.LineSegment{<:gt.Point2{<:Real}}, c::gt.Circle{<:Real}; only_in_lineSegment::Bool = false)
    # initialization
    @inbounds x1, y1 = l[1] .- c.center
    @inbounds x2, y2 = l[2] .- c.center
    dx = x2 - x1
    dy = y2 - y1

    dr = sqrt(dx^2 + dy^2)
    D = x1*y2 - x2*y1
    sgn_dy = dy < 0.0 ? -1.0 : 1.0
    differ = c.r^2*dr^2-D^2

    # check if there is at least one intersection point
    if differ < 0
        return false, [0.0, 0.0], false, [0.0, 0.0]
    end
    sqrt_term = sqrt(differ)
    dr2 = dr^2

    xr = (D*dy - sgn_dy*dx*sqrt_term)/dr2
    yr = (-D*dx - abs(dy)*sqrt_term)/dr2
    xl = (D*dy + sgn_dy*dx*sqrt_term)/dr2
    yl = (-D*dx + abs(dy)*sqrt_term)/dr2
    right = [xr, yr].+c.center
    left = [xl, yl].+c.center
    out1, out2 = true, true
    if only_in_lineSegment
        if !is_on_LineSegment(right, l)
            out1 = false
        end
        if !is_on_LineSegment(left, l)
            out2 = false
        end
    end
    out1, right, out2, left
end

"""
    is_touching(c1::gt.HyperSphere{N, <:Number}, c2::gt.HyperSphere{N, <:Number}) where {N}

Check if two HyperSheres are overlapping or at least touching each other. The
HyperSpheres `c1` and `c2` must be of equal dimension.

# Examples

```jldoctest
julia> is_touching(gt.Circle(gt.Point2(0, 0), 1), gt.Circle(gt.Point2(0, 0), 1))
true
```
"""
@inline function is_touching(c1::gt.HyperSphere{N, <:Number}, c2::gt.HyperSphere{N,<:Number}) where {N}
    distance(c1.center, c2.center) <= c1.r + c2.r
end
@inline is_touching(p1::gt.Point{N, <:Number}, r1::Number, p2::gt.Point{N, <:Number}, r2::Number) where {N} = is_touching(gt.HyperSphere(p1, r1), gt.HyperSphere(p2, r2))
@inline function is_touching(p1::AbstractVector{<:Number}, r1::Number, p2::AbstractVector{<:Number}, r2::Number)
    @assert length(p1)==length(p2) "`p1` and `p2` must be in equal in length!"
    is_touching(gt.Point{length(p1)}(p1), r1, gt.Point{length(p2)}(p2), r2)
end

"""
    does_intersect(l::gt.LineSegment{<:gt.Point2{<:Real}}, c::gt.Circle{<:Number}; only_in_lineSegment::Bool = false, r_is_outside::Bool = true)

Check if a gt.LineSegment (as Line) does_intersect a gt.Circle.

# Optional Arguments
- `only_in_lineSegment::Bool = false`: set to true, if only the segment `l` is interesting and not the whole line
- `r_is_outside::Bool = true`: set to false if the circle ring shall be inside the circle

# Examples

```jldoctest
julia> does_intersect(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.Circle(gt.Point2(0.0, 0.0), 1.0))
true
```
"""
function does_intersect(l::gt.LineSegment{<:gt.Point2{<:Real}}, c::gt.Circle{<:Number}; only_in_lineSegment::Bool = false, r_is_outside::Bool = true)
    # initialization
    v = vector(l[1], l[2])
    center = c.center

    # calc the intersection of the line and the line: center+normal
    v_n = normal2d(v)
    not_parallel, isec = intersection(l, gt.LineSegment(center, center + v_n))

    # touches the circle the line segment?
    only_in_lineSegment && !isapprox(distance(l[1], isec) + distance(isec, l[2]), distance(l[1], l[2]), atol=1e-4) && return false

    # sanity check
    !not_parallel && error("Orthognal lines seems to be parallel!")

    # decide on the input
    d = distance(center, isec)
    if r_is_outside
        if d < c.r
            return true
        end
    else
        if d <= c.r
            return true
        end
    end
    return false
end

"""
    is_inside(p::AbstractVector{<:Number}, c::gt.HyperSphere{2,<:Number}; r_is_outside::Bool = true)

Return true, if a point `p` stays inside of an circle `c`.

# Optional Arguments
- `r_is_outside::Bool = false`: set to true if the circle ring shall be outside of the circle

# Examples

```jldoctest
julia> is_inside(gt.Point2([0, 0]), gt.Circle(gt.Point2([0,0]), 1))
true
```
"""
@inline function is_inside(p::AbstractVector{<:Number}, c::gt.HyperSphere{2,<:Number}; r_is_outside::Bool = false)
    r_is_outside && return distance(p, c.center) < c.r
    distance(p, c.center) <= c.r
end

"""
    polygon_area(p::AbstractVector{<:AbstractVector{<:Number}})

Compute the signed area of a planar non-self-intersecting polygon.
Note that the area of a convex polygon is defined to be positive
if the points are arranged in a counterclockwise order,
and negative if they are in clockwise order (Beyer 1987).

Algorithm from [http://mathworld.wolfram.com/PolygonArea.html](http://mathworld.wolfram.com/PolygonArea.html)

# Examples

```jldoctest
julia> polygon_area([[0, 0], [1, 0], [1, 1], [0, 1]])
1.0
```
"""
function polygon_area(p::AbstractVector{<:AbstractVector{<:Number}})::Float64
    if length(p) < 3
        return 0.0
    end
    @inbounds s = la.det(hcat(p[end],p[1]))
    for i in 1:(length(p)-1)
        @inbounds s += la.det(hcat(p[i],p[i+1]))
    end
    s*0.5
end

"""
    get_all_polygon_sides(points::AbstractVector{<:gt.Point2{<:Real}})

Returns a vector with all sides (`LineSegments`) for a polygon. The argument
is a vector with all corners.

# Examples

```jldoctest
julia> get_all_polygon_sides([gt.Point2(0, 0), gt.Point2(1, 0), gt.Point2(1, 1), gt.Point2(0, 1)])
4-element Array{GeometryTypes.Simplex{2,GeometryTypes.Point{2,Float64}},1}:
 GeometryTypes.Point{2,Float64}[[0.0, 0.0], [1.0, 0.0]]
 GeometryTypes.Point{2,Float64}[[1.0, 0.0], [1.0, 1.0]]
 GeometryTypes.Point{2,Float64}[[1.0, 1.0], [0.0, 1.0]]
 GeometryTypes.Point{2,Float64}[[0.0, 1.0], [0.0, 0.0]]
```
"""
function get_all_polygon_sides(points::AbstractVector{<:gt.Point2{<:Real}})
    len = length(points)
    len == 0 && return gt.LineSegment{gt.Point2{Float64}}[]
    sides = zeros(gt.LineSegment{gt.Point2{Float64}}, len)

    for i in 1:(length(points) - 1)
        @inbounds sides[i] = gt.LineSegment(points[i], points[i+1])
    end
    @inbounds sides[end] = gt.LineSegment(points[end], points[1])

    sides
end

"""
    is_inside(point::gt.Point2{<:Real}, polygon::AbstractVector{<:gt.LineSegment{<:gt.Point2{<:Real}}})

Checks if a `point` is inside of a `polygon`. Edges and corners of polygons are inside.

# Examples

```jldoctest
julia> is_inside(gt.Point2(0.5, 0.5), [gt.Point2(0, 0), gt.Point2(1, 0), gt.Point2(1, 1), gt.Point2(0, 1)])
true
```
"""
function is_inside(point::gt.Point2{<:Real}, polygon::AbstractVector{<:gt.Point2{<:Real}}; tolerance=1e-4)
    path1 = [cl.IntPoint(Int.(round.(v./tolerance))...) for v in polygon]

    return cl.pointinpolygon(cl.IntPoint(Int.(round.(point./tolerance))...), path1) != 0
end

"""
    is_inside(point::gt.Point2{<:Real}, rectangle::gt.HyperRectangle{2,<:Real})

Checks if a `point` lies inside of a `rectangle`. On the edge is inside.

# Examples

```jldoctest
julia> is_inside(gt.Point2(1.0, 1.0), gt.HyperRectangle([gt.Point2(0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(2.0, 0.0)]))
true
```
"""
function is_inside(point::gt.Point2{<:Real}, rectangle::gt.HyperRectangle{2,<:Real})
    px, py = point
    x_min, y_min = rectangle.origin
    x_max, y_max = rectangle.origin + rectangle.widths
    x_min <= px <= x_max && y_min <= py <= y_max
end
is_inside(point::AbstractArray{<:Real}, rectangle::AbstractArray{<:gt.Point2{<:Real}}) = is_inside(gt.Point2(point...), gt.HyperRectangle(rectangle))
is_inside(point::AbstractArray{<:Real}, rectangle::gt.HyperRectangle{2,<:Real}) = is_inside(gt.Point2(point...), rectangle)

"""
    polygon_intersection(a::AbstractVector{<:AbstractVector{<:Real}}, b::AbstractVector{<:AbstractVector{<:Real}})

Calculates the intersection polygon of the polygons `a` and `b`, wherby the polygons are stored as
`Vector` of points (also `Vector`s). The algorithm works in 2d for not selfintersection polygones with no holes, but they don't need to be convex.

# Return value

- a vector of polygons (vector of points) in the case of intersection. This also covers the case, if one of the two polygons is fully contained by the other.
- an empty vector

# Examples

```jldoctest
julia> polygon_intersection([gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0),gt. Point2(5.0, 1.0), gt.Point2(3.0, 4.0)])
2-element Array{Array{GeometryTypes.Point{2,Float64},1},1}:
 GeometryTypes.Point{2,Float64}[[2.0, 2.0], [1.6667, 2.0], [1.0, 1.0]]
 GeometryTypes.Point{2,Float64}[[4.3333, 2.0], [4.0, 2.0], [5.0, 1.0]]
```
"""
function polygon_intersection(a::AbstractVector{<:gt.Point2{<:Real}}, b::AbstractVector{<:gt.Point2{<:Real}}; tolerance=1e-4)
    path1 = cl.IntPoint[cl.IntPoint(Int.(round.(v./tolerance))...) for v in a]
    path2 = cl.IntPoint[cl.IntPoint(Int.(round.(v./tolerance))...) for v in b]

    c = cl.Clip()

    cl.add_path!(c, path2, cl.PolyTypeSubject, true)
    cl.add_path!(c, path1, cl.PolyTypeClip, true)

    result, polys = cl.execute(c, cl.ClipTypeIntersection, cl.PolyFillTypeEvenOdd, cl.PolyFillTypeEvenOdd)

    result || @warn "Result from polygon clipping is negative."

    return [[gt.Point2(intpoint.X*tolerance, intpoint.Y*tolerance) for intpoint in poly] for poly in polys]
end

"""
    polygon_union(polygons::AbstractVector{<:AbstractVector{<:gt.Point2{<:Real}}}; tolerance=1e-4)

Merges all polygons. If there are some disjunct polygons, they will stay disjunct.

# Examples

```jldoctest
julia> polygon_union([[gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0)]])
1-element Array{Array{GeometryTypes.Point{2,Float64},1},1}:
 GeometryTypes.Point{2,Float64}[[0.0, 0.0], [2.0, 0.0], [2.0, 1.0], [0.0, 1.0]]
```
"""
function polygon_union(polygons::AbstractVector{<:AbstractVector{<:gt.Point2{<:Real}}}; tolerance=1e-4)
    c = cl.Clip()

    for polygon in polygons
        cl.add_path!(c, cl.IntPoint[cl.IntPoint(Int.(round.(v./tolerance))...) for v in polygon], cl.PolyTypeSubject, true)
    end

    result, polys = cl.execute(c, cl.ClipTypeUnion, cl.PolyFillTypePositive, cl.PolyFillTypePositive)

    if !result
        @warn "Result from polygon union is negative."
        return [gt.Point2{Float64}[]]
    end

    return [[gt.Point2(intpoint.X*tolerance, intpoint.Y*tolerance) for intpoint in poly] for poly in polys]
end

"""
    is_on_LineSegment(point::gt.Point2{<:Number}, line::gt.LineSegment{<:gt.Point2{<:Number}})

Checks if a given `point` resides on the `gt.LineSegment`. Is also false, if the point is on the line but not between the start and the end point of the `line`.

# Examples

```jldoctest
julia> is_on_LineSegment(gt.Point2(0.5, 0.0), gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0)))
true
```
"""
@inline function is_on_LineSegment(point::gt.Point2{<:Number}, line::gt.LineSegment{<:gt.Point2{<:Number}})
    @inbounds res = distance(point, line[1]) + distance(point, line[2]) ≈ distance(line[1], line[2])
    res
end
is_on_LineSegment(point::AbstractArray{<:Number}, line::gt.LineSegment{<:gt.Point2{<:Number}}) = is_on_LineSegment(gt.Point2(point[1], point[2]), line)
