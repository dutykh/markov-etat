#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Exceptional terminal modular certificate builder, prototype.

This is NOT a proof of the exceptional terminal core exclusion by itself.
It is a reproducible certificate-search and audit tool.

It computes Markov/Cohn residues m_{p/q} modulo a product of pairwise
coprime moduli using the central lower-Christoffel word, scans terminal
exceptional pairs

    P=(q,p), Q=(q+r-s,p+r),

and records a separating modulus for each tested pair.  It can also check
whether a bounded rectangle has no survivors for a chosen modulus set.

A future finite-state certificate should replace the bounded scan by an
emptiness check of an automaton.  The functions here are deliberately kept
small and auditable so that they can serve as the transition/evaluation core
of that automaton.
"""
from __future__ import annotations

import argparse
import json
from dataclasses import dataclass, asdict
from math import gcd, prod
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

Matrix = Tuple[int, int, int, int]
Point = Tuple[int, int]
Pair = Tuple[int, int, int, int, int, int]

A_INT: Matrix = (2, 1, 1, 1)
B_INT: Matrix = (5, 2, 2, 1)


@dataclass(frozen=True)
class ScanReport:
    qmax: int
    rmax: int
    moduli: Tuple[int, ...]
    tested_pairs: int
    survivors: int
    survivor_examples: Tuple[Pair, ...]
    witness_counts: Dict[int, int]


def matmul(X: Matrix, Y: Matrix, N: int) -> Matrix:
    return (
        (X[0] * Y[0] + X[1] * Y[2]) % N,
        (X[0] * Y[1] + X[1] * Y[3]) % N,
        (X[2] * Y[0] + X[3] * Y[2]) % N,
        (X[2] * Y[1] + X[3] * Y[3]) % N,
    )


def central_matrix_mod(q: int, p: int, N: int) -> Matrix:
    """Matrix of central word z_{p/q} modulo N, using lower Christoffel path."""
    if q <= 0 or p < 0 or p > q or gcd(q, p) != 1:
        raise ValueError(f"Expected primitive 0 <= p <= q, got {(q, p)}")

    A: Matrix = tuple(v % N for v in A_INT)  # type: ignore[assignment]
    B: Matrix = tuple(v % N for v in B_INT)  # type: ignore[assignment]
    M: Matrix = (1 % N, 0, 0, 1 % N)

    previous_height = 0
    # The lower Christoffel word has q letters.  We strip first and last
    # letters to get the central word.
    for i in range(1, q + 1):
        height = (p * i) // q
        letter_is_A = height == previous_height
        if 1 < i < q:
            M = matmul(M, A if letter_is_A else B, N)
        previous_height = height
    return M


def markov_mod_product(q: int, p: int, N: int) -> int:
    """Compute m_{p/q} mod N as a^T M(z_{p/q}) a, a=(2,1)."""
    M = central_matrix_mod(q, p, N)
    return (4 * M[0] + 2 * M[1] + 2 * M[2] + M[3]) % N


def residue_vector_from_product(value: int, moduli: Sequence[int]) -> Tuple[int, ...]:
    return tuple(value % m for m in moduli)


def validate_moduli(moduli: Sequence[int]) -> Tuple[int, ...]:
    mods = tuple(moduli)
    if not mods:
        raise ValueError("At least one modulus is required")
    if len(set(mods)) != len(mods):
        raise ValueError("Moduli must be distinct")
    for i, m in enumerate(mods):
        if m <= 1:
            raise ValueError("Moduli must be > 1")
        for n in mods[:i]:
            if gcd(m, n) != 1:
                raise ValueError("Moduli must be pairwise coprime")
    return mods


def is_exceptional_direction(r: int, s: int) -> bool:
    # r<s and 9/5 < s/r < 15/8.
    return r < s and 9 * r < 5 * s and 8 * s < 15 * r and gcd(r, s) > 1


def is_primitive_point(q: int, p: int) -> bool:
    return q > 0 and 0 <= p <= q and gcd(q, p) == 1


def precompute_residues(qmax: int, modulus_product: int) -> Dict[Point, int]:
    residues: Dict[Point, int] = {}
    for q in range(1, qmax + 1):
        for p in range(0, q + 1):
            if gcd(q, p) == 1:
                residues[(q, p)] = markov_mod_product(q, p, modulus_product)
    return residues


def first_separating_modulus(a: int, b: int, moduli: Sequence[int]) -> Optional[int]:
    for m in moduli:
        if (a - b) % m != 0:
            return m
    return None


def scan(qmax: int, rmax: int, moduli: Sequence[int], max_survivors: int = 20) -> ScanReport:
    mods = validate_moduli(moduli)
    modulus_product = prod(mods)
    residues = precompute_residues(qmax, modulus_product)
    tested = 0
    survivors: List[Pair] = []
    witness_counts: Dict[int, int] = {m: 0 for m in mods}

    for r in range(2, rmax + 1):
        for s in range(r + 1, rmax + 1):
            if not is_exceptional_direction(r, s):
                continue
            # q2=q+r-s must be positive and p2=p+r <= q2, so p <= q-s.
            for q in range(s + 1, qmax + 1):
                q2 = q + r - s
                max_p = q - s
                for p in range(1, max_p + 1):
                    p2 = p + r
                    if not is_primitive_point(q, p) or not is_primitive_point(q2, p2):
                        continue
                    tested += 1
                    v1 = residues[(q, p)]
                    v2 = residues[(q2, p2)]
                    sep = first_separating_modulus(v1, v2, mods)
                    if sep is None:
                        if len(survivors) < max_survivors:
                            survivors.append((q, p, r, s, q2, p2))
                    else:
                        witness_counts[sep] += 1

    return ScanReport(
        qmax=qmax,
        rmax=rmax,
        moduli=mods,
        tested_pairs=tested,
        survivors=len(survivors),
        survivor_examples=tuple(survivors),
        witness_counts={m: c for m, c in witness_counts.items() if c},
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Exceptional terminal modular certificate builder prototype")
    parser.add_argument("--qmax", type=int, default=150)
    parser.add_argument("--rmax", type=int, default=70)
    parser.add_argument("--moduli", type=str, default="2,3,5,7,11,13,17")
    parser.add_argument("--max-survivors", type=int, default=20)
    parser.add_argument("--json-out", type=str, default="")
    args = parser.parse_args()

    moduli = tuple(int(x) for x in args.moduli.split(",") if x.strip())
    report = scan(args.qmax, args.rmax, moduli, args.max_survivors)
    data = asdict(report)
    # json cannot serialize tuple keys, so witness_counts keys are already ints.
    text = json.dumps(data, indent=2, sort_keys=True)
    print(text)
    if args.json_out:
        with open(args.json_out, "w", encoding="utf-8") as f:
            f.write(text + "\n")


if __name__ == "__main__":
    main()
