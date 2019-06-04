"""
    bresenham(start::Tuple{<:T, <:T}, stop::Tuple{<:T, <:T}) where T<:Number

Implements the [Bresenham's line algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).

# Examples

```jldoctest
julia> bresenham()

```
"""
function bresenham(start::Tuple{T, T}, stop::Tuple{T, T}) where T<:Integer
    x0, y0 = start
    x1, y1 = stop
    if abs(y1 - y0) < abs(x1 - x0)
        if x0 > x1
            reverse!(low_line(stop, start))
        else
            low_line(start, stop)
        end
    else
        if y0 > y1
            reverse!(high_line(stop, start))
        else
            high_line(start, stop)
        end
    end
end

"""
    low_line(start::Tuple{T, T}, stop::Tuple{T, T}) where T<:Integer



# Examples

```jldoctest
julia> low_line()

```
"""
function low_line(start::Tuple{T, T}, stop::Tuple{T, T}) where T<:Integer
    x0, y0 = start
    x1, y1 = stop
    line = fill((zero(T), zero(T)), length(x0:x1))
    dx = x1 - x0
    dy = y1 - y0
    yi = 1
    if dy < 0
        yi = -1
        dy = -dy
    end
    D = 2*dy - dx
    y = y0

    for x in x0:x1
        line[x - x0 + 1] =  (x, y)
        if D > 0
            y = y + yi
            D = D - 2*dx
        end
        D = D + 2*dy
    end

    line
end

"""
    high_line(start::Tuple{T, T}, stop::Tuple{T, T}) where T<:Integer



# Examples

```jldoctest
julia> high_line()

```
"""
function high_line(start::Tuple{T, T}, stop::Tuple{T, T}) where T<:Integer
    x0, y0 = start
    x1, y1 = stop
    line = fill((zero(T), zero(T)), length(y0:y1))
    dx = x1 - x0
    dy = y1 - y0
    xi = 1
    if dx < 0
        xi = -1
        dx = -dx
    end
    D = 2*dx - dy
    x = x0

    for y in y0:y1
        line[y - y0 + 1] =  (x, y)
        if D > 0
            x = x + xi
            D = D - 2*dy
        end
        D = D + 2*dx
    end

    line
end
