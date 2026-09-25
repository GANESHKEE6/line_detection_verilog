import os
import sys

def parse_results_file(filepath):
    results = {}
    if not os.path.exists(filepath):
        return results
    current_test = None
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith("TEST_ID="):
                current_test = int(line.split("=")[1])
                results[current_test] = {}
            elif current_test is not None:
                parts = line.split("=")
                if len(parts) == 2:
                    key, val = parts[0], parts[1]
                    if key in ["PIXEL_COUNT", "SUM_X", "LINE_X", "DETECTED"]:
                        results[current_test][key] = int(val)
                    else:
                        results[current_test][key] = val
    return results

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_dir = os.path.join(base_dir, 'data')
    golden_path = os.path.join(data_dir, 'golden_results.txt')
    rtl_path = os.path.join(data_dir, 'rtl_results.txt')
    
    golden = parse_results_file(golden_path)
    rtl = parse_results_file(rtl_path)
    
    if not golden:
        print("Error: Golden results not found. Run reference_model.py first.")
        sys.exit(1)
    if not rtl:
        print("Error: RTL results not found. Run Vivado simulation first.")
        sys.exit(1)
        
    print("==================================================oth")
    print("PYTHON vs RTL VERIFICATION")
    print("==================================================")
    
    passed_tests = 0
    total_tests = len(golden)
    
    for t in range(1, total_tests + 1):
        g = golden.get(t, {})
        r = rtl.get(t, {})
        
        print(f"\nTEST {t}:")
        pc_pass = (g.get("PIXEL_COUNT") == r.get("PIXEL_COUNT"))
        sx_pass = (g.get("SUM_X") == r.get("SUM_X"))
        lx_pass = (g.get("LINE_X") == r.get("LINE_X"))
        dir_pass = (g.get("DIRECTION") == r.get("DIRECTION"))
        det_pass = (g.get("DETECTED") == r.get("DETECTED"))
        
        print(f"Pixel count : {'PASS' if pc_pass else 'FAIL'} (Exp: {g.get('PIXEL_COUNT')}, Act: {r.get('PIXEL_COUNT')})")
        print(f"Sum X       : {'PASS' if sx_pass else 'FAIL'} (Exp: {g.get('SUM_X')}, Act: {r.get('SUM_X')})")
        print(f"Line X      : {'PASS' if lx_pass else 'FAIL'} (Exp: {g.get('LINE_X')}, Act: {r.get('LINE_X')})")
        print(f"Direction   : {'PASS' if dir_pass else 'FAIL'} (Exp: {g.get('DIRECTION')}, Act: {r.get('DIRECTION')})")
        print(f"Detected    : {'PASS' if det_pass else 'FAIL'} (Exp: {g.get('DETECTED')}, Act: {r.get('DETECTED')})")
        
        test_overall = pc_pass and sx_pass and lx_pass and dir_pass and det_pass
        print(f"Overall     : {'PASS' if test_overall else 'FAIL'}")
        
        if test_overall:
            passed_tests += 1
            
    print("\n==================================================")
    print("FINAL RESULT")
    print("==================================================")
    print(f"Tests passed: {passed_tests}/{total_tests}")
    if passed_tests == total_tests:
        print("Verification: PASS")
    else:
        print("Verification: FAIL")
    print("==================================================")

if __name__ == '__main__':
    main()
