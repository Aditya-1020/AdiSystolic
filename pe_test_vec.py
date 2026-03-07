# creates pe_test_vectors.hex for testbench
import random
import argparse

def signed_hex(val, width):  # signed int to hex str (2's complement)
    if val < 0:
        val = (1 << width) + val  # Fixed: 1 not i
    mask = (1 << width) - 1
    val = val & mask
    width_hex = width // 4  # Fixed: // not /
    return f"{val:0{width_hex}X}"

def generate_vectors(num_tests=100, seed=42):
    random.seed(seed)
    vectors = []

    corners = [
        (5, 3, 0),           # multiply
        (-2, 4, 0),          # negative mult
        (5, 3, 10),          # add
        (-2, 10, -20),       # negative add
        (127, 127, 0),       # max pos mult overflow
        (-128, -128, 0),     # max neg mult overflow
        (0, 0, 0),           # zero
        (1, -1, 100),        # mixed signs
    ]
    for d, w, p in corners:
        vectors.append((d, w, p))

    # Random Tests
    for _ in range(num_tests - len(corners)):
        data = random.randint(-128, 127)
        weight = random.randint(-128, 127)
        psum = random.choice([0, random.randint(-2**31//4, 2**31//4 - 1)])  # 0 for mul else add
        vectors.append((data, weight, psum))

    return vectors

def write_hex_file(vectors, filename="test_vectors.hex"):
    with open(filename, "w") as f:
        for data, weight, psum in vectors:  # Fixed: remove extra comma
            f.write(f"{signed_hex(data, 8)} {signed_hex(weight, 8)} {signed_hex(psum, 32)}\n")
    print(f"Generated {len(vectors)} vectors -> {filename}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate PE test vectors")
    parser.add_argument("-n", "--num", type=int, default=100, help="Number of tests")
    parser.add_argument("-s", "--seed", type=int, default=42, help="Random seed")
    parser.add_argument("-o", "--output", default="test_vectors.hex", help="Output file")
    args = parser.parse_args()
    
    vecs = generate_vectors(args.num, args.seed)
    write_hex_file(vecs, args.output)
