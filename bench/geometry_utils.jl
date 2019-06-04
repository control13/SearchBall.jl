using BenchmarkTools, GeometryTypes
import SearchBall

@benchmark SearchBall.rotate2d_left90([1, 1]) # realistic example

a = rand(1_000_000)
b = rand(1_000_000)
@benchmark SearchBall.vector(a, b) # maximum example
@benchmark SearchBall.vector([1.0, 2.0], [2.3, 4.5]) # realistic example

@benchmark SearchBall.intersection(LineSegment(Point2(2.0, 2.0), Point2(3.0, 3.0)), LineSegment(Point2(3.0, 2.0), Point2(2.0, 3.0))) == (true, Point2(2.5, 2.5)) # realistic example

@benchmark SearchBall.intersection(LineSegment(Point2(2.0, 2.0), Point2(3.0, 3.0)), HyperRectangle{2,Float64}([0.0, 0.0], [7.0, 4.0])) == (true, Point2(4.0, 4.0)) # realistic example

@benchmark SearchBall.does_intersect(LineSegment(Point2(2.0, 2.0), Point2(3.0, 3.0)), Circle(Point2(0.0, 0.0), 1.0)) # realistic example

@benchmark SearchBall.polygon_intersection([Point2(0.0, 0.0), Point2(6.0, 0.0), Point2(6.0, 2.0), Point2(3.0, 2.0), Point2(0.0, 2.0)], [Point2(1.0, 1.0), Point2(3.0, 3.0), Point2(5.0, 1.0), Point2(3.0, 4.0)]) # realistic example
