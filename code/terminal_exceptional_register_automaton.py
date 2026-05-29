#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Register-automaton layer for terminal exceptional pair certificates.

This is a proof-engineering component, not a final proof.  It gives an exact
semantics for asynchronous paired Stern-Brocot words by carrying integer
registers for the two endpoint fractions, together with Cohn residue automata.

The point is to separate two tasks:
  (1) finite residue computation modulo chosen moduli, which is finite-state;
  (2) recognition of the terminal exceptional language, which naturally uses
      integer affine registers (q,p,q',p').

A future certificate can replace the integer-register layer by a proven finite
abstraction or a finite family of regular sublanguages.  This script is the
reference semantics against which such abstractions are checked.
"""
from __future__ import annotations

import argparse
import json
import math
from dataclasses import dataclass
from itertools import zip_longest
from typing import Dict, List, Tuple, Iterable, Optional, Any

Mat = Tuple[int, int, int, int]
A0: Mat = (2, 1, 1, 1)
B0: Mat = (5, 2, 2, 1)
SINGLE = ("L", "R")
ASYNC = ("LL", "LR", "RL", "RR", "L_", "R_", "_L", "_R")


def mat_mul(X: Mat, Y: Mat, mod: int) -> Mat:
    a, b, c, d = X
    e, f, g, h = Y
    return ((a * e + b * g) % mod,
            (a * f + b * h) % mod,
            (c * e + d * g) % mod,
            (c * f + d * h) % mod)


def mat_trace(X: Mat) -> int:
    return X[0] + X[3]


def cohn_start(mod: int) -> Tuple[Mat, Mat]:
    return (tuple(x % mod for x in A0), tuple(x % mod for x in B0))  # type: ignore


def cohn_step(state: Tuple[Mat, Mat], letter: str, mod: int) -> Tuple[Mat, Mat]:
    L, R = state
    M = mat_mul(L, R, mod)
    if letter == "L":
        return (L, M)
    if letter == "R":
        return (M, R)
    raise ValueError(letter)


def residue_from_cohn_state(state: Tuple[Mat, Mat], modulus: int) -> int:
    mod = 3 * modulus
    L, R = state
    M = mat_mul(L, R, mod)
    tr = mat_trace(M) % mod
    if tr % 3 != 0:
        raise ArithmeticError(f"trace {tr} not divisible by 3 modulo {mod}")
    return (tr // 3) % modulus


@dataclass
class SBRegister:
    """Exact Stern-Brocot interval registers for a single path.

    Endpoints are lo = lo_p / lo_q and hi = hi_p / hi_q.  The represented
    current mediant after reading the path is (lo_p+hi_p)/(lo_q+hi_q).
    """
    lo_p: int = 0
    lo_q: int = 1
    hi_p: int = 1
    hi_q: int = 1

    def step(self, letter: str) -> None:
        mp = self.lo_p + self.hi_p
        mq = self.lo_q + self.hi_q
        if letter == "L":
            self.hi_p, self.hi_q = mp, mq
        elif letter == "R":
            self.lo_p, self.lo_q = mp, mq
        else:
            raise ValueError(letter)

    def point(self) -> Tuple[int, int]:
        """Return (q,p) of current mediant."""
        return (self.lo_q + self.hi_q, self.lo_p + self.hi_p)


def stern_brocot_path(q: int, p: int) -> str:
    if q <= 0 or p <= 0 or p >= q or math.gcd(q, p) != 1:
        raise ValueError("expected primitive interior point 0 < p < q")
    lo_p, lo_q = 0, 1
    hi_p, hi_q = 1, 1
    out: List[str] = []
    while True:
        mp, mq = lo_p + hi_p, lo_q + hi_q
        if mp == p and mq == q:
            return "".join(out)
        if p * mq < mp * q:
            hi_p, hi_q = mp, mq
            out.append("L")
        else:
            lo_p, lo_q = mp, mq
            out.append("R")


def padded_pair(path_l: str, path_r: str) -> List[str]:
    return [a + b for a, b in zip_longest(path_l, path_r, fillvalue="_")]


@dataclass
class AsyncEvaluation:
    left_point: Tuple[int, int]
    right_point: Tuple[int, int]
    r: int
    h: int
    s: int
    exceptional: bool
    primitive_endpoints: bool
    residues: Dict[int, Tuple[int, int]]
    first_separator: Optional[int]


def evaluate_async_word(symbols: List[str], moduli: List[int]) -> AsyncEvaluation:
    for sym in symbols:
        if sym not in ASYNC:
            raise ValueError(f"bad async symbol {sym}")
    left = SBRegister()
    right = SBRegister()
    cohn_left = {m: cohn_start(3 * m) for m in moduli}
    cohn_right = {m: cohn_start(3 * m) for m in moduli}
    for sym in symbols:
        l, r = sym[0], sym[1]
        if l != "_":
            left.step(l)
            for m in moduli:
                cohn_left[m] = cohn_step(cohn_left[m], l, 3 * m)
        if r != "_":
            right.step(r)
            for m in moduli:
                cohn_right[m] = cohn_step(cohn_right[m], r, 3 * m)
    P = left.point()
    Q = right.point()
    q, p = P
    q2, p2 = Q
    rr = p2 - p
    h = q - q2
    s = rr + h
    primitive = (0 < p < q and 0 < p2 < q2 and math.gcd(q, p) == 1 and math.gcd(q2, p2) == 1)
    exceptional = bool(rr > 1 and h > 0 and s > rr and 9 * rr < 5 * s and 8 * s < 15 * rr and math.gcd(rr, s) > 1)
    residues: Dict[int, Tuple[int, int]] = {}
    first = None
    for m in moduli:
        ml = residue_from_cohn_state(cohn_left[m], m)
        mr = residue_from_cohn_state(cohn_right[m], m)
        residues[m] = (ml, mr)
        if first is None and ml != mr:
            first = m
    return AsyncEvaluation(P, Q, rr, h, s, exceptional, primitive, residues, first)


def exceptional_pairs(qmax: int, rmax: int) -> Iterable[Tuple[Tuple[int, int], Tuple[int, int], Tuple[int, int]]]:
    for r in range(2, rmax + 1):
        for s in range(r + 1, rmax + 1):
            if not (9 * r < 5 * s and 8 * s < 15 * r):
                continue
            if math.gcd(r, s) <= 1:
                continue
            h = s - r
            for q in range(2, qmax + 1):
                q2 = q - h
                if q2 <= 1 or q2 > qmax:
                    continue
                lo = max(1, 1 - r)
                hi = min(q - 1, q2 - r - 1)
                for p in range(lo, hi + 1):
                    p2 = p + r
                    if 0 < p2 < q2 and math.gcd(q, p) == 1 and math.gcd(q2, p2) == 1:
                        yield (q, p), (q2, p2), (r, s)


def scan(qmax: int, rmax: int, moduli: List[int], limit: int = 20) -> Dict[str, Any]:
    first_counts: Dict[str, int] = {}
    survivors: List[Any] = []
    examples: List[Any] = []
    total = 0
    for P, Q, rs in exceptional_pairs(qmax, rmax):
        total += 1
        pl = stern_brocot_path(P[0], P[1])
        pr = stern_brocot_path(Q[0], Q[1])
        ev = evaluate_async_word(padded_pair(pl, pr), moduli)
        if ev.first_separator is None:
            if len(survivors) < limit:
                survivors.append({"P": P, "Q": Q, "r_s": rs, "path_P": pl, "path_Q": pr})
        else:
            first_counts[str(ev.first_separator)] = first_counts.get(str(ev.first_separator), 0) + 1
        if len(examples) < limit:
            examples.append({
                "P": P,
                "Q": Q,
                "r_s": rs,
                "path_P": pl,
                "path_Q": pr,
                "async_word": " ".join(padded_pair(pl, pr)),
                "first_separator": ev.first_separator,
            })
    return {
        "qmax": qmax,
        "rmax": rmax,
        "moduli": moduli,
        "total_pairs": total,
        "survivors_recorded": survivors,
        "first_separator_counts": first_counts,
        "examples": examples,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("check-word")
    p.add_argument("--word", required=True, help="space-separated async symbols, e.g. 'LR LR L_ _R'")
    p.add_argument("--moduli", nargs="+", type=int, default=[2,3,5,7,11,13,17,19])
    p.add_argument("--out", required=True)

    p = sub.add_parser("scan")
    p.add_argument("--qmax", type=int, default=100)
    p.add_argument("--rmax", type=int, default=50)
    p.add_argument("--moduli", nargs="+", type=int, default=[2,3,5,7,11,13,17,19])
    p.add_argument("--out", required=True)
    p.add_argument("--limit", type=int, default=20)

    args = ap.parse_args()
    if args.cmd == "check-word":
        ev = evaluate_async_word(args.word.split(), args.moduli)
        rep = {
            "left_point": ev.left_point,
            "right_point": ev.right_point,
            "r": ev.r,
            "h": ev.h,
            "s": ev.s,
            "exceptional": ev.exceptional,
            "primitive_endpoints": ev.primitive_endpoints,
            "residues": {str(k): v for k, v in ev.residues.items()},
            "first_separator": ev.first_separator,
        }
        with open(args.out, "w", encoding="utf-8") as f:
            json.dump(rep, f, indent=2, sort_keys=True)
    elif args.cmd == "scan":
        rep = scan(args.qmax, args.rmax, args.moduli, args.limit)
        with open(args.out, "w", encoding="utf-8") as f:
            json.dump(rep, f, indent=2, sort_keys=True)


if __name__ == "__main__":
    main()
