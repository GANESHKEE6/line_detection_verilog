import cv2
import numpy as np
import sys

# ==========================================
# CONFIGURATION (Future Hardware Parameters)
# ==========================================
IMG_WIDTH = 320
IMG_HEIGHT = 240

# THRESHOLD: Assuming a dark line on a light background. 
# Anything darker than 100 becomes a line pixel (value 255).
THRESHOLD_VALUE = 100 

# ROI: Process only the bottom 40% of the image (Y > 144)
ROI_START_Y_PCT = 0.0 

# CLASSIFICATION BOUNDARIES (X coordinates)
BOUND_LEFT = 140
BOUND_RIGHT = 180

def load_and_resize(path):
    img = cv2.imread(path)
    if img is None:
        print(f"Error: Could not load image at {path}")
        sys.exit(1)
    return cv2.resize(img, (IMG_WIDTH, IMG_HEIGHT))

def convert_to_grayscale(img):
    # Hardware Note: OpenCV uses floating point math. 
    # In RTL, we will use integer approximation: Gray = (77*R + 150*G + 29*B) >> 8
    return cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

def threshold_image(gray_img):
    # Hardware Note: 1-bit Comparator.
    # THRESH_BINARY_INV makes dark pixels (<100) turn white (255) and everything else black (0).
    _, binary_img = cv2.threshold(gray_img, THRESHOLD_VALUE, 255, cv2.THRESH_BINARY_INV)
    return binary_img

def extract_roi(binary_img):
    # Hardware Note: X/Y Counters. We create a mask and only keep the bottom 40%.
    roi_start_y = int(IMG_HEIGHT * ROI_START_Y_PCT)
    roi_img = np.zeros_like(binary_img)
    roi_img[roi_start_y:IMG_HEIGHT, :] = binary_img[roi_start_y:IMG_HEIGHT, :]
    return roi_img, roi_start_y

def calculate_centroid(roi_img):
    # Hardware Note: sum_x = Accumulator, count = Counter, division = Divider
    
    # Get coordinates of all pixels that equal 255 (our line pixels)
    y_coords, x_coords = np.nonzero(roi_img == 255)
    pixel_count = len(x_coords)
    
    if pixel_count == 0:
        return 0, 0 # Safely handle divide-by-zero if no line is found
    
    sum_x = np.sum(x_coords)
    line_x = int(sum_x / pixel_count)
    
    return line_x, pixel_count

def classify_line(line_x, pixel_count):
    # Hardware Note: Two comparators
    if pixel_count == 0:
        return "NO LINE"
    elif line_x < BOUND_LEFT:
        return "LEFT"
    elif line_x > BOUND_RIGHT:
        return "RIGHT"
    else:
        return "CENTER"

def visualize_results(original, gray, binary, roi, line_x, direction, count, roi_y):
    output_img = original.copy()
    
    # Draw ROI boundary (Blue)
    cv2.line(output_img, (0, roi_y), (IMG_WIDTH, roi_y), (255, 0, 0), 2)
    # Draw Center of camera (Green)
    cv2.line(output_img, (IMG_WIDTH//2, 0), (IMG_WIDTH//2, IMG_HEIGHT), (0, 255, 0), 1)

    # Draw Detected Line Centroid (Red)
    if count > 0:
        cv2.line(output_img, (line_x, roi_y), (line_x, IMG_HEIGHT), (0, 0, 255), 3)
        cv2.circle(output_img, (line_x, roi_y + 30), 5, (0, 0, 255), -1)

    # Console Output
    print("=== PIPELINE RESULTS ===")
    print(f"Image resolution : {IMG_WIDTH}x{IMG_HEIGHT}")
    print(f"Line detected    : {'YES' if count > 0 else 'NO'}")
    print(f"Line position    : {line_x}")
    print(f"Direction        : {direction}")
    print(f"Detected pixels  : {count}")

    # Display Windows
    cv2.imshow("1. Original", original)
    cv2.imshow("2. Grayscale", gray)
    cv2.imshow("3. Threshold", binary)
    cv2.imshow("4. ROI", roi)
    cv2.imshow("5. Final Output", output_img)
    
    print("\nPress any key on the image windows to close them and exit.")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def main():
    # 1. Load and Resize
    image_path = 'input_images/input_1.jpg'
    img = load_and_resize(image_path)
    
    # 2. Grayscale
    gray = convert_to_grayscale(img)
    
    # 3. Threshold
    binary = threshold_image(gray)
    
    # 4. ROI
    roi, roi_start_y = extract_roi(binary)
    
    # 5. Centroid Calculation
    line_x, pixel_count = calculate_centroid(roi)
    
    # 6. Classification
    direction = classify_line(line_x, pixel_count)
    
    # 7. Visualization
    visualize_results(img, gray, binary, roi, line_x, direction, pixel_count, roi_start_y)

if __name__ == "__main__":
    main()
