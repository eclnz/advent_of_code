using BenchmarkTools

function find_max_joltage(string::String)
    sort_ind_batteries = sortperm(collect(string), rev = true)
    if sort_ind_batteries[1] != length(string)
        highest_index = sort_ind_batteries[1]
        second_index = highest_index
        for ind in sort_ind_batteries[2:end]
            if ind > highest_index
                second_index = ind
                break
            end
        end
    else
        highest_index = sort_ind_batteries[2]
        second_index = sort_ind_batteries[1]
    end
    return parse(Int, string[highest_index] * string[second_index])
end

function total_joltage(battery_vec::Vector{String})
    total = 0
    for string in battery_vec
        max_joltage = find_max_joltage(string)
        total += max_joltage
    end
    return total
end

function test_batteries()
    return ["987654321111111", "811111111111119", "234234234234278", "818181911112111"]
end

test_result = total_joltage(test_batteries())
@assert test_result == 357

function main()
    batteries = readlines("input/2025_3.txt")
    batteries[end] = replace(batteries[end], "\n" => "")
    @btime result = total_joltage($batteries)
    print(result)
end

main()