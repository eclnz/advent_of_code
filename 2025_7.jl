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

function split_beams(new_line::Vector{Char}, beam_indices::Set{Int}, split_counter::Ref{Int}, timelines_counter::Ref{Int})
    split_indices = find_splits(new_line)
    for s_i in eachindex(split_indices)
        split_index = split_indices[s_i]
        if split_index == 0
            continue
        end
        if split_index in beam_indices 
            delete!(beam_indices, split_index)
            if split_index - 1 > 0 
                push!(beam_indices, split_index - 1)
            end
            if split_index + 1 <= length(new_line)
                push!(beam_indices, split_index + 1)
            end
            split_counter[] += 1
            timelines_counter[] += 2

        end
    end
end

function find_beam_start_index(start_line::Vector{Char})
    idx = findfirst(c -> c == 'S', start_line)
    return idx === nothing ? 0 : idx
end

function increment_beam(strings::Vector{String})
    string_arrays = [collect(s) for s in strings]
    starting_position = find_beam_start_index(string_arrays[1])
    beam_indices = Set{Int}([starting_position])
    split_counter = Ref(0)
    timeline_counter = Ref(0)
    for i in 3:2:length(string_arrays)
        split_beams(string_arrays[i], beam_indices, split_counter, timeline_counter)
    end
    return split_counter[]
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

@assert increment_beam(test) == 21

function main()
    lines = readlines("input/2025_7.txt")
    lines[end] = replace(lines[end], "\n" => "")
    print(increment_beam(lines))
end

main()