module BaJakob

    using SearchBall
    using GeometryTypes
    using Reactive

    function calc_myPlayers(config::SearchBall.Config, dt::Number,
        set_type::Symbol, moved_object::Union{SearchBall.Object{<:Number}, Nothing}=nothing)

        world_state = config.ws

        try
            # Initialization
            if set_type == :init
                config.printables["dist:opp-off"] = Signal("")
                config.printables["dist:opp-ball"] = Signal("")
                config.printables["dist:off-ball"] = Signal("")
            end

        catch error
        end

        return world_state.myPlayers
    end

    function calc_opponend(config::SearchBall.Config,
        dt::Number, set_type::Symbol,
        moved_object::Union{SearchBall.Object{<:Number}, Nothing}=nothing)

        world_state = config.ws
        if set_type == :init
            # Initialization
        end

        return world_state.opponents
    end

    function run_strategies(config::SearchBall.Config, dt::Number = 0.1,
        set_type::Symbol=:default,
        moved_object::Union{SearchBall.Object{<:Number}, Nothing}=nothing)

        return (
            calc_myPlayers(config, dt, set_type, moved_object),
            calc_opponend(config, dt, set_type, moved_object)
        )
    end

end
