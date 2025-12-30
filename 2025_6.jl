get_symbol_indices(last_line::String) = findall(!=(' '), last_line)

function get_col_lengths(symbol_indices::Vector{Int}, line_length::Int)
    first = [1; symbol_indices]
    last = [symbol_indices; (line_length + 1)]
    diff = last .- first
    return diff[2:end]
end

function get_col_ranges(end_line)
    inds = get_symbol_indices(end_line)
    line_length = length(end_line)
    ind_lengths = get_col_lengths(inds, line_length)
    ranges = [inds[i] : inds[i] + (ind_lengths[i] - 1) for i in eachindex(inds)]
    return ranges
end

function as_matrix(lines::Vector{String})
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

function apply_operations(matrix::Matrix, operations::Vector{Function})
    total = 0
    for (col_idx, col) in enumerate(eachcol(matrix))
        total += reduce(operations[col_idx], col)
    end
    return total
end

get_grand_total(lines::Vector{String}) = apply_operations(as_matrix(lines)...)

test = [
    "123 328  51 64 "
    " 45 64  387 23 "
    "  6 98  215 314"
    "*   +   *   +  "
]

@assert get_grand_total(test) == 4277556

lines = readlines("input/2025_6.txt")
print(get_grand_total(lines))
