### copied from https://github.com/sswatson/Graphics2D.jl/blob/master/src/Graphics2D.jl
### at 08.12.2017 (commit: e6e2e1e7646d458b1db859721eb2c1253ced322b)

import Base.show,
       Base.*,
       Base.-,
       Cairo

COLORS = Dict(
"red" =>    [1.0, 0.0, 0.0, 1.0],
"green" =>  [0.0, 1.0, 0.0, 1.0],
"blue" =>   [0.0, 0.0, 1.0, 1.0],
"yellow" => [1.0, 1.0, 0.0, 1.0],
"purple" => [0.5, 0.0, 0.5, 1.0],
"orange" => [1.0, 0.4, 0.0, 1.0], 
"white" =>  [1.0, 1.0, 1.0, 1.0],
"black" =>  [0.0, 0.0, 0.0, 1.0],
"gray" =>   [0.5, 0.5, 0.5, 1.0]
)

abstract type GraphicElement end

struct GraphicsBoundingBox
    xmin::Real
    xmax::Real
    ymin::Real
    ymax::Real
end

struct GraphicPoint <: GraphicElement
    x::Real
    y::Real
    pointsize::Real
    color::Array{Float64,1}
end

struct GraphicLine{T<:Real} <: GraphicElement
    coords::Array{T,2}
    linewidth::Real
    color::Array{Float64,1}
    fill::Bool
    fillcolor::Array{Float64,1}
end

struct GraphicArrow{T<:Real} <: GraphicElement
    coords::Array{T,2}
    linewidth::Real
    color::Array{Float64,1}
    arrowsize::Real
    arrowloc::Real
end

struct GraphicCircle <: GraphicElement
    center::Array{Float64,1}
    radius::Float64
    linewidth::Real
    color::Array{Float64,1}
    fill::Bool
    fillcolor::Array{Float64,1}
end

struct GraphicArc <: GraphicElement
    center::Array{Float64,1}
    radius::Real
    theta1::Real
    theta2::Real
    linewidth::Real
    color::Array{Float64,1}
    fill::Bool
    fillcolor::Array{Float64,1}
end

struct GraphicText <: GraphicElement
    location::Array{Float64,1}
    text::AbstractString
    textsize::Real
    color::Array{Float64,1}
end

*(x::Real,s::String) = x * COLORS[s]

tocolor(string_or_rgb) = isa(string_or_rgb,AbstractString) ? 
                            COLORS[string_or_rgb] : string_or_rgb
function GraphicPoint(x::Real, 
               y::Real; 
               pointsize::Real=0.005, 
               color=[0.0,0.0,0.0,1.0])
    return GraphicPoint(x,y,pointsize,tocolor(color))
end

function GraphicPoint(z::Complex{T}; args...) where T <: Real
    return GraphicPoint(real(z),imag(z); args...)
end

function GraphicPoint(p::Tuple{T,T}; args...) where T <: Real
    return GraphicPoint(p[1],p[2]; args...)
end

function GraphicPoint(a::Array{T,1}; args...) where T <: Real
    return GraphicPoint(a[1],a[2]; args...)
end

"""
    GraphicPoint(args...)

Draws a point in the gui.

# Optinal Arguments

- `pointsize::Real=0.005`
- `color=[0.0,0.0,0.0,1.0]`
"""
function GraphicPoint(; args...)
    return x -> GraphicPoint(x; args...)
end

function GraphicLine(A::Array{T,2};
                       linewidth::Real=1.0,
                       color=[0.0,0.0,0.0,1.0],
                       fill::Bool=false,
                       fillcolor=[1.0,1.0,1.0,1.0]) where T<:Real
    return GraphicLine(A,linewidth,tocolor(color),fill,tocolor(fillcolor))
end

function GraphicLine(a::Array{T,2};args...) where T
    return GraphicLine(map(float,a);args...)
end

function GraphicLine(a::Array{Complex{T},1};args...) where T
    return GraphicLine(hcat(real(a),imag(a));args...)
end

