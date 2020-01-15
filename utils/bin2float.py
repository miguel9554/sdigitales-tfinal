# Python3 program to demonstrate above steps 
# of binary fractional to decimal conversion
# from https://www.geeksforgeeks.org/convert-binary-fraction-decimal/

# Function to convert binary fractional 
# to decimal 
def binaryToDecimal(binary, decimal_places=None): 
    
    # Fetch the radix point 
    point = binary.find('.') 

    # Update point if not found 
    if (point == -1) : 
        point = len(binary)-1

    integer_part = int(binary[:point], 2)
    decimal_part = 0
    
    for i in range(point+1, len(binary)): 
        decimal_part += int(binary[i])*2**-(i-point)
    
    return integer_part + decimal_part 

# Driver code : 
if __name__ == "__main__" :
    
    # Take the user input for 
    # the binary number 
    n = input("Enter your binary number : \n") 

    print(binaryToDecimal(n))

# This code is contributed 
# by aishwarya.27
