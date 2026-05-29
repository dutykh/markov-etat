#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Sanity checker for the one-turn fixed-arm problem.

This is NOT the final proof. It verifies the formulae and searches for
solutions of
    3*L_{4n+12} + 4 = 5*Pell_{2m+3}
in a large finite box. The proof certificate is supplied separately as
Sage/Magma scripts using integral points on the associated genus-one curve.
"""
from math import isqrt


def lucas_numbers(N):
    L = [0]*(N+1)
    if N >= 0: L[0] = 2
    if N >= 1: L[1] = 1
    for i in range(1, N):
        L[i+1] = L[i] + L[i-1]
    return L


def pell_numbers(N):
    P = [0]*(N+1)
    if N >= 1: P[1] = 1
    for i in range(1, N):
        P[i+1] = 2*P[i] + P[i-1]
    return P


def X(n, L):
    return (3*L[4*n+12] + 4)//5


def Y(m, P):
    return P[2*m+3]


def main(Nn=300, Nm=350):
    L = lucas_numbers(4*Nn + 20)
    P = pell_numbers(2*Nm + 20)

    # Verify integrality and recurrence for X.
    xs = [X(n, L) for n in range(Nn+1)]
    assert xs[0] == 194 and xs[1] == 1325
    for n in range(1, Nn):
        assert xs[n+1] == 7*xs[n] - xs[n-1] - 4

    # Verify Y recurrence.
    ys = [Y(m, P) for m in range(Nm+1)]
    assert ys[0] == 5 and ys[1] == 29
    for m in range(1, Nm):
        assert ys[m+1] == 6*ys[m] - ys[m-1]

    hits = []
    setY = {y:m for m,y in enumerate(ys)}
    for n,x in enumerate(xs):
        if x in setY:
            hits.append((n,setY[x],x))
    print({
        "checked_n_le": Nn,
        "checked_m_le": Nm,
        "hits": hits,
        "X0_X1": xs[:2],
        "Y0_Y1": ys[:2],
    })

    # Check Pellian system for odd Pell y up to bound.
    pell_hits = []
    for M in range(1, 2*Nm+4, 2):
        y = P[M]
        val = 5*y*y - 8*y - 4
        if val % 9 == 0:
            v2 = val//9
            v = isqrt(v2)
            if v*v == v2:
                pell_hits.append((M,y,v,(5*y-4)//3 if (5*y-4)%3==0 else None))
    print({"pellian_hits_odd_index_le": 2*Nm+3, "hits": pell_hits[:10], "num_hits": len(pell_hits)})

if __name__ == "__main__":
    main()
