using Gtk
import GeometryTypes, Cairo, Colors, Reactive, Chipmunk, DelimitedFiles
const gt = GeometryTypes
const ca = Cairo
const co = Colors
const re = Reactive
const df = DelimitedFiles

"""
    ClickObject

Struct for keeping the clicked object on screen and additional rendering
information.
The object is accessed by reference, so changes are visible the multiple owners.
"""
mutable struct ClickObject
    kind::Symbol
    object::Union{Object{<:Number}, Nothing}
end

mutable struct FunctionWrapper
    fun::Function
end

"""
get_world_to_screen_coeffs(width::Integer, height::Integer,
    field_size::AbstractVector{<:AbstractFloat},
    border_strip::AbstractVector{<:AbstractFloat})

Get the coefficints for world to screen and screen to world coordiate
transformation.

# Examples

```jldoctest
julia> get_world_to_screen_coeffs(900, 1500, [9.0, 6.0], [1.0, 1.0])
(81.81818181818181, [0.0, 422.727])
```
"""
function get_world_to_screen_coeffs(width::Integer, height::Integer,
    field_size::AbstractVector{<:AbstractFloat},
    border_strip::AbstractVector{<:AbstractFloat})

    @inbounds field_aspect_ratio =
        (field_size[2] + 2*border_strip[2]) /
        (field_size[1] + 2*border_strip[1])

    if width*field_aspect_ratio > height
        width_offset = (width*field_aspect_ratio - height)/2.0
        height_offset = 0.0
        @inbounds multiplier = height/(field_size[2] + 2*border_strip[2])#8.0
    else
        height_offset = (height - width*field_aspect_ratio)/2.0
        width_offset = 0.0
        @inbounds multiplier = width/(field_size[1] + 2*border_strip[1])#12.0
    end
    multiplier, [width_offset, height_offset]
end

"""
world_to_screen(x::AbstractVector{<:AbstractFloat},
    multiplier::AbstractFloat, offset::AbstractVector{<:AbstractFloat},
    xy_inversion_correction::AbstractVector{<:Real}=[0, 0],
    border_strip::AbstractVector{<:AbstractFloat})

Converts world to screen coordinates by respecting the field origin.
The origin of worldcoordinates is the lower left corner of the field.
Respects the inversion of coordinate axis, if the width or the hieght is set to
the `xy_inversion_correction` array ([width, height]). Axis, which should not be
inverted are set to zero. For example: [0, height] for an inversion of the y-Axis,
what is quite common for the most gui-frameworks.

# Examples

```jldoctest
julia> world_to_screen([1.0, 1.0], 75.0, [0.0, 450.0], [1.0, 1.0])
2-element Array{Float64,1}:
 150.0
 600.0
```
"""
@inline function world_to_screen(x::AbstractVector{<:AbstractFloat},
    center_offset::AbstractVector{<:AbstractFloat},
    border_strip::AbstractVector{<:AbstractFloat},
    multiplier::AbstractFloat,
    offset::AbstractVector{<:AbstractFloat},
    xy_inversion_correction::AbstractVector{<:Real}=[0, 0])

    abs.(xy_inversion_correction .- ((x .+ border_strip .+ center_offset).*multiplier .+ offset))
end

"""
screen_to_world(x::AbstractVector{<:AbstractFloat},
    multiplier::AbstractFloat, offset::AbstractVector{<:AbstractFloat},
    xy_inversion_correction::AbstractVector{<:Real}=[0, 0],
    border_strip::AbstractVector{<:AbstractFloat})

Converts screen to worl coordinates by respecting the field origin.
The origin of worldcoordinates is the lower left corner of the field.
Respects the inversion of coordinate axis, if the width or the hieght is set to
the `xy_inversion_correction` array ([width, height]). Axis, which should not be
inverted are set to zero. For example: [0, height] for an inversion of the y-Axis,
what is quite common for the most gui-frameworks.

# Examples

```jldoctest
julia> screen_to_world([112.5, 525.0], 75.0, [0.0, 450.0], [1.0, 1.0])
2-element Array{Float64,1}:
 0.5
 0.0
```
"""
@inline function screen_to_world(x::AbstractVector{<:AbstractFloat},
    center_offset::AbstractVector{<:AbstractFloat},
    border_strip::AbstractVector{<:AbstractFloat},
    multiplier::AbstractFloat,
    offset::AbstractVector{<:AbstractFloat},
    xy_inversion_correction::AbstractVector{<:Real}=[0, 0])

    ((abs.(xy_inversion_correction .- x) .- offset)./multiplier .- border_strip .- center_offset)
