function parse_ranges(ranges::Vector{String})
    parsed = Vector{UnitRange{Int}}(undef, length(ranges))
    for (i, range) in enumerate(ranges)
        parts = split(range, "-")
        start_val = parse(Int, parts[1])
        end_val = parse(Int, parts[2])
        parsed[i] = start_val:end_val
    end
    return parsed
end

parse_available(available::Vector{String}) = [parse(Int, x) for x in available]

struct Database
    fresh_ranges::Vector{UnitRange{Int}}
    available::Vector{Int}
end

function get_db(input::Vector{String})::Database
    for (index, line) in enumerate(input)
        if line == ""
            fresh_ranges = parse_ranges(input[1:index-1])
            available = parse_available(input[index+1:end])
            return Database(fresh_ranges, available)
        end
    end
end

function get_fresh_items(database::Database)
    fresh_items = Int[]
    for item in database.available
        if any(r -> item in r, database.fresh_ranges)
            append!(fresh_items, item)
        end 
    end
    return fresh_items
end

get_num_fresh_a(database::Database) = length(get_fresh_items(database))

function is_crossover(range1::UnitRange, range2::UnitRange)
    return first(range1) <= last(range2) && first(range2) <= last(range1)
end

function merge_ranges(ranges::Vector{UnitRange{Int}})
    merged = UnitRange{Int}[]
    sorted_ranges = sort(ranges; by = x -> first(x))
    for range in sorted_ranges
        if !isempty(merged) && is_crossover(range, merged[end])
            merged[end] = min(first(range), first(merged[end])):max(last(range), last(merged[end]))
        else
            push!(merged, range)
        end
    end
    return merged
end

get_num_in_range(ranges::Vector{UnitRange{Int}}) = sum([length(range) for range in ranges])

function get_num_fresh_b(database::Database)
    merged = merge_ranges(database.fresh_ranges)
    return get_num_in_range(merged)
end

test = [
    "3-5"
    "10-14"
    "16-20"
    "12-18"
    ""
    "1"
    "5"
    "8"
    "11"
    "17"
    "32"
]
@assert get_num_fresh_a(get_db(test)) == 3
@assert get_num_fresh_b(get_db(test)) == 14

lines = readlines("input/2025_5.txt")

db = get_db(lines)
println(get_num_fresh_a(db))
println(get_num_fresh_b(db))



