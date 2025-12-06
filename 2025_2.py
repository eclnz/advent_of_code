import numpy as np


def is_odd(n: int) -> bool:
    return n % 2 == 1


def get_multiples(n: int) -> list[int]:
    return [i for i in range(n // 2, 0, -1) if n % i == 0]


def is_invalid_part_1(id_string: str) -> bool:
    length = len(id_string)
    if length == 1:
        return False
    if is_odd(length):
        return False
    num_substrings = int(length / 2)
    id_substrings = [
        id_string[i * num_substrings : (i + 1) * num_substrings] for i in range(2)
    ]
    return all(id_substring == id_substrings[0] for id_substring in id_substrings)


def is_invalid_part_2(id_string: str) -> bool:
    length = len(id_string)
    if length == 1:
        return False
    multiples = get_multiples(length)
    for multiple in multiples:
        num_substrings = int(length / multiple)
        if num_substrings == 1:
            continue
        id_substrings = [
            id_string[i * multiple : (i + 1) * multiple] for i in range(num_substrings)
        ]
        if all(id_substring == id_substrings[0] for id_substring in id_substrings):
            return True
    return False


def get_str_range(min: int, max: int) -> list[str]:
    integers = np.arange(min, max + 1)  # Account for 0 indexing
    return [str(integer) for integer in integers]


def parse_range_ids(string: str) -> list[str]:
    min_str, max_str = string.split("-")
    return get_str_range(int(min_str), int(max_str))


def get_invalid_ids(strings: list[str], part: int) -> list[str]:
    if part == 1:
        return [s for s in strings if is_invalid_part_1(s)]
    elif part == 2:
        return [s for s in strings if is_invalid_part_2(s)]
    else:
        raise ValueError(f"Invalid part: {part}")


def get_id_total(strings: list[str], part: int) -> int:
    sum = 0
    for string in strings:
        all_ids = parse_range_ids(string)
        invalid_ids = get_invalid_ids(all_ids, part)
        sum += np.sum([int(id) for id in invalid_ids])
    return int(sum)


ranges_test = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
ranges_test_list = ranges_test.split(",")
assert get_id_total(ranges_test_list, part=1) == 1227775554
assert get_id_total(ranges_test_list, part=2) == 4174379265


def main() -> None:
    import time

    with open("input/2025_2.txt", "r") as file:
        lines = file.read().split(",")
    lines[-1] = lines[-1].replace("\n", "")

    start_time_1 = time.perf_counter()
    result_1 = get_id_total(lines, part=1)
    end_time_1 = time.perf_counter()
    print(result_1)
    print(f"Part 1 runtime: {end_time_1 - start_time_1:.6f} seconds")

    start_time_2 = time.perf_counter()
    result_2 = get_id_total(lines, part=2)
    end_time_2 = time.perf_counter()
    print(result_2)
    print(f"Part 2 runtime: {end_time_2 - start_time_2:.6f} seconds")


if __name__ == "__main__":
    main()
