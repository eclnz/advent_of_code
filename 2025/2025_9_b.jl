
struct Point
    x::Int
    y::Int
end

function parse_coord(string::String)::Point
    x_coord,y_coord = split(string, ",")
    x_int, y_int = parse(Int, x_coord), parse(Int, y_coord)
    return Point(x_int, y_int)
end

function parse_coords(strings::Vector{String})
    vec_str = collect(strings)
    points = Vector{Point}(undef, length(vec_str))
    for i in eachindex(vec_str)
        points[i] = parse_coord(vec_str[i])
    end
    points = sort(points, by = p -> (p.y, p.x))
    return points
end

mutable struct PendingRectangle
    min_x::Int
    max_x::Int
    point::Point
end

mutable struct Polygon
    min_x::Int
    max_x::Int
    max_area::Int
    pending_rectangles::Vector{PendingRectangle}
end

function iter_polygon(points::Vector{Point}, polygon::Polygon)

    min_x, max_x = points[1].x, points[end].x
    current_y = points[1].y
    
    # Remove pending rectangles that are no longer possible.
    filter!(r -> !(r.min_x > min_x || r.max_x < max_x), polygon.pending_rectangles)
    
    # Max area loop.
    for rectangle in polygon.pending_rectangles
        dy = current_y - rectangle.point.y
        for point in points
            # Skip rectangles that are not valid.
            if point.x > rectangle.max_x || point.x < rectangle.min_x
                continue
            end
            # If the rectangle is valid, calculate it's area. 
            dx = abs(point.x - rectangle.point.x)
            area = dx * dy
            if area > polygon.max_area
                polygon.max_area = area
            end
        end
    end

    for point in points
        # For each point, create 2 pending rectangles. One left pointing and one right pointing...
        right_p_rectangle = PendingRectangle(point.x, max_x, point)
        left_p_rectangle = PendingRectangle(min_x, point.x, point)
        push!(polygon.pending_rectangles, right_p_rectangle)
        push!(polygon.pending_rectangles, left_p_rectangle)
    end 
end

function line_scan(points::Vector{Point})
    
    groups = Dict{Int, Vector{Point}}()
    for p in points
        push!(get!(groups, p.y, Point[]), p)
    end 
    # Loop over each line, iterate the polygon.
    polygon = Polygon(typemax(Int), 0, 0, PendingRectangle[])
    for y in sort(collect(keys(groups)))
        row_points = sort(groups[y], by = p -> p.x)
        iter_polygon(row_points, polygon)
    end
end

test = [
    "7,1",  # 1
    "11,1", # 2 <-
    "11,7", # 3 <- 
    "9,7",  # 4
    "9,5",  # 5
    "2,5",  # 6 <-
    "2,3",  # 7 <- 
    "7,3"   # 8
]

coords = parse_coords(test)
line_scan(coords)
