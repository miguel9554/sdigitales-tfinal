import serial

COORDS_WIDTH = 31

'''
with open('coordenadas.txt') as fp:
    
    l = fp.readline()
    print(l)
    x = int(float(l.split('\t')[0])*2**COORDS_WIDTH)
    y = int(float(l.split('\t')[1])*2**COORDS_WIDTH)
    z = int(float(l.split('\t')[2])*2**COORDS_WIDTH)

    print(f"{x} {y} {z}")
'''

with serial.Serial('/dev/ttyUSB0', 19200, timeout=1) as ser:
    n = 214783648
    s = True if n < 0 else False
    ser.write((n).to_bytes(4, 'big', signed=s))
    n = 2137443648
    s = True if n < 0 else False
    ser.write((n).to_bytes(4, 'big', signed=s))
    n = -2145603648
    s = True if n < 0 else False
    ser.write((n).to_bytes(4, 'big', signed=s))