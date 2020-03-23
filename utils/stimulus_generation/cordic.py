import random
import math
import pathlib

class cordic():
    
    def __init__(self, stages=16, coords_width=30, offset_coords_width=2, angle_integer_width=6, angle_fractional_width=16):
        self.stages = stages
        self.coords_width = coords_width
        self.offset_coords_width = offset_coords_width
        self.angle_integer_width = angle_integer_width
        self.angle_fractional_width = angle_fractional_width
        self.angle_width = angle_integer_width + angle_fractional_width + 1
        self.pure_cordic_scale_factor = 0.607252935
        self.rounded_cordic_scale_factor = int(round(self.pure_cordic_scale_factor*2**(coords_width+offset_coords_width-1)))*2**-(coords_width+offset_coords_width-1)
        self.atan_degrees = [45,
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
        self.atan_fixed_point = [int(round(angle_degrees*2**angle_fractional_width)) for angle_degrees in self.atan_degrees]

    def floor_round(self, number):
        return int(math.floor(number))

    def rotate(self, X0, Y0, angle):
        
        X_old = X0
        Y_old = Y0
        # Z es el valor de punto fijo del ángulo
        Z_old = angle*2**self.angle_fractional_width

        for step in range(self.stages):

            X = X_old - self.floor_round(Y_old/(2**step)) if Z_old >= 0 else X_old + self.floor_round(Y_old/(2**step))
            Y = Y_old + self.floor_round(X_old/(2**step)) if Z_old >= 0 else Y_old - self.floor_round(X_old/(2**step))
            Z = Z_old - self.atan_fixed_point[step] if Z_old >= 0 else Z_old + self.atan_fixed_point[step]
            # if self.overflow(X, self.coords_width) or self.overflow(Y, self.coords_width) or self.overflow(Z, self.coords_width):
            if self.overflow(X, self.coords_width + self.offset_coords_width) or self.overflow(Y, self.coords_width + self.offset_coords_width) or self.overflow(Z, self.angle_width):
                raise OverflowError

            X_old = X
            Y_old = Y
            Z_old = Z

        X = self.floor_round(X*self.rounded_cordic_scale_factor)
        Y = self.floor_round(Y*self.rounded_cordic_scale_factor)

        return X, Y

    def overflow(self, number, width):
        if -2**(width-1) <= number <= 2**(width-1)-1:
            return False
        else:
            return True

def main():

    filepath = pathlib.Path(__file__).absolute().parent.parent.parent / 'rotator' / 'verification' / 'tb_cordic' / 'stimulus.dat'

    # Deterministic seed for reproducibility
    random.seed(54)

    # Number of test cases to generate
    NUMBER_OF_TESTS = 1000

    # Width, in bits, of coordinates
    COORDINATES_WIDTH = 30
    # VHDL_COORDINATES_WIDTH - PYTHON_COORDINATES_WIDTH (how many more bits are used in the vhdl testbench)
    OFFSET_VHDL_COORDS_WIDTH = 2

    # Width, in bits, of the integer part of angles
    # queda en 8 para ir de -90 a 90 grados
    ANGLE_INTEGER_WIDTH = 8
    # Width, in bits, of the fractional part of angles
    # esto tiene importancia nada más para la precisión de la atan, el ángulo de entrada no tiene parte fraccional
    ANGLE_FRACTIONAL_WIDTH = 16
    # Total width, in bits, of angles
    ANGLE_WIDTH = ANGLE_INTEGER_WIDTH + ANGLE_FRACTIONAL_WIDTH + 1

    cordic_instace = cordic(coords_width=COORDINATES_WIDTH, offset_coords_width=OFFSET_VHDL_COORDS_WIDTH, 
        angle_integer_width=ANGLE_INTEGER_WIDTH, angle_fractional_width=ANGLE_FRACTIONAL_WIDTH)

    with open(filepath, 'w') as fp:

        fp.write("# X0 Y0 angle X Y\n")

        for _ in range(NUMBER_OF_TESTS):

            X0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
            Y0 = random.randint(-2**(COORDINATES_WIDTH-1), 2**(COORDINATES_WIDTH-1)-1)
            # el ángulo es número entero, el módulo se encarga de pasarlo a una representación de punto fijo
            angle = random.randint(-90, 90)

            try:
                X, Y = cordic_instace.rotate(X0, Y0, angle)

                fp.write(f"{X0} {Y0} {angle} {X} {Y}\n")
            except OverflowError:
                print('overflow ñero')

if __name__ == "__main__":
    main()
