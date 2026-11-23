get_symbol_indices(last_line::String) = findall(!=(' '), last_line)

function get_col_lengths(symbol_indices::Vector{Int}, line_length::Int)
    first = [1; symbol_indices]
    last = [symbol_indices; (line_length + 1)]
	diff = (last .- first) .- 1
	diff[end] += 1
    return diff[2:end]
end

function get_col_ranges(end_line)
    inds = get_symbol_indices(end_line)
    line_length = length(end_line)
    ind_lengths = get_col_lengths(inds, line_length)
    ranges = [inds[i] : inds[i] + (ind_lengths[i] - 1) for i in eachindex(inds)]
    return ranges
end

function as_hor_mat(lines::Vector{String})
    ranges = get_col_ranges(lines[end])
    mat = Array{Int}(undef, length(lines)-1, length(ranges))
    for (col, range) in enumerate(ranges)
        for row in 1:(length(lines)-1)
            line = lines[row]
            substr = line[range]
            num = parse(Int, strip(substr))
            mat[row, col] = num
        end
    end
    operation_map = Dict("*" => (*), "+" => (+))
    operations = [operation_map[strip(lines[end][range])] for range in ranges]
    return mat, operations
end

function as_ver_mat(lines::Vector{String})
    ranges = get_col_ranges(lines[end])
	n_rows = length(lines)-1
	n_cols = length(ranges)
	max_char_count = maximum([length(range) for range in ranges])
	char_arr = fill('x', n_rows, n_cols, max_char_count)
    for (col_i, range) in enumerate(ranges)
		subdivided_matrix = Matrix(undef, n_rows, length(ranges))
       	for row_i in 1:n_rows
        	line = lines[row_i]
            substr = line[range]
			substr = replace(substr," " => "x")
			chars = collect(substr)
			char_arr[row_i, col_i, 1:length(range)] = chars
        end
    end
	str_mat = [@view char_arr[:, j, k] for j in axes(char_arr, 2), k in axes(char_arr, 3)]
	display(str_mat)
	# remove filler chars following indexing along rows
	clean_mat = [filter(c -> c != 'x', s) for s in str_mat]
	# Suppose clean_mat is an array of Vector{Char} or strings
	mat = Vector{Vector{Int}}()  # start with an empty vector of vectors

	for s in clean_mat
    	if !isempty(s)
        	# Convert chars to integers
        	vec = [parse(Int, c) for c in s]
        	push!(mat, vec)  # only add if not empty
    	end
	end
	operation_map = Dict("*" => (*), "+" => (+))
    operations = [operation_map[strip(lines[end][range])] for range in ranges]
	return Matrix(mat'), operations
end

function apply_operations(matrix::Matrix, operations::Vector{Function})
    total = 0
    for (col_idx, col) in enumerate(eachcol(matrix))
        total += reduce(operations[col_idx], col)
    end
    return total
end

get_grand_total_a(lines::Vector{String}) = apply_operations(as_hor_mat(lines)...)
get_grand_total_b(lines::Vector{String}) = apply_operations(as_ver_mat(lines)...)

test = [
    "123 328  51 64 "
    " 45 64  387 23 "
    "  6 98  215 314"
    "*   +   *   +  "
]

@assert get_grand_total_a(test) == 4277556
@assert get_grand_total_b(test) == 3263827

mat, ops = as_ver_mat(test)
display(mat)
lines = readlines("input/2025_6.txt")
println(get_grand_total_a(lines))
println(get_grand_total_b(lines))
