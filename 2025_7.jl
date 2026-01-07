using BenchmarkTools

function find_splits(line::Vector{Char})
    splits = Int[]
    @inbounds for index in 1:length(line)
        if line[index] == '^'
            push!(splits, index)
        end
    end
    return splits
end

@assert find_splits(collect(".....^.^.^.....")) == [6,8,10]
@assert find_splits(collect("....^.^...^....")) == [5,7,11]
beam_positions = [5,7,9,11]
split_positions = [5,7,11]

function split_beams_a(new_line::Vector{Char}, beam_indices::Set{Int}, split_counter::Ref{Int})
    split_indices = find_splits(new_line)
    for split_index in split_indices
        if split_index in beam_indices 
            delete!(beam_indices, split_index)
            push!(beam_indices, split_index - 1)
            push!(beam_indices, split_index + 1)
            split_counter[] += 1
        end
    end
end

function split_beams_b(new_line::Vector{Char}, beam_indices::Set{Int}, n_timelines::Vector{Int})
    split_indices = find_splits(new_line)
    for s_i in eachindex(split_indices)
        split_index = split_indices[s_i]
        if split_index == 0
            continue
        end
        if split_index in beam_indices
            delete!(beam_indices, split_index)
            push!(beam_indices, split_index - 1)
            push!(beam_indices, split_index + 1)
            n_timelines[split_index + 1] += n_timelines[split_index]
            n_timelines[split_index - 1] += n_timelines[split_index]
            n_timelines[split_index] = 0
        end
    end
end

function split_beams(new_line::Vector{Char}, beam_indices::Vector{Int}, timelines_counter::Ref{Int})
    split_indices = find_splits(new_line)
    new_beams = Int[]
    deleted_indices = Int[]
    for split_index in split_indices
        match_indices = findall(x -> x == split_index, beam_indices)
        if !isempty(match_indices)
            append!(deleted_indices, match_indices)
            for _ in 1:length(match_indices)
                push!(new_beams, split_index - 1)
                push!(new_beams, split_index + 1)
                timelines_counter[] += 1
            end
        end
    end
    for idx in sort(deleted_indices; rev=true)
        deleteat!(beam_indices, idx)
    end
    append!(beam_indices, new_beams)
end

function find_beam_start_index(start_line::Vector{Char})
    idx = findfirst(c -> c == 'S', start_line)
    return idx === nothing ? 0 : idx
end

function increment_beam_a(strings::Vector{String})
    string_arrays = [collect(s) for s in strings]
    starting_position = find_beam_start_index(string_arrays[1])
    beam_indices = Set{Int}([starting_position])
    split_counter = Ref(0)
    for i in 3:2:length(string_arrays)
        split_beams_a(string_arrays[i], beam_indices, split_counter)
    end
    return split_counter[]
end

function increment_beam_b(strings::Vector{String})
    string_arrays = [collect(s) for s in strings]
    starting_position = find_beam_start_index(string_arrays[1])
    beam_indices = Set{Int}([starting_position])
    n_timelines = zeros(Int,length(string_arrays[1]))
    middle_index = Int(length(string_arrays) / 2)
    n_timelines[middle_index] = 1
    for i in 3:2:length(string_arrays)
        split_beams_b(string_arrays[i], beam_indices, n_timelines)
    end
    return sum(n_timelines)
end

test = 
[
    ".......S.......",
    "...............",
    ".......^.......",
    "...............",
    "......^.^......",
    "...............",
    ".....^.^.^.....",
    "...............",
    "....^.^...^....",
    "...............",
    "...^.^...^.^...",
    "...............",
    "..^...^.....^..",
    "...............",
    ".^.^.^.^.^...^.",
    "..............."
]

@assert increment_beam_a(test) == 21
@assert increment_beam_b(test) == 40

function main()
    lines = readlines("input/2025_7.txt")
    lines[end] = replace(lines[end], "\n" => "")
    print(increment_beam_a(lines))
    print(" ")
    print(increment_beam_b(lines))
    @btime increment_beam_b($lines)
end

function get_first_index(array::AbstractVector{T}, find_val::T, forward::Bool) where T
    indices = forward ? (1:length(array)) : (length(array):-1:1)
    for index in indices
        if array[index] == find_val
            return index
        end
    end
    return nothing
end

function substrings_from_first_index(s::String)::Vector{Char}
    chars = collect(s)
    forward_idx = get_first_index(chars, '^', true)
    backward_idx = get_first_index(chars, '^', false)
    return chars[forward_idx:2:backward_idx]
end

function sanitise_input(strings::Vector{String})
    n = length(strings)
    trimmed = strings[3:n-1][1:2:end]
    substrings = [substrings_from_first_index(s) for s in trimmed]
    return substrings
end

function triangle_matrix(triangle::Vector{Vector{Char}})
    height = length(triangle)
    width = maximum(length.(triangle))
    grid = zeros(Int, height, width)
    for (row_idx, row) in enumerate(triangle)
        for (col_idx, cell) in enumerate(row)
            grid[row_idx, col_idx] = cell == '^' ? 1 : 0
        end
    end
    return grid
end

function pascal_sum(n::Int)::BigInt
    return big(2)^(n+1) - 2
end

function pascal_value(row_num::Int, n_from_side::Int)::BigInt
    k_sym = min(n_from_side - 1, row_num - (n_from_side - 1))
    n = row_num - 1
    val = big(1)
    for i in 1:k_sym
        val *= (n - i + 1) ÷ i
    end
    return val
end

function find_no_splits(triangle::Vector{Vector{Char}})
    no_split_positions = Vector{Tuple{Int,Int}}(undef, 0)
    sizehint!(no_split_positions, sum(length, triangle))
    for (depth, row) in enumerate(triangle)
        for (n_from_side, cell) in enumerate(row)
            if cell == '.'
                push!(no_split_positions, (n_from_side, depth))
            end
        end
    end
    return no_split_positions
end

function get_all_timelines(triangle::Vector{Vector{Char}})
    total_height = length(triangle[end])
    total_timelines = pascal_sum(total_height)
    no_splits = find_no_splits(triangle)
    for (n_from_side, depth) in no_splits
        mini_tri_height = total_height - depth + 1
        sum = pascal_sum(mini_tri_height) * pascal_value(depth, n_from_side)
        total_timelines -= sum
    end
    print(total_timelines)
end

lines = readlines("input/2025_7.txt")
lines[end] = replace(lines[end], "\n" => "")
sanitise_input(test)