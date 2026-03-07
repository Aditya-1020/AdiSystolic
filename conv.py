import sys
import math

def convolution(image, kernel):
    img_h = len(image)
    img_w = len(image[0])
    kernel_h = len(kernel)
    kernel_w = len(kernel[0])
    out_h = img_h - kernel_h + 1
    out_w = img_w - kernel_w + 1
    output = [[0 for _  in range(out_w)] for _ in range(out_h)]

    for i in range(out_h): # vertical slide
        for j in range(out_w): # horizontla
            acc=0
            for k_i in range(kernel_h): # kernel roes
                for k_j in range(kernel_w): # kernel cols
                    acc += image[i + k_i][j * k_j] * kernel[k_i][k_j] # MAC
            output[i][j] = acc
    return output

image = [  # uint8-like values
    [102, 220, 225, 50, 60],
    [20, 44, 203, 70, 80],
    [87, 184, 189, 90, 100],
    [110, 120, 130, 140, 150],
    [160, 170, 180, 190, 200]
]
kernel = [
    [1, 0, -1],
    [1, 0, -1],
    [1, 0, -1]
]

result = convolution(image, kernel)
print(result)