function GraphicLine(a::Array{Array{T,1},1};args...) where T
    return GraphicLine(hcat(T[a[k][1] for k=1:length(a)],T[a[k][2] for k=1:length(a)]);args...)
end

function GraphicLine(a::Array{Tuple{T,T},1};args...) where T
    return GraphicLine(hcat(T[a[k][1] for k=1:length(a)],T[a[k][2] for k=1:length(a)]);args...)
end

function GraphicLine(a::GraphicArrow)
    return GraphicLine(a.coords;linewidth=a.linewidth,color=a.color)
end

"""
    GraphicLine(args...)

Draws a line in the gui. Needs a two element vector with the start and the endpoint.

# Optinal Arguments

- `linewidth::Real=1.0`
- `color=[0.0,0.0,0.0,1.0]`
- `fill::Bool=false`
- `fillcolor=[1.0,1.0,1.0,1.0])`
"""
function GraphicLine(; args...)
    return x -> GraphicLine(x; args...)
end

function GraphicArrow(A::Array{T,2};
                        linewidth::Real=1.0,
                        color=[0.0,0.0,0.0,1.0],
                        arrowsize::Real=0.05,
                        arrowloc::Real=0.5) where T<:Real
    return GraphicArrow(A,linewidth,tocolor(color),arrowsize,arrowloc)
end

function GraphicArrow(a::Array{T,2};args...) where T
    return GraphicArrow(map(float,a);args...)
end

function GraphicArrow(a::Array{Complex{T},1};args...) where T
    return GraphicArrow(hcat(real(a),imag(a));args...)
end

function GraphicArrow(a::Array{Array{T,1},1};args...) where T
    return GraphicArrow(hcat(T[a[k][1] for k=1:length(a)],T[a[k][2] for k=1:length(a)]);args...)
end

function GraphicArrow(a::Array{Tuple{T,T},1};args...) where T
    return GraphicArrow(hcat(T[a[k][1] for k=1:length(a)],T[a[k][2] for k=1:length(a)]);args...)
end

"""
    GraphicArrow(args...)

Draws an arrow in the gui. Needs a two element vector with the start and the endpoint. The arrow head lies in the endpoint.

# Optinal Arguments

- `linewidth::Real=1.0`
- `color=[0.0,0.0,0.0,1.0]`
- `arrowsize::Real=0.05`
- `arrowloc::Real=0.5`
"""
function GraphicArrow(; args...)
    return x -> GraphicArrow(x; args...)
end

function -(a::GraphicArrow)
    return GraphicArrow(a.coords[end:-1:1,1:end],
                 a.linewidth,
		 a.color,
		 a.arrowsize,
		 a.arrowloc)
end

function *(i::Integer,a::GraphicArrow)
    return signbit(i) ? -a : a
end


function GraphicCircle(center::Array{T,1},
                     radius::U;
                     linewidth::Real=1.0,
                     color=[0.0,0.0,0.0, 1.0],
                     fill::Bool=false,
                     fillcolor=[1.0,1.0,1.0, 1.0]
                     ) where {T,U}
    return GraphicCircle(map(float, center), float(radius), linewidth,
        tocolor(color), fill, tocolor(fillcolor))
end

function GraphicCircle(x::T,
                     y::T,
                     radius::U;
                     args...
                     )  where {T,U}
    return GraphicCircle(T[x,y],radius;args...)
end

function GraphicCircle(p::Tuple{T,T},
                     radius::U;
                     args...
                     ) where {T,U}
    return GraphicCircle(p[1],p[2],radius;args...)
end

"""
    GraphicCircle(args...)

Draws a circle in the gui. Needs a tuple with the center and the radius.

# Optinal Arguments

- `linewidth::Real=1.0`
- `color=[0.0,0.0,0.0,1.0]`
- `fill::Bool=false`
- `fillcolor=[1.0,1.0,1.0,1.0])`
"""
function GraphicCircle(; args...)
    return (x, r) -> GraphicCircle(x, r; args...)
end

