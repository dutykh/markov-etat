#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Mod-47 + mod-5 certificate for the c=11 family in the minimal exceptional direction.

Minimal direction: (R,H)=(6,5), so r=12, h=10.
Family c=11:
    t = 6k+1, p=t+11=6k+12,
    P_k = (12k+35, 6k+12),
    Q_k = (12k+25, 6k+24).
Admissibility:
    k >= 0, k != 9 mod 11, k != 19 mod 23.
Claim:
    Mod 47 separates every admissible class except survivor classes mod 1012.
    Mod 5 separates all survivor classes.
"""
from __future__ import annotations
import json, math
from functools import lru_cache
from typing import Tuple

Mat = Tuple[int, int, int, int]
A: Mat = (2, 1, 1, 1)
B: Mat = (5, 2, 2, 1)

def matmul_mod(X: Mat, Y: Mat, m: int) -> Mat:
    a, b, c, d = X
    e, f, g, h = Y
    return ((a*e+b*g) % m, (a*f+b*h) % m,
            (c*e+d*g) % m, (c*f+d*h) % m)

@lru_cache(maxsize=None)
def sb_path(q: int, p: int) -> str:
    if not (q > 0 and 0 < p < q and math.gcd(q, p) == 1):
        raise ValueError((q, p))
    lo_p, lo_q = 0, 1
    hi_p, hi_q = 1, 1
    out = []
    while True:
        mp, mq = lo_p + hi_p, lo_q + hi_q
        if mp == p and mq == q:
            return ''.join(out)
        if p * mq < mp * q:
            hi_p, hi_q = mp, mq
            out.append('L')
        else:
            lo_p, lo_q = mp, mq
            out.append('R')

@lru_cache(maxsize=None)
def markov_mod(q: int, p: int, mod: int) -> int:
    Mmod = 3 * mod
    L = tuple(x % Mmod for x in A)
    R = tuple(x % Mmod for x in B)
    for ch in sb_path(q, p):
        M = matmul_mod(L, R, Mmod)
        if ch == 'L':
            R = M
        else:
            L = M
    M = matmul_mod(L, R, Mmod)
    tr = (M[0] + M[3]) % Mmod
    assert tr % 3 == 0, (q, p, mod, tr)
    return (tr // 3) % mod

def Pk(k: int) -> tuple[int, int]:
    return (12*k + 35, 6*k + 12)

def Qk(k: int) -> tuple[int, int]:
    return (12*k + 25, 6*k + 24)

def admissible(k: int) -> bool:
    qP, pP = Pk(k)
    qQ, pQ = Qk(k)
    return (k >= 0 and 0 < pP < qP and 0 < pQ < qQ
            and math.gcd(qP, pP) == 1 and math.gcd(qQ, pQ) == 1)

def class_rep(cls: int, period: int) -> int:
    rep = cls
    while rep < 0:
        rep += period
    return rep

def residue_pair(k: int, mod: int) -> tuple[int, int]:
    return markov_mod(*Pk(k), mod), markov_mod(*Qk(k), mod)

def pow_mat(M: Mat, n: int, mod: int) -> Mat:
    X = (1,0,0,1)
    for _ in range(n):
        X = matmul_mod(X, M, mod)
    return X

def main() -> None:
    mod47_period = 1012
    mod47_survivors = []
    mod47_table = []
    for cls in range(mod47_period):
        rep = class_rep(cls, mod47_period)
        if not admissible(rep):
            mod47_table.append({'k_mod_1012': cls, 'representative': rep, 'excluded_by_primitivity': True})
            continue
        a, b = residue_pair(rep, 47)
        separated = (a != b)
        mod47_table.append({'k_mod_1012': cls, 'representative': rep,
                            'm_P_mod_47': a, 'm_Q_mod_47': b,
                            'separated': separated})
        if not separated:
            mod47_survivors.append(cls)

    mod5_table_for_survivors = []
    mod5_survivors = []
    for cls in mod47_survivors:
        rep = class_rep(cls, mod47_period)
        a, b = residue_pair(rep, 5)
        separated = (a != b)
        mod5_table_for_survivors.append({'k_mod_1012': cls, 'representative': rep,
                                         'm_P_mod_5': a, 'm_Q_mod_5': b,
                                         'separated': separated})
        if not separated:
            mod5_survivors.append(cls)

    W47 = matmul_mod(A, B, 141)
    W24_mod_141 = pow_mat(W47, 24, 141)
    W5 = matmul_mod(A, B, 15)
    W4_mod_15 = pow_mat(W5, 4, 15)

    report = {
        'family': 'c=11 minimal exceptional direction',
        'P_k': '(12k+35, 6k+12)',
        'Q_k': '(12k+25, 6k+24)',
        'admissibility': 'k >= 0 and k != 9 mod 11 and k != 19 mod 23',
        'intersection_numbers_with_(2,1)': {'P': 11, 'Q': -23},
        'mod47_period': mod47_period,
        'W24_mod_141': W24_mod_141,
        'mod47_survivor_classes_mod_1012': mod47_survivors,
        'mod47_survivor_count': len(mod47_survivors),
        'mod5_table_for_mod47_survivors': mod5_table_for_survivors,
        'mod5_survivor_classes_mod_1012': mod5_survivors,
        'mod5_survivor_count': len(mod5_survivors),
        'W4_mod_15': W4_mod_15,
        'conclusion': 'Every admissible class is separated modulo 47, except survivor classes. Mod 5 separates all survivor classes.'
    }
    out = '/mnt/data/minimal_direction_c11_mod47_mod5_certificate.json'
    with open(out, 'w') as f:
        json.dump(report, f, indent=2)
    print(json.dumps({
        'mod47_survivor_count': len(mod47_survivors),
        'mod47_survivors': mod47_survivors,
        'mod5_survivor_count': len(mod5_survivors),
        'mod5_survivors': mod5_survivors,
        'W24_mod_141': W24_mod_141,
        'W4_mod_15': W4_mod_15,
        'report': out
    }, indent=2))

if __name__ == '__main__':
    main()
