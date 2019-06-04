module CompareShadow

# TODO: OUTDATED
using Printf
import SearchBall, GeometryTypes
const sb = SearchBall
const gt = GeometryTypes

function init_strategies(config; kwargs...)
    ws = config.ws

    radioButtons = []
    for off_idx in eachindex(ws.myPlayers)
        config.printables[string("init_shadow", off_idx)] = re.Signal("")
        config.printables[string("left_shadow", off_idx)] = re.Signal("")
        initShadows[off_idx] = sb.calc_shadow(ws, off_idx, config.field_corners, "init_shadow")
        # initShadows[off_idx] = get_shadow(ws.myPlayers[off_idx], ws, field_corners)
        config.manipulators[string("DoffShadow",off_idx)] = (sb.check_button(string("draw shaodws for off",off_idx)),
        () -> begin
            if !sb.get_value(config.manipulators[string("DoffShadow",off_idx)][1], Bool)
                compare_shadow(ws, off_idx, initShadows[off_idx], config.field_corners)
            else
                [delete!(config.drawables, string("shadow", off_idx, idx)) for idx in 1:(length(ws.myPlayers)+length(ws.opponents))]
                push!(config.printables[string("shadow", off_idx)], "")
                push!(config.printables[string("left_shadow", off_idx)], "")
            end
        end
        )
        config.printables[string("shadow", off_idx)] = re.Signal("")
        rb = sb.radio_button(string(off_idx))
        config.manipulators["DNrb$off_idx"] = (rb,
        () -> begin
            if sb.get_value(config.manipulators["Ddraw function"][1], Bool)
                vals, ins = sb.sample(config, off_idx, x -> sum([sum(sb.polygon_area.(sb.polygon_intersection(@view(i[2:end]), @view(x[2:end])))) for i in initShadows[off_idx]]))
                sb.send_background(vals, ins, config)
            end
        end)
        push!(radioButtons, rb)
    end
    config.manipulators["show function for"] = sb.radio_button_group(radioButtons)

    config.manipulators["Ddraw function"] = (sb.check_button("draw background"),
        () -> begin
            if !sb.get_value(config.manipulators["Ddraw function"][1], Bool)
                off_idx = parse(Int, sb.get_value(config.manipulators["show function for"], String))
                vals, ins = sb.sample(config, off_idx, x -> sum([sum(sb.polygon_area.(sb.polygon_intersection(@view(i[2:end]), @view(x[2:end])))) for i in initShadows[off_idx]]))
                sb.send_background(vals, ins, config)
            else
                delete!(config.drawables, "_fieldBackground")
                delete!(config.drawables, "_color_bar")
                delete!(config.drawables, "color_bar_edge")
                delete!(config.drawables, "text_min")
                delete!(config.drawables, "text_33p")
                delete!(config.drawables, "text_66p")
                delete!(config.drawables, "text_max")
            end
        end
        )
    return
end

function compare_shadow(ws::sb.WorldState, off_idx::Int, initShadows::Vector{Vector{gt.Point2{Float64}}}, field_corners::AbstractVector{<:gt.Point2{<:Number}})
    currentShadows = sb.calc_shadow(ws, off_idx, field_corners)
    overlapping_shadow = sum([sum(sb.polygon_area.(sb.polygon_intersection(@view(i[2:end]), @view(c[2:end])))) for i in initShadows for c in currentShadows])
    # overlapping_shadow = 0.0
    push!(config.printables[string("left_shadow", off_idx)], @sprintf("%.2fm²", overlapping_shadow))
end

const initShadows = Dict{Int, Vector{Vector{gt.Point2{Float64}}}}()
function calc_myPlayers(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    if moved_object[1]==:opponent
        for off_idx in eachindex(ws.myPlayers)
            if !sb.is_inside(ws.myPlayers[off_idx], config.field_corners)
                continue
            end
            initShadows[off_idx] = sb.calc_shadow(ws, off_idx, config.field_corners, "init_shadow")
        end
    end
    for off_idx in eachindex(ws.myPlayers)
        if !sb.is_inside(ws.myPlayers[off_idx], config.field_corners)
            for k in keys(config.drawables)
                if startswith(k, string("shadow", off_idx))
                    delete!(config.drawables, k)
                end
            end
            continue
        end
        if !sb.get_value(config.manipulators[string("DoffShadow",off_idx)][1], Bool)
            continue
        end
        compare_shadow(ws, off_idx, initShadows[off_idx], config.field_corners)
    end
    offender_for_function = parse(Int, sb.get_value(config.manipulators["show function for"], String))
    if set_type ∈ [:reset, :release] && sb.get_value(config.manipulators["Ddraw function"][1], Bool) && (moved_object[1]!=:myPlayer || moved_object[2]!= offender_for_function)
        vals, ins = sb.sample(config, offender_for_function, x -> sum([sum(sb.polygon_area.(sb.polygon_intersection(@view(i[2:end]), @view(x[2:end])))) for i in initShadows[offender_for_function]]))
        sb.send_background(vals, ins, config)
    end
    return
end

function calc_opponend(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    return
end

function run_strategies(config::sb.Config, dt::Number=0, set_type::Symbol=:default, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    calc_myPlayers(config, dt, set_type, moved_object)
    calc_opponend(config, dt, set_type, moved_object)
    return
end

end
