isodd

get_multiples(n::Int) = [i for i in div(n, 2):-1:1 if n % i == 0]::Vector{Int}

mutable struct IDStringCharacteristics
    min_len::Int
    max_len::Int
    fixed_len::Bool
    odd_len::Int
    multiples::Vector{Int}
    num_substrings::Int
end

function get_id_attr(min_id::Int, max_id::Int)::IDStringCharacteristics
    min_len = length(string(min_id))
    max_len = length(string(max_id))
    fixed_len = min_len == max_len
    odd_len = isodd(min_len) ? 1 : -1
    multiples = get_multiples(max_len)
    num_substrings = div(min_len, 2)
    return IDStringCharacteristics(min_len, max_len, fixed_len, odd_len, multiples, num_substrings)
end

function is_invalid_part_1(id_string::String, id_attr::IDStringCharacteristics)
    # Fast route, if all the numbers in the range have a fixed length then we only need to compute
    # the attributes related to length once. In an ideal world the datastructure would live in cache
    # and provide fast access.
    if id_attr.fixed_len
        if id_attr.odd_len == 1
            id_attr.odd_len *= -1 * id_attr.odd_len # Increment for next number
            return false
        end
        num_substrings = id_attr.num_substrings
        substring1 = id_string[1:num_substrings]
        substring2 = id_string[num_substrings+1 : 2 * num_substrings]
        return substring1 == substring2
    else
        substring_length = length(id_string)
        if isodd(substring_length) == true # Doesnt need to be incremented as all will follow slow route
            return false
        end
        num_substrings = div(substring_length, 2)
        substring1 = id_string[1:num_substrings]
        substring2 = id_string[num_substrings+1 : 2 * num_substrings]
        return substring1 == substring2
    end
end

function is_invalid_part_2(id_string::String, id_attr::IDStringCharacteristics)
    if id_attr.fixed_len
        substring_length = id_attr.min_len
        if substring_length == 1
            return false
        end
        for multiple in id_attr.multiples
            num_substrings = div(substring_length, multiple)
            if num_substrings == 1
                continue
            end
            all_substrings_equal = true
            for i in 1:num_substrings
                id_substring = id_string[(i-1) * multiple + 1 : i * multiple]
                if id_substring != id_string[1:multiple]
                    all_substrings_equal = false
                    break
                end
            end
            if all_substrings_equal
                return true
            end
        end
    else
        substring_length = length(id_string)
        if substring_length == 1
            return false
        end
        multiples = get_multiples(substring_length)
        for multiple in multiples
            num_substrings = div(substring_length, multiple)
            if num_substrings == 1
                continue
            end
            for i in 1:num_substrings
                id_substring = id_string[(i-1) * multiple + 1 : i * multiple]
                if id_substring != id_string[1:multiple]
                    return true
                end
            end
        end
    end
    return false
end


function parse_range_ids(substring::SubString{String})::Tuple{SubString{String}, SubString{String}}
    min_str, max_str = split(substring, "-")
    return min_str, max_str
end


function get_invalid_ids(min_id_str::SubString{String}, max_id_str::SubString{String}, part::Int)
    min_id = parse(Int, min_id_str)
    max_id = parse(Int, max_id_str)
    id_attr = get_id_attr(min_id, max_id)
    result = Vector{Int}()
    if part == 1
        for id in min_id:max_id
            if is_invalid_part_1(string(id), id_attr) == true
                push!(result, id)
            end
        end
        return result
    elseif part == 2
        for id in min_id:max_id
            if is_invalid_part_2(string(id), id_attr) == true
                push!(result, id)
            end
        end
        return result
    else
        error("Invalid part: $part")
    end
end

function get_id_total(substrings::Vector{SubString{String}}, part::Int)
    sum = Int(0)
    for substring in substrings
        min_id, max_id = parse_range_ids(substring)
        invalid_ids = get_invalid_ids(min_id, max_id, part)
        for id in invalid_ids
            sum += Int(id)
        end
    end
    return sum
end

ranges_test = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
ranges_test_list = split(ranges_test, ",")
@assert get_id_total(ranges_test_list, 1) == 1227775554
@assert get_id_total(ranges_test_list, 2) == 4174379265


function main()
    import time

    lines = readlines("input/2025_2.txt")
    lines[end] = replace(lines[end], "\n" => "")

    start_time_1 = time_ns()
    result_1 = get_id_total(lines, part=1)
    end_time_1 = time_ns()
    print(result_1)
    print("Part 1 runtime: $((end_time_1 - start_time_1) / 1000000000) seconds")

    start_time_2 = time_ns()
    result_2 = get_id_total(lines, part=2)
    end_time_2 = time_ns()
    print(result_2)
    print("Part 2 runtime: $((end_time_2 - start_time_2) / 1000000000) seconds")
end

if abspath(PROGRAM_FILE) == basename(@__FILE__)
    main()
end