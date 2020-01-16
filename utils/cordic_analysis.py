import random
import math
from stimulus_generation.cordic import cordic


# Random input generation
X0 = round(random.random(), 10)
Y0 = round(random.random(), 10)
angle = random.randint(-40,40) + round(random.random(), 10) 

# "Correct" calculation, using trigonometric functions
X_correct = (X0*math.cos(angle*math.pi/180)-Y0*math.sin(angle*math.pi/180))
Y_correct = (X0*math.sin(angle*math.pi/180)+Y0*math.cos(angle*math.pi/180))

# CORDIC calculation
COORDINATES_WIDTH = 30
ANGLE_FRACTIONAL_WIDTH = 16

X0_fixed_point = int(X0*2**COORDINATES_WIDTH)
Y0_fixed_point = int(Y0*2**COORDINATES_WIDTH)
angle_fixed_point = int(angle*2**ANGLE_FRACTIONAL_WIDTH)

cordic_instace = cordic(coords_width=COORDINATES_WIDTH, angle_fractional_width=ANGLE_FRACTIONAL_WIDTH)

X_CORDIC, Y_CORDIC = cordic_instace.rotate(X0_fixed_point, Y0_fixed_point, angle_fixed_point)

X_CORDIC *=2**-COORDINATES_WIDTH
Y_CORDIC *=2**-COORDINATES_WIDTH

print(f"X0: {X0}")
print(f"Y0: {Y0}")
print(f"Ángulo: {angle}\n")

print(f"X real: {X_correct}")
print(f"Y real: {Y_correct}\n")

print(f"X CORDIC: {X_CORDIC}")
print(f"Y CORDIC: {Y_CORDIC}\n")

print(f"X error: {abs(X_correct - X_CORDIC)/abs(X_correct)*100:.4f}%")
print(f"Y error: {abs(Y_correct - Y_CORDIC)/abs(Y_correct)*100:.4f}%")
