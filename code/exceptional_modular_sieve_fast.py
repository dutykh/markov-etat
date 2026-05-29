#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Fast modular sieve for terminal exceptional Markov/Cohn pairs.

This script improves exceptional_modular_sieve.py by computing residues modulo
the product of the requested pairwise-coprime moduli. Equality modulo the
product is equivalent to equality modulo every listed modulus.

It scans terminal exceptional pairs
    P=(q,p), Q=(q+r-s,p+r)
with r<s, 9r<5s, 8s<15r, gcd(r,s)>1, and primitive endpoints.

This is a search/certificate-building aid, not a proof by itself.
"""
from __future__ import annotations

import argparse
from math import gcd, prod
from typing import Dict, List, Sequence, Tuple

Matrix = Tuple[int, int, int, int]
Point = Tuple[int, int]
Pair = Tuple[int, int, int, int, int, int]


def matmul(X: Matrix, Y: Matrix, N: int) -> Matrix:
    return (
        (X[0] * Y[0] + X[1] * Y[2]) % N,
        (X[0] * Y[1] + X[1] * Y[3]) % N,
        (X[2] * Y[0] + X[3] * Y[2]) % N,
        (X[2] * Y[1] + X[3] * Y[3]) % N,
    )


def markov_mod_product(q: int, p: int, N: int) -> int:
    if q <= 0 or p < 0 or p > q or gcd(q, p) != 1:
        raise ValueError(f"Expected primitive 0 <= p <= q, got {(q, p)}")

    A: Matrix = (2 % N, 1 % N, 1 % N, 1 % N)
    B: Matrix = (5 % N, 2 % N, 2 % N, 1 % N)
    M: Matrix = (1 % N, 0, 0, 1 % N)

    previous_height = 0
    for i in range(1, q + 1):
        height = (p * i) // q
        letter_is_A = height == previous_height
        if 1 < i < q:  # strip first and last Christoffel letters
            M = matmul(M, A if letter_is_A else B, N)
        previous_height = height

    return (4 * M[0] + 2 * M[1] + 2 * M[2] + M[3]) % N


def is_exceptional_direction(r: int, s: int) -> bool:
    return r < s and 9 * r < 5 * s and 8 * s < 15 * r and gcd(r, s) > 1


def precompute_residues(qmax: int, modulus_product: int) -> Dict[Point, int]:
    residues: Dict[Point, int] = {}
    for q in range(1, qmax + 1):
        for p in range(0, q + 1):
            if gcd(q, p) == 1:
                residues[(q, p)] = markov_mod_product(q, p, modulus_product)
    return residues


def scan(qmax: int, rmax: int, moduli: Sequence[int], max_survivors: int = 20) -> Tuple[int, List[Pair]]:
    modulus_product = prod(moduli)
    residues = precompute_residues(qmax, modulus_product)
    tested = 0
    survivors: List[Pair] = []

    for r in range(2, rmax + 1):
        for s in range(r + 1, rmax + 1):
            if not is_exceptional_direction(r, s):
                continue
            for q in range(s + 1, qmax + 1):
                q2 = q + r - s
                max_p = q - s
                for p in range(1, max_p + 1):
                    p2 = p + r
                    if gcd(q, p) != 1 or gcd(q2, p2) != 1:
                        continue
                    tested += 1
                    if residues[(q, p)] == residues[(q2, p2)]:
                        survivors.append((q, p, r, s, q2, p2))
                        if len(survivors) >= max_survivors:
                            return tested, survivors
    return tested, survivors


def main() -> None:
    parser = argparse.ArgumentParser(description="Fast modular sieve for terminal exceptional pairs")
    parser.add_argument("--qmax", type=int, default=500)
    parser.add_argument("--rmax", type=int, default=200)
    parser.add_argument("--moduli", type=str, default="2,3,5,7,11,13,17,19,23,29,31,37,41,43,47")
    parser.add_argument("--max-survivors", type=int, default=20)
    args = parser.parse_args()

    moduli = tuple(int(x) for x in args.moduli.split(",") if x.strip())
    if len(set(moduli)) != len(moduli):
        raise SystemExit("Moduli must be distinct.")
    # The product method is logically strongest when moduli are pairwise coprime.
    for i, m in enumerate(moduli):
        if m <= 1:
            raise SystemExit("Moduli must be > 1.")
        for n in moduli[:i]:
            if gcd(m, n) != 1:
                raise SystemExit("Moduli must be pairwise coprime for product equality to be equivalent.")

    tested, survivors = scan(args.qmax, args.rmax, moduli, args.max_survivors)
    print(f"moduli={moduli}")
    print(f"product={prod(moduli)}")
    print(f"qmax={args.qmax} rmax={args.rmax}")
    print(f"tested={tested}")
    print(f"survivors={len(survivors)}")
    for pair in survivors:
        print(pair)


if __name__ == "__main__":
    main()
