import argparse
import stimulus_generation.cordic
import math

def parse_string_value(value: str):
    if 'x' in value:
        return_value = int(value, 16)
    elif 'b' in value:
        return_value =int(value, 2)
    else:
        return_value = int(value)
    if (return_value > 2**8) or (return_value < 0):
        exit('Las coordenadas tienen que ser de 8 bits!')
    else:
        return return_value

def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)


parser = argparse.ArgumentParser(description='Rota tres coordenadas. Útil para usar con el test de implementación del rotador.')
parser.add_argument('X0', metavar='X0', type=str, help='Coordenada X inicial')
parser.add_argument('Y0', metavar='Y0', type=str, help='Coordenada Y inicial')
parser.add_argument('angle', metavar='alfa0', type=str, help='Angulo a rotar')

args = parser.parse_args()
X0 = parse_string_value(args.X0)
Y0 = parse_string_value(args.Y0)
angle = parse_string_value(args.angle)

# Width, in bits, of coordinates
COORDINATES_WIDTH = 8
# VHDL_COORDINATES_WIDTH - PYTHON_COORDINATES_WIDTH (how many more bits are used in the vhdl testbench)
OFFSET_VHDL_COORDS_WIDTH = 2

# Width, in bits, of the integer part of angles
ANGLE_INTEGER_WIDTH = 6
# Width, in bits, of the fractional part of angles
ANGLE_FRACTIONAL_WIDTH = 16
# Total width, in bits, of angles
ANGLE_WIDTH = ANGLE_INTEGER_WIDTH + ANGLE_FRACTIONAL_WIDTH + 1

cordic_instace = stimulus_generation.cordic.cordic(coords_width=COORDINATES_WIDTH, offset_coords_width=OFFSET_VHDL_COORDS_WIDTH, 
    angle_integer_width=ANGLE_INTEGER_WIDTH, angle_fractional_width=ANGLE_FRACTIONAL_WIDTH)

X, Y = cordic_instace.rotate(X0, Y0, angle*2**ANGLE_FRACTIONAL_WIDTH)
Xr = X0*math.cos(angle*math.pi/180) - Y0*math.sin(angle*math.pi/180)
Yr = X0*math.sin(angle*math.pi/180) + Y0*math.cos(angle*math.pi/180)

print(f"X0: {X0} ({hex(int(bindigits(X0, 8), 2))}, {bindigits(X0, 8)}) Y0: {Y0} ({hex(int(bindigits(Y0, 8), 2))}, {bindigits(Y0, 8)}) Angle: {angle} ({hex(int(bindigits(angle, 8), 2))}, {bindigits(angle, 8)})")
print(f"X: {X} ({hex(int(bindigits(X, 8), 2))}, {bindigits(X, 8)}) Y: {Y} ({hex(int(bindigits(Y, 8), 2))}, {bindigits(Y, 8)})")
print(f"Xr: {Xr:.2f} Yr: {Yr:.2f}")
