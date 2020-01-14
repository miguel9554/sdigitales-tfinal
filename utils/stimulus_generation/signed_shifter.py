import random
import math


def round(number):
    return int(math.floor(number))


filepath = '../../verification/tb_signed_shifter/stimulus.dat'
# Number of test cases to generate
NUMBER_OF_TESTS = 10000
# Deterministic seed for reproducibility
random.seed(54)

# Width, in bits, of general values
WIDTH = 10
# Width, in bits, of number of shifts
SHIFT_WIDTH = 4

with open(filepath, 'w') as fp:
    fp.write(f"# input_vector shift_positions expected_result\n")
    for _ in range(NUMBER_OF_TESTS):

        input_value = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
        number_of_shifts = random.randint(0, 2**(SHIFT_WIDTH)-1)

        expected_result = round(input_value/(2**number_of_shifts))

        # The smallest number we can get right shifting a negative number is -1
        if (input_value < 0) and (expected_result == 0):
            expected_result = -1

        fp.write(f"{input_value} {number_of_shifts} {expected_result}\n")
