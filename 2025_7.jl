using BenchmarkTools

function find_splits(line::Vector{Char})
    line_length = length(line)
    splits = zeros(Int, line_length)
    counter = 1
    @inbounds for index in 1:line_length
        if line[index] == '^'
            splits[counter] = index
            counter += 1
        end
    end
    return splits
end

@assert find_splits(collect(".....^.^.^....."))[1:3] == [6,8,10]
@assert find_splits(collect("....^.^...^...."))[1:3] == [5,7,11]
beam_positions = [5,7,9,11]
split_positions = [5,7,11]

function split_beams_a(new_line::Vector{Char}, beam_indices::Set{Int}, split_counter::Ref{Int})
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

main()