end

"""
    draw_player!(ctx, pos::Robot{<:Number}, radius::Real, col::co.RGBA{<:Number}, multiplier::Number, wts::Function)

Draws a Robot as a circle with radius `get_size(robot)` on its position on the screen. Adds a isosceles triangle for the body orientation with its head heaing in the direction of the angle.
"""
function draw_player!(ctx, robot::Robot{<:Number}, radius::Real, col::co.RGBA{<:Number}, multiplier::Number, wts::Function)
    arc_open = robot.hfov/2 # β/2
    add_r = radius/3
    x, y = wts(robot)
    angle = robot.body_orientation
    arrow_a = wts([cos(angle), sin(angle)] .* (radius + add_r) .+ robot)
    arrow_b = wts([cos(angle + arc_open), sin(angle + arc_open)] .* radius .+ robot)
    arrow_c = wts([cos(angle - arc_open), sin(angle - arc_open)] .* radius .+ robot)
    # ca.circle(ctx, x, y, radius*multiplier)
    # ca.set_source_rgba(ctx, col.r, col.g, col.b, col.alpha)

    sketch(ctx, GraphicLine([arrow_a, arrow_b, arrow_c, arrow_a], fill=true, fillcolor=[col.r, col.g, col.b, col.alpha]))
    draw_circle!(ctx, robot, radius, col, multiplier, wts)
end

"""
    draw_circle!(ctx, pos::AbstractVector{<:AbstractFloat}, radius::Real,
        col::co.RGBA{<:AbstractFloat}, multiplier::AbstractFloat, wts::Function)

# Attributes
- `ctx`: grphics context for drawing
- `pos::AbstractVector{<:Number}`: the postion for drawing the circle in world coordinates
- `radius:Real`: the radius of the circle in world
- `col::co.RGBA{<:Number}`: color in rgba (0..1) format
- `multiplier::Number, offset::AbstractVector{<:Number}`: render coefficients, returned by the function `get_world_to_screen_coeffs`
- `wts::Function`: function for converting world coordinates to screen coordinates (must have exact one argument of type AbstractVector{<:Real})
(for drawing on canvas, the y axis is inverted respectivly to coordinatesystems used in math)
"""
function draw_circle!(ctx, pos::AbstractVector{<:Number}, radius::Real, col::co.RGBA{<:Number}, multiplier::Number, wts::Function)
    x, y = wts(pos)
    ca.circle(ctx, x, y, radius*multiplier)
    ca.set_source_rgba(ctx, col.r, col.g, col.b, col.alpha)
    ca.fill(ctx)
end

