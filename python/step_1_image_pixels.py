import cv2
import sys

def main():
    # 1. Load a local image
    image_path = 'input_images/input_1.jpg'
    img = cv2.imread(image_path)

    if img is None:
        print(f"Error: Could not load image at {image_path}")
        print("Please ensure you have placed a 'test_image.jpg' in the input_images folder.")
        sys.exit(1)

    # 2. Print Dimensions and Channels (The Software view)
    height, width, channels = img.shape
    print("=== ORIGINAL IMAGE DATA ===")
    print(f"Original Dimensions : {width}x{height}")
    print(f"Number of Channels  : {channels} (Usually B, G, R in OpenCV)")

    # 3. Resize to a manageable resolution (320x240)
    # Why? Hardware struggles with 4K images. A 320x240 image is 76,800 pixels. 
    # At 1 clock cycle per pixel, that's easy to simulate in Verilog later!
    img_resized = cv2.resize(img, (320, 240))
    res_height, res_width, res_channels = img_resized.shape
    print("\n=== RESIZED IMAGE DATA ===")
    print(f"Resized Dimensions  : {res_width}x{res_height}")

    # 4. Look at specific pixel data
    # Coordinates in OpenCV are (y, x) -> (row, column)
    y, x = 120, 160 # Center of the 320x240 image
    b, g, r = img_resized[y, x]
    print(f"\nPixel at (x={x}, y={y}):")
    print(f"Red: {r}, Green: {g}, Blue: {b}")

    # 5. Convert to Grayscale (3 channels -> 1 channel)
    # Hardware perspective: Reducing 24-bit RGB data to 8-bit Gray data 
    # saves a massive amount of wires, logic gates, and memory in an FPGA.
    img_gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    gray_val = img_gray[y, x]
    print(f"Grayscale value at (x={x}, y={y}): {gray_val}")

    # 6. Convert to Binary (1 channel 8-bit -> 1 channel 1-bit)
    # Hardware perspective: A 1-bit signal is just a single wire! (1 = line, 0 = background)
    # Here we say: if pixel < 100, make it 255 (White), else make it 0 (Black)
    threshold_value = 100
    _, img_binary = cv2.threshold(img_gray, threshold_value, 255, cv2.THRESH_BINARY_INV)

    # 7. Display the results
    print("\nDisplaying images. Press any key on the image windows to close them and exit.")
    cv2.imshow("1. Original Resized (RGB)", img_resized)
    cv2.imshow("2. Grayscale (8-bit)", img_gray)
    cv2.imshow("3. Binary/Thresholded (1-bit concept)", img_binary)
    
    cv2.waitKey(0) # Wait indefinitely until the user presses a key
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
