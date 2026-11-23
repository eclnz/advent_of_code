
function parse_coord(string::String)
    coords = split(string, ",")
    return (parse(Int, coords[1]), parse(Int, coords[2]))
end

function parse_coords(strings::Vector{String})
    vec_str = collect(strings)
    x_coords = Vector{Int}(undef, length(vec_str))
    y_coords = Vector{Int}(undef, length(vec_str))
    @inbounds for i in eachindex(vec_str)
        x, y = parse_coord(vec_str[i])
        x_coords[i] = x
        y_coords[i] = y
    end
    return (x_coords,y_coords)
end


function get_max_area(strings::Vector{String})
    x_coords,y_coords = parse_coords(strings)
    diff_map_x = x_coords .- x_coords'
    diff_map_x .+= 1
    diff_map_y = y_coords .- y_coords'
    diff_map_y .+= 1
    diff_mat = diff_map_x .* diff_map_y
    return(maximum(diff_mat))
end

# Returns the signed distance to the closest edge of the bounding box.
# Negative values indicate the point is inside.
function get_distance(xmin::Int, xmax::Int, ymin::Int, ymax::Int, point::Tuple{Int,Int})
    x, y = point
    dx = min(x - xmin, xmax - x)
    dy = min(y - ymin, ymax - y)
    return (dx, dy)
end

function is_point_inside_bbox(x::Int, y::Int, x_min::Int, x_max::Int, y_min::Int, y_max::Int)::Bool
    return (x_min < x < x_max) && (y_min < y < y_max)
end

function is_point_outside_bbox_both_axes(x::Int, y::Int, x_min::Int, x_max::Int, y_min::Int, y_max::Int)::Bool
    return (x < x_min || x > x_max) && (y < y_min || y > y_max)
end

function is_point_on_bbox_corner(x::Int, y::Int, x_min::Int, x_max::Int, y_min::Int, y_max::Int)::Bool
    return (x == x_min || x == x_max) && (y == y_min || y == y_max)
end

function b_box_is_valid(b_box_ind::Tuple{Int, Int}, coords::Vector{Tuple{Int, Int}})::Bool
    i, j = b_box_ind
    x1, y1 = coords[i]
    x2, y2 = coords[j]
    x_min, x_max = min(x1, x2), max(x1, x2)
    y_min, y_max = min(y1, y2), max(y1, y2)

    for k in eachindex(coords)
        if k == i || k == j
            continue
        end
        x, y = coords[k]
        if is_point_inside_bbox(x, y, x_min, x_max, y_min, y_max)
            return false
        end
        if is_point_outside_bbox_both_axes(x, y, x_min, x_max, y_min, y_max)
            continue
        end
        if is_point_on_bbox_corner(x, y, x_min, x_max, y_min, y_max)
            continue
        end
        # If last point, we cant get the next coords
        if k == length(coords)
            continue
        end

        

        # next_point = coords[k+1]
        # # Calculate signed distances from the current and next point to the box
        # dx1, dy1 = get_distance(x_min, x_max, y_min, y_max, coords[k])
        # dx2, dy2 = get_distance(x_min, x_max, y_min, y_max, next_point)
        # ddx = dx2 - dx1
        # ddy = dy2 - dy1

        # # If the movement in x or y brings the point closer than zero (i.e., would cross into the box or land inside)
        # if (dx1 > 0) && (dx1 + ddx < 0)
        #     return false
        # end
        # if (dy1 > 0) && (dy1 + ddy < 0)
        #     return false
        # end
    end
    return true
end

function get_max_area_b(strings::Vector{String})
    x_coords, y_coords = parse_coords(strings)
    all_coords = collect(zip(x_coords, y_coords))
    diff_map_x = x_coords .- x_coords'
    diff_map_x .+= 1
    diff_map_y = y_coords .- y_coords'
    diff_map_y .+= 1
    diff_mat = diff_map_x .* diff_map_y
    mat_size = size(diff_mat, 1)
    lin_idx_sorted = sortperm(vec(diff_mat); rev=true)
    inds = collect(zip(
        ((lin_idx_sorted .- 1) .% mat_size) .+ 1,
        ((lin_idx_sorted .- 1) .÷ mat_size) .+ 1
    ))
    for ind in inds
        if b_box_is_valid(ind, all_coords)
            return(ind)
        end
    end
end

test = [
    "7,1",  # 1
    "11,1", # 2
    "11,7", # 3 <- 
    "9,7",  # 4
    "9,5",  # 5
    "2,5",  # 6
    "2,3",  # 7 <- 
    "7,3"   # 8
]
@assert get_max_area(test) == 50
print(get_max_area_b(test))
# @assert get_max_area_b(test) == 24

lines = readlines("input/2025_9.txt")
print(get_max_area_b(lines)) # 205.826 μs