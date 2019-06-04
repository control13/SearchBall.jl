module BaMichelle

using SearchBall
using GeometryTypes, Reactive
using Deldir

strategy_logger = SearchBall.getlogger(split(string(current_module()), ".")[end])
SearchBall.setlevel!(strategy_logger, "debug")
log_debug(text...) = SearchBall.debug(strategy_logger, strip(string(["$x " for x in text]...)))

function calc_myPlayers(config::SearchBall.Config, dt::Number, set_type::Symbol, moved_object::Union{SearchBall.Object{<:Number}, Nothing}=nothing)
    ws = config.ws
    if set_type==:init
        #initialization
    end

    # Berechnung der Voronoi-Zellen

    # Zeichnen der Kanten der Voronoi-Zellen
    ## config.drawables[strig("line", idx)] = ([edgw_start, edge_end], x -> SearchBall.GraphicLine(x, color=[0.0, 0.0, 0.0, 1.0]))

    #Eigene Spieler Voronoi Zellen

#    x_pos=getindex.(ws.myPlayers,1)
#    y_pos=getindex.(ws.myPlayers,2)

#    del, vor, summ=Deldir.deldirwrapper(x_pos,y_pos,[0.0; config.field_size[1]; 0.0; config.field_size[2]])

#    i=1
#    while i<=size(vor)[1]
#        config.drawables[string("line",i)]=([[vor[i,1],vor[i,2]],[vor[i,3],vor[i,4]]],x -> SearchBall.GraphicArrow(x,arrowloc=1.0, color=[0.0,0.8,0.2,0.6]))
#        i +=1
#    end

    #Loeschen der Linien
    for s in keys(config.drawables)
        if startswith(s,"aline")
            delete!(config.drawables,s)
        end
    end

    #Voronoi Zellen für Gegner und Eigenen Spieler
    x_pos=vcat(getindex.(ws.myPlayers,1),getindex.(ws.opponents,1))
    y_pos=vcat(getindex.(ws.myPlayers,2),getindex.(ws.opponents,2))

    del, vor, summ=Deldir.deldirwrapper(x_pos,y_pos,[0.0; config.field_size[1]; 0.0; config.field_size[2]])

    i=1
    while i<=size(vor)[1]
        config.drawables[string("aline",i)]=([[vor[i,1],vor[i,2]],[vor[i,3],vor[i,4]]],x -> SearchBall.GraphicLine(x, color=[0.9,0.3,0.6,0.8]))
        i +=1
    end
    ws.myPlayers
end

function calc_opponend(config::SearchBall.Config, dt::Number, set_type::Symbol, moved_object::Union{SearchBall.Object{<:Number}, Nothing}=nothing)
    ws = config.ws
    if set_type==:init
        #initialization
    end
    ws.opponents
end

function run_strategies(config::SearchBall.Config, dt::Number=0, set_type::Symbol=:default, moved_object::Union{SearchBall.Object{<:Number}, Nothing}=nothing)
    (
        calc_myPlayers(config, dt, set_type, moved_object),
        calc_opponend(config, dt, set_type, moved_object)
    )
end

end
