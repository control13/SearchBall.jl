include("src/MyUtils.jl")
using MyUtils

@testset "project Tests" begin
    @test project(5.0,4.0,6.0,3.0,8.0) == 5.5
    @test project(0,0,1,0,1) == 0.0
    @test project(1.0,0.0,1.0,0.0,1.0) == 1.0
    @test project(1.0,0,1.0,0,2.0) == 2.0
    @test project(2,0.0,1.0,0.0,1.0) == 2.0
    @test project(0.25,1.0,0.0,0.0,1.0) == 0.75
end;