"""
    draw_and_save_pathlines!(ctx, cur_position::AbstractVector{<:AbstractFloat},
        pathline::AbstractVector{<:AbstractVector{<:AbstractFloat}},
        col::co.RGBA{<:AbstractFloat}, multiplier::AbstractFloat,
        offset::AbstractVector{<:AbstractFloat}, inv_y::Function,
        atol::Real=0.01, size::Real=1.0)

# Attributes
- `ctx`: graphics context for drawing
- `cur_position::AbstractVector{<:Number}`: the current position of the tracked object
- `pathline::AbstractVector{<:AbstractVector{<:Number}}`: vector for storing ll path line points
- `col::co.RGBA{<:Number}`: color in rgba (0..1) format
- `multiplier::Number, offset::AbstractVector{<:Number}`: render coefficients, returned by the function `get_world_to_screen_coeffs`
- `wts::Function`: function for converting world coordinates to screen coordinates (must have exact one argument of type AbstractVector{<:Real})
(for drawing on canvas, the y axis is inverted respectively to coordinatesystems used in math)
- `atol::Real=0.01`: tolerance for storing points to the path line, in m - default: only if `cur_postition` is more than 1 cm away from the last added position
- `size::Real=0.01`: size of the drawn points (drawn as circle) in m
"""
function draw_and_save_pathlines!(ctx,
    cur_position::AbstractVector{<:AbstractFloat},
    pathline::AbstractVector{<:AbstractVector{<:AbstractFloat}},
    col::co.RGBA{<:AbstractFloat}, multiplier::AbstractFloat,
    wts::Function, atol::Real=0.012, size::Real=0.01)

    if isempty(pathline) || !isapprox(pathline[end], cur_position, atol=atol)
        push!(pathline, copy(cur_position))
        if length(pathline) == 10_000
            @warn "More than 10_000 points saved for path lines."
        end
    end
    for line in pathline
        draw_circle!(ctx, line, size, col, multiplier, wts)
    end
end

using Images

mutable struct App
    config::Config
    background_cache::Dict{String, ca.CairoSurface{co.ColorTypes.RGB24}}

    main_window::GtkWindow
    root::Gtk.GtkWidget
    canvas::GtkCanvas
    status_bar::GtkStatusbar
    progress_bar::GtkProgressBar
    ball_check_button::GtkCheckButton

    myPlayer_pathline_signal::AbstractVector{re.Signal{Bool}}
    opponent_pathline_signal::AbstractVector{re.Signal{Bool}}
    obstacle_pathline_signal::AbstractVector{re.Signal{Bool}}

    center_offset::AbstractVector{<:Number} #TODO: move to config
    border_strip::AbstractVector{<:Number} #TODO: move to config

    App() = new()
end

