using BenchmarkTools

function get_indices_range(total_length::Int, num_digits::Int, digit_position::Int)
    start_idx = digit_position
    end_idx = min(total_length, total_length - num_digits + digit_position)
    return start_idx:end_idx
end

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

function find_max_joltage_pt_2(string::String, j_digits::Int)
    battery_num_array = parse.(Int, collect(string))
    out_index = zeros(Int, j_digits)
    out_joltage = zeros(Int, j_digits)
    for digit in 1:j_digits
        possible_indices = get_indices_range(length(string), j_digits, digit)
        sorted = sortperm(battery_num_array[possible_indices], rev=true) .+ (digit - 1)
        for sorted_ind in sorted
            if !(sorted_ind in out_index) && (sorted_ind > maximum(out_index))
                out_index[digit] = sorted_ind
                out_joltage[digit] = battery_num_array[sorted_ind]
                break
            end
        end
    end

    return parse(Int, join(out_joltage))
end

function total_joltage(battery_vec::Vector{String})
    total = 0
    for string in battery_vec
        max_joltage = find_max_joltage_pt_2(string, 12)
        total += max_joltage
    end
    return total
end

@assert find_max_joltage_pt_2("987654321111111", 12) == 987654321111
@assert find_max_joltage_pt_2("811111111111119", 12) == 811111111119
@assert find_max_joltage_pt_2("234234234234278", 12) == 434234234278
@assert find_max_joltage_pt_2("818181911112111", 12) == 888911112111

function main()
    batteries = readlines("input/2025_3.txt")
    batteries[end] = replace(batteries[end], "\n" => "")
    result = total_joltage(batteries)
    @btime total_joltage($batteries)
    print(result)
end

main()