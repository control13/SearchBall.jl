module GrowingRegions

using Printf
import SearchBall, GeometryTypes
const sb = SearchBall
const gt = GeometryTypes

function init_strategies(config; kwargs...)
    # myPlayers
    ws = config.ws

    xlen, ylen = Int(ceil(config.field_size[1]))*10, Int(ceil(config.field_size[2]))*10
    config.global_communication["sight_regions"] = fill(0.0, (xlen, ylen))
    config.global_communication["x_raster"] = sb.raster(-config.field_size[1]/2, config.field_size[1]/2, xlen)
    config.global_communication["y_raster"] = sb.raster(-config.field_size[2]/2, config.field_size[2]/2, ylen)

    if length(ws.myPlayers) > 0
        # sb.add_check_button!(config, "draw function", "draw background")do widget
        #     if sb.get_value(widget, Bool)
        #         run_strategies(config, 0.0, :reset)
        #     else
        #         sb.clear_background!(config)
        #     end
        # end

    # radiobuttons = []
    #     for myIdx in eachindex(ws.myPlayers)
    #         myPlayer = ws.myPlayers[myIdx]
    #         rb = sb.add_radio_button!(config, "rb$myIdx", string(myIdx))do widget
    #             # if sb.get_manip_value(config, "draw function")
    #                 run_strategies(config, 0.0, :reset)
    #             # end
    #         end
    #         push!(radiobuttons, rb)
    #     end
    #     sb.add_radio_button_group!(config, "show function for", radiobuttons)
    end
    sb.add_check_button!(config, "sight_regions", "show sight_regions") do widget
        run_strategies(config, 0.0, :reset)
    end
    sb.add_check_button!(config, "with hfov", "with hfov") do widget
        run_strategies(config, 0.0, :reset)
    end

    add_shadowcheckbuttons(ws.myPlayers, "myPlayer", config)
    add_shadowcheckbuttons(ws.opponents, "opponent", config)

    return
end

function update_sightregions!(config::sb.Config, dt::Number)
    x_raster = config.global_communication["x_raster"]
    y_raster = config.global_communication["y_raster"]
    regs = config.global_communication["sight_regions"]
    for (idx, x) in enumerate(x_raster), (idy, y) in enumerate(y_raster)
        position = [x, y]
        # @warn position
        # @warn config.ws.myPlayers[1]
        # @warn sb.is_in_line_of_sight(config.ws, config.ws.myPlayers[1], position)
        if any(map(p -> sb.iswithin_hfov(p, position) && sb.is_in_line_of_sight(config.ws, p, position, excludes=[p]), config.ws.myPlayers))
            # @warn "inside"
            regs[idx, idy] = 0.0
        elseif regs[idx, idy] ≤ 5.0
            regs[idx, idy] += dt/10
        end
    end
    # @warn regs[1, 1]
    # @warn regs[1, end]
    # @warn regs[end, 1]
    # @warn regs[end, end]
    return
end

function add_shadowcheckbuttons(player::AbstractVector{<:sb.Robot}, name::AbstractString, config::sb.Config)
    for myplayer_idx in eachindex(player)
        sb.add_check_button!(config, string(name, "Shadow", myplayer_idx), string(name, " ", myplayer_idx)) do widget
            if !sb.get_value(widget, Bool)
                sb.show_text!(config, string(name, " ", myplayer_idx, " area:"), "")
            end
            run_strategies(config)
        end
        sb.init_text!(config, string(name, " ", myplayer_idx, " area:"), "")
    end
end

function handle_shadow(player::AbstractVector{<:sb.Robot}, name::AbstractString, config::sb.Config)
    for myplayer_idx in eachindex(player)
        sb.remove_graphics_filter!(config) do s
            startswith(s, string(name, " ", myplayer_idx, " area:"))
        end

        if !sb.get_manip_value(config, string(name, "Shadow", myplayer_idx))
            continue
        end
        shadows = sb.get_shadow_polygons(player[myplayer_idx], config, sb.get_manip_value(config, "with hfov"))

        shadow_area = sum([sb.polygon_area(s) for s in shadows])

        sb.show_text!(config, string(name, " ", myplayer_idx, " area:"), @sprintf("%.2fm²",shadow_area))

        for (idx, shadow) in enumerate(shadows)
            if isempty(shadow)
                continue
            end
            sb.show_graphic!(config, string(name, " ", myplayer_idx, " area:", idx), shadow[vcat(1:end, 1)], sb.GraphicLine(fill=true, fillcolor=[0.0, 0.0, 0.0, 0.2]))
        end
    end
end

function calc_myPlayers(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    handle_shadow(ws.myPlayers, "myPlayer", config)
    handle_shadow(ws.opponents, "opponent", config)

    if length(ws.myPlayers) > 0
        if dt > 0
            update_sightregions!(config, dt)
        end
        if sb.get_manip_value(config, "sight_regions")
            sb.send_background(config.global_communication["sight_regions"], [true], config, (0.0, 5.0), allways_repaint=true)
            # @warn "sended"
        else
            sb.clear_background!(config)
        end
        # myforfunction = parse(Int, sb.get_manip_value(config, "show function for"))

        # if set_type ∈ [:reset, :release] && sb.get_manip_value(config, "draw function") && moved_object!=ws.myPlayers[myforfunction] && (sb.get_manip_value(config, "with hfov") || length(ws.myPlayers) > 1 || length(ws.opponents) > 0)
        #     vals, ins = sb.sample(config, myforfunction, sb.get_manip_value(config, "with hfov"))
        #     sb.send_background(vals, ins, config)
        # end
    end

    return
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
