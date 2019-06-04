module GlobalComShadow

using Printf
import SearchBall, GeometryTypes
const sb = SearchBall
const gt = GeometryTypes

function init_strategies(config; kwargs...)
    sb.init_text!(config, "shadow", "")
    sb.add_check_button!(config, "with hfov", "with hfov") do widget
        run_strategies(config)
    end
end

function calc_myPlayers(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    sb.remove_graphics_filter!(config) do s
        startswith(s, "coreShadow")
    end
    
    all_shadows = [sb.get_shadow_polygons(player, config, sb.get_manip_value(config, "with hfov")) for player in ws.myPlayers if sb.is_inside(player, config.field_corners)]

    if !isempty(all_shadows)
        core_shadows = all_shadows[1]
        for off_shadow in @view(all_shadows[2:end])
            new_core_shadows = Vector{gt.Point2{Float64}}[]
            for s1 in core_shadows, s2 in off_shadow
                core_shads = sb.polygon_intersection(s1, s2)
                for core in core_shads
                    if length(core) > 2
                        push!(new_core_shadows, core)
                    end
                end
            end
            core_shadows = new_core_shadows
        end
    else
        core_shadows = []
    end

    area = 0.0
    for (idx, shadow) in enumerate(core_shadows)
        isempty(shadow) && continue
        push!(shadow, shadow[1])
        sb.show_graphic!(config, string("coreShadow", idx), shadow, sb.GraphicLine(fill=true, fillcolor=[0.0, 0.0, 0.0, 0.2]))
        area += sb.polygon_area(shadow)
    end
    sb.show_text!(config, "shadow", @sprintf("%.2fm²", area))
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
