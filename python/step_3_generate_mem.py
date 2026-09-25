import cv2
import numpy as np
import os
import sys

# ==========================================
# CONFIGURATION
# ==========================================
IMG_WIDTH = 320
IMG_HEIGHT = 240
THRESHOLD_VALUE = 100 
ROI_START_Y_PCT = 0.4
BOUND_LEFT = 140
BOUND_RIGHT = 180

def main():
    # 1. Setup paths
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    image_path = os.path.join(base_dir, 'python', 'input_images', 'input_1.jpg')
    data_dir = os.path.join(base_dir, 'data')
    mem_file = os.path.join(data_dir, 'input_binary.mem')
    result_file = os.path.join(data_dir, 'expected_result.txt')

    os.makedirs(data_dir, exist_ok=True)

    # 2. Load, Resize, Grayscale
    img = cv2.imread(image_path)
    if img is None:
        print(f"Error: Could not load {image_path}")
        sys.exit(1)
        
    img_resized = cv2.resize(img, (IMG_WIDTH, IMG_HEIGHT))
    gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    
    # 3. Threshold (0 or 1)
    # THRESH_BINARY_INV makes dark lines 255. We divide by 255 to get strictly 0 or 1.
    _, binary_img = cv2.threshold(gray, THRESHOLD_VALUE, 255, cv2.THRESH_BINARY_INV)
    binary_img = (binary_img / 255).astype(np.uint8)

    # 4. Calculate expected results (applying ROI logic)
    roi_start_y = int(IMG_HEIGHT * ROI_START_Y_PCT)
    roi = binary_img[roi_start_y:, :]
    
    y_coords, x_coords = np.nonzero(roi == 1)
    detected_pixels = len(x_coords)
    
    if detected_pixels > 0:
        sum_x = np.sum(x_coords)
        line_x = int(sum_x / detected_pixels)
        if line_x < BOUND_LEFT: direction = "LEFT"
        elif line_x > BOUND_RIGHT: direction = "RIGHT"
        else: direction = "CENTER"
    else:
        line_x, direction = 0, "NO LINE"

    # 5. Generate .mem file (Raster scan order)
    flat_img = binary_img.flatten()
    with open(mem_file, 'w') as f:
        for pixel in flat_img:
            f.write(f"{pixel}\n")

    # 6. Generate expected result file
    with open(result_file, 'w') as f:
        f.write(f"WIDTH={IMG_WIDTH}\n")
        f.write(f"HEIGHT={IMG_HEIGHT}\n")
        f.write(f"THRESHOLD={THRESHOLD_VALUE}\n")
        f.write(f"DETECTED_PIXELS={detected_pixels}\n")
        f.write(f"LINE_X={line_x}\n")
        f.write(f"DIRECTION={direction}\n")

    # 7. Validation & Verification
    total_generated = len(flat_img)
    total_ones = np.count_nonzero(flat_img == 1)
    total_zeros = total_generated - total_ones
    
    if total_generated != (IMG_WIDTH * IMG_HEIGHT):
        print("ERROR: Generated memory size mismatch!")
        sys.exit(1)

    print("\n==================================================")
    print("MEMORY GENERATION RESULTS")
    print("==================================================")
    print(f"Image resolution  : {IMG_WIDTH}x{IMG_HEIGHT}")
    print(f"Total pixels      : {total_generated}")
    print(f"Line pixels       : {total_ones} (Across entire image)")
    print(f"Background pixels : {total_zeros}")
    print(f"Threshold         : {THRESHOLD_VALUE}")
    print(f"Line X position   : {line_x}")
    print(f"Direction         : {direction}")
    print(f"\nMEM file          : data/input_binary.mem")
    print(f"Expected result   : data/expected_result.txt")
    print("==================================================")
    print("VERIFYING MEMORY FILE")
    print("==================================================")
    
    with open(mem_file, 'r') as f:
        lines = f.read().splitlines()
        
    print(f"Counted lines     : {len(lines)}")
    print(f"First 20 entries  : {lines[:20]}")
    print(f"Last 20 entries   : {lines[-20:]}")
    print(f"Checksum valid    : {len(lines) == 76800 and total_zeros + total_ones == 76800}")
    print("==================================================\n")

if __name__ == "__main__":
    main()
