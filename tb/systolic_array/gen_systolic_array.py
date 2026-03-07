import random, os, sys, argparse
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../scripts'))
from vec_utils import fmt, base_parser

def matmul(A, B, N):
    C = [[0]*N for _ in range(N)]
    for i in range(N):
        for j in range(N):
            for k in range(N):
                C[i][j] += A[i][k] * B[k][j]
    return C

def stagger(M, direction, N, DW):
    """
    Returns flat list of values to write, one per line.
    Total lines = (2*N-1) * N  (cycle-major, then col within cycle)
    direction='row': A matrix — row r starts at cycle r
    direction='col': B matrix — col c starts at cycle c
    """
    total_cycles = 2 * N - 1
    result = [[0] * N for _ in range(total_cycles)]
    if direction == 'row':
        for r in range(N):
            for k in range(N):
                result[r + k][r] = M[r][k]
    else:
        for c in range(N):
            for k in range(N):
                result[c + k][c] = M[k][c]
    # Flatten: one value per line
    flat = []
    for cycle in result:
        for val in cycle:
            flat.append(val)
    return flat

def main():
    parser = base_parser("Generate systolic array test vectors")
    parser.add_argument("--N", type=int, default=4, help="Matrix dimension")
    parser.add_argument("--data-width", type=int, default=8)
    parser.add_argument("--accum-width", type=int, default=32)
    args = parser.parse_args()

    N, DW, AW = args.N, args.data_width, args.accum_width
    rng = random.Random(args.seed)
    os.makedirs(args.outdir, exist_ok=True)

    lo, hi = -(1 << (DW-1)), (1 << (DW-1)) - 1
    A = [[rng.randint(lo, hi) for _ in range(N)] for _ in range(N)]
    B = [[rng.randint(lo, hi) for _ in range(N)] for _ in range(N)]
    C = matmul(A, B, N)

    a_flat = stagger(A, 'row', N, DW)
    b_flat = stagger(B, 'col', N, DW)
    c_flat = [C[i][j] for i in range(N) for j in range(N)]

    def write(fname, vals, width):
        with open(os.path.join(args.outdir, fname), 'w') as f:
            for v in vals:
                f.write(fmt(v, width) + '\n')

    write('tv_a.hex',   a_flat, DW)
    write('tv_b.hex',   b_flat, DW)
    write('gold_c.hex', c_flat, AW)

    total_cycles = 2 * N - 1
    
    # debug check
    print("\nA ="); [print(' ', r) for r in A]
    print("B ="); [print(' ', r) for r in B]
    print("C ="); [print(' ', r) for r in C]

if __name__ == "__main__":
    main()