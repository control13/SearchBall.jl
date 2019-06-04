module TestStrategy

using Printf
import SearchBall, GeometryTypes, LinearAlgebra
const sb = SearchBall
const gt = GeometryTypes
const la = LinearAlgebra

function init_strategies(config; kwargs...)
    sb.init_text!(config, "dist:opp-off")
    sb.init_text!(config, "dist:opp-ball")
    sb.init_text!(config, "dist:off-ball")
    sb.add_slider!(config, "c1", 0:0.05:1, 0.7)
end

v = 0.1 # m/s
function calc_myPlayers(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws
    
    # push!(config.printables["dist:opp-off"], @sprintf("%.2fm", sb.distance(ws.opponents[1], ws.myPlayers[1]))) # debug output
    sb.show_text!(config, "dist:opp-off", @sprintf("%.2fm", sb.distance(ws.opponents[1], ws.myPlayers[1]))) # debug output
    sb.show_text!(config, "dist:opp-ball", @sprintf("%.2fm", sb.distance(ws.opponents[1], ws.obstacles[1]))) # debug output
    sb.show_text!(config, "dist:off-ball", @sprintf("%.2fm", sb.distance(ws.obstacles[1], ws.myPlayers[1]))) # debug output
    if sb.is_in_line_of_sight(ws, ws.myPlayers[1], ws.obstacles[1])
        sb.send_order!(ws.myPlayers[1], sb.GoToAbsPosition(ws.myPlayers[1] .+ la.normalize(sb.vector(ws.myPlayers[1], ws.obstacles[1])) .* dt .* v))
    else
        t = sb.outer_tangent(gt.Circle(gt.Point2(ws.myPlayers[1]), dt*v), gt.Circle(gt.Point2(ws.opponents[1]), sb.get_size(ws.opponents[1])))
        sb.send_order!(ws.myPlayers[1], sb.GoToAbsPosition([x for x in t[1]]))
    end

    return
end

# c1, c2 = 0.5, 0.5
function calc_opponend(config::sb.Config, dt::Number, set_type::Symbol, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    ws = config.ws

    # parameter decision
    if sb.is_in_line_of_sight(ws, ws.myPlayers[1], ws.obstacles[1])
        c1, c2 = 0.0, 1.0
    else
        # c1, c2 = 0.7, 0.3
        c1 = sb.get_manip_value(config, "c1")
        c2 = 1.0 - c1
    end
    # helping lines
    a = la.normalize(sb.vector(ws.opponents[1], ws.myPlayers[1]))
    offender_ball = sb.vector(ws.myPlayers[1], ws.obstacles[1])
    n_off_ball = sb.normal2d(offender_ball)
    crossing, isec = sb.intersection(gt.LineSegment(gt.Point2(ws.myPlayers[1]), gt.Point2(ws.obstacles[1])), gt.LineSegment(gt.Point2(ws.opponents[1]), gt.Point2(ws.opponents[1].+n_off_ball)))

    sb.show_graphic!(config, "opp1", [ws.opponents[1], isec], sb.GraphicArrow(arrowloc=1.0, color=[0.0, 0.8, 0.2, 0.6]))

    b = la.normalize(sb.vector(ws.opponents[1], isec))
    if any(isnan.(b))
        b = gt.Point2(0.0) # prevents error if `sb.vector(ws.opponents[1], isec)` is a zero sb.vector, becaus normalize evaluates zero sb.vectors to NaN
    end
    
    g = c1.* a .+ c2.* b
    sb.send_order!(ws.opponents[1], sb.GoToAbsPosition(ws.opponents[1] .+ la.normalize(g) .* dt .* v))

    return
end

function run_strategies(config::sb.Config, dt::Number=0, set_type::Symbol=:default, moved_object::Union{sb.Object{<:Number}, Nothing}=nothing)
    calc_myPlayers(config, dt, set_type, moved_object)
    calc_opponend(config, dt, set_type, moved_object)
    return
end

end