function GraphicArc(center::Array{T,1},
                radius,
                theta1,
                theta2;
                linewidth::Real=1.0,
                color=[0.0,0.0,0.0, 1.0],
                fill::Bool=false,
                fillcolor=[1.0,1.0,1.0, 1.0]
                ) where T
    return GraphicArc(map(float,center),
               float(radius),
               float(theta1),
               float(theta2),
               linewidth,
               tocolor(color),
               fill,
               tocolor(fillcolor))
end

function GraphicArc(; args...)
    return (center, radius, theta1, theta2) -> GraphicArc(center, radius, theta1, theta2; args...)
end

function GraphicText(location::Array{T,1},
                text::AbstractString;
                textsize::Float64=0.2,
                color=[1.0,1.0,1.0, 1.0]
                ) where T
    return GraphicText(location,text,textsize,tocolor(color))
end

"""
    GraphicText(args...)

Draws text in the gui. Needs a tuple with the startposition and the text.

# Optinal Arguments

- `textsize::Real=0.2`
- `color=[1.0,1.0,1.0, 1.0]`
"""
function GraphicText(; args...)
    return (x, text) -> GraphicText(x, text; args...)
end

function arrowhead(a::GraphicArrow)
    A = a.coords[end-1,:]
    B = a.coords[end,:]
    z = (B-A)[1] + im*((B-A)[2])
    θ = angle(z)
    ψ = 20π/180
    l = a.arrowsize
    tip = A + a.arrowloc*(B-A)
    C = tip-abs(z)*l*[cos(θ+ψ),sin(θ+ψ)]
    D = tip-abs(z)*l*[cos(θ-ψ),sin(θ-ψ)]

    return GraphicLine([tip,C,D,tip],fill=true,color=a.color,fillcolor=a.color)
end

function show(io::IO,line::GraphicLine)
    print(io,"GraphicLine(coordinates =\n")
    show(io,line.coords)
    print(io,",\nlinewidth = ",line.linewidth)
    if line.fill
        print(io,",\nfillcolor = ")
        print(io,"[",line.fillcolor[1],",",
              line.fillcolor[2],",",line.fillcolor[3],",",line.fillcolor[4],"]")
    else
        print(io,",\nfill = ",line.fill)
    end
    print(io,")")
end

function show(io::IO,arrow::GraphicArrow)
    print(io,"GraphicArrow(coordinates =\n")
    show(io,arrow.coords)
    print(io,",\nlinewidth = ",arrow.linewidth)
    print(io,",\narrowsize = ",arrow.arrowsize)
    print(io,",\narrowloc = ",arrow.arrowloc)
    print(io,")")
end

function show(io::IO,point::GraphicPoint)
    print(io,"GraphicPoint(")
    print(io,point.x)
    print(io,",")
    print(io,point.y)
    print(io,")")
end

function boundingbox(l::GraphicLine)
    # Coordinates are returned in the order xmin, xmax, ymax, ymin
    return GraphicsBoundingBox(minimum(l.coords[:,1]), maximum(l.coords[:,1]),
        minimum(l.coords[:,2]),maximum(l.coords[:,2]))
end

function boundingbox(a::GraphicArrow)
    # Coordinates are returned in the order xmin, xmax, ymax, ymin
    return boundingbox(map(boundingbox,[GraphicLine(a),arrowhead(a)]))
end

function boundingbox(c::GraphicCircle)
    return GraphicsBoundingBox(c.center[1] - c.radius, c.center[1] + c.radius,
        c.center[2] - c.radius, c.center[2] + c.radius)
end

function boundingbox(p::GraphicPoint)
    return GraphicsBoundingBox(p.x,p.x,p.y,p.y)
end

function boundingbox(a::GraphicArc)
    return GraphicsBoundingBox(a.center[1] - a.radius,
        a.center[1] + a.radius, a.center[2] - a.radius, a.center[2] + a.radius)
end

function boundingbox(t::GraphicText)
    return GraphicsBoundingBox(t.location[1],t.location[1],t.location[2],
        t.location[2])
