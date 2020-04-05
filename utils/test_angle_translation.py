import math
import argparse


def rotate(angle: int, limit: bool = False) -> (float, float):
    if limit and (angle > 90 or angle < -90):
        exit(f"¡El ángulo tiene que estar entre -90 y 90! (es {angle})")
    X = math.cos(angle*math.pi/180) - math.sin(angle*math.pi/180)
    Y = math.sin(angle*math.pi/180) + math.cos(angle*math.pi/180)
    return X, Y

def rotate_with_translation(angle: int) -> (float, float):
    if -90 < angle < 90:
        return rotate(angle)
    else:
        angle += 90 if angle < 0 else -90
        X, Y = rotate(angle, True)
        return -Y, X
        
def main():

    parser = argparse.ArgumentParser(description='Rota normalmente y usando ángulos solo entre 0 y 90.')
    parser.add_argument('angle', metavar='Ángulo', type=int, help='Ángulo a rotar, en grados')

    args = parser.parse_args()
    angle = args.angle

    Xcorrect, Ycorrect = rotate(angle)
    Xtranslated, Ytranslated = rotate_with_translation(angle)

    print(f"Xc: {Xcorrect}, Yc: {Ycorrect}")
    print(f"Xt: {Xtranslated}, Yt: {Ytranslated}")

if __name__ == "__main__":
    main()