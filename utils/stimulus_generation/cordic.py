import random
import math
import pathlib


def floor_round(number):
    return int(math.floor(number))


filepath = pathlib.Path(__file__).parent.parent.parent.absolute() / 'verification' / 'tb_cordic' / 'stimulus.dat'

# Deterministic seed for reproducibility
random.seed(54)

# Number of test cases to generate
NUMBER_OF_TESTS = 100
# Number of stages of the architecture
NUMBER_OF_STAGES = 16


# Width, in bits, of coordinates
COORDINATES_WIDTH = 30
# VHDL_COORDINATES_WIDTH - PYTHON_COORDINATES_WIDTH (how many more bits are used in the vhdl testbench)
OFFSET_VHDL_COORDS_WIDTH = 2

# Width, in bits, of the integer part of angles
ANGLE_INTEGER_WIDTH = 6
# Width, in bits, of the fractional part of angles
ANGLE_FRACTIONAL_WIDTH = 16
ANGLE_WIDTH = ANGLE_INTEGER_WIDTH + ANGLE_FRACTIONAL_WIDTH + 1

# CORDIC scale factor
PURE_CORDIC_SCALE_FACTOR = 0.607252935
ROUNDED_CORDIC_SCALE_FACTOR = int(round(PURE_CORDIC_SCALE_FACTOR*2**(COORDINATES_WIDTH+OFFSET_VHDL_COORDS_WIDTH-1)))*2**-(COORDINATES_WIDTH+OFFSET_VHDL_COORDS_WIDTH-1)

atan_degrees = [45,
26.565051177078,
14.0362434679265,
7.1250163489018,
3.57633437499735,
1.78991060824607,
0.895173710211074,
0.447614170860553,
0.223810500368538,
0.111905677066207,
0.055952891893804,
0.027976452617004,
0.013988227142265,
0.006994113675353,
0.003497056850704,
0.00174852842698]

atan_fixed_point = [int(round(angle_degrees*2**ANGLE_FRACTIONAL_WIDTH)) for angle_degrees in atan_degrees]

with open(filepath, 'w') as fp:

    fp.write("# X0 Y0 angle X Y\n")

    for _ in range(NUMBER_OF_TESTS):

        X0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
        Y0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
        angle = random.randint(-2**(ANGLE_WIDTH-1), 2**(ANGLE_WIDTH-1)-1)

        X_old = X0
        Y_old = Y0
        Z_old = angle
        sigma_old = 0 if angle >= 0 else 1


        for step in range(NUMBER_OF_STAGES):

            X = X_old - floor_round(Y_old/(2**step)) if not sigma_old else X_old + floor_round(Y_old/(2**step))
            Y = Y_old + floor_round(X_old/(2**step)) if not sigma_old else Y_old - floor_round(X_old/(2**step))
            Z = Z_old - atan_fixed_point[step] if not sigma_old else Z_old + atan_fixed_point[step]
            sigma = 0 if Z >= 0 else 1

            X_old = X
            Y_old = Y
            Z_old = Z
            sigma_old = sigma

        X = floor_round(X*ROUNDED_CORDIC_SCALE_FACTOR)
        Y = floor_round(Y*ROUNDED_CORDIC_SCALE_FACTOR)

        fp.write(f"{X0} {Y0} {angle} {X} {Y}\n")
