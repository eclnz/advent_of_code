using BenchmarkTools

function find_max_joltage_pt_2(string::String, j_digits::Int)
    battery_num_array = parse.(Int, collect(string))
    out_index = zeros(Int, j_digits)
    out_joltage = zeros(Int, j_digits)
    for digit in 1:j_digits
        start_idx = digit
        end_idx = min(length(string), length(string) - j_digits + digit)
        possible_indices = start_idx:end_idx
        sorted = sortperm(battery_num_array[possible_indices], rev=true) .+ (digit - 1)
        for sorted_ind in sorted
            if sorted_ind > maximum(out_index)
                out_index[digit] = sorted_ind
                out_joltage[digit] = battery_num_array[sorted_ind]
                break
            end
        end
    end
    return parse(Int, join(out_joltage))
end

function total_joltage(battery_vec::Vector{String})
    return sum(string -> find_max_joltage_pt_2(string, 12), battery_vec)
end

@assert find_max_joltage_pt_2("987654321111111", 12) == 987654321111
@assert find_max_joltage_pt_2("811111111111119", 12) == 811111111119
@assert find_max_joltage_pt_2("234234234234278", 12) == 434234234278
@assert find_max_joltage_pt_2("818181911112111", 12) == 888911112111

function main()
    batteries = readlines("input/2025_3.txt")
    result = total_joltage(batteries)
    @btime total_joltage($batteries)
    print(result)
end

main()