"""
    Create a canvas for a football robot simulator app.
    Here the canvas is used to display the simulation of a strategy.
"""
function create_canvas(app::App)
    ws = app.config.ws
    field_size = app.config.field_size

    canvas = GtkCanvas()
    set_gtk_property!(canvas, :expand, true)
    set_gtk_property!(canvas, :width_request, 390)

    # Initialize arrays for pathlines
    # TODO: Move to Linked List from DataStructurres.jl for performance
    myPlayer_pathlines = fill(Vector{Float64}[], length(ws.myPlayers))
    opponent_pathlines = fill(Vector{Float64}[], length(ws.opponents))
    obstacle_pathlines = fill(Vector{Float64}[], length(ws.obstacles))

    # Register functions for deleting pathlines
    del_off_pathlines = [map(!, sig) for sig in app.myPlayer_pathline_signal]
    foreach(enumerate(del_off_pathlines)) do element
        idx, signal = element
        re.foreach(signal) do sig
            empty!(myPlayer_pathlines[idx])
            draw(canvas)
        end
    end
    del_opp_pathlines = [map(!, sig) for sig in app.opponent_pathline_signal]
    foreach(enumerate(del_opp_pathlines)) do element
        idx, signal = element
        re.foreach(signal) do sig
            empty!(opponent_pathlines[idx])
            draw(canvas)
        end
    end
    del_obs_pathlines = [map(!, sig) for sig in app.obstacle_pathline_signal]
    foreach(enumerate(del_obs_pathlines)) do element
        idx, signal = element
        re.foreach(signal) do sig
            empty!(obstacle_pathlines[idx])
            draw(canvas)
        end
    end

    @guarded draw(canvas) do widget
        # Initialization
        ctx = Gtk.getgc(canvas)
        h = Gtk.height(canvas)
        w = Gtk.width(canvas)
        ca.set_source_rgb(ctx, 1.0, 1.0, 1.0)
        ca.rectangle(ctx, 0.0, 0.0, w, h)
        ca.fill(ctx)
        ca.paint(ctx)

        multiplier, offset = get_world_to_screen_coeffs(w, h, field_size, app.border_strip)
        wts(pos::AbstractVector{<:Real}) = world_to_screen(pos, app.center_offset, app.border_strip, multiplier, offset, [0, h])

        # Draw all config.drawables, which are images and shall be below the other stuff
        for (name, (pos, fun)) in app.config.drawables
            if startswith(name, "_")
                @inbounds screen_tl_pos = wts(pos[1])
                @inbounds screent_br_pos = wts(pos[2])
                # screen_size = wts(pos[2], multiplier, offset) .- screen_tl_pos
                screen_size = screent_br_pos .- screen_tl_pos
                preimage, redraw = fun()
                if !haskey(app.background_cache, name) || redraw
                    @inbounds image = @view preimage[:, end:-1:1]
                    im_enlarged = imresize(image, trunc.(Int, screen_size)...)
                    if any(isnan.(im_enlarged))
                        @warn "resized image: isnan"
                        im_enlarged[isnan.(im_enlarged)] = co.ColorTypes.RGB(0.0, 0.0, 0.0)
                    end
                    app.background_cache[name] = ca.CairoImageSurface(co.RGB24.(im_enlarged))
                end
                ca.save(ctx)
                ca.rectangle(ctx, screen_tl_pos..., screen_size...)
                ca.clip(ctx)
                ca.new_path(ctx)
                ca.set_source(ctx, app.background_cache[name], screen_tl_pos...)
                ca.paint(ctx)
                ca.restore(ctx)
            end
        end

        # Draw field border
        ca.set_line_width(ctx,2)
        @inbounds tl_rect = wts([-field_size[1]/2, field_size[2]/2])
        size_rect = world_to_screen(field_size./2, app.center_offset, app.border_strip, multiplier, offset) .- tl_rect
        @inbounds ca.rectangle(ctx, tl_rect[1], tl_rect[2], size_rect[1], size_rect[2])
        ca.set_source_rgb(ctx, 0.0, 0.0, 0.0)
        ca.stroke(ctx)

        # Draw pathlines
        for idx in 1:length(ws.myPlayers)
            if re.value(app.myPlayer_pathline_signal[idx])
                @inbounds draw_and_save_pathlines!(ctx, ws.myPlayers[idx],
                    myPlayer_pathlines[idx], co.RGBA(0.1, 0.4, 1.0, 1.0),
                    multiplier, wts)
            end
        end
        for idx in 1:length(ws.opponents)
            if re.value(app.opponent_pathline_signal[idx])
                @inbounds draw_and_save_pathlines!(ctx, ws.opponents[idx],
                    opponent_pathlines[idx], co.RGBA(0.1, 0.1, 0.1, 1.0),
                    multiplier, wts)
            end
        end
        for idx in 1:length(ws.obstacles)
            if re.value(app.obstacle_pathline_signal[idx])
                @inbounds draw_and_save_pathlines!(ctx, ws.obstacles[idx],
                    obstacle_pathlines[idx], co.RGBA(ws.obstacles[idx].color...), multiplier, wts)
            end
        end

        # Draw player and ball
        for (idx, myPlayer) in enumerate(ws.myPlayers)
            draw_player!(ctx, myPlayer, get_size(myPlayer),
                co.RGBA(0.1, 0.4, 1.0, 1.0), multiplier, wts)
            sketch(ctx, GraphicText(wts(myPlayer),
                string(idx), textsize=15.0))
        end
        for (idx, opponent) in enumerate(ws.opponents)
            draw_player!(ctx, opponent, get_size(opponent),
                co.RGBA(0.1, 0.1, 0.1, 1.0), multiplier, wts)
            sketch(ctx, GraphicText(wts(opponent),
                string(idx), textsize=15.0))
        end
        for (idx, obstacle) in enumerate(ws.obstacles)
            !(typeof(obstacle.shape) <: Chipmunk.CircleShape) && continue
            draw_circle!(ctx, obstacle, get_size(obstacle),
                co.RGBA(obstacle.color...), multiplier, wts)
            sketch(ctx, GraphicText(wts(obstacle),
                string(idx), textsize=get_size(obstacle)*180))
        end
        # ws.isballwhere && draw_circle!(ctx, ws.ball, ws.ball_size, co.RGBA(1.0, 0.1, 0.1, 1.0),
            # multiplier, wts)

        # Draw config.drawables from GameState
        for (name, (pos, fun)) in app.config.drawables
            screen_pos = wts.(pos)
            if startswith(name, "_")
                continue
            end

            # If the element is too small, there will be an error
            @inbounds if length(screen_pos) == 2 && screen_pos[1] ≈ screen_pos[2]
                continue
            end
            sketch(ctx, fun(screen_pos))
        end
    end

    clicked_object = ClickObject(:nothing, nothing)
    stwWrap = FunctionWrapper(() -> nothing)

    function click_player!(clicked_object::ClickObject, player::Object{<:Number}, event_pos::gt.Point2)
        if is_inside(event_pos, gt.Circle(gt.Point2(player), get_size(player)))
            clicked_object.kind = :position
            clicked_object.object = player
            return true
        end
        norm_x, norm_y = event_pos .- player
        if typeof(player) <: Robot && get_size(player) < distance(event_pos, player) ≤ get_size(player)*1.3 # HACK: Magic number
            angle_diff = abs(player.body_orientation - atan(norm_y, norm_x))
            if angle_diff < π/4 || angle_diff > 15π/8
                clicked_object.kind = :angle
                clicked_object.object = player
                return true
            end
        end
        clicked_object.kind = :nothing
        false
    end

    canvas.mouse.button1press = @guarded (widget, event) -> begin
        pos = gt.Point2(stwWrap.fun([event.x, event.y]))
        for player in vcat(ws.myPlayers, ws.opponents, ws.obstacles)
            click_player!(clicked_object, player, pos) && return
        end
        return
    end

    function set_pos!(clicked_object::ClickObject, widget, event, kind::Symbol)
        pos = stwWrap.fun([event.x, event.y])
        if clicked_object.kind == :angle
            x, y = pos .- clicked_object.object
            angle = atan(y, x)
            clicked_object.object.body_orientation = angle
        elseif clicked_object.kind == :position
            set_position!(clicked_object.object, physic(ws, clicked_object.object, pos))
        else
            return
        end
        get_strategy(app.config).run_strategies(app.config, 0, kind, clicked_object.object)
        draw(widget)
    end

    canvas.mouse.button1motion = @guarded (widget, event) -> begin
        clicked_object.kind == :nothing && return
        # empty!(app.background_cache) # HACK: only no new drawing of cached
        set_pos!(clicked_object, widget, event, :motion)
    end

    canvas.mouse.button1release = @guarded (widget, event) -> begin
        clicked_object.kind == :nothing && return
        empty!(app.background_cache)
        set_pos!(clicked_object, widget, event, :release)
        clicked_object.kind = :nothing
    end

    canvas.mouse.button3release = @guarded (widget, event) -> begin
        pos = gt.Point2(stwWrap.fun([event.x, event.y]))
        if length(ws.myPlayers) ≥ 1
            for (idx, off) in enumerate(ws.myPlayers)
                if click_player!(clicked_object, off, pos)
                    remove_object!(app.config, ws.myPlayers[idx])
                    deleteat!(ws.myPlayers, idx)
                    # ws.player = vcat(ws.myPlayers, ws.opponents)
                    # ws.all = vcat(ws.myPlayers, ws.opponents, ws.obstacles)
                    break
                end
            end
        end
        if clicked_object.kind == :nothing && length(ws.opponents) ≥ 1
            for (idx, opp) in enumerate(ws.opponents)
                if click_player!(clicked_object, opp, pos)
                    remove_object!(app.config, ws.opponents[idx])
                    deleteat!(ws.opponents, idx)
                    # ws.player = vcat(ws.myPlayers, ws.opponents)
                    # ws.all = vcat(ws.myPlayers, ws.opponents, ws.obstacles)
                    break
                end
            end
        end
        if clicked_object.kind == :nothing && length(ws.obstacles) ≥ 1
            for (idx, obs) in enumerate(ws.obstacles)
                if click_player!(clicked_object, obs, pos)
                    remove_object!(app.config, ws.obstacles[idx])
                    deleteat!(ws.obstacles, idx)
                    # ws.player = vcat(ws.myPlayers, ws.opponents)
                    # ws.all = vcat(ws.myPlayers, ws.opponents, ws.obstacles)
                    break
                end
            end
        end
        clicked_object.kind == :nothing && return
        empty!(app.background_cache)
        clicked_object.kind = :nothing
        recreate_root!(app::App)
    end

    canvas.mouse.motion = @guarded (widget, event) -> begin
        x, y = stwWrap.fun([event.x, event.y])
        push!(app.status_bar, 0,
            @sprintf("Position: %.2f, %.2f - Screen: %.2f, %.2f",
                x, y, event.x, event.y))
    end

    # signal_connect(canvas_frame, "resize") do widget, width, height
    canvas.resize = @guarded (widget) -> begin
        h = Gtk.height(widget)
        w = Gtk.width(widget)
        multiplier, offset = get_world_to_screen_coeffs(w, h, field_size, app.border_strip)
        stwWrap.fun = x -> screen_to_world(x, app.center_offset, app.border_strip, multiplier, offset, [0, h])
    end

    return canvas
