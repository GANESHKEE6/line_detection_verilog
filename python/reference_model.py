import cv2
import numpy as np
import os
import sys

IMG_WIDTH = 320
IMG_HEIGHT = 240
THRESHOLD_VALUE = 100
Y_START = 96
Y_END = 240
BOUND_L = 106
BOUND_R = 213

def create_test_images(test_dir, input_img_path):
    os.makedirs(test_dir, exist_ok=True)
    
    # Test 1: LEFT line
    img1 = np.ones((360, 360, 3), dtype=np.uint8) * 255
    cv2.line(img1, (30, 270), (90, 270), (0, 0, 0), 10)
    cv2.imwrite(os.path.join(test_dir, 'test1.jpg'), img1)
    
    # Test 2: CENTER line
    img2 = np.ones((360, 360, 3), dtype=np.uint8) * 255
    cv2.line(img2, (130, 270), (190, 270), (0, 0, 0), 10)
    cv2.imwrite(os.path.join(test_dir, 'test2.jpg'), img2)
    
    # Test 3: RIGHT line
    img3 = np.ones((360, 360, 3), dtype=np.uint8) * 255
    cv2.line(img3, (230, 270), (290, 270), (0, 0, 0), 10)
    cv2.imwrite(os.path.join(test_dir, 'test3.jpg'), img3)
    
    # Test 4: NO LINE (completely white)
    img4 = np.ones((360, 360, 3), dtype=np.uint8) * 255
    cv2.imwrite(os.path.join(test_dir, 'test4.jpg'), img4)
    
    # Test 5: Original input image
    if os.path.exists(input_img_path):
        orig = cv2.imread(input_img_path)
        orig_resized = cv2.resize(orig, (360, 360))
        cv2.imwrite(os.path.join(test_dir, 'test5.jpg'), orig_resized)
    else:
        cv2.imwrite(os.path.join(test_dir, 'test5.jpg'), img2)

def process_image(img_path):
    img = cv2.imread(img_path)
    if img is None:
        print(f"Error loading {img_path}")
        sys.exit(1)
        
    img_resized = cv2.resize(img, (IMG_WIDTH, IMG_HEIGHT))
    gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    
    _, binary = cv2.threshold(gray, THRESHOLD_VALUE, 255, cv2.THRESH_BINARY_INV)
    binary_flat = (binary / 255).astype(np.uint8).flatten()
    
    binary_2d = binary_flat.reshape((IMG_HEIGHT, IMG_WIDTH))
    roi = binary_2d[Y_START:Y_END, :]
    
    y_coords, x_coords = np.nonzero(roi == 1)
    pixel_count = len(x_coords)
    
    if pixel_count > 0:
        sum_x = int(np.sum(x_coords))
        line_x = int(sum_x / pixel_count)
        detected = 1
        if line_x <= BOUND_L:
            direction = "LEFT"
        elif line_x < BOUND_R:
            direction = "CENTER"
        else:
            direction = "RIGHT"
    else:
        sum_x = 0
        line_x = 0
        detected = 0
        direction = "NO_LINE"
        
    return binary_flat, pixel_count, sum_x, line_x, direction, detected

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    test_dir = os.path.join(base_dir, 'python', 'test_images')
    data_dir = os.path.join(base_dir, 'data')
    input_img_path = os.path.join(base_dir, 'python', 'input_images', 'input_1.jpg')
    
    os.makedirs(test_dir, exist_ok=True)
    os.makedirs(data_dir, exist_ok=True)
    
    create_test_images(test_dir, input_img_path)
    
    golden_file = os.path.join(data_dir, 'golden_results.txt')
    with open(golden_file, 'w') as gf:
        for t in range(1, 6):
            img_p = os.path.join(test_dir, f'test{t}.jpg')
            binary_flat, p_count, s_x, l_x, dir_str, det = process_image(img_p)
            
            if len(binary_flat) != 76800:
                print(f"Error: test{t} pixel count is {len(binary_flat)}, expected 76800")
                sys.exit(1)
                
            mem_path = os.path.join(data_dir, f'test{t}.mem')
            with open(mem_path, 'w') as mf:
                for px in binary_flat:
                    mf.write(f"{px}\n")
                    
            gf.write(f"TEST_ID={t}\n")
            gf.write(f"PIXEL_COUNT={p_count}\n")
            gf.write(f"SUM_X={s_x}\n")
            gf.write(f"LINE_X={l_x}\n")
            gf.write(f"DIRECTION={dir_str}\n")
            gf.write(f"DETECTED={det}\n")
            
    print("Python Reference Model completed. Generated test images, .mem files, and golden_results.txt successfully.")

if __name__ == '__main__':
    main()
