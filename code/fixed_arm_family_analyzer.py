#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Prototype analyzer for fixed-arm terminal families L^{n+1} R^k versus R^m.

This is an exploratory/audit script for the Markov uniqueness proof program.
It computes exact Markov numbers via central Christoffel words, samples the
sequence X_n(k)=m_{path L^{n+1}R^k}, guesses low-order linear recurrences,
and records a finite comparison against the endpoint Pell arm R^m.

It is not a proof by itself.  It supplies reproducible data and candidate
recurrences for the next recurrence-intersection certificates.
"""
from __future__ import annotations

import json
import argparse
from dataclasses import dataclass, asdict
from math import gcd
from fractions import Fraction
from typing import List, Tuple, Optional

A = (2, 1, 1, 1)
B = (5, 2, 2, 1)
Matrix = Tuple[int, int, int, int]


def matmul(X: Matrix, Y: Matrix) -> Matrix:
    return (
        X[0] * Y[0] + X[1] * Y[2],
        X[0] * Y[1] + X[1] * Y[3],
        X[2] * Y[0] + X[3] * Y[2],
        X[2] * Y[1] + X[3] * Y[3],
    )


def central_matrix(q: int, p: int) -> Matrix:
    if q <= 0 or not (0 <= p <= q) or gcd(q, p) != 1:
        raise ValueError((q, p))
    M = (1, 0, 0, 1)
    prev = 0
    for i in range(1, q + 1):
        height = (p * i) // q
        letter = A if height == prev else B
        if 1 < i < q:
            M = matmul(M, letter)
        prev = height
    return M


def markov(q: int, p: int) -> int:
    M = central_matrix(q, p)
    return 4 * M[0] + 2 * M[1] + 2 * M[2] + M[3]


def path_fraction(path: str) -> Tuple[int, int]:
    # Stern-Brocot interval [0/1,1/1]. Return current mediant after path.
    lq, lp = 1, 0
    rq, rp = 1, 1
    for ch in path:
        mq, mp = lq + rq, lp + rp
        if ch == "L":
            rq, rp = mq, mp
        elif ch == "R":
            lq, lp = mq, mp
        else:
            raise ValueError(ch)
    return lq + rq, lp + rp


def pell(n: int) -> int:
    # Pell P_0=0,P_1=1
    a, b = 0, 1
    if n == 0:
        return a
    if n == 1:
        return b
    for _ in range(1, n):
        a, b = b, 2 * b + a
    return b


def family_sequence(k: int, count: int) -> List[int]:
    return [markov(*path_fraction("L" * (n + 1) + "R" * k)) for n in range(count)]


def solve_linear_system(A_mat, b_vec):
    # Basic rational Gaussian elimination.
    n = len(b_vec)
    m = len(A_mat[0]) if A_mat else 0
    M = [[Fraction(x) for x in row] + [Fraction(b_vec[i])] for i, row in enumerate(A_mat)]
    row = 0
    pivots = []
    for col in range(m):
        pivot = None
        for r in range(row, n):
            if M[r][col] != 0:
                pivot = r
                break
        if pivot is None:
            continue
        M[row], M[pivot] = M[pivot], M[row]
        fac = M[row][col]
        M[row] = [x / fac for x in M[row]]
        for r in range(n):
            if r != row and M[r][col] != 0:
                fac = M[r][col]
                M[r] = [M[r][j] - fac * M[row][j] for j in range(m + 1)]
        pivots.append(col)
        row += 1
        if row == n:
            break
    # check consistency
    for r in range(n):
        if all(M[r][c] == 0 for c in range(m)) and M[r][m] != 0:
            return None
    # choose zero for free variables
    sol = [Fraction(0) for _ in range(m)]
    for i, col in enumerate(pivots):
        sol[col] = M[i][m]
    return sol


def guess_recurrence(vals: List[int], max_order: int = 10):
    # Tries homogeneous and affine linear recurrences.
    N = len(vals)
    for order in range(1, max_order + 1):
        # homogeneous: x_n = sum c_i x_{n-1-i}
        rows = []
        rhs = []
        for n in range(order, min(N, 3 * order + 4)):
            rows.append([vals[n - 1 - i] for i in range(order)])
            rhs.append(vals[n])
        sol = solve_linear_system(rows, rhs)
        if sol is not None:
            if all(Fraction(vals[n]) == sum(sol[i] * vals[n - 1 - i] for i in range(order)) for n in range(order, N)):
                return {"type": "homogeneous", "order": order, "coefficients": [str(s) for s in sol]}
        # affine: x_n = c0 + sum c_i x_{n-1-i}
        rows = []
        rhs = []
        for n in range(order, min(N, 3 * order + 4)):
            rows.append([1] + [vals[n - 1 - i] for i in range(order)])
            rhs.append(vals[n])
        sol = solve_linear_system(rows, rhs)
        if sol is not None:
            if all(Fraction(vals[n]) == sol[0] + sum(sol[i + 1] * vals[n - 1 - i] for i in range(order)) for n in range(order, N)):
                return {"type": "affine", "order": order, "coefficients": [str(s) for s in sol]}
    return None


@dataclass
class FamilyReport:
    k: int
    fractions: List[Tuple[int, int]]
    values: List[int]
    recurrence: object
    finite_pell_intersections: List[Tuple[int, int, int]]


def analyze(kmax: int, ncount: int, pell_m_max: int) -> List[FamilyReport]:
    reports = []
    pell_values = {pell(2 * m + 3): m for m in range(pell_m_max + 1)}
    for k in range(1, kmax + 1):
        fracs = [path_fraction("L" * (n + 1) + "R" * k) for n in range(ncount)]
        vals = [markov(q, p) for q, p in fracs]
        rec = guess_recurrence(vals, max_order=12)
        inter = []
        for n, val in enumerate(vals):
            if val in pell_values:
                inter.append((n, pell_values[val], val))
        reports.append(FamilyReport(k, fracs[:8], vals[:8], rec, inter))
    return reports


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--kmax", type=int, default=6)
    ap.add_argument("--ncount", type=int, default=24)
    ap.add_argument("--pell-m-max", type=int, default=200)
    ap.add_argument("--out", default="/mnt/data/fixed_arm_family_report.json")
    args = ap.parse_args()
    reports = analyze(args.kmax, args.ncount, args.pell_m_max)
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump([asdict(r) for r in reports], f, indent=2)
    print(json.dumps({"out": args.out, "families": len(reports)}, indent=2))

if __name__ == "__main__":
    main()
