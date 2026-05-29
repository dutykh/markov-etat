#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Modular sieve for terminal exceptional Markov/Cohn pairs.

For a primitive lattice point (q,p), 0 <= p <= q, the script computes the
Markov number m_{p/q} modulo a list of moduli using the central word of the
lower Christoffel word.  It then scans terminal exceptional pairs

    P=(q,p),   Q=(q+r-s, p+r),

where r<s, 9r<5s, 8s<15r, gcd(r,s)>1, and both endpoints are primitive.

This is not a proof of the full exceptional terminal exclusion, but it is a
certificate-search tool: a pair is excluded by a modulus N if its two residues
mod N differ.
"""

from __future__ import annotations

import argparse
from math import gcd
from typing import Dict, Iterable, List, Sequence, Tuple

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


def markov_mod(q: int, p: int, N: int) -> int:
    """Compute m_{p/q} mod N using the central Christoffel word."""
    if q <= 0 or p < 0 or p > q or gcd(q, p) != 1:
        raise ValueError(f"Expected primitive 0 <= p <= q, got {(q, p)}")

    A: Matrix = (2 % N, 1 % N, 1 % N, 1 % N)
    B: Matrix = (5 % N, 2 % N, 2 % N, 1 % N)
    M: Matrix = (1 % N, 0, 0, 1 % N)

    previous_height = 0
    for i in range(1, q + 1):
        height = (p * i) // q
        # Lower Christoffel letter: A for horizontal, B for diagonal step.
        letter_is_A = height == previous_height
        # Strip first and last letters to get the central word z_{p/q}.
        if 1 < i < q:
            M = matmul(M, A if letter_is_A else B, N)
        previous_height = height

    # a^T M a for a=(2,1).
    return (4 * M[0] + 2 * M[1] + 2 * M[2] + M[3]) % N


def is_exceptional_direction(r: int, s: int) -> bool:
    return r < s and 9 * r < 5 * s and 8 * s < 15 * r and gcd(r, s) > 1


def precompute_residues(Qmax: int, moduli: Sequence[int]) -> Dict[Point, Tuple[int, ...]]:
    residues: Dict[Point, Tuple[int, ...]] = {}
    for q in range(1, Qmax + 1):
        for p in range(0, q + 1):
            if gcd(q, p) == 1:
                residues[(q, p)] = tuple(markov_mod(q, p, N) for N in moduli)
    return residues


def scan(Qmax: int, Rmax: int, moduli: Sequence[int], max_survivors: int = 20) -> Tuple[int, List[Pair]]:
    residues = precompute_residues(Qmax, moduli)
    tested = 0
    survivors: List[Pair] = []

    for r in range(2, Rmax + 1):
        for s in range(r + 1, Rmax + 1):
            if not is_exceptional_direction(r, s):
                continue
            for q in range(s + 1, Qmax + 1):
                # Q=(q+r-s,p+r) must satisfy p+r <= q+r-s, so p <= q-s.
                for p in range(1, q - s + 1):
                    q2 = q + r - s
                    p2 = p + r
                    if (q, p) not in residues or (q2, p2) not in residues:
                        continue
                    tested += 1
                    if residues[(q, p)] == residues[(q2, p2)]:
                        survivors.append((q, p, r, s, q2, p2))
                        if len(survivors) >= max_survivors:
                            return tested, survivors
    return tested, survivors


def main() -> None:
    parser = argparse.ArgumentParser(description="Modular sieve for terminal exceptional pairs")
    parser.add_argument("--qmax", type=int, default=100)
    parser.add_argument("--rmax", type=int, default=50)
    parser.add_argument("--moduli", type=str, default="2,3,5,7,11,13,17")
    parser.add_argument("--max-survivors", type=int, default=20)
    args = parser.parse_args()

    moduli = tuple(int(x) for x in args.moduli.split(",") if x.strip())
    tested, survivors = scan(args.qmax, args.rmax, moduli, args.max_survivors)
    print(f"moduli={moduli}")
    print(f"tested={tested}")
    print(f"survivors={len(survivors)}")
    for pair in survivors:
        print(pair)


if __name__ == "__main__":
    main()
