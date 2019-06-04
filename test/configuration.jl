@testset "Config" begin

    @testset "ArgParse.parse_item" begin
        robot = sb.ArgParse.parse_item(sb.Robot{Float64}, "\"--position 0.2 2.0\"")
        @test sb.get_position(robot) == [0.2, 2.0]
    end;

    @testset "get_config" begin
        config = sb.get_config(["--strategy", "TestStrategy"])
        @test length(config.ws.myPlayers) == 0
        @test typeof(sb.get_strategy(config)) <: Module
        @test config.active_strategy == "TestStrategy"
    end;

end;
