test = ["0:", "###", "##.", "##.", "", "1:", "###", "##.", ".##", "", "2:", ".##", "###", "##.", "", "3:", "##.", "###", "##.", "", "4:", "###", "#..", "###", "", "5:", "###", ".#.", "###", "", "4x4: 0 0 0 0 2 0", "12x5: 1 0 1 0 2 2", "12x5: 1 0 1 0 3 2"]

function find_starts(input::Vector{String})
    shape_start_ind = Int[]
    region_start_ind = Int[]
    for (i,string) in enumerate(input)
        if ':' in string
            if 'x' in string
                push!(region_start_ind, i)
            else
                push!(shape_start_ind, i)
            end
        end
    end
    return shape_start_ind, region_start_ind
end

function get_shape_dims(input::Vector{String})
	ncol = length(input[2])
	nrow = 0
	for (i, string) in enumerate(input)
		if string == ""
			nrow = i - 2 # Skip the first line and the last line
			break
		end
	end
	return nrow,ncol
end

function parse_matrix!(input::Vector{String}, start_index::Int, nrow::Int, ncol::Int,  matrix::AbstractArray)
	for (i,string) in enumerate(input[start_index+1:start_index+nrow])
		for (j,char) in enumerate(string)
			if char == '#'
				matrix[i,j] = 1
			end
		end
	end
end

function parse_shapes(input::Vector{String}, start_indices::Vector{Int})
    nrow,ncol = get_shape_dims(input)
	nshapes = length(start_indices)
	shapes = zeros(Bool, nrow, ncol, nshapes)
    for (i, index) in enumerate(start_indices)
		parse_matrix!(input, index, nrow, ncol, @view shapes[:,:,i])
    end
	return shapes
end

struct Region
	nrow::Int
	ncol::Int
	shapes_required::Vector{Int}
end

function parse_region(string::String)::Region
	dims_str,shapes_str = split(string,':')
	ncol_char,nrow_char = split(dims_str, 'x')
	ncol,nrow = parse(Int, ncol_char), parse(Int, nrow_char)
	shapes_required = Int[]
	for char in shapes_str
		if char != ' '
			push!(shapes_required, parse(Int,char))
		end
	end
	return Region(nrow,ncol,shapes_required)
end

function parse_regions(input::Vector{String}, start_indices::Vector{Int})
	regions = Region[]
	for index in start_indices
		push!(regions, parse_region(input[index]))
	end
	return regions
end

shape_starts, region_starts = find_starts(test)
@time parse_shapes(test, shape_starts)
@time parse_regions(test, region_starts)

