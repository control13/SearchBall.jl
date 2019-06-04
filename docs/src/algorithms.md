# Algorithms Documentation

## Physic-Engine

### One touches one

If two circles overlapping each other, the moved circle will pushed back, that they only touches at one point.

### One touches two

If one circle overlaps with two others, the moved circle is place in front of both circles, so that it touches both circles in one point. This is achieved with the midpoint between both circles (both circles have the size) and the point above, which is far enough away.

## GeometryUtils

### `rotate2d_left90`
- used the result from applying the 2d [rotation matix](https://en.wikipedia.org/wiki/Rotation_matrix) with ``\theta=90°``

### `normal2d`
- performs `rotate2d_left90`

### `vector`
- difference

### `distance`
- square root of the sum of the squared dimensionwise differences

### `contained` for circles
- is the distance of the centers larger than the sum of the radii

### `outer tangent`
- uses this [algorithm](https://en.wikipedia.org/wiki/Tangent_lines_to_circles#Outer_tangent) but modified
- ``\alpha=-\gamma-\beta`` and the function `atan2` instead of `atan`

### `intersection` for two linesegments
- put lines in vectorized form
- does the directions of the lines point in the same or the opposite direction -> parallel
- calc the intersection point based on the algebraic formula

### `intersection` for ray and rectangle
- transform ray and the four lines of the rectangle in lines with parametric forms
- the rectangle is axis aligned, the x, respectively the y coordinate can be omitted
- calc the ``\lambda``'s for the intersections
- the lowest positive ``\lambda`` is the searched intersection

### `intersection` for linesegment and circle
- algorithm from [http://mathworld.wolfram.com/Circle-LineIntersection.html](http://mathworld.wolfram.com/Circle-LineIntersection.html)

### `is_touching`
- is the distance of the centers smaller than the sum of the radii

### `does_intersect`
- put the line in parametric form
- calc the intersection of the line with a line beginning in the center of the circle and the normal of the line direction
- calc the distance from the intersection and the center
- if the distance is smaller than the radius, it intersects, otherwise it doesn't

### `is_inside` for point in a circle
- checks if the distance of the point from the center is lower as the the radius of the circle

### `polygon_area`
- algorithm from [http://mathworld.wolfram.com/PolygonArea.html](http://mathworld.wolfram.com/PolygonArea.html)
- sums the determinant of the matrices defined by all consecutive two points ((p1,p2), (p2,p3), ... (pN,p1))
- areas outside of the polygon are eliminated by the outside points, based on the interpretation, that the determinate is a area by two vectors (in ``\mathbb{R}^2`` space).

### `polygon_intersection`
- checks if on polygon fully contains the other
- if not, proceed
- make graphs of the polygon edges from the points lists
- create the connected graph of both polygons with the intersections
    - for all edges in polygon A
        - for all edges in polygon B
            - add the intersection on the current edge of B
            - if the intersection is equal to a corner, replace the corner with the intersection
        - add all found intersection sorted (smallest distance to the start point) to the current edge of polygon A
        - replace corners by intersections
- find all circles in the connected graph
    - for all corners in A
        - iterate, until one corner is inside (or an intersection) and not visited
        - add this corner to the current circle
            - step to the next inside corner (alternate polygon A and B) until the first corner of the current circle is reached
        - go back to the iteration until the first corner of polygon A is reached
- return the point list of the circles

### `is_inside` - point in polygon
- checks if the point lies on any of the polygon edges, if yes, return true
- find the minimum bounding box of all corners of the polygon and the point
- calculate a line with the length of the diameter of the bounding box and in the direction of the center of the first edge of the polygon
- if the point has the same direction as the choosen edge, an other edge and center are choosen
- the intersections of the line and the edges of the polygon are counted, only if the result is odd or even is interesting, so a boolean will be toggled
- begins with false (==0 => even - outside)

### `get_all_polygon_sides`
- iterates over a list of points, creates a `LineSegment` with the start first point as the startpoint and the second point from the list as the end point
- it goes on with the second point as the start point and the third point as the end point, and so on until the last point ist the start point and the first point of the list is the end point

### `is_on_LineSegment`
- compare the sum of the distances of the point to the both endpoints of the line and the length of the `LineSegment`
- if they are (nearly) equal, the point lies on the line, else it is outside

## StrategyUtils

### `is_in_line_of_sight`
- create a line of view from my position and a point I want to see
- excludes the obstacles that are at `my_position`/at the `p_view`
- check if any obstacle on the field intersects this line

### `what_is_in_line_of_sight`
- same as [`is_in_line_of_sight`](#`is_in_line_of_sight`), but returns a list with all obstacles on this line

### `intervall`
- correct start and stop values from 1 based to zero based
- counts in ``+1 \mod mod`` steps
- collects all intermediate steps

### `get_edge`
- **HARDCODED**
- check if either the ``x`` or the ``y`` coordinate matches with the appropriate coordinates of field corners

### `get_shadow` and `treat_obstacles!`
- for a position `new_pos` all obstacles (the player on this position, or on the position `my_pos` is excluded) will be sorted within the distance to `new_pos`, shortest distances comes first
- for all (sorted) obstacles will be the shadow polygons calculated
- processed obstacles will marked as visited
- for the shadow polygon:
    - both outer tangents are calculated
    - if there are other obstacles intersecting the tangents, these will be also marked as visited and their shadows are added to polygon of the current processed obstacle
    - if in the tangents of the intersecting obstacles are also obstacles, the last operation is proceeded until the tangents intersecting the field borders
    - for intersecting obstacles, all possible (that are more near to `new_pos` then the intersection obstacle and less near to the processed obstacle) other obstacles are checked, if their tangents intersects the intersecting obstacle. These obstacles also marked as visited and their shadow is added to them of the current processed obstacle


### `raster`
- takes an intervall and splits it in `n`+2 equidistant points and returns it with the start and endpoint exclusive

### `sample`
- rasters a field with a given resolution and evaluates a map function for every position and reduces it with another function
- returns two maps, one for the calculated value and one for satisfying the inside condition (e.g. position on players are not inside) 

### `calc_shadow`
- wraps `get_shadow` and calculates the polygon area for the shadows and displays it in the gui

### `send_background`
- easy for drawing the scalar field in the gui and draw additional information, like a colorbar (currently the only additional information)

## GameViewGtk

### `get_world_to_screen_coeffs`
- checks if the by the fieldratio adjusted width is greater than the height
- depending on this, calculate the offsets for the width and height nd the multiplier
- for example:
    - if the the adjusted width is greater than the height
    - the half of the difference of bath values is the width offset (half for both sides -symmetry)
    - the heightoffset is 0, because the rendered field reaches top and bottom
    - for the multiplier, the height is crucial and is divided by its length in the world (in m)
- for the else case vice versa

### `draw_and_save_pathlines!`
- checks if the storage `pathline` is empty or the current position is not near the last added position
- if so, adds the current point to `pathline`
- emits a warning if the storage gets to full (more than 10_000 entries)
- draws all points in the storage as circle
