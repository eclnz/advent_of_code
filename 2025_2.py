import numpy as np


def is_odd(n: int) -> bool:
    return n % 2 == 1


def get_multiples(n: int) -> list[int]:
    return [i for i in range(n // 2, 0, -1) if n % i == 0]

class IDStringCharacteristics:
    def __init__(self, min_str: str, max_str: str) -> None:
        self.min_len = len(min_str)
        self.max_len = len(max_str)
        self.fixed_len = self.min_len == self.max_len
        self.odd_len = 1 if is_odd(self.min_len) else -1
        self.num_substrings: int = int(self.min_len/2)
        self.multiples = get_multiples(self.max_len)


def is_invalid_part_1(id_string: str, id_attr: IDStringCharacteristics) -> bool:
    # Fast route, if all the numbers in the range have a fixed length then we only need to compute
    # the attributes related to length once. In an ideal world the datastructure would live in cache
    # and provide fast access.
    if id_attr.fixed_len:
        if id_attr.odd_len == 1:
            id_attr.odd_len *= -1 * id_attr.odd_len
            return False
        num_substrings = id_attr.num_substrings
        return id_string[0 : num_substrings] == id_string[num_substrings : 2 * num_substrings]
    else:
        length = len(id_string)
        if is_odd(length):
            return False
        num_substrings = int(length / 2)
        return id_string[0 : num_substrings] == id_string[num_substrings : 2 * num_substrings]


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


def parse_range_ids(string: str) -> tuple[str, str]:
    min_str, max_str = string.split("-")
    return min_str,max_str

def get_invalid_ids(min_id_str: str, max_id_str: str, part: int) -> list[str]:
    # Loop through each number from min id to max id (+ 1 to account for 0 indexing of range function)
    # Test each of these values whether they are invalid
    if part == 1:
        result = []
        id_attr = IDStringCharacteristics(min_id_str, max_id_str)
        for id in range(int(min_id_str), int(max_id_str) + 1):
            if is_invalid_part_1(str(id), id_attr):
                result.append(str(id))
        return result
    elif part == 2:
        return [str(id) for id in range(int(min_id_str), int(max_id_str) + 1) if is_invalid_part_2(str(id))]
    else:
        raise ValueError(f"Invalid part: {part}")


def get_id_total(strings: list[str], part: int) -> int:
    sum = 0
    for string in strings:
        min_id, max_id = parse_range_ids(string)
        invalid_ids = get_invalid_ids(min_id, max_id, part)
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
