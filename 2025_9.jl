
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

function contains_point(p1_i::Int, p2_i::Int, x_coords::Vector{Int}, y_coords::Vector{Int})::Bool
    p1_x, p1_y = x_coords[p1_i], y_coords[p1_i]
    p2_x, p2_y = x_coords[p2_i], y_coords[p2_i]
    for i in eachindex(x_coords)
        x_coord = x_coords[i]
        y_coord = y_coords[i]
        is_within_x = x_coord >= p2_x && x_coord <= p1_x
        is_within_y = y_coord >= p2_y && y_coord <= p1_y
        if is_within_x && is_within_y
            return true
        end
    end
    return false
end

function get_max_area_b(strings::Vector{String})
    x_coords,y_coords = parse_coords(strings)
    diff_map_x = x_coords .- x_coords'
    diff_map_x .+= 1
    diff_map_y = y_coords .- y_coords'
    diff_map_y .+= 1
    diff_mat = diff_map_x .* diff_map_y
    mat_size = size(diff_mat, 1)
    lin_idx_sorted = sortperm(vec(diff_mat); rev=true)
    x_ind = ((lin_idx_sorted .- 1) .% mat_size) .+ 1
    y_ind = ((lin_idx_sorted .- 1) .÷ mat_size) .+ 1
    for i in eachindex(x_ind)
       point_found = contains_point(x_ind[i], y_ind[i], x_coords, y_coords)
        if point_found
            continue
        end
        return(diff_mat[x_ind[i], y_ind[i]])
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
@assert get_max_area(test) == 50

@assert get_max_area_b(test) == 24

lines = readlines("input/2025_9.txt")
print(get_max_area_b(lines)) # 205.826 μs