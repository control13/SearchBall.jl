@testset "StrategyUtils" begin

    @testset "is_in_line_of_sight Tests" begin
        # myPlayer at [3,3]
        # obstacle (opponent) at [6,3] and size 0.3
        # ball at [8,3]
        ws = sb.WorldState([sb.Robot([3.0, 3.0], 0.0)], [sb.Robot([6.0, 3.0], 0.0)], [sb.Ball([8.0, 3.0])])
        @test sb.is_in_line_of_sight(ws, ws.myPlayers[1], ws.obstacles[1]) == false
        ws = sb.WorldState([sb.Robot([3.0, 3.0], 0.0)], [sb.Robot([6.0, 3.0], 0.0)], [sb.Ball([8.0, 3.0])])
        @test sb.is_in_line_of_sight(ws, ws.myPlayers[1], ws.obstacles[1], excludes=[ws.opponents[1]]) == false
        @test sb.is_in_line_of_sight(ws, ws.myPlayers[1], ws.obstacles[1], excludes=[ws.opponents[1], ws.myPlayers[1]]) == true
        ws = sb.WorldState([sb.Robot([3.0, 3.0], 0.0)], [sb.Robot([6.0, 3.15], 0.0)], [sb.Ball([8.0, 3.0])])
        @test sb.is_in_line_of_sight(ws, ws.myPlayers[1], ws.obstacles[1], tol=0.05, excludes=[ws.myPlayers[1]]) == true
        ws = sb.WorldState([sb.Robot([8.0, 6.0], 0.0)], [sb.Robot([6.0, 3.0], 0.0)], [sb.Ball([8.0, 3.0])])
        @test sb.is_in_line_of_sight(ws, ws.myPlayers[1], ws.obstacles[1]) == false
        @test sb.is_in_line_of_sight(ws, ws.myPlayers[1], ws.obstacles[1], excludes=[ws.myPlayers[1]]) == true
    end;

    @testset "iswithin_hfov Tests" begin
        robot = sb.Robot([2.0, 2.0], 0.0)
        @test sb.iswithin_hfov(robot, [4.0, 2.0]) == true
        @test sb.iswithin_hfov(robot, [0.0, 2.0]) == false
        @test sb.iswithin_hfov(robot, [4.0, 9.0]) == false
        @test sb.iswithin_hfov(robot, [3.0, 0.0]) == false
        robot = sb.Robot([0.0, 0.0], 0.0)
        @test sb.iswithin_hfov(robot, [3.0, 0.0]) == true
    end;

    # @testset "what_is_in_line_of_sight Tests" begin
    #     # myPlayer at [3,3]
    #     # obstacle (opponent) at [6,3] and size 0.3
    #     # ball at [8,3]
    #     ws = sb.WorldState([sb.Posture([3.0, 3.0], 0.0)], [sb.Posture([6.0, 3.0], 0.0)], [8.0, 3.0])
    #     @test sb.what_is_in_line_of_sight(ws, ws.myPlayers[1], ws.ball) == [sb.Posture([6.0, 3.0], 0.0)]
    #     ws = sb.WorldState([sb.Posture([3.0, 3.0], 0.0)], [sb.Posture([6.0, 3.0], 0.0)], [8.0, 3.0])
    #     @test sb.what_is_in_line_of_sight(ws, ws.myPlayers[1], ws.ball, excludes=[[6.0, 3.0]]) == []
    #     ws = sb.WorldState([sb.Posture([3.0, 3.0], 0.0)], [sb.Posture([6.0, 3.15], 0.0)], [8.0, 3.0])
    #     @test sb.what_is_in_line_of_sight(ws, ws.myPlayers[1], ws.ball, tol=0.05) == []
    #     ws = sb.WorldState([sb.Posture([8.0, 6.0], 0.0)], [sb.Posture([6.0, 3.0], 0.0)], [8.0, 3.0])
    #     @test sb.what_is_in_line_of_sight(ws, ws.myPlayers[1], ws.ball) == []
    # end;

    @testset "intervall" begin
        @test sb.intervall(1, 4, 4) == [2, 3, 4]
        @test sb.intervall(1, 4, 4, true) == [2, 3, 4]
        @test sb.intervall(3, 1, 4) == [4, 1]
        @test sb.intervall(3, 1, 4, true) == [4, 1]
        @test sb.intervall(5, 3, 8) == [6, 7, 8, 1, 2, 3]
        @test sb.intervall(5, 3, 8, true) == [6, 7, 8, 1, 2, 3]
        @test sb.intervall(2, 2, 4) == []
        @test sb.intervall(2, 2, 4, true) == [3, 4, 1, 2]
        @test sb.intervall(5, 5, 8, true) == [6, 7, 8, 1, 2, 3, 4, 5]
    end;

    @testset "get_edge Tests" begin
        @test sb.get_edge([9.0, 2.32]) == 2
        @test sb.get_edge([9.0, 0.0]) == 1
        @test sb.get_edge([9.0, 6.0]) == 2
        @test sb.get_edge([0.0, 6.0]) == 3
        @test sb.get_edge([0.0, 0.0]) == 1
        @test sb.get_edge([0.0, 2.32]) == 4
        @test sb.get_edge([5.0, 6.0]) == 3
        @test sb.get_edge([1.0, 0.0]) == 1
    end;

    @testset "raster Tests" begin
        @test sb.raster(0.0, 10.0, 9) == 1.0:9.0
        @test sb.raster(0.0, 2.0, 3) == 0.5:0.5:1.5
        @test sb.raster(0.0, 6.0, 59) == 0.1:0.1:5.9
        @test sb.raster(0.0, 9.0, 89) == 0.1:0.1:8.9
    end;

    @testset "get_shadow_polygon Tests" begin
        config = sb.get_config(["--add_myPlayer","\"--position -0.5 1.0\""])
        @test string(sb.get_shadow_polygon([-1.0, 0.7],config.ws.myPlayers[1], config)) == "GeometryTypes.Point{2,Float64}[[-0.458511, 0.855852], [4.5, 2.28302], [1.23115, 3.0], [-0.607665, 1.10444], [-0.458511, 0.855852]]"
        @test string(sb.get_shadow_polygon([-1.5, 0.0],config.ws.myPlayers[1], config)) == "GeometryTypes.Point{2,Float64}[[-0.405782, 0.883282], [2.21643, 3.0], [0.921682, 3.0], [-0.616718, 1.09422], [-0.405782, 0.883282]]"
    end;

    @testset "get_shadow_polygons Tests" begin
        config = sb.get_config(["--add_myPlayer","\"--position -0.5 1.0\"","--add_opponent","\"--position 1.5 1.0\""])
        @test string(sb.get_shadow_polygons(config.ws.myPlayers[1], config)) == "Array{GeometryTypes.Point{2,Float64},1}[[[4.5, 1.3761], [1.4888, 1.1496], [1.4888, 0.8504], [4.5, 0.6239]]]"
        @test string(sb.get_shadow_polygons(config.ws.myPlayers[1], config, true)) == "Array{GeometryTypes.Point{2,Float64},1}[[[2.8974, 3.0], [0.0398, 0.6822], [-0.5, 1.0], [2.8974, 3.0], [-4.5, 3.0], [-0.0894, 0.5774], [-4.5, -3.0], [4.5, -3.0], [4.5, 3.0]]]"
    end;

end
