import random
import math
import matplotlib.pyplot as plt
import numpy as np


def round(number):
	return int(math.floor(number))


def overflow(number, width):
	if -2**(width-1) <= number <= 2**(width-1)-1:
		return False
	else:
		return True


filepath = '../verification/tb_cordic/stimulus.dat'
# Number of test cases to generate
NUMBER_OF_TESTS = 1000
# Deterministic seed for reproducibility
random.seed(54)

# Width, in bits, of general values
WIDTH = 10
# Width, in bits, of angles
ANGLE_WIDTH = 22
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

X_erorr_list = []
Y_erorr_list = []

with open(filepath, 'w') as fp:

	fp.write(" {X0:^5} {Y0:^5} {angle:^5} {X:^14} {Y:^14} {X_correct:^14} {Y_correct:^14} {X_error:^14} {Y_error:^14}\n".format(
		X0='X0', Y0='Y0', angle='angle', X='X', Y='Y', X_correct='X_correct', Y_correct='Y_correct', X_error='X_error', Y_error='Y_error'))

	for _ in range(NUMBER_OF_TESTS):

		X0 = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
		Y0 = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
		angle = random.randint(-90, 90)

		X_old = X0
		Y_old = Y0
		Z_old = angle
		sigma_old = 1


		for step in range(NUMBER_OF_STAGES):

			X = X_old - round(Y_old/(2**step)) if sigma_old else X_old + round(Y_old/(2**step))
			Y = Y_old + round(X_old/(2**step)) if sigma_old else Y_old - round(X_old/(2**step))
			Z = Z_old - atan[step] if sigma_old else Z_old + atan[step]
			sigma = 1 if Z >= 0 else 0

			X_old = X
			Y_old = Y
			Z_old = Z
			sigma_old = sigma

		X = X*0.6072
		Y = Y*0.6072
		
		X_correct = X0*math.cos(angle*math.pi/180)-Y0*math.sin(angle*math.pi/180)
		Y_correct = X0*math.sin(angle*math.pi/180)+Y0*math.cos(angle*math.pi/180)
		
		X_error = abs((X_correct-X)/X_correct)*100
		Y_error = abs((Y_correct-Y)/Y_correct)*100

		X_erorr_list.append(X_error)
		Y_erorr_list.append(Y_error)

		fp.write(f"{X0:>5} {Y0:>5} {angle:>5} {X:14.6f} {Y:14.6f} {X_correct:14.6f} {Y_correct:14.6f} {X_error:8.3f}% {Y_error:8.3f}%\n")

# An "interface" to matplotlib.axes.Axes.hist() method
n, bins, patches = plt.hist(x=X_erorr_list, bins=1000, alpha=1)
plt.grid()
plt.xlabel('Error')
plt.ylabel('Frecuencia')
plt.title('Errores para componente X')
maxfreq = n.max()
# Set a clean upper y-axis limit.
plt.ylim()
plt.show()