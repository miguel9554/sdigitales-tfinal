import serial
import pathlib


def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)


COORDS_WIDTH = 32
LINES_TO_SEND = 11946

filepath = pathlib.Path(__file__).absolute().parent / 'coordenadas.txt' 

with open(filepath) as fp, serial.Serial('/dev/ttyUSB0', 115200, timeout=1) as ser:
    
    for line_number, line in enumerate(fp):
        
        if line_number < LINES_TO_SEND:

            x = int(float(line.split('\t')[0])*2**(COORDS_WIDTH-1))
            x_signed = True if x < 0 else False
            y = int(float(line.split('\t')[1])*2**(COORDS_WIDTH-1))
            y_signed = True if y < 0 else False
            z = -1*int(float(line.split('\t')[2])*2**(COORDS_WIDTH-1))
            z_signed = True if z < 0 else False

            ser.write((x).to_bytes(4, 'big', signed=x_signed))
            ser.write((y).to_bytes(4, 'big', signed=y_signed))
            ser.write((z).to_bytes(4, 'big', signed=z_signed))

            print(f"line {line_number} (mem_address: {line_number*6}): {hex(int(bindigits(x, 32), 2))} {hex(int(bindigits(y, 32), 2))} {hex(int(bindigits(z, 32), 2))}")
