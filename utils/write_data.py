import serial


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