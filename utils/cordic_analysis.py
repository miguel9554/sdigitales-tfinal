import random
import math
from stimulus_generation.cordic import cordic
import matplotlib.pyplot as plt
import numpy as np


def histogram(d):
    # An "interface" to matplotlib.axes.Axes.hist() method
    n, bins, patches = plt.hist(x=d, bins='auto', color='#0504aa',
                                alpha=0.7, rwidth=0.85)
    plt.grid(axis='y', alpha=0.75)
    plt.xlabel('Value')
    plt.ylabel('Frequency')
    plt.title('My Very Own Histogram')
    maxfreq = n.max()
    plt.ylim(ymax=np.ceil(maxfreq / 10) * 10 if maxfreq % 10 else maxfreq + 10)
    plt.xlim(xmax=0.5, xmin=0)

    return plt

NUMBER_OF_TESTS = 500
x_errors = []
y_errors = []

for _ in range(NUMBER_OF_TESTS):

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

    x_errors.append(abs(X_correct - X_CORDIC)/abs(X_correct)*100)
    y_errors.append(abs(Y_correct - Y_CORDIC)/abs(Y_correct)*100)

hist_plot = histogram(x_errors)
hist_plot.show()

hist_plot = histogram(y_errors)
hist_plot.show()