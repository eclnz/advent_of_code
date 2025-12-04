NUM_MIN = 0
NUM_MAX = 99

def get_rotation_sign(rotation: str) -> int:
    if rotation == "R":
        return 1
    elif rotation == "L":
        return -1
    else:
        raise(ValueError)

def unwind_length(length: int) -> int:
    """Handle cases where rotation length is higher than a full rotation"""
    if length > NUM_MAX:
        # Implement divmod
        length %= NUM_MAX + 1 
    return length

def get_new_position(position, transform):
    new_position = position + transform
    # Handle crossover 99:0
    if new_position > NUM_MAX:
        new_position -= NUM_MAX + 1
    elif new_position < NUM_MIN:
        new_position += NUM_MAX + 1
    return new_position

class Rotation:
    def __init__(self, sign: int, length: int):
        self.sign = sign
        self.length = unwind_length(length)
        self.transform = self.length * sign
        # self.full_rotations

def get_rotated_position(position: int, rotation: Rotation):
    return get_new_position(position,rotation.transform)

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

test_string = ["L68", "L30","R48","L5","R60","L55","L1","L99","R14","L82"]
assert count_zeros(50,test_string) == 3

with open("input/2025_1.txt", "r") as file:
    lines = file.readlines()
print(count_zeros(50,lines))