end

"""
    Create a strategy menu for a football robot simulator app.
"""
function create_strategy_menu(app::App)
    print_grid = GtkGrid()

    for (idx, p) in enumerate(app.config.printables)
        name, sig = p
        l1 = GtkLabel(string(name,": "))
        l2 = GtkLabel(string(re.value(sig)))
        foreach(sig) do s
            set_gtk_property!(l2, :label, s)
        end
        print_grid[1, idx] = l1
        print_grid[2, idx] = l2
    end

    manipulator_menu = GtkBox(:v)
    scrolled_manip_menu = GtkScrolledWindow(manipulator_menu)
    set_gtk_property!(scrolled_manip_menu, :vexpand, true)

    # Register all manipulators from the strategy
    for (name, widget) in app.config.manipulators
        widget, _, fun = widget
        if typeof(widget) <: Gtk.GtkRadioButtonGroupLeaf && length(widget) < 2
            continue
        end
        signal_connect(widget, "clicked") do w
            fun(w)
            empty!(app.background_cache)
            @async draw(app.canvas)
            return
        end
        if typeof(widget) <: Gtk.GtkRadioButtonLeaf
            continue
        end
        push!(manipulator_menu, GtkLabel(name))
        push!(manipulator_menu, widget)
    end

    result = GtkBox(:v)
    set_gtk_property!(result, :margin, 5)
    set_gtk_property!(result, :width_request, 150)
    push!(result, print_grid)
    push!(result, scrolled_manip_menu)

    return result
