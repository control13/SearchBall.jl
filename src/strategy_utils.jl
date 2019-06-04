import Gtk, Clipper, GeometryTypes, Reactive, Statistics
const gtk = Gtk
const cl = Clipper
const gt = GeometryTypes
const re = Reactive
const stat = Statistics

"""
    init_text!(config::Config, key::AbstractString, init="")

Registers a field in the gui for pritning arbitrary values.
The type of `init` determines the type, that can passed to `show_text!`.
All registered texts must have a unique `key`.
"""
function init_text!(config::Config, key::AbstractString, init="")
    config.printables[key] = re.Signal(init)
end

"""
    show_text!(config::Config, key::AbstractString, value)

Shows the given `value` in the registered field in the gui (see `init_text!`).
Uses the key for the right field.
"""
function show_text!(config::Config, key::AbstractString, value)
    push!(config.printables[key], value)
end

"""
    get_text!(config::Config, key::AbstractString)

Returns the current `value` in the registered field in the gui (see `init_text!`).
Uses the key for the right field.
"""
function get_text!(config::Config, key::AbstractString)
    re.value(config.printables[key])
end

"""
    show_graphic!(config::Config, key::AbstractString, position, graphic::GraphicElement)

Shows a GraphicElement in the gui. There are various graphic element like points, circle, line and arrows or text.
Some need mor than a position, like the circle needs also a radius. Look in the specific docs of the graphic element.
The keys need to be unique for each graphic element. Graphic elements don't need to registered beforhead.
```
"""
function show_graphic!(config::Config, key::AbstractString, position, graphic::Function)
    config.drawables[key] = (position, graphic)
end

"""
    get_manip_valu(config::Config, key::AbstractString)

Returns the current value of a manipulator by its key. For example `true` or `false` if a checkbutton is checked or not.
"""
function get_manip_value(config::Config, key::AbstractString)
    get_value(config.manipulators[key][1], config.manipulators[key][2])
end

"""
    remove_graphic!(config::Config, key::AbstractString)

Removes a graphic element from the gui by its key.
"""
function remove_graphic!(config::Config, key::AbstractString)
    delete!(config.drawables, key)
end

"""
    remove_graphics_filter!(filter::Function, config::Config)

Removes graphic elements, for which key the filter function returns true.

# Examples

```jldoctest
julia> remove_graphics_filter!(key -> startswith(key, "arrows_"), config)

```
"""
function remove_graphics_filter!(filter::Function, config::Config)
    for s in keys(config.drawables)
        if filter(s)
            delete!(config.drawables, s)
        end
    end
end

"""
    is_in_line_of_sight(ws::WorldState, my_position::AbstractVector{T}, p_view::AbstractVector{T}; tol::Real=0.0, excludes::Vector{Robot{T}}=Robot[]) where T<:Number

Check if in the current WorldState `ws` a position `p_view` is visible and there is no obstacle in the line my position->`p_view`, that prevents the sight.

# Current limits

- only the point `p_view` will be checked, not the object on this position

# Optional Arguments

- `tol::Number=0.0`: tolerace of the radii for all elements in `ws`
(the tolerance will be subtracted from the real radius)
- `excludes::AbstractVector{<:AbstractVector{<:Number}}=Vector{Float64}[]`: elemtent which are subtracted from the list in `ws`

# Examples

```jldoctest
julia> ws = WorldState([[3.0, 3.0]], [[6.0, 3.0]], [8.0, 3.0])
WorldState(Array{Float64,1}[[3.0, 3.0]], Array{Float64,1}[[6.0, 3.0]], [8.0, 3.0], 0.15, 0.05)

julia> is_in_line_of_sight(ws, ws.myPlayers[1], ws.ball)
false
```
"""
function is_in_line_of_sight(ws::WorldState, my_position::AbstractVector{T}, p_view::AbstractVector{T}; tol::Real=0.0, excludes::Vector{Robot{T}}=Robot{Float64}[]) where T<:Number
    view_line = gt.LineSegment(gt.Point2(my_position), gt.Point2(p_view))
    !any([any(intersection(view_line, gt.Circle(gt.Point2(x), get_size(x) - tol), only_in_lineSegment = true)[[1,3]]) for x in vcat(ws.myPlayers, ws.opponents) if x ∉ excludes])
end

"""
    iswithin_hfov(player::Robot{<:Number}, point::AbstractVector{<:Number})

Checks if a point is within the horizontal field of view of the player. Doesn't mean, that the robot can see the point!

# Examples

```jldoctest
julia> iswithin_hfov(Robot([2.0, 2.0], 0.0), [4.0, 2.0])
true
```
"""
function iswithin_hfov(player::Robot{<:Number}, point::AbstractVector{<:Number})
    p = point .- player
    angle_diff = abs(player.body_orientation - atan(p[2], p[1]))
    angle_diff < player.hfov/2 || angle_diff > 2π - player.hfov/2
