import random
import math
import pathlib
import cordic


def round(number):
    return int(math.floor(number))


def overflow(number, width):
    if -2**(width-1) <= number <= 2**(width-1)-1:
        return False
    else:
        return True


filepath = pathlib.Path(__file__).absolute().parent.parent.parent / 'rotator' / 'verification' / 'tb_cordic_stage' / 'stimulus.dat'
# Number of test cases to generate
NUMBER_OF_TESTS = 10000
# Deterministic seed for reproducibility
random.seed(54)

# Width, in bits, of general values
WIDTH = 10
# Width, in bits, of the integer part of angles
ANGLE_INTEGER_WIDTH = 8
# Width, in bits, of the fractional part of angles
ANGLE_FRACTIONAL_WIDTH = 16
# Width, in bits, of angles
ANGLE_WIDTH = ANGLE_FRACTIONAL_WIDTH+ANGLE_INTEGER_WIDTH
# Width, in bits, of number of shifts
SHIFT_WIDTH = 4

cordic_instace = cordic.cordic(coords_width=WIDTH, offset_coords_width=0, angle_integer_width=ANGLE_INTEGER_WIDTH, angle_fractional_width=ANGLE_FRACTIONAL_WIDTH)

with open(filepath, 'w') as fp:
    fp.write(f"# X0 Y0 Z0 sigma0 atan step X Y Z sigma\n")
    for _ in range(NUMBER_OF_TESTS):
        
        X0 = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
        Y0 = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
        Z0 = random.randint(-2**(ANGLE_WIDTH-1), 2**(ANGLE_WIDTH-1)-1)
        atan = random.randint(0, 45*2**ANGLE_FRACTIONAL_WIDTH)
        step = random.randint(0, 2**(SHIFT_WIDTH)-1)

        try:
            X, Y, Z = cordic_instace.cordic_stage(X0, Y0, Z0,  atan, step)
            fp.write(f"{X0} {Y0} {Z0} {atan} {step} {X} {Y} {Z}\n")
        except OverflowError:
            continue
