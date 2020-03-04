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


filepath = pathlib.Path(__file__).absolute().parent.parent.parent / 'rotator' / 'verification' / 'tb_cordic_stage' / 'stimulus.dat'
# Number of test cases to generate
NUMBER_OF_TESTS = 100000
# Deterministic seed for reproducibility
random.seed(54)

# Width, in bits, of general values
WIDTH = 10
# Width, in bits, of the integer part of angles
ANGLE_INTEGER_WIDTH = 6
# Width, in bits, of the fractional part of angles
ANGLE_FRACTIONAL_WIDTH = 16
# Width, in bits, of angles
ANGLE_WIDTH = ANGLE_FRACTIONAL_WIDTH+ANGLE_INTEGER_WIDTH+1
# Width, in bits, of number of shifts
SHIFT_WIDTH = 4

with open(filepath, 'w') as fp:
    fp.write(f"# X0 Y0 Z0 sigma0 atan step X Y Z sigma\n")
    for _ in range(NUMBER_OF_TESTS):
        
        X0 = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
        Y0 = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
        Z0 = random.randint(-2**(ANGLE_WIDTH-1), 2**(ANGLE_WIDTH-1)-1)
        atan = random.randint(0, 45*2**16)
        sigma0 = random.randint(0, 1)
        step = random.randint(0, 2**(SHIFT_WIDTH)-1)
        
        X = X0 - round(Y0/(2**step)) if not sigma0 else X0 + round(Y0/(2**step))
        Y = Y0 + round(X0/(2**step)) if not sigma0 else Y0 - round(X0/(2**step))
        Z = Z0 - atan if not sigma0 else Z0 + atan
        sigma = 0 if Z >= 0 else 1

        # Check for overflow

        if overflow(X, WIDTH) or overflow(Y, WIDTH) or overflow(Z, ANGLE_WIDTH):
            continue

        fp.write(f"{X0} {Y0} {Z0} {sigma0} {atan} {step} {X} {Y} {Z} {sigma}\n")
