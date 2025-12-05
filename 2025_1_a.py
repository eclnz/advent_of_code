from typing import Tuple
NUM_MIN = 0
NUM_MAX = 99
TOTAL_NUM = 100

def get_rotation_sign(rotation: str) -> int:
    if rotation == "R":
        return 1
    elif rotation == "L":
        return -1
    else:
        raise ValueError(f"Invalid rotation: {rotation}")

def unwind_length(length: int) -> Tuple[int, int]:
    """Handle cases where rotation length is higher than a full rotation"""
    full_rotations = 0
    if length > NUM_MAX:
        full_rotations, length = divmod(length, TOTAL_NUM)
    return full_rotations, length

class Rotation:
    def __init__(self, sign: int, length: int):
        self.sign = sign
        self.full_rotations, self.length = unwind_length(length)
        self.transform = self.length * sign

def get_rotated_position(position: int, rotation: Rotation) -> int:
    new_position = position + rotation.transform
    # Handle crossover 99:0
    if new_position > NUM_MAX or new_position < NUM_MIN:
        new_position = (position + rotation.transform) % TOTAL_NUM
    return new_position

# Test rotate forward and backwards
assert get_rotated_position(50, Rotation(1, 5)) == 55
assert get_rotated_position(55, Rotation(-1, 5)) == 50
# Test crossing boundary
assert get_rotated_position(95, Rotation(1, 10)) == 5
assert get_rotated_position(5, Rotation(-1, 10)) == 95
# Test multiple rotations
assert get_rotated_position(5, Rotation(1, 100)) == 5
assert get_rotated_position(5, Rotation(-1, 100)) == 5
assert get_rotated_position(5, Rotation(1, 200)) == 5

def get_num_full_rotations(position: int, rotation: Rotation) -> int:
    new_position = position + rotation.transform
    num_full_rotations = rotation.full_rotations
    # If new position is crossing over 99:0 then count that as a rotation.
    # Arrivals and dispatches to and from 0 should not be counted in this 
    # function; it's captured later when the position is checked for 0.
    # 99 + 1 should be considered 0, its just hitting 0 from the opposite side.
    if new_position > (NUM_MAX + 1) or new_position < NUM_MIN and position != 0:
        num_full_rotations += 1
    return num_full_rotations

# Test detection of normal crossover
assert get_num_full_rotations(95, Rotation(1,10)) == 1
assert get_num_full_rotations(95, Rotation(1,110)) == 2
assert get_num_full_rotations(5, Rotation(-1,300)) == 3

def parse_rotation(line: str) -> Rotation:
    rotation_dir = line[0]
    rotation_sign = get_rotation_sign(rotation_dir)
    rotation_len = int(line[1:])
    return Rotation(rotation_sign, rotation_len)

def count_zeros(start_position: int, strings: list[str]) -> int:
    rotations = [
        parse_rotation(string) for string in strings
    ]
    position = start_position
    zeros = 0
    for rotation in rotations:
        position = get_rotated_position(position, rotation)
        if position == 0:
            zeros += 1
    return zeros

def count_cross_zero(start_position: int, strings: list[str]) -> int:
    rotations = [
        parse_rotation(string) for string in strings
    ]
    position = start_position
    num_zeros = 0
    for rotation in rotations:
        num_zeros += get_num_full_rotations(position, rotation)
        position = get_rotated_position(position, rotation)
        if position == 0:
            num_zeros += 1
    return num_zeros

test_string = ["L68", "L30","R48","L5","R60","L55","L1","L99","R14","L82"]
assert count_zeros(50,test_string) == 3
assert count_cross_zero(50,test_string) == 6
assert count_cross_zero(1, ["R999"]) == 10
assert count_cross_zero(50, ["L999", "R50"]) == 11

#  Thanks to the following thread for these assertion tests. https://www.reddit.com/r/adventofcode/comments/1pbnu0f/2025_day_1_part_2_python_help_on_part_2/
assert count_cross_zero(50, ["L150", "R50"]) == 2
assert count_cross_zero(50, ["L150", "L50"]) == 2

with open("input/2025_1.txt", "r") as file:
    lines = file.readlines()

print(f"Part 1:{count_zeros(50,lines)}")
print(f"Part 2:{count_cross_zero(50,lines)}")
