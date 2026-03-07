import random
from vec_utils import VecWriter, base_parser, rand_signed, rand_signed_small

DATA_W  = 8
ACCUM_W = 32

def pe_model(data, weight, psum):
    mult = data * weight
    return mult, psum + mult

def corner_cases():
    return [
        (   5,    3,    0),
        (  -2,    4,    0),
        (   5,    3,   10),
        (  -2,   10,  -20),
        ( 127,  127,    0),
        (-128, -128,    0),
        (   0,    0,    0),
        (   1,   -1,  100),
        ( 127, -128,    0),
        (-128,  127,    0),
        (   1,    1,  (2**31)//2 - 1),
        (  -1,    1, -(2**31)//2),
    ]

def random_cases(n, seed):
    rng = random.Random(seed)
    return [(rand_signed(rng, DATA_W),
             rand_signed(rng, DATA_W),
             rand_signed_small(rng, ACCUM_W, frac=0.3))
            for _ in range(n)]

def main():
    args = base_parser("Generate pe.sv test vectors").parse_args()
    vectors = corner_cases() + random_cases(args.num, args.seed)
    fields = {"tv_data": DATA_W, "tv_weight": DATA_W, "tv_psum": ACCUM_W,
              "gold_mult": 2*DATA_W, "gold_mac": ACCUM_W}
    with VecWriter(args.outdir, fields) as w:
        for data, weight, psum in vectors:
            mult, mac = pe_model(data, weight, psum)
            w.write(tv_data=data, tv_weight=weight, tv_psum=psum,
                    gold_mult=mult, gold_mac=mac)
        w.report()

if __name__ == "__main__":
    main()