end

function boundingbox(A::Array)
    a = minimum([bb.xmin for bb in A])
    b = maximum([bb.xmax for bb in A])
    c = maximum([bb.ymax for bb in A])
    d = minimum([bb.ymin for bb in A])
    if a == b || c == d
        error(logger, "Bounding box has empty interior")
    end
    return GraphicsBoundingBox(a - 0.05*(b-a), b + 0.05*(b-a), d - 0.05*(c-d),
        c + 0.05*(c-d))
end

function sketch(cr::Cairo.CairoContext,
                l::GraphicLine,
                bb::GraphicsBoundingBox=boundingbox(l))

    Cairo.set_line_width(cr,l.linewidth)

    Cairo.move_to(cr,l.coords[1,1],l.coords[1,2]);
    for i=1:size(l.coords)[1]-1
        Cairo.line_to(cr,l.coords[i+1,1],l.coords[i+1,2]);
    end

    if l.coords[end,:] == l.coords[1,:]
        Cairo.close_path(cr)
    end

    if l.coords[end,:] == l.coords[1,:] && l.fill
        Cairo.set_source_rgba(cr,l.fillcolor...)
        Cairo.fill_preserve(cr)
        Cairo.set_source_rgba(cr,l.color...)
        Cairo.stroke(cr)
    else
        Cairo.set_source_rgba(cr,l.color...)
        Cairo.stroke(cr)
    end
end

function sketch(cr::Cairo.CairoContext,
                a::GraphicArrow,
                bb::GraphicsBoundingBox=boundingbox(a))

    Cairo.set_line_width(cr,a.linewidth)

    Cairo.move_to(cr,a.coords[1,1],a.coords[1,2]);
    for i=1:size(a.coords)[1]-1
        Cairo.line_to(cr,a.coords[i+1,1],a.coords[i+1,2]);
    end

    Cairo.set_source_rgba(cr,a.color...)
    Cairo.stroke(cr)

    sketch(cr,arrowhead(a),bb)

end


function sketch(cr::Cairo.CairoContext,
                c::GraphicCircle,
                bb::GraphicsBoundingBox=boundingbox(c))

    Cairo.set_line_width(cr,c.linewidth)
    Cairo.arc(cr, c.center[1], c.center[2], c.radius, 0, 2*pi)

    if c.fill
        Cairo.set_source_rgba(cr,c.fillcolor...)
        Cairo.fill_preserve(cr)
    end

    Cairo.set_source_rgba(cr,c.color...)
    Cairo.stroke(cr)
end

function sketch(cr::Cairo.CairoContext,
                a::GraphicArc,
                bb::GraphicsBoundingBox=boundingbox(a))
    Cairo.arc(cr, a.center[1], a.center[2], a.radius, a.theta1, a.theta2);
    Cairo.set_source_rgba(cr,a.color...)
    Cairo.stroke(cr)
end

function sketch(cr::Cairo.CairoContext,
                p::GraphicPoint,
                bb::GraphicsBoundingBox=boundingbox(p))

    Cairo.arc(cr, p.x, p.y, 
              p.pointsize*max(bb.xmax-bb.xmin,bb.ymax-bb.ymin), 0, 2*pi);
    Cairo.set_source_rgba(cr,p.color...)
    Cairo.fill(cr)
end

function sketch(cr::Cairo.CairoContext,
                t::GraphicText,
                bb::GraphicsBoundingBox=boundingbox(t))

    Cairo.save(cr)

    Cairo.set_font_size(cr,t.textsize)
    Cairo.set_source_rgba(cr,t.color...)

    x_bearing, y_bearing, width, height = Cairo.text_extents(cr,t.text)

    Cairo.move_to(cr,t.location[1] - width/2 - x_bearing, t.location[2] + (3/2)*height + y_bearing)
  
    # Cairo.scale(cr,1,-1)
    # Cairo.translate(cr, 0.0, -height)
    Cairo.show_text(cr,t.text)
    Cairo.restore(cr)
end
