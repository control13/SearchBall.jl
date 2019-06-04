@testset "GameViewGtk" begin

    @testset "get_world_to_screen_coeffs Tests" begin
        @test string(sb.get_world_to_screen_coeffs(900, 1500, [9.0, 6.0], [1.0, 1.0])) == string((81.81818181818181, [0.0, 422.727]))
    end;

    @testset "world_to_screen Tests" begin
        @test sb.world_to_screen([-4.5, -3.0], [4.5, 3.0], [1.0, 1.0], 75.0, [0.0, 450.0]) == [75.0, 525.0]
    end;

    @testset "screen_to_world Tests" begin
        @test sb.screen_to_world([112.5, 525.0], [4.5, 3.0], [1.0, 1.0], 75.0, [0.0, 450.0]) == [-4.0, -3.0]
    end;

end;
