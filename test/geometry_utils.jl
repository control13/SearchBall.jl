import GeometryTypes
const gt = GeometryTypes

@testset "GeometryUtils" begin

    @testset "rotate2d_left90 Tests" begin
        @test sb.rotate2d_left90([1, 1]) == [-1, 1]
        @test sb.rotate2d_left90([0, 0]) == [0, 0]
        @test sb.rotate2d_left90([1, 0]) == [0, 1]
        @test sb.rotate2d_left90([0, 1]) == [-1, 0]
        @test_throws AssertionError sb.rotate2d_left90([0, 1, 3])
    end;

    @testset "rotate2d" begin
        @test sb.rotate2d([1, 0], π/2) ≈ [0, 1]
        @test sb.rotate2d([1, 0], 3π/2) ≈ [0, -1]
        @test sb.rotate2d([1, 1], -π/4) ≈ [sqrt(2), 0]
        @test_throws AssertionError sb.rotate2d([0, 1, 3], π/2)
    end

    @testset "normal2d Tests" begin
        @test sb.normal2d([1, 1]) == [-1, 1]
        @test sb.normal2d([0, 0]) == [0, 0]
        @test sb.normal2d([1, 0]) == [0, 1]
        @test sb.normal2d([0, 1]) == [-1, 0]
        @test_throws AssertionError sb.normal2d([0, 1, 3])
    end;

    @testset "vector Tests" begin
        @test sb.vector([2], [5]) == [3]
        @test sb.vector([2, 1], [5, -1]) == [3, -2]
    end;

    @testset "distance Tests" begin
        @test sb.distance(gt.Point2(0), gt.Point2(0)) == 0
        @test sb.distance(gt.Point2(1.3), gt.Point2(1.3)) == 0
        @test sb.distance(gt.Point2(0,1), gt.Point2(1,1)) == 1
        @test sb.distance(gt.Point2(0,-1), gt.Point2(-1,-1)) == 1
        @test sb.distance(gt.Point3(0,-1,0), gt.Point3(-1,-1,0)) == 1
        @test sb.distance(gt.Point{5}([0,-1,0,5,5]), gt.Point{5}([-1,-1,0,5,5])) == 1
        @test sb.distance([0,-1], [-1,-1]) == 1
        @test sb.distance([0,-1,0,5,5], [-1,-1,0,5,5]) == 1
    end;

    @testset "contained Tests" begin
        @test sb.contained(gt.Circle(gt.Point2(0, 0), 0), gt.Circle(gt.Point2(1, 1),1)) == false # point outside of the gt.Circle
        @test sb.contained(gt.Circle(gt.Point2(0, 0), 0), gt.Circle(gt.Point2(1, 1),2)) == true # point insinde of the gt.Circle
        @test sb.contained(gt.Circle(gt.Point2(1, 0), 0), gt.Circle(gt.Point2(1, 1),1)) == true # point on the gt.Circle ring
        @test sb.contained(gt.Circle(gt.Point2(3.5, -0.5), 0.5), gt.Circle(gt.Point2(5, -0.5), 1.5)) == false # gt.Circle with center on the gt.Circle ring and overlapping
        @test sb.contained(gt.Circle(gt.Point2(4, -0.5), 0.5), gt.Circle(gt.Point2(5, -0.5), 1.5)) == true # gt.Circle insinde other gt.Circle, touching on gt.Circle ring
        @test sb.contained(gt.Circle(gt.Point2(4.5, -0.5), 0.5), gt.Circle(gt.Point2(5, -0.5), 1.5)) == true # gt.Circle insinde other gt.Circle
        @test sb.contained(gt.Circle(gt.Point2(5, -0.5), 1.5), gt.Circle(gt.Point2(5, -0.5), 1.5)) == true # same gt.Circles
        @test sb.contained(gt.Circle(gt.Point2(2.5, -0.5), 1.5), gt.Circle(gt.Point2(5, -0.5), 1.5)) == false # disjunct gt.Circles
        @test sb.contained(gt.Circle(gt.Point2(3, -0.5), 1.5), gt.Circle(gt.Point2(5, -0.5), 1.5)) == false # touching in one point
    end;

    @testset "outer_tangent Tests" begin
        @test string(sb.outer_tangent(gt.Point2(0), gt.Circle(gt.Point(3,0),1))) == "GeometryTypes.Point{2,Float64}[[0.0, 0.0], [2.66667, 0.942809]]"
        @test string(sb.outer_tangent(gt.Circle(gt.Point(3,0),1), gt.Point2(0))) == "GeometryTypes.Point{2,Float64}[[2.66667, -0.942809], [0.0, 0.0]]"
        @test string(sb.outer_tangent(gt.Circle(gt.Point2(0), 1), gt.Circle(gt.Point(0, 3), 1))) == string(gt.LineSegment(gt.Point2(-1.0, 1.22465e-16), gt.Point(-1.0, 3.0)))
        @test string(sb.outer_tangent(gt.Circle(gt.Point2(0), 1), gt.Circle(gt.Point(0, 3), 1), true)) == string(gt.LineSegment(gt.Point(-1.0, 3.0), gt.Point2(-1.0, 1.22465e-16)))
        @test string(sb.outer_tangent(gt.Circle(gt.Point(0, 3), 1), gt.Circle(gt.Point2(0), 1))) == string(gt.LineSegment(gt.Point2(1.0, 3.0), gt.Point(1.0, 0.0)))
        @test string(sb.outer_tangent(gt.Circle(gt.Point2(0.5, 0.5), 1.5), gt.Circle(gt.Point(5.5, -0.5), 2.0))) == string(gt.LineSegment(gt.Point2(0.648526, 1.99263), gt.Point(5.69803, 1.49017)))
        @test string(sb.outer_tangent(gt.Circle(gt.Point(5.5, -0.5), 2.0), gt.Circle(gt.Point2(0.5, 0.5), 1.5))) == string(gt.LineSegment(gt.Point2(4.91735, -2.41325), gt.Point(0.0630127, -0.934936)))
        @test sb.outer_tangent(gt.Circle(gt.Point2(4, -0.5), 0.5), gt.Circle(gt.Point2(5, -0.5), 1.5)) == gt.LineSegment(gt.Point2(0.0), gt.Point2(0.0))
        @test sb.outer_tangent(gt.Circle(gt.Point2(5, -0.5), 1.5), gt.Circle(gt.Point2(4, -0.5), 0.5)) == gt.LineSegment(gt.Point2(0.0), gt.Point2(0.0))
    end;

    @testset "intersect gt.LineSegment/gt.LineSegment Tests" begin
        @test sb.intersection(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.LineSegment(gt.Point2(3.0, 2.0), gt.Point2(2.0, 3.0))) == (true, gt.Point2(2.5, 2.5))
        @test sb.intersection(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.LineSegment(gt.Point2(3.0, 2.0), gt.Point2(2.0, 3.0)), true) == (true, gt.Point2(2.5, 2.5))
        @test sb.intersection(gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point2(4.0, 1.0)), gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(0.0, 4.0))) == (true, gt.Point2(0.0, 1.0))
        @test sb.intersection(gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point2(4.0, 1.0)), gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(0.0, 4.0)), true) == (false, gt.Point2(0))
        @test sb.intersection(gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point2(4.0, 4.0)), gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point2(4.0, 4.0))) == (false, gt.Point2(0))
        @test sb.intersection(gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point2(4.0, 4.0)), gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point2(4.0, 4.0))) == (false, gt.Point2(0))
        @test sb.intersection(gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point2(4.0, 4.0)), gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(5.0, 5.0))) == (false, gt.Point2(0))
    end;

    @testset "intersect gt.LineSegment/Rectangel Tests" begin
        @test sb.intersection(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.HyperRectangle{2,Float64}([0.0, 0.0], [7.0, 4.0])) == (true, gt.Point2(4.0, 4.0))
        @test sb.intersection(gt.LineSegment(gt.Point2(3.0, 3.0), gt.Point2(2.0, 2.0)), gt.HyperRectangle{2,Float64}([0.0, 0.0], [7.0, 4.0])) == (true, gt.Point2(0.0, 0.0))
        @test sb.intersection(gt.LineSegment(gt.Point2(3.0, 2.0), gt.Point2(3.0, 3.0)), gt.HyperRectangle{2,Float64}([0.0, 0.0], [7.0, 4.0])) == (true, gt.Point2(3.0, 4.0))
        @test sb.intersection(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.HyperRectangle{2,Float64}([-1.0, -2.0], [7.0, 4.0])) == (true, gt.Point2(2.0, 2.0))
        @test sb.intersection(gt.LineSegment(gt.Point2(8.0, 0.0), gt.Point2(9.0, 0.0)), gt.HyperRectangle{2,Float64}([0.0,0.0], [7.0, 4.0])) == (false, gt.Point2(0.0, 0.0))
    end;

    @testset "intersect gt.LineSegment/gt.Circle Tests" begin
        @test string(sb.intersection(gt.LineSegment(gt.Point2(0.0, 0.5), gt.Point2(3.0, 0.5)), gt.Circle(gt.Point2(1.5, 1.5), 1.5))) == string((true, [0.381966, 0.5], true, [2.61803, 0.5]))
        @test string(sb.intersection(gt.LineSegment(gt.Point2(0.0, 2.5), gt.Point2(3.0, 2.5)), gt.Circle(gt.Point2(1.5, 1.5), 1.5))) == string((true, [0.381966, 2.5], true, [2.61803, 2.5]))
        @test sb.intersection(gt.LineSegment(gt.Point2(-1.0, 1.0), gt.Point(1.0, 1.0)), gt.Circle(gt.Point2(0.0, 0.0), 1.0)) == (true, [0.0, 1.0], true, [0.0, 1.0])
        @test sb.intersection(gt.LineSegment(gt.Point2(-1.5, 1.5), gt.Point(1.0, 1.0)), gt.Circle(gt.Point2(0.0, 0.0), 1.0)) == (false, [0.0, 0.0],false,  [0.0, 0.0])
        @test sb.intersection(gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point(2.0, 1.0)), gt.Circle(gt.Point2(0.0, 0.0), 1.0)) == (true, [0.0, 1.0], true, [0.0, 1.0])
        @test sb.intersection(gt.LineSegment(gt.Point2(1.0, 1.0), gt.Point(2.0, 1.0)), gt.Circle(gt.Point2(0.0, 0.0), 1.0), only_in_lineSegment=true) == (false, [0.0, 1.0],false,  [0.0, 1.0])
    end;

    @testset "touching Tests" begin
        @test sb.is_touching(gt.Circle(gt.Point2(0, 0), 0), gt.Circle(gt.Point2(1, 1), 1)) == false # point outside of the gt.Circle
        @test sb.is_touching(gt.Circle(gt.Point2(0, 0), 1), gt.Circle(gt.Point2(2, 2), 1)) == false # distinct gt.Circles
        @test sb.is_touching(gt.Circle(gt.Point2(1, 0), 0), gt.Circle(gt.Point2(1, 1), 1)) == true # point touching gt.Circle
        @test sb.is_touching(gt.Circle(gt.Point2(1, 1), 0), gt.Circle(gt.Point2(1, 1), 1)) == true # point inside gt.Circle
        @test sb.is_touching(gt.Circle(gt.Point2(0, 0), 1), gt.Circle(gt.Point2(0, 2), 1)) == true # touchinggt.Circle
        @test sb.is_touching(gt.Circle(gt.Point2(0, 0), 1), gt.Circle(gt.Point2(1, 1), 1)) == true # overlapping gt.Circles
        @test sb.is_touching(gt.Circle(gt.Point2(0, 0), 1), gt.Circle(gt.Point2(0, 0), 1)) == true # same gt.Circles
        @test sb.is_touching(gt.Point2(0, 0), 1, gt.Point2(0, 0), 1) == true # same gt.Circles
        @test sb.is_touching([0, 0], 1, [0, 0], 1) == true # same gt.Circles
        @test sb.is_touching([0, 0, 0, 0], 1, [0, 0, 0, 0], 1) == true # same gt.Circles
        @test_throws AssertionError sb.is_touching([0, 0, 0, 0], 1, [0, 0, 0], 1)
    end;

    @testset "does_intersect gt.LineSegment/gt.Circle Tests" begin
        @test sb.does_intersect(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.Circle(gt.Point2(0.0, 0.0), 1.0)) == true
        @test sb.does_intersect(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.Circle(gt.Point2(2.5, 2.5), 1.0)) == true
        @test sb.does_intersect(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.Circle(gt.Point2(10.0, 0.0), 1.0)) == false
        @test sb.does_intersect(gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0)), gt.Circle(gt.Point2(1.0, 1.0), 1.0)) == false
        @test sb.does_intersect(gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0)), gt.Circle(gt.Point2(1.0, 1.0), 1.0), r_is_outside = false) == true
        @test sb.does_intersect(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.Circle(gt.Point2(0.0, 0.0), 1.0), only_in_lineSegment = true) == false
        @test sb.does_intersect(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.Circle(gt.Point2(2.5, 2.5), 1.0), only_in_lineSegment = true) == true
        @test sb.does_intersect(gt.LineSegment(gt.Point2(2.0, 2.0), gt.Point2(3.0, 3.0)), gt.Circle(gt.Point2(10.0, 0.0), 1.0), only_in_lineSegment = true) == false
        @test sb.does_intersect(gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0)), gt.Circle(gt.Point2(1.0, 1.0), 1.0), only_in_lineSegment = true) == false
        @test sb.does_intersect(gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0)), gt.Circle(gt.Point2(1.0, 1.0), 1.0), only_in_lineSegment = true, r_is_outside = false) == true
    end;

    @testset "is_inside Point/gt.Circle Tests" begin
        @test sb.is_inside(gt.Point2(2.0, 2.0), gt.Circle(gt.Point2(0.0, 0.0), 1.0)) == false
        @test sb.is_inside(gt.Point2(1.0, 0.0), gt.Circle(gt.Point2(0.0, 0.0), 1.0)) == true
        @test sb.is_inside(gt.Point2(1.0, 0.0), gt.Circle(gt.Point2(0.0, 0.0), 1.0), r_is_outside = true) == false
    end;

    @testset "polygon_area" begin
        @test sb.polygon_area(Vector{Float64}[]) ≈ 0.0
        @test sb.polygon_area([[0, 0]]) ≈ 0.0
        @test sb.polygon_area([[0, 0], [0, 0]]) ≈ 0.0
        @test sb.polygon_area([[0, 0], [1, 0]]) ≈ 0.0
        @test sb.polygon_area([[0, 0], [1, 0], [0, 0]]) ≈ 0.0
        @test sb.polygon_area([[0, 0], [1, 0], [1, 1], [0, 1]]) ≈ 1.0
        @test sb.polygon_area([[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]) ≈ 1.0
        @test sb.polygon_area([[20, 20], [21, 20], [21, 21], [20, 21]]) ≈ 1.0
        @test sb.polygon_area([[20, 20], [21, 20], [21, 21], [20, 21], [20, 20]]) ≈ 1.0
        @test sb.polygon_area([[0, 0], [2, 0], [2, 1], [1, 1], [1, 2], [0, 2]]) ≈ 3.0
        @test sb.polygon_area([[0, 0], [2, 0], [2, 1], [1, 1], [1, 2], [0, 2], [0, 0]]) ≈ 3.0
        @test sb.polygon_area([[20, 20], [22, 20], [22, 21], [21, 21], [21, 22], [20, 22], [20, 20]]) ≈ 3.0
    end;

    @testset "get_all_polygon_sides" begin
        @test sb.get_all_polygon_sides([gt.Point2(0, 0), gt.Point2(1, 0), gt.Point2(1, 1), gt.Point2(0, 1)]) == [gt.LineSegment(gt.Point2(0, 0), gt.Point2(1, 0)), gt.LineSegment(gt.Point2(1, 0), gt.Point2(1, 1)), gt.LineSegment(gt.Point2(1, 1), gt.Point2(0, 1)), gt.LineSegment(gt.Point2(0, 1), gt.Point2(0, 0))]
        @test sb.get_all_polygon_sides([gt.Point2(0, 0), gt.Point2(0, 1)]) == [gt.LineSegment(gt.Point2(0, 0), gt.Point2(0, 1)), gt.LineSegment(gt.Point2(0, 1), gt.Point2(0, 0))]
        @test sb.get_all_polygon_sides([gt.Point2(0, 0)]) == [gt.LineSegment(gt.Point2(0, 0), gt.Point2(0, 0))]
        @test sb.get_all_polygon_sides(gt.Point2{Float64}[]) == gt.LineSegment{gt.Point2{Float64}}[]
    end;

    @testset "is_inside point in polygon" begin
        # point fully inside, list of of points polygon
        @test sb.is_inside(gt.Point2(0.5, 0.5), [gt.Point2(0, 0), gt.Point2(1, 0), gt.Point2(1, 1), gt.Point2(0, 1)]) == true
        # point fully outside, list of of points polygon
        @test sb.is_inside(gt.Point2(1.5, 1.5), [gt.Point2(0, 0), gt.Point2(1, 0), gt.Point2(1, 1), gt.Point2(0, 1)]) == false
        # point on edge, edge is outside (default)
        @test sb.is_inside(gt.Point2(0.0, 0.0), [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)]) == true
        polygon = [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(1.0, 2.0)]
        for r in 1:4
            for p in [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(3.0, 0.0), gt.Point2(3.0, 1.0), gt.Point2(3.0, 2.0), gt.Point2(3.0, 3.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 3.0), gt.Point2(0.0, 3.0), gt.Point2(0.0, 2.0), gt.Point2(0.0, 1.0)]
                @test sb.is_inside(p, polygon) == false
            end
            for p in [gt.Point2(1.5, 1.5), gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(1.0, 2.0), gt.Point2(1.5, 2.0), gt.Point2(1.5, 1.0), gt.Point2(1.0, 1.5), gt.Point2(2.0, 1.5)]
                @test sb.is_inside(p, polygon) == true
            end
            polygon = circshift(polygon, 1)
        end
        @test sb.is_inside(gt.Point2(0.0, 0.0), [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(1.0, 2.0)]) == false

        @test sb.is_inside(gt.Point2(2.5, 1.5), [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 3.0)]) == false
        @test sb.is_inside(gt.Point2(2.6, 1.4), [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 3.0)]) == false
        @test sb.is_inside(gt.Point2(2.4, 1.6), [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 3.0)]) == false

        @test sb.is_inside(gt.Point2(1.0, 1.0), [gt.Point2(2.0, 3.0), gt.Point2(4.0, 1.0), gt.Point2(4.0, 5.0)]) == false
        @test sb.is_inside(gt.Point2(3.0, 3.0), [gt.Point2(2.0, 3.0), gt.Point2(4.0, 1.0), gt.Point2(4.0, 5.0)]) == true
        @test sb.is_inside(gt.Point2(1.0, 5.0), [gt.Point2(2.0, 3.0), gt.Point2(4.0, 1.0), gt.Point2(4.0, 5.0)]) == false

        @test sb.is_inside(gt.Point2(2.0, 3.0), [gt.Point2(2.0, 3.0), gt.Point2(4.0, 1.0), gt.Point2(4.0, 5.0)]) == true
        @test sb.is_inside(gt.Point2(3.0, 2.0), [gt.Point2(2.0, 3.0), gt.Point2(4.0, 1.0), gt.Point2(4.0, 5.0)]) == true

        @test sb.is_inside(gt.Point2(2.0, 3.0), [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 5.0)]) == true
        @test sb.is_inside(gt.Point2(4.0, 1.0), [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 5.0)]) == false
        @test sb.is_inside(gt.Point2(4.0, 5.0), [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 5.0)]) == false

        @test sb.is_inside(gt.Point2(1.0, 0.0), [gt.Point2(0.0, 0.0), gt.Point2(-1.0, 0.0), gt.Point2(-1.0, -1.0), gt.Point2(0.0, -1.0)]) == false

        @test sb.is_inside(gt.Point2(0.0), [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == false

        @test sb.is_inside(gt.Point2(3.0, 4.0), [gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0)]) == false
    end;

    @testset "is_inside point in rectangle" begin
        # point fully inside, list of of points polygon
        @test sb.is_inside(gt.Point2(1.0, 1.0), gt.HyperRectangle([gt.Point2(0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(2.0, 0.0)])) == true
        @test sb.is_inside(gt.Point2(5.0, 5.0), gt.HyperRectangle([gt.Point2(0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(2.0, 0.0)])) == false
        @test sb.is_inside(gt.Point2(0.0, 0.0), gt.HyperRectangle([gt.Point2(0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(2.0, 0.0)])) == true
        @test sb.is_inside(gt.Point2(1.0, 0.0), gt.HyperRectangle([gt.Point2(0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(2.0, 0.0)])) == true
        @test sb.is_inside(gt.Point2(7.0, 7.0), gt.HyperRectangle([gt.Point2(6.0, 6.0), gt.Point2(8.0, 6.0), gt.Point2(8.0, 8.0), gt.Point2(6.0, 8.0)])) == true
        @test sb.is_inside(gt.Point2(8.0, 6.0), gt.HyperRectangle([gt.Point2(6.0, 6.0), gt.Point2(8.0, 6.0), gt.Point2(8.0, 8.0), gt.Point2(6.0, 8.0)])) == true
        @test sb.is_inside(gt.Point2(1.0, 1.0), gt.HyperRectangle([gt.Point2(6.0, 6.0), gt.Point2(8.0, 6.0), gt.Point2(8.0, 8.0), gt.Point2(6.0, 8.0)])) == false
    end;

    @testset "polygon_intersection" begin

        function check_all_combination(polygonA::Vector{<:gt.Point2}, polygonB::Vector{<:gt.Point2}, solution::Vector{<:gt.Point2})
            sol_length = length(solution)
            for itB in 1:length(polygonB)
                for itA in 1:length(polygonA)
                    res = sb.polygon_intersection(polygonA, polygonB)
                    if sol_length == 0
                        @test res == solution
                        continue
                    else
                        res = res[1]
                    end
                    correct = any(map(it -> circshift(solution, it) ≈ res, 1:length(solution)))
                    if !correct
                        println(polygonA)
                        println(polygonB)
                        println(res)
                        println(solution)
                    end
                    # @test length(res) == sol_length && all(map(e -> e in solution, res))
                    @test correct
                    polygonA = circshift(polygonA, 1)
                end
                polygonB = circshift(polygonB, 1)
            end
        end
        # same polygons
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], [gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0), gt.Point2(0.0, 0.0)])

        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)])

        check_all_combination([gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(1.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(1.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(1.0, 2.0)])

        check_all_combination([gt.Point2(-1.0, -1.0), gt.Point2(2.0, -1.0), gt.Point2(2.0, 2.0), gt.Point2(-1.0, 2.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)])
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(-1.0, -1.0), gt.Point2(2.0, -1.0), gt.Point2(2.0, 2.0), gt.Point2(-1.0, 2.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)])

        check_all_combination([gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 5.0)], [gt.Point2(2.0, 3.0), gt.Point2(4.0, 1.0), gt.Point2(4.0, 5.0)], [gt.Point2(2.5,2.5), gt.Point2(3.0, 3.0), gt.Point2(2.5, 3.5), gt.Point2(2.0, 3.0)])
        check_all_combination([gt.Point2(2.0, 3.0), gt.Point2(4.0, 1.0), gt.Point2(4.0, 5.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 5.0)], [gt.Point2(2.0, 3.0), gt.Point2(2.5,2.5), gt.Point2(3.0, 3.0), gt.Point2(2.5, 3.5)])

        # C - correct
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 4.0), gt.Point2(0.0, 4.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 3.0)], [gt.Point2(1.5, 1.0), gt.Point2(2.0, 2.0), gt.Point2(2.5, 1.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 1.0)])
        check_all_combination([gt.Point2(1.0, 1.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 3.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 4.0), gt.Point2(0.0, 4.0)], [gt.Point2(1.0, 1.0), gt.Point2(1.5, 1.0), gt.Point2(2.0, 2.0), gt.Point2(2.5, 1.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 3.0)])

        # D - correct
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 3.0), gt.Point2(0.0, 3.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 3.0)], [gt.Point2(1.5, 1.0), gt.Point2(2.0, 2.0), gt.Point2(2.5, 1.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 1.0)])
        check_all_combination([gt.Point2(1.0, 1.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 3.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 2.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 3.0), gt.Point2(0.0, 3.0)], [gt.Point2(1.0, 1.0), gt.Point2(1.5, 1.0), gt.Point2(2.0, 2.0), gt.Point2(2.5, 1.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 3.0)])

        # K - infinite loop for two combinations
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0), gt.Point2(0.0, 0.0)])
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)])

        # L - correct
        check_all_combination([gt.Point2(0.0, 2.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 2.0)], [gt.Point2(0.0, 1.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 2.0)], [gt.Point2(0.4, 1.2), gt.Point2(0.6667, 0.6667), gt.Point2(1.2, 0.4), gt.Point2(2.0, 2.0)])
        check_all_combination([gt.Point2(0.0, 1.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 2.0)], [gt.Point2(0.0, 2.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 2.0)], [gt.Point2(0.4, 1.2), gt.Point2(0.6667, 0.6667), gt.Point2(1.2, 0.4), gt.Point2(2.0, 2.0)]) # [gt.Point2(2.0, 2.0)]

        # correct - Arrrgh - Error
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(-1.0, 0.0), gt.Point2(-1.0, -1.0), gt.Point2(0.0, -1.0)], gt.Point2[])
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(-1.0, 0.0), gt.Point2(-1.0, -1.0), gt.Point2(0.0, -1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], gt.Point2[])

        # A - correct
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 4.0), gt.Point2(3.0, 4.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 4.0), gt.Point2(0.0, 4.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 4.0), gt.Point2(0.0, 4.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 4.0), gt.Point2(3.0, 4.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 4.0), gt.Point2(0.0, 4.0)])
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 4.0), gt.Point2(0.0, 4.0)], [gt.Point2(0.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 4.0), gt.Point2(3.0, 4.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 4.0), gt.Point2(0.0, 4.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(4.0, 4.0), gt.Point2(3.0, 4.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 4.0), gt.Point2(0.0, 4.0)])

        # B correct
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(2.0, 3.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(2.0, 2.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(2.0, 2.0)])
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(2.0, 2.0)], [gt.Point2(0.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(2.0, 3.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(3.0, 0.0), gt.Point2(4.0, 0.0), gt.Point2(2.0, 2.0)])

        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)])
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)])

        # H
        @test sb.polygon_intersection([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(2.0, 0.0), gt.Point2(3.0, 0.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 1.0)]) == Vector[]
        @test sb.polygon_intersection([gt.Point2(2.0, 0.0), gt.Point2(3.0, 0.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)]) == Vector[]

        # I - infinite loop
        check_all_combination([gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], [gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], gt.Point2[])
        check_all_combination([gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(0.0, 1.0)], gt.Point2[])

        # M
        check_all_combination([gt.Point2(0.0, 1.0), gt.Point2(3.0, 1.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)], [gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 3.0)], [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(1.0, 2.0)])
        check_all_combination([gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 3.0)], [gt.Point2(0.0, 1.0), gt.Point2(3.0, 1.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 2.0), gt.Point2(1.0, 2.0)])

        # complicated tests

        # F - seperatist - correct
        @test sb.polygon_intersection([gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]

        # no intersection
        @test sb.polygon_intersection(gt.Point2{Float64}[], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)]) == Vector{gt.Point2{Float64}}[]
        @test sb.polygon_intersection([gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)], gt.Point2{Float64}[]) == Vector{gt.Point2{Float64}}[]
        @test sb.polygon_intersection(gt.Point2{Float64}[], gt.Point2{Float64}[]) == Vector{gt.Point2{Float64}}[]

        @test sb.polygon_intersection([gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0), gt.Point2(1.0, 1.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]

        @test sb.polygon_intersection([gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0), gt.Point2(1.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0), gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0)], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(3.0, 4.0), gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(3.0, 2.0), gt.Point2(0.0, 2.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]

        # G - seperatist
        @test sb.polygon_intersection([gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(0.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(0.0, 2.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]

        @test sb.polygon_intersection([gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(6.0, 2.0), gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(0.0, 2.0), gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0)], [gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]

        @test sb.polygon_intersection([gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0), gt.Point2(1.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(0.0, 2.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(5.0, 1.0), gt.Point2(3.0, 4.0), gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0)], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(0.0, 2.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
        @test sb.polygon_intersection([gt.Point2(3.0, 4.0), gt.Point2(1.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(5.0, 1.0)], [gt.Point2(0.0, 0.0), gt.Point2(6.0, 0.0), gt.Point2(6.0, 2.0), gt.Point2(0.0, 2.0)]) == [[gt.Point2(2.0, 2.0), gt.Point2(1.6667, 2.0), gt.Point2(1.0, 1.0)], [gt.Point2(4.3333, 2.0), gt.Point2(4.0, 2.0), gt.Point2(5.0, 1.0)]]
    end;

    @testset "polygon_union" begin
        @test sb.polygon_union([gt.Point2{Float64}[], [gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0)]]) == [[gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0)]]
        @test sb.polygon_union([[gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0)], gt.Point2{Float64}[]]) == [[gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0)]]

        @test sb.polygon_union([gt.Point2{Float64}[]]) == [gt.Point2{Float64}[]]
        @test sb.polygon_union(Vector{gt.Point2{Float64}}[]) == [gt.Point2{Float64}[]]
        @test sb.polygon_union([[gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0)]]) == [[gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0), gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0)]]

        @test sb.polygon_union([[gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0)]]) == [[gt.Point2(0.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(0.0, 1.0)]]
        @test sb.polygon_union([[gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0), gt.Point2(0.0, 0.0)], [gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0)]]) == [[gt.Point2(0.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(0.0, 1.0)]]
        @test sb.polygon_union([[gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)], [gt.Point2(1.0, 0.0), gt.Point2(2.0, 0.0), gt.Point2(2.0, 1.0), gt.Point2(1.0, 1.0)], [gt.Point2(2.0, 0.0), gt.Point2(3.0, 0.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 1.0)]]) == [[gt.Point2(0.0, 0.0), gt.Point2(3.0, 0.0), gt.Point2(3.0, 1.0), gt.Point2(0.0, 1.0)]]
        @test sb.polygon_union([[gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0), gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0)],  [gt.Point2(2.0, 0.0), gt.Point2(3.0, 0.0), gt.Point2(3.0, 1.0), gt.Point2(2.0, 1.0)]]) == [[gt.Point2(1.0, 1.0), gt.Point2(0.0, 1.0), gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0)],  [gt.Point2(3.0, 1.0), gt.Point2(2.0, 1.0), gt.Point2(2.0, 0.0), gt.Point2(3.0, 0.0)]]
        @test sb.polygon_union([[gt.Point2(1.0, 1.0), gt.Point2(3.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 3.0)],  [gt.Point2(2.0, 2.0), gt.Point2(4.0, 2.0), gt.Point2(4.0, 4.0), gt.Point2(2.0, 4.0)]]) == [[gt.Point2(3.0, 2.0), gt.Point2(4.0, 2.0), gt.Point2(4.0, 4.0), gt.Point2(2.0, 4.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 3.0), gt.Point2(1.0, 1.0), gt.Point2(3.0, 1.0)]]
        @test sb.polygon_union([[gt.Point2(1.0, 1.0), gt.Point2(3.0, 1.0), gt.Point2(3.0, 3.0), gt.Point2(1.0, 3.0)],  [gt.Point2(2.0, 2.0), gt.Point2(4.0, 2.0), gt.Point2(4.0, 4.0), gt.Point2(2.0, 4.0)], [gt.Point2(3.0, 1.0), gt.Point2(5.0, 1.0), gt.Point2(5.0, 3.0), gt.Point2(3.0, 3.0)]]) == [[gt.Point2(5.0, 3.0), gt.Point2(4.0, 3.0), gt.Point2(4.0, 4.0), gt.Point2(2.0, 4.0), gt.Point2(2.0, 3.0), gt.Point2(1.0, 3.0), gt.Point2(1.0, 1.0), gt.Point2(5.0, 1.0)]]
    end

    @testset "is_on_line_segment" begin
        @test sb.is_on_LineSegment(gt.Point2(0.0, 0.0), gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0))) == true
        @test sb.is_on_LineSegment(gt.Point2(0.5, 0.0), gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0))) == true
        @test sb.is_on_LineSegment(gt.Point2(1.0, 0.0), gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0))) == true
        @test sb.is_on_LineSegment(gt.Point2(2.0, 0.0), gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0))) == false
        @test sb.is_on_LineSegment(gt.Point2(2.0, 2.0), gt.LineSegment(gt.Point2(0.0, 0.0), gt.Point2(1.0, 0.0))) == false
    end;

end