end

"""
    Create a general menu for a football robot simulator app.
"""
function create_general_menu(app::App)
    config = app.config
    ws = config.ws

    # Create stratgies combobox
    strategies_combobox = GtkComboBoxText()
    strategies_list = collect(keys(config.strategies_table))
    for s in strategies_list
        push!(strategies_combobox, s)
    end
    set_gtk_property!(strategies_combobox, :active,
        argmax(strategies_list.==config.active_strategy) - 1)

    # # Save worldstate for resetting
    # initial_ws = deepcopy(ws)

    # Create control elements
    config_filechooser_button = GtkButton("Load config")
    play_button = GtkToggleButton("Play Strategy")
    fps_label = GtkLabel("Frames per s")
    speed_scalebutton = GtkScale(false, 1:60)
    # velocity_scale_label = GtkLabel("Velocity scale in m/s")
    speed_adjustment = GtkAdjustment(speed_scalebutton)
    set_gtk_property!(speed_adjustment, :value, 30)
    # velocity_scalebutton = GtkScale(false, 0.05:0.05:1.0)
    # velocity_adjustment = GtkAdjustment(velocity_scalebutton)
    # set_gtk_property!(velocity_adjustment, :value, 0.1)
    step_button = GtkButton("Step")
    # reset_button = GtkButton("Reset")
    addmyPlayer_button = GtkButton("Add myPlayer")
    addopponent_button = GtkButton("Add opponent")
    pathlines_label = GtkLabel("Pathlines")

    set_gtk_property!(fps_label, :halign, Gtk.GConstants.GtkAlign.GTK_ALIGN_START)
    # set_gtk_property!(velocity_scale_label,
    #     :halign, Gtk.GConstants.GtkAlign.GTK_ALIGN_START)
    set_gtk_property!(pathlines_label,
        :halign, Gtk.GConstants.GtkAlign.GTK_ALIGN_START)

    # Create menu_box
    menu_box = GtkBox(:v)
    set_gtk_property!(menu_box, :margin, 5)
    set_gtk_property!(menu_box, :spacing, 5)

    push!(menu_box, strategies_combobox)
    push!(menu_box, config_filechooser_button)
    push!(menu_box, play_button)
    push!(menu_box, fps_label)
    push!(menu_box, speed_scalebutton)
    # push!(menu_box, velocity_scale_label)
    # push!(menu_box, velocity_scalebutton)
    push!(menu_box, step_button)
    # push!(menu_box, reset_button)
    push!(menu_box, addmyPlayer_button)
    push!(menu_box, addopponent_button)
    push!(menu_box, pathlines_label)

    pathline_menu_box = GtkBox(:v)
    set_gtk_property!(pathline_menu_box, :vexpand, true)

    # Register checkboxes for pathlines and emit signals
    app.myPlayer_pathline_signal = fill(re.Signal(false), length(ws.myPlayers))
    myPlayer_check_buttons = [GtkCheckButton("myPlayer $idx")
    for idx in 1:length(ws.myPlayers)]

    [signal_connect(off_check_button, "clicked") do widget
        push!(app.myPlayer_pathline_signal[idx],
            get_gtk_property(widget, :active, Bool))
        end
        for (idx, off_check_button) in enumerate(myPlayer_check_buttons)]
    append!(pathline_menu_box, myPlayer_check_buttons)

    app.opponent_pathline_signal = fill(re.Signal(false), length(ws.opponents))
    opponent_check_buttons =
        [GtkCheckButton("Opponent $idx") for idx in 1:length(ws.opponents)]
    [signal_connect(opp_check_button, "clicked") do widget
        push!(app.opponent_pathline_signal[idx],
            get_gtk_property(widget, :active, Bool))
        end
        for (idx, opp_check_button) in enumerate(opponent_check_buttons)]
    append!(pathline_menu_box, opponent_check_buttons)

    app.obstacle_pathline_signal = fill(re.Signal(false), length(ws.obstacles))
    obstacle_check_buttons =
        [GtkCheckButton("Obstacle $idx") for idx in 1:length(ws.obstacles)]
    [signal_connect(obs_check_button, "clicked") do widget
        push!(app.obstacle_pathline_signal[idx],
            get_gtk_property(widget, :active, Bool))
        end
        for (idx, obs_check_button) in enumerate(obstacle_check_buttons)]
    append!(pathline_menu_box, obstacle_check_buttons)

    push!(menu_box, GtkScrolledWindow(pathline_menu_box))

    signal_connect(config_filechooser_button, "clicked") do widget
        config_file_path = open_dialog("Choose config file.", app.main_window)
        if typeof(config_file_path)<:AbstractArray || config_file_path == ""
            return
        end
        empty!(app.background_cache)
        app.config = get_config(String["--file", config_file_path])
        recreate_root!(app::App)
    end

    signal_connect(strategies_combobox, "changed") do widget, others...
        idx = get_gtk_property(strategies_combobox, "active", Int)
        config.active_strategy = Gtk.bytestring(
            GAccessor.active_text(strategies_combobox))
        empty!(app.background_cache)
        recreate_root!(app::App)
    end

    # Perform animation
    animate = re.Signal(false)
    signal_connect(play_button, "clicked") do widget
        active = get_gtk_property(widget, :active, Bool)
        push!(animate, active)
        set_gtk_property!(widget, :label, active ? "Stop Strategy" : "Play Strategy")
    end
    animation_speed = re.Signal(get_gtk_property(speed_adjustment, :value, Int))
    signal_connect(speed_adjustment, "value-changed") do widget
        push!(animation_speed, get_gtk_property(widget, :value, Int))
    end
    animation = re.fpswhen(animate, animation_speed)

    function one_step(dt::Number)
        (dt ≤ 0.0 || dt > 2/get_gtk_property(speed_adjustment, :value, Float64)) && return
        # dt ≤ 0.0 && return
        update_game!(ws, dt, app.config)
        # physic_step(config, dt)
        @async draw(app.canvas)
        return
    end
    signal_connect(step_button, "clicked") do widget
        one_step(1/get_gtk_property(speed_adjustment, :value, Float64))
    end
    re.foreach(one_step, animation, init=nothing)

    # # Reset_button world
    # signal_connect(reset_button, "clicked") do widget
    #     empty!(app.background_cache)
    #     app.config.ws = initial_ws
    #     recreate_root!(app)
    # end

    # addmyPlayer_button world
    signal_connect(addmyPlayer_button, "clicked") do widget
        config.maximum_player_per_side ≤ length(config.ws.myPlayers) && return
        empty!(app.background_cache)
        add_myPlayer!(config)
        recreate_root!(app)
        # draw(app.canvas)
    end

    # addopponent_button world
    signal_connect(addopponent_button, "clicked") do widget
        config.maximum_player_per_side ≤ length(config.ws.opponents) && return
        empty!(app.background_cache)
        add_opponent!(config)
        recreate_root!(app)
    end

    # Initialize everything
    get_strategy(config).init_strategies(config)
    # get_strategy(config).init_strategies(config, x=reshape(df.readdlm("run01.txt"), (12)))
    # get_strategy(config).run_strategies(config)

    return menu_box
