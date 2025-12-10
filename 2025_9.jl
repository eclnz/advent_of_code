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
result = get_max_area(test)
@assert result == 50

lines = readlines("input/2025_9.txt")
print(get_max_area(lines)) # 205.826 μs