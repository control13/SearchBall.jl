find . -name "*\.jl\.[0-9]*\.mem" -delete
julia --track-allocation=user other/gameSimulationNN01test.jl
julia getCoverage.jl