end

"""
    add_slider!(callback::Function, config::Config, key::AbstractString, range::Range{<:T}, init::T) where T<:Number

Adds a `GtkSlider` to the gui. You can access it's current value by `get_manip_value`
"""
function add_slider!(callback::Function, config::Config, key::AbstractString, range::AbstractRange{T}, init::T) where T<:Number
    speed = gtk.GtkScale(false, range)
    speed_adj = gtk.GtkAdjustment(speed)
    gtk.set_gtk_property!(speed_adj, :value, init)
    config.manipulators[key] = (speed, T, callback)
    return
end
add_slider!(config::Config, key::AbstractString, range::AbstractRange{T}, init::T) where T<:Number = add_slider!(_ -> nothing, config, key, range, init)

"""
    check_button(name::String)

Adds a `GtkCheckButton` to the gui. You can access it's current value by `get_manip_value`
"""
function add_check_button!(callback::Function, config::Config, key::AbstractString, name::AbstractString)
    config.manipulators[key] = (gtk.GtkCheckButton(name), Bool, callback)
    return
end
add_check_button!(config::Config, key::AbstractString, name::AbstractString) = add_check_button!(_ -> nothing, config, key, name)

"""
    radio_button(name::String)

Adds and returns a `GtkRadioButton` to the gui. The radiobutton will not shown in the gui, only the callback function
will be registered. For showing the radio button, you need to put the in a radio button group. See `add_radio_button_group!`.
"""
function add_radio_button!(callback::Function, config::Config, key::AbstractString, name::String)
    rb = gtk.GtkRadioButton(name)
    config.manipulators[key] = (rb, Bool, callback)
    return rb
end
add_radio_button!(config::Config, key::AbstractString, name::AbstractString) = add_radio_button!(_ -> nothing, config, key, name)

"""
    radio_button_group(elements::AbstractVector)

Adds a `GtkRadioButtonGroup` to the gui. You must pass a vector of radio buttons to it (see `add_radio_button`).
You can access it's current choosen radio button by `get_manip_value`
"""
function add_radio_button_group!(config::Config, key::AbstractString, elements::AbstractVector)
    config.manipulators[key] = (gtk.GtkRadioButtonGroup(elements, 1), String, _ -> nothing)
    return
end

"""
Easier access to values stored in this container.
"""
get_value(widget::gtk.GtkScaleLeaf, t::Type) = gtk.get_gtk_property(gtk.GtkAdjustment(widget), :value, t)
get_value(widget::gtk.GtkCheckButtonLeaf, t::Type) = gtk.get_gtk_property(widget, :active, t)
get_value(widget::gtk.GtkRadioButtonGroupLeaf, t::Type) = gtk.get_gtk_property(gtk.get_gtk_property(widget, :active), :label, t)

"""
    intervall(start::Int, stop::Int, mod::Int)

Return a array with elements between `start` and `stop` in a modulo counter.
`start` is exclusive, `stop` inclusive. Assumes the input is 1 based.
The modulocounter is starting by 1 and counts until `mod`.

# Examples

```jldoctest
julia> intervall(3, 1, 4)
2-element Array{Int64,1}:
 4
 1
"""
function intervall(start::Int, stop::Int, mod::Int, full::Bool=false)
    if full && start==stop
        return circshift(1:mod, -start)
    end

    # initialization, correct to 0 based
    intervall_array = Int[]
    start -= 1
    stop -= 1

    # modulo count
    while start != stop
        start = (start+1) % mod
        push!(intervall_array, start)
    end

    # correction from 0 based to 1 based
    return intervall_array.+1
end

"""
    get_edge(to::AbstractVector{<:Number}, tol::Real=eps())

Checks if a 2D point `to` lies on a edge of the (hardcoded) filed within a `tol`.
By default, tol is set to `eps()`.
The edges in the world coordinate systems are named like:

(0.0,6.0) (9.0,6.0)
    +----3----+
    |         |
    4         2
    |         |
    +----1----+
(0.0,0.0) (9.0,0.0)
# Examples

```jldoctest
julia> get_edge([9.0, 2.32])
2
"""
function get_edge(to::AbstractVector{<:Number}, tol::Real=eps())
    @inbounds if isapprox(to[2], 0.0, atol=tol)
        return 1
    elseif isapprox(to[1], 9.0, atol=tol)
        return 2
    elseif isapprox(to[2], 6.0, atol=tol)
        return 3
    else
        return 4
    end
end

"""
    raster(from::Real, to::Real, n::Int)

Rasters a range [`from`, `to`] in `n` segments.
[`from`, `to`] are exclusive.

# Examples

```jldoctest
julia> raster(0.0, 2.0, 3)
[0.5, 1.0, 1.5]
"""
function raster(from::Real, to::Real, n::Int)
    padding = (to - from)/(n+1)
    range(from+padding, stop=to-padding, length=n)
