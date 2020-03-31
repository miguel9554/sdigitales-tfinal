import pathlib
import numpy as np
import matplotlib.pyplot as plt


filepath = pathlib.Path(__file__).absolute().parent / 'coordenadas.txt' 

X_V = []
Y_V = []
Z_V = []

with open(filepath) as fp:
    for line in fp:
        x = float(line.split('\t')[0])
        y = float(line.split('\t')[1])
        z = float(line.split('\t')[2])

        X_V.append(x)
        Y_V.append(y)
        Z_V.append(z)


n, bins, patches = plt.hist([X_V, Y_V, Z_V], bins=1000, label=['X', 'Y', 'Z'])
plt.title("Histogram with 'auto' bins")
plt.legend()
plt.show()

