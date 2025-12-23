parse_ranges(ranges::Vector{String}) = [parse(Int, s[1]):parse(Int, s[2]) for r in ranges for s = [split(r, "-")]]

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

get_num_fresh(database::Database) = length(get_fresh_items(database))

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
@assert get_num_fresh(get_db(test)) == 3

lines = readlines("input/2025_5.txt")

get_num_fresh(get_db(lines))