end

"""
    get_shadow_polygon(position::AbstractVector{<:Number}, obstacle::Robot{<:Number}, config::Config)

Calculates the shadow of a virtial omnidirectional lightsource on the `position` for a robot obstacle. Assumes that the robot is a circle with `position` and radius `size`.

# Examples

```jldoctest
julia> config = SearchBall.get_config(["--add_myPlayer","\"--position 4.0 4.0\""]);
julia> get_shadow_polygon([0.0, 0.0], config.ws.myPlayers[1], config)
5-element Array{GeometryTypes.Point{2,Float64},1}:
 [4.10322, 3.89116]
 [0.0, 0.0]
 [0.0, 0.0]
 [3.89116, 4.10322]
 [4.10322, 3.89116]
"""
function get_shadow_polygon(position::AbstractVector{<:Number}, obstacle::Robot{<:Number}, config::Config)
        # get left (tan2) and right (tan1) tangents
        tan1 = outer_tangent(gt.Point2(position), gt.Circle(gt.Point2(obstacle), get_size(obstacle)))
        isinside1, isec1 = intersection(tan1, gt.HyperRectangle(config.field_corners))
        tan2 = outer_tangent(gt.Circle(gt.Point2(obstacle), get_size(obstacle)), gt.Point2(position), true)
        isinside2, isec2 = intersection(tan2, gt.HyperRectangle(config.field_corners))

        !(isinside1 && isinside2) && return Vector{Float64}[]

        # add corners of the field to the polygones, if the corner belongs to it
        edge1 = get_edge(isec2, 1e-10)
        edge2 = get_edge(isec1, 1e-10)
        vcat([tan2[2], isec2], config.field_corners[intervall(edge1, edge2, length(config.field_corners))], [isec1, tan1[2], tan2[2]])
end

"""
    get_shadow_polygons(current_player::Robot{<:Number}, config::Config, with_hfov::Bool=false, pos::AbstractVector{<:Number}=current_player, orientation::Number=current_player.body_orientation)

Returns an array with all shadow polygons occur by a view position `new_pos` within
the current world state `ws`.

# Examples

```jldoctest
julia> config = get_config(["--add_myPlayer","\"--position 4.0 4.0\"","--add_opponent","\"--position 6.0 4.0\""])
julia> get_shadow_polygons(config.ws.myPlayers[1], config)
1-element Array{Array{GeometryTypes.Point{2,Float64},1},1}:
 GeometryTypes.Point{2,Float64}[[9.0, 4.3761], [5.9887, 4.1496], [5.9887, 3.8504], [9.0, 3.6239]]
"""
function get_shadow_polygons(current_player::Robot{<:Number}, config::Config, with_hfov::Bool=false, pos::AbstractVector{<:Number}=current_player, orientation::Number=current_player.body_orientation)
    # TODO: only obstacle which are within line of sight and in the hfov
    polygons = Vector{gt.Point2{Float64}}[get_shadow_polygon(pos, obstacle, config) for obstacle in vcat(config.ws.myPlayers, config.ws.opponents) if obstacle != current_player]

    if with_hfov
        init_orientation = [1.0, 0.0]
        d1 = rotate2d(init_orientation, current_player.body_orientation + current_player.hfov/2)
        isinside1, isec1 = intersection(gt.LineSegment(gt.Point2(pos), gt.Point2(d1 .+ pos)), gt.HyperRectangle(config.field_corners))
        d2 = rotate2d(init_orientation, current_player.body_orientation - current_player.hfov/2)
        isinside2, isec2 = intersection(gt.LineSegment(gt.Point2(pos), gt.Point2(d2.+ pos)), gt.HyperRectangle(config.field_corners))
        if isinside1 && isinside2
            edge1 = get_edge(isec1, 1e-10)
            edge2 = get_edge(isec2, 1e-10)
            corner_numbers = intervall(edge1, edge2, length(config.field_corners))
            outofview_field = vcat([pos, isec1], config.field_corners[intervall(edge1, edge2, length(config.field_corners), current_player.hfov < π)], [isec2])
            push!(polygons, outofview_field)
        end
    end

    return polygon_union(polygons)
end

using Distributed
using SharedArrays

