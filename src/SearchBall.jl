__precompile__(true)
module SearchBall

    using Reactive
    include("reactive_extension.jl")
    include("geometry_utils.jl")
    include("orders.jl")
    include("graphics_2d.jl")
    include("world_state.jl")
    include("handle_orders.jl")
    include("configuration.jl")
    include("strategy_utils.jl")
    include("strategies/compare_shadow.jl")
    include("strategies/show_shadow.jl")
    include("strategies/test_strategy.jl")
    include("strategies/global_com_shadow.jl")
    # include("strategies/ba_jakob.jl")
    include("strategies/startpositions01.jl")
    include("strategies/pushball_NN.jl")
    include("strategies/growing_regions.jl")

    include("game_state.jl")
    include("game_view_gtk.jl")

    export main

    function main(arguments::AbstractVector{<:AbstractString},
        ignore_commandline::Bool=false)

        if ignore_commandline || isinteractive()
            config = get_config(arguments)
        else
            # Parse the command line arguments as initialization
            config = get_config(ARGS)
        end

        start_view(config)
    end

    main(config_file_path::AbstractString) =
        main(String["--file", config_file_path], true)
    main(ignore_commandline::Bool=false) = main(String[], ignore_commandline)
end
