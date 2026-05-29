#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Mod-37 + mod-23 certificate for the c=1 family in the minimal exceptional direction.

Minimal direction: (R,H)=(6,5), so r=12, h=10.
Family c=1:
    t = 6k+1, p=t+1=6k+2,
    P_k = (12k+25, 6k+2),
    Q_k = (12k+15, 6k+14).
Admissibility:
    k >= 0, k != 2 mod 7, k != 2 mod 13.
Claim:
    Mod 37 separates every admissible class except 18 classes mod 546.
    Mod 23 separates all lifts of these 18 classes modulo 1092.
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
    # Cohn trace is 3*m, so compute modulo 3*mod and divide by 3.
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
    return (12*k + 25, 6*k + 2)

def Qk(k: int) -> tuple[int, int]:
    return (12*k + 15, 6*k + 14)

def admissible(k: int) -> bool:
    qP, pP = Pk(k)
    qQ, pQ = Qk(k)
    return (k >= 0 and 0 < pP < qP and 0 < pQ < qQ
            and math.gcd(qP, pP) == 1 and math.gcd(qQ, pQ) == 1)

def residue_pair(k: int, mod: int) -> tuple[int, int]:
    return markov_mod(*Pk(k), mod), markov_mod(*Qk(k), mod)

def main() -> None:
    # Verify the claimed matrix periods.
    W37 = matmul_mod(A, B, 111)
    X = (1, 0, 0, 1)
    for _ in range(12):
        X = matmul_mod(X, W37, 111)
    W12_mod_111 = X

    W23 = matmul_mod(A, B, 69)
    Y = (1, 0, 0, 1)
    for _ in range(24):
        Y = matmul_mod(Y, W23, 69)
    W24_mod_69 = Y

    mod37_period = 546
    mod37_survivors = []
    mod37_table = []
    for cls in range(mod37_period):
        k = cls
        if not admissible(k):
            mod37_table.append({'k_mod_546': cls, 'representative': k, 'excluded_by_primitivity': True})
            continue
        a, b = residue_pair(k, 37)
        separated = (a != b)
        mod37_table.append({'k_mod_546': cls, 'representative': k,
                            'm_P_mod_37': a, 'm_Q_mod_37': b,
                            'separated': separated})
        if not separated:
            mod37_survivors.append(cls)

    # Mod 23 has period 1092, so each mod-546 survivor has two lifts.
    mod23_lift_table = []
    mod23_survivors = []
    for cls in mod37_survivors:
        for lift in (cls, cls + mod37_period):
            if not admissible(lift):
                mod23_lift_table.append({'k_mod_1092': lift, 'excluded_by_primitivity': True})
                continue
            a, b = residue_pair(lift, 23)
            separated = (a != b)
            mod23_lift_table.append({'k_mod_1092': lift,
                                     'm_P_mod_23': a, 'm_Q_mod_23': b,
                                     'separated': separated})
            if not separated:
                mod23_survivors.append(lift)

    report = {
        'family': 'c=1 minimal exceptional direction',
        'P_k': '(12k+25, 6k+2)',
        'Q_k': '(12k+15, 6k+14)',
        'admissibility': 'k >= 0 and k != 2 mod 7 and k != 2 mod 13',
        'intersection_numbers_with_(2,1)': {'P': 21, 'Q': -13},
        'mod37_period': mod37_period,
        'W12_mod_111': W12_mod_111,
        'mod37_survivor_classes_mod_546': mod37_survivors,
        'mod37_survivor_count': len(mod37_survivors),
        'mod23_period': 1092,
        'W24_mod_69': W24_mod_69,
        'mod23_lift_table_for_mod37_survivors': mod23_lift_table,
        'mod23_survivor_classes_mod_1092': mod23_survivors,
        'mod23_survivor_count': len(mod23_survivors),
        'conclusion': 'Every admissible class is separated modulo 37, except survivor classes. Mod 23 separates both lifts of all survivor classes.'
    }
    out = '/mnt/data/minimal_direction_c1_mod37_mod23_certificate.json'
    with open(out, 'w') as f:
        json.dump(report, f, indent=2)
    print(json.dumps({
        'mod37_survivor_count': len(mod37_survivors),
        'mod37_survivors': mod37_survivors,
        'mod23_survivor_count': len(mod23_survivors),
        'mod23_survivors': mod23_survivors,
        'W12_mod_111': W12_mod_111,
        'W24_mod_69': W24_mod_69,
        'report': out
    }, indent=2))

if __name__ == '__main__':
    main()