"""
    sample(config::Config, off_idx::Int, my_reduce::Function=(x -> polygon_area(@view(x[2:end]))), my_map::Function=get_shadow)

# Optional Arguments
- `my_reduce::Function=(x -> polygon_area(@view(x[2:end])))`: function for calculation the scalar value on the current position, by default the area of the shadow (polygon)
- `my_map::Function=get_shadow`: function, which shall be evaluation on every position on the field, by default the shadow of the current player of myPlayers

Calculates for a raster on the field the shadow area.
"""
function sample(config::Config, off_idx::Int, use_hfov::Bool=false, my_map::Function=get_shadow_polygons, my_reduce::Function=polygon_area; resolution::AbstractArray{Int}=[90, 60])
    ws = config.ws
    field_corners = config.field_corners
    # initialization
    scalar_field = SharedArray(zeros(Float64, resolution...))
    # insides = falses(resolution...)
    insides = SharedArray{Bool}(resolution...)

    x_raster = raster(field_corners[1][1], field_corners[3][1], resolution[1])
    # x_length = length(x_raster)
    y_raster = raster(field_corners[1][2], field_corners[3][2], resolution[2])
    @sync @distributed for ind_x in eachindex(x_raster)
        w = x_raster[ind_x]
        @distributed for ind_y in eachindex(y_raster)
            h = y_raster[ind_y]
            shadow_area = 0.0
            # checks if no player is at this exact position
            insides[ind_x, ind_y] = !any(map(p -> is_inside([w, h], gt.Circle(gt.Point2(p), get_size(p)*1.5+eps())), [x for x in vcat(ws.myPlayers, ws.opponents) if x!=ws.myPlayers[off_idx] && is_inside(x, field_corners)]))
            if insides[ind_x, ind_y]
                polygons = my_map(ws.myPlayers[off_idx], config, use_hfov, [w, h])
                for polygon in polygons
                    shadow_area += my_reduce(polygon)
                end
            end
            scalar_field[ind_x, ind_y] = shadow_area
            # config.set_progress_bar(ind_x/x_length)
        end
    end

    scalar_field, insides
end

using ColorSchemes: inferno
const color_scheme = deepcopy(inferno)
reverse!(color_scheme.colors)

using Printf

const color_bar = get(inferno, reshape(collect(0.0:0.01:1.0), 1, 101), :clamp)

"""
    send_background(vals::AbstractArray{<:Real}, ins::AbstractArray{Bool})

Samples the shadow function on a raster of the field and draws the scalarfield in the gui.
"""
function send_background(vals::AbstractArray{<:Real}, ins::AbstractArray{Bool}, config::Config, bounds::Union{Nothing, Tuple{<:Real, <:Real}}=nothing; allways_repaint::Bool=false)

    if typeof(bounds) <: Nothing
        # clean up the positions where the player stay (players of myPlayers can't go there)
        @inbounds mean_val = stat.median(vals[ins])
        @inbounds vals[.!ins] = mean_val
        # vals[isnan.(vals)] = mean_val
        min_val = minimum(vals)
        max_val = maximum(vals)
    else
        min_val, max_val = bounds
    end

    # make a colored image from the scalar field
    image = get(color_scheme, vals, (min_val, max_val)) # :extrema

    # draw stuff
    config.drawables["_fieldBackground"] = ([[0.0, 6.0], [9.0, 0.0]], () -> (image, allways_repaint))
    config.drawables["_color_bar"] = ([[9.2, 6.0], [9.4, 0.0]], () -> (color_bar, false))
    config.drawables["color_bar_edge"] = ([[9.2, 6.0], [9.2, 0.0], [9.4, 0.0], [9.4, 6.0], [9.2, 6.0]], x -> GraphicLine(x, fill=false))
    config.drawables["text_min"] = ([[9.6, 6.0]], x -> GraphicText(x[1], @sprintf("%.2fm²", min_val), textsize=12.0, color=[0.0, 0.0, 0.0, 1.0]))
    config.drawables["text_33p"] = ([[9.6, 4.0]], x -> GraphicText(x[1], @sprintf("%.2fm²", min_val+(max_val-min_val)/3.0), textsize=12.0, color=[0.0, 0.0, 0.0, 1.0]))
    config.drawables["text_66p"] = ([[9.6, 2.0]], x -> GraphicText(x[1], @sprintf("%.2fm²", min_val+2*(max_val-min_val)/3.0), textsize=12.0, color=[0.0, 0.0, 0.0, 1.0]))
    config.drawables["text_max"] = ([[9.6, 0.0]], x -> GraphicText(x[1], @sprintf("%.2fm²", max_val), textsize=12.0, color=[0.0, 0.0, 0.0, 1.0]))
end

"""
    clear_background!(config::Config)



# Examples

```jldoctest
julia> clear_background!()

```
"""
function clear_background!(config::Config)
    delete!(config.drawables, "_fieldBackground")
    delete!(config.drawables, "_color_bar")
    delete!(config.drawables, "color_bar_edge")
    delete!(config.drawables, "text_min")
    delete!(config.drawables, "text_33p")
    delete!(config.drawables, "text_66p")
    delete!(config.drawables, "text_max")
end