end

"""
Create and fill the root container of the window.
"""
function create_root!(app::App)

    empty!(app.config.drawables)
    empty!(app.config.printables)
    empty!(app.config.manipulators)

    left_menu = create_general_menu(app)
    app.canvas = create_canvas(app)
    right_menu = create_strategy_menu(app)

    # Setup main view
    main_view = GtkBox(:h)
    push!(main_view, left_menu)
    push!(main_view, app.canvas)
    push!(main_view, right_menu)

    # Setup status bar
    app.status_bar = GtkStatusbar()

    # app.progress_bar = ProgressBar()

    # function set_progressbar(fraction::Real)
    #     @debug fraction
    #     set_gtk_property!(app.progress_bar, :fraction, fraction)
    # end

    # app.config.set_progress_bar = set_progressbar

    # Setup root
    root = GtkBox(:v)
    push!(root, main_view)
    push!(root, app.status_bar)
    # push!(root, app.progress_bar)

    root
end

"""
Recreates the window root after changes.
"""
function recreate_root!(app::App)
    destroy(app.root)
    app.root = create_root!(app)
    push!(app.main_window, app.root)
    showall(app.main_window)
    # visible(app.ball_check_button, app.config.ws.isballwhere)
end

"""
    Create and start a new football robot simulator app.
"""
function start_view(config::Config)
    app = App()
    app.config = config
    app.border_strip = [0.7, 0.7] # HACK: magic numer
    app.center_offset = config.field_size./2 # HACK: magic numer
    app.background_cache = Dict{String, Any}()

    # Setup main window
    app.main_window = GtkWindow("Football Robot Simulator", 1440, 900) # HACK: magic numer
    app.root = create_root!(app)

    push!(app.main_window, app.root)

    showall(app.main_window)

    on_destroy(windowLeaf::Gtk.GtkWindowLeaf) = Gtk.gtk_quit()
    signal_connect(on_destroy, app.main_window, :destroy)

    # visible(app.ball_check_button, config.ws.isballwhere)

    Gtk.gtk_main()
end
