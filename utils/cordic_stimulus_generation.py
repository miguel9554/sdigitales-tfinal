import random
import math


def round(number):
    return int(math.floor(number))


filepath = '../verification/tb_cordic/stimulus.dat'
# Number of test cases to generate
NUMBER_OF_TESTS = 10
# Deterministic seed for reproducibility
random.seed(54)

# Width, in bits, of coordinates
COORDINATES_WIDTH = 10
# Width, in bits, of the integer part of angles
ANGLE_INTEGER_WIDTH = 6
# Width, in bits, of the fractional part of angles
ANGLE_FRACTIONAL_WIDTH = 16
# Width, in bits, of number of shifts
SHIFT_WIDTH = 4
# Number of stages of the architecture
NUMBER_OF_STAGES = 16

atan = [45,
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

with open(filepath, 'w') as fp:

    fp.write("# X0 Y0 angle X Y\n")

    for _ in range(NUMBER_OF_TESTS):

        X0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
        Y0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
        angle = random.randint(-2**(ANGLE_INTEGER_WIDTH-1), 2**(ANGLE_INTEGER_WIDTH-1)-1)

        X_old = X0
        Y_old = Y0
        Z_old = angle
        sigma_old = 0 if angle >= 0 else 1


        for step in range(NUMBER_OF_STAGES):

            X = X_old - round(Y_old/(2**step)) if not sigma_old else X_old + round(Y_old/(2**step))
            Y = Y_old + round(X_old/(2**step)) if not sigma_old else Y_old - round(X_old/(2**step))
            Z = Z_old - atan[step] if not sigma_old else Z_old + atan[step]
            sigma = 0 if Z >= 0 else 1

            X_old = X
            Y_old = Y
            Z_old = Z
            sigma_old = sigma

        # X = int(X*0.607252935)
        # Y = int(Y*0.607252935)

        X_correct = (X0*math.cos(angle*math.pi/180)-Y0*math.sin(angle*math.pi/180))
        Y_correct = (X0*math.sin(angle*math.pi/180)+Y0*math.cos(angle*math.pi/180))

        fp.write(f"{X0} {Y0} {angle*2**ANGLE_FRACTIONAL_WIDTH} {X} {Y} {X_correct} {Y_correct}\n")
        # fp.write(f"{X0} {Y0} {angle*2**ANGLE_FRACTIONAL_WIDTH} {X} {Y}\n")
