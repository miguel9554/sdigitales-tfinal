import random
import math
import pathlib
import stimulus_generation.cordic
import matplotlib.pyplot as plt
import numpy as np
import pathlib


def matrix_rotation(X0: float, Y0: float, Z0: float, angle_X: int, angle_Y: int, angle_Z: int):
    
    V0 = np.array([X0, Y0, Z0])

    Rx = np.array([ [1, 0, 0], \
                    [0, math.cos(angle_X*math.pi/180), -math.sin(angle_X*math.pi/180)], \
                    [0, math.sin(angle_X*math.pi/180), math.cos(angle_X*math.pi/180)]])

    Ry = np.array([ [math.cos(angle_Y*math.pi/180), 0, math.sin(angle_Y*math.pi/180)], \
                    [0, 1, 0], \
                    [-math.sin(angle_Y*math.pi/180), 0, math.cos(angle_Y*math.pi/180)]])

    Rz = np.array([ [math.cos(angle_Z*math.pi/180), -math.sin(angle_Z*math.pi/180), 0], \
                    [math.sin(angle_Z*math.pi/180), math.cos(angle_Z*math.pi/180), 0], \
                    [0, 0, 1]])

    Mr = Rz.dot(Ry).dot(Rx)
    Vr = Mr.dot(V0)

    return Vr[0], Vr[1], Vr[2]

def main():

    filepath = pathlib.Path(__file__).absolute().parent / 'coordenadas.txt'

    # Width, in bits, of coordinates
    COORDINATES_WIDTH = 32
    # VHDL_COORDINATES_WIDTH - PYTHON_COORDINATES_WIDTH (how many more bits are used in the vhdl testbench)
    OFFSET_VHDL_COORDS_WIDTH = 0

    # Width, in bits, of the integer part of angles
    # queda en 8 para ir de -90 a 90 grados
    ANGLE_INTEGER_WIDTH = 8
    # Width, in bits, of the fractional part of angles
    # esto tiene importancia nada más para la precisión de la atan, el ángulo de entrada no tiene parte fraccional
    ANGLE_FRACTIONAL_WIDTH = 16
    STAGES = 8

    cordic_instace = stimulus_generation.cordic.cordic(stages=STAGES, coords_width=COORDINATES_WIDTH, offset_coords_width=OFFSET_VHDL_COORDS_WIDTH, 
        angle_integer_width=ANGLE_INTEGER_WIDTH, angle_fractional_width=ANGLE_FRACTIONAL_WIDTH)
    
    overflow_errors = 0

    X_errors = []
    Y_errors = []
    Z_errors = []

    with open(filepath) as fp:
        for line in fp:
            # las coordenadas "reales" a rotar
            X0r = float(line.split('\t')[0])
            Y0r = float(line.split('\t')[1])
            Z0r = float(line.split('\t')[2])
            # los valores que mandamos al cordic
            # corresponden a una notación de punto fijo con COORDINATES_WIDTH-1 bits
            X0c = int(X0r*2**(COORDINATES_WIDTH-1))
            Y0c = int(Y0r*2**(COORDINATES_WIDTH-1))
            Z0c = int(Z0r*2**(COORDINATES_WIDTH-1))
            # el ángulo es un número entero, el módulo se encarga de pasarlo a una representación de punto fijo
            angle_X = random.randint(-90, 90)
            angle_Y = random.randint(-90, 90)
            angle_Z = random.randint(-90, 90)
            try:
                Xc, Yc, Zc = cordic_instace.rotate_3d(X0c, Y0c, Z0c, angle_X, angle_Y, angle_Z)
            except OverflowError:
                overflow_errors += 1
                continue

            Xactual = Xc*2**-(COORDINATES_WIDTH-1)
            Yactual = Yc*2**-(COORDINATES_WIDTH-1)
            Zactual = Zc*2**-(COORDINATES_WIDTH-1)

            Xtarget, Ytarget, Ztarget = matrix_rotation(X0r, Y0r, Z0r, angle_X, angle_Y, angle_Z)

            X_errors.append(abs(Xtarget-Xactual)/abs(Xtarget)*100)
            Y_errors.append(abs(Ytarget-Yactual)/abs(Ytarget)*100)
            Z_errors.append(abs(Ztarget-Zactual)/abs(Ztarget)*100)

    print(f"Se dieron {overflow_errors} errores de overflow")
    
    n, bins, patches = plt.hist([X_errors, Y_errors, Z_errors], range=(0,100), bins=100, label=['X', 'Y', 'Z'])
    plt.title("Errores del método CORDIC")
    plt.xlabel('Porcentaje de error')
    plt.ylabel('Ocurrencias')
    plt.legend()
    plt.show()


if __name__ == "__main__":
    main()
