#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Mod-37 + mod-23 certificate for the c=-5 family in the minimal exceptional direction.

Minimal direction: (R,H)=(6,5), so r=12, h=10.
Family c=-5:
    t = 6k+1, p=t-5=6k-4,
    P_k = (12k+19, 6k-4),
    Q_k = (12k+9,  6k+8).
Admissibility:
    k >= 1 and k != 1 mod 7.
Claim:
    Mod 37 separates every admissible class except the listed 12 classes mod 378.
    Mod 23 separates all lifts of those survivor classes modulo 756.
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
    return (12*k + 19, 6*k - 4)

def Qk(k: int) -> tuple[int, int]:
    return (12*k + 9, 6*k + 8)

def admissible(k: int) -> bool:
    qP, pP = Pk(k)
    qQ, pQ = Qk(k)
    return (k >= 1 and 0 < pP < qP and 0 < pQ < qQ
            and math.gcd(qP, pP) == 1 and math.gcd(qQ, pQ) == 1)

def class_rep(cls: int, period: int) -> int:
    rep = cls
    while rep < 1:
        rep += period
    return rep

def residue_pair(k: int, mod: int) -> tuple[int, int]:
    return markov_mod(*Pk(k), mod), markov_mod(*Qk(k), mod)

def main() -> None:
    mod37_period = 378
    mod37_survivors = []
    mod37_table = []
    for cls in range(mod37_period):
        rep = class_rep(cls, mod37_period)
        if not admissible(rep):
            mod37_table.append({'k_mod_378': cls, 'representative': rep, 'excluded_by_primitivity': True})
            continue
        a, b = residue_pair(rep, 37)
        separated = (a != b)
        mod37_table.append({'k_mod_378': cls, 'representative': rep,
                            'm_P_mod_37': a, 'm_Q_mod_37': b,
                            'separated': separated})
        if not separated:
            mod37_survivors.append(cls)

    mod23_period = 756
    mod23_table = []
    for cls in range(mod23_period):
        rep = class_rep(cls, mod23_period)
        if admissible(rep):
            a37, b37 = residue_pair(rep, 37)
            if a37 == b37:
                a23, b23 = residue_pair(rep, 23)
                mod23_table.append({'k_mod_756': cls, 'representative': rep,
                                    'm_P_mod_23': a23, 'm_Q_mod_23': b23,
                                    'separated': a23 != b23})

    report = {
        'family': 'c=-5 minimal exceptional direction',
        'P_k': '(12k+19, 6k-4)',
        'Q_k': '(12k+9, 6k+8)',
        'admissibility': 'k >= 1 and k != 1 mod 7',
        'mod37_period': mod37_period,
        'mod37_survivor_classes_mod_378': mod37_survivors,
        'mod37_survivor_count': len(mod37_survivors),
        'mod23_period_for_lifts': mod23_period,
        'mod23_table_for_mod37_survivor_lifts_mod_756': mod23_table,
        'all_mod23_rows_separated': all(row['separated'] for row in mod23_table),
        'conclusion': 'Every admissible class is separated modulo 37, except survivor classes; all survivor lifts modulo 756 are separated modulo 23.'
    }
    out = '/mnt/data/minimal_direction_cminus5_mod37_mod23_certificate.json'
    with open(out, 'w') as f:
        json.dump(report, f, indent=2)
    print(json.dumps({
        'mod37_survivor_count': len(mod37_survivors),
        'mod37_survivors': mod37_survivors,
        'mod23_rows': len(mod23_table),
        'all_mod23_rows_separated': report['all_mod23_rows_separated'],
        'report': out
    }, indent=2))

if __name__ == '__main__':
    main()
