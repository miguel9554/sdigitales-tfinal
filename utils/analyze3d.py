import argparse
import stimulus_generation.cordic
import math
import numpy as np

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


def parse_string_value(value: str):
    fvalue = float(value)
    if -1 < fvalue < 1:
        return fvalue
    else:
        exit('Las coordenadas tienen que estar entre -1 y 1')

def parse_angle(value: str):
    if -90 < int(value) < 90:
        return int(value)
    else:            
        exit('El ángulo tiene que estar entre -90 y 90')

def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

def twos_complement(val_str):
    val = int(val_str, 2)
    b = val.to_bytes(1, byteorder='big', signed=False)
    return int.from_bytes(b, byteorder='big', signed=True)


parser = argparse.ArgumentParser(description='Rota tres coordenadas, útil para verificar validez de datos y conversion entre cantidad de bits.'
parser.add_argument('X0', metavar='X0', type=str, help='Coordenada X inicial')
parser.add_argument('Y0', metavar='Y0', type=str, help='Coordenada Y inicial')
parser.add_argument('Z0', metavar='Z0', type=str, help='Coordenada Z inicial')
parser.add_argument('angle', metavar='alfa0', type=str, help='Angulo a rotar, en grados')

args = parser.parse_args()

# Width, in bits, of coordinates
COORDINATES_WIDTH = 32
# VHDL_COORDINATES_WIDTH - PYTHON_COORDINATES_WIDTH (how many more bits are used in the vhdl testbench)
OFFSET_VHDL_COORDS_WIDTH = 0
STAGES = 8
DISPLAY_WIDTH = 8

# Width, in bits, of the integer part of angles
ANGLE_INTEGER_WIDTH = 8
# Width, in bits, of the fractional part of angles
ANGLE_FRACTIONAL_WIDTH = 16
# Total width, in bits, of angles
ANGLE_WIDTH = ANGLE_INTEGER_WIDTH + ANGLE_FRACTIONAL_WIDTH + 1

cordic_instace = stimulus_generation.cordic.cordic(stages=STAGES, coords_width=COORDINATES_WIDTH, offset_coords_width=OFFSET_VHDL_COORDS_WIDTH, 
    angle_integer_width=ANGLE_INTEGER_WIDTH, angle_fractional_width=ANGLE_FRACTIONAL_WIDTH)

# los valores que se encontrarían en el archivo de coordenadas
X0r = parse_string_value(args.X0)
Y0r = parse_string_value(args.Y0)
Z0r = parse_string_value(args.Z0)
angle = parse_angle(args.angle)

# en este caso, todos los ángulos son iguales
angle_X = angle
angle_Y = angle
angle_Z = angle

# los valores que le mando al cordic
X0c = int(X0r*2**(COORDINATES_WIDTH-1))
Y0c = int(Y0r*2**(COORDINATES_WIDTH-1))
Z0c = int(Z0r*2**(COORDINATES_WIDTH-1))

# los resultados que salen del cordic
Xc, Yc, Zc = cordic_instace.rotate_3d(X0c, Y0c, Z0c, angle_X, angle_Y, angle_Z)
# el resultado escalado a los valores reales
Xesc = Xc*2**-(COORDINATES_WIDTH-1)
Yesc = Yc*2**-(COORDINATES_WIDTH-1)
Zesc = Zc*2**-(COORDINATES_WIDTH-1)
# Si uso 4 bits?
Xc4 = int(Xesc*2**(DISPLAY_WIDTH-1))
Yc4 = int(Yesc*2**(DISPLAY_WIDTH-1))
Zc4 = int(Zesc*2**(DISPLAY_WIDTH-1))
# Los valores "reales" que obtendría con 4 bits
Xesc4 = Xc4*2**-(DISPLAY_WIDTH-1)
Yesc4 = Yc4*2**-(DISPLAY_WIDTH-1)
Zesc4 = Zc4*2**-(DISPLAY_WIDTH-1)

# el valor que debería dar
# rotamos por el eje x
Xr, Yr, Zr = matrix_rotation(X0r, Y0r, Z0r, angle_X, angle_Y, angle_Z)

# imprimimos los argumentos
print(f"X0r: {X0r} (X0c: {X0c}, {hex(int(bindigits(X0c, COORDINATES_WIDTH), 2))}, {bindigits(X0c, COORDINATES_WIDTH)}), \
Y0r: {Y0r} (Y0c: {Y0c}, {hex(int(bindigits(Y0c, COORDINATES_WIDTH), 2))}, {bindigits(Y0c, COORDINATES_WIDTH)}), \
Z0r: {Z0r} (Z0c: {Z0c}, {hex(int(bindigits(Z0c, COORDINATES_WIDTH), 2))}, {bindigits(Z0c, COORDINATES_WIDTH)}), \
Angle: {angle} ({hex(int(bindigits(angle, ANGLE_INTEGER_WIDTH), 2))}, {bindigits(angle, ANGLE_INTEGER_WIDTH)})")
# imprimimos los resultados
print(f"Xesc: {Xesc} (Xc: {Xc} {hex(int(bindigits(Xc, COORDINATES_WIDTH), 2))}, {bindigits(Xc, COORDINATES_WIDTH)}), \
Yesc: {Yesc} (Yc: {Yc} {hex(int(bindigits(Yc, COORDINATES_WIDTH), 2))}, {bindigits(Yc, COORDINATES_WIDTH)}), \
Zesc: {Zesc} (Zc: {Zc} {hex(int(bindigits(Zc, COORDINATES_WIDTH), 2))}, {bindigits(Zc, COORDINATES_WIDTH)})")
# print(f"Xesc4: {Xesc4} (Xc4: {Xc4} {hex(int(bindigits(Xc4, DISPLAY_WIDTH), 2))}, {bindigits(Xc4, DISPLAY_WIDTH)}), Yesc4: {Yesc4} (Yc4: {Yc4} {hex(int(bindigits(Yc4, DISPLAY_WIDTH), 2))}, {bindigits(Yc4, DISPLAY_WIDTH)})")
# los resultados "reales"
print(f"Xr: {Xr:.2f}, Yr: {Yr:.2f}, Zr: {Zr:.2f}")
