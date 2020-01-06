import random


def round(number):
	if number > 0:
		return int(number)
	elif number < 0:
		return int(number - 0.5)
	else:
		return 0


def overflow(number, width):
	if -2**(width-1) <= number <= 2**(width-1)-1:
		return False
	else:
		return True


filepath = '../verification/tb_cordic_stage/stimulus.dat'
# Number of test cases to generate
NUMBER_OF_TESTS = 10000
# Deterministic seed for reproducibility
random.seed(54)

# Width, in bits, of general values
WIDTH = 10
# Width, in bits, of angles
ANGLE_WIDTH = 22

with open(filepath, 'w') as fp:
	fp.write(f"# X0 Y0 Z0 sigma0 atan X Y Z sigma\n")
	for _ in range(NUMBER_OF_TESTS):
		
		X0 = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
		Y0 = random.randint(-2**(WIDTH-1), 2**(WIDTH-1)-1)
		Z0 = random.randint(-2**(ANGLE_WIDTH-1), 2**(ANGLE_WIDTH-1)-1)
		atan = random.randint(1, 2**(ANGLE_WIDTH)-1)
		sigma0 = random.randint(0, 1)
		
		X = X0 - round(Y0/2) if sigma0 else X0 + round(Y0/2)
		Y = Y0 + round(X0/2) if sigma0 else Y0 - round(X0/2)
		Z = Z0 - atan if sigma0 else Z0 + atan
		sigma = 1 if Z >= 0 else 0

		# Check for overflow

		if overflow(X, WIDTH) or overflow(Y, WIDTH) or overflow(Z, ANGLE_WIDTH + 1):
			continue

		fp.write(f"{X0} {Y0} {Z0} {sigma0} {atan} {X} {Y} {Z} {sigma}\n")