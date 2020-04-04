import random
import math
import pathlib
import stimulus_generation.cordic
import matplotlib.pyplot as plt


def main():

    # Deterministic seed for reproducibility
    random.seed(54)

    # Number of test cases to generate
    NUMBER_OF_TESTS = 10000

    # Width, in bits, of coordinates
    COORDINATES_WIDTH = 32
    # VHDL_COORDINATES_WIDTH - PYTHON_COORDINATES_WIDTH (how many more bits are used in the vhdl testbench)
    OFFSET_VHDL_COORDS_WIDTH = 2

    cordic_instace = stimulus_generation.cordic.cordic(coords_width=COORDINATES_WIDTH, offset_coords_width=OFFSET_VHDL_COORDS_WIDTH)
    
    overflow_errors = 0

    X_errors = []
    Y_errors = []

    for _ in range(NUMBER_OF_TESTS):

        # las coordenadas "reales" a rotar
        X0r = random.uniform(-1, 1)
        Y0r = random.uniform(-1, 1)
        # los valores que mandamos al cordic
        # corresponden a una notación de punto fijo con COORDINATES_WIDTH-1 bits
        X0c = int(X0r*2**(COORDINATES_WIDTH-1))
        Y0c = int(Y0r*2**(COORDINATES_WIDTH-1))
        # el ángulo es un número entero, el módulo se encarga de pasarlo a una representación de punto fijo
        angle = random.randint(-90, 90)
        try:
            Xc, Yc = cordic_instace.rotate(X0c, Y0c, angle)
        except OverflowError:
            overflow_errors += 1
            continue

        Xactual = Xc*2**-(COORDINATES_WIDTH-1)
        Yactual = Yc*2**-(COORDINATES_WIDTH-1)

        Xtarget = X0r*math.cos(angle*math.pi/180) - Y0r*math.sin(angle*math.pi/180)
        Ytarget = X0r*math.sin(angle*math.pi/180) + Y0r*math.cos(angle*math.pi/180)

        X_errors.append(abs(Xtarget-Xactual)/abs(Xtarget)*100)
        Y_errors.append(abs(Ytarget-Yactual)/abs(Ytarget)*100)
    
    print(f"Se dieron {overflow_errors} errores de overflow")

    n, bins, patches = plt.hist([X_errors, Y_errors], range=(0,100), bins=100, label=['X', 'Y'])
    plt.title("Errores del método CORDIC")
    plt.xlabel('Porcentaje de error')
    plt.ylabel('Ocurrencias')
    plt.legend()
    plt.show()

if __name__ == "__main__":
    main()
