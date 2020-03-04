import random
import math
import pathlib
import cordic


def main():

    filepath = pathlib.Path(__file__).absolute().parent.parent.parent / 'rotator' / 'verification' / 'tb_rz' / 'stimulus.dat'

    # Deterministic seed for reproducibility
    random.seed(54)

    # Number of test cases to generate
    NUMBER_OF_TESTS = 1000

    # Width, in bits, of coordinates
    COORDINATES_WIDTH = 30
    # VHDL_COORDINATES_WIDTH - PYTHON_COORDINATES_WIDTH (how many more bits are used in the vhdl testbench)
    OFFSET_VHDL_COORDS_WIDTH = 2

    # Width, in bits, of the integer part of angles
    ANGLE_INTEGER_WIDTH = 6
    # Width, in bits, of the fractional part of angles
    ANGLE_FRACTIONAL_WIDTH = 16
    # Total width, in bits, of angles
    ANGLE_WIDTH = ANGLE_INTEGER_WIDTH + ANGLE_FRACTIONAL_WIDTH + 1

    cordic_instace = cordic.cordic(coords_width=COORDINATES_WIDTH, offset_coords_width=OFFSET_VHDL_COORDS_WIDTH, 
        angle_integer_width=ANGLE_INTEGER_WIDTH, angle_fractional_width=ANGLE_FRACTIONAL_WIDTH)

    with open(filepath, 'w') as fp:

        fp.write("# X0 Y0 Z0 angle X Y Z\n")

        for _ in range(NUMBER_OF_TESTS):

            X0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
            Y0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
            Z0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
            angle = random.randint(-2**(ANGLE_WIDTH-1), 2**(ANGLE_WIDTH-1)-1)

            X, Y = cordic_instace.rotate(X0, Y0, angle)
            Z = Z0

            fp.write(f"{X0} {Y0} {Z0} {angle} {X} {Y} {Z}\n")

if __name__ == "__main__":
    main()