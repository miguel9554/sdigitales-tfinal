import random
import math
import pathlib


def round(number):
    return int(math.floor(number))


def overflow(number, width):
    if -2**(width-1) <= number <= 2**(width-1)-1:
        return False
    else:
        return True


filepath = pathlib.Path(__file__).absolute().parent.parent.parent / 'rotator' / 'verification' / 'tb_addsub' / 'stimulus.dat'
# Number of test cases to generate
NUMBER_OF_TESTS = 10000
# Deterministic seed for reproducibility
random.seed(54)

# Width, in bits, of general values
WIDTH = 10

with open(filepath, 'w') as fp:
    fp.write(f"# operation first_input second_input expected_result\n")
    for _ in range(NUMBER_OF_TESTS):

        first_input = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
        second_input = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
        
        if random.randint(0, 1) == 1:
            operation = '+'
            expected_result = first_input + second_input
        else:
            operation = '-'
            expected_result = first_input - second_input

        if overflow(expected_result, WIDTH):
            continue

        fp.write(f"{operation} {first_input} {second_input} {expected_result}\n")
