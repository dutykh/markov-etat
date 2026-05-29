#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Asynchronous pair-automaton framework for Cohn/Stern-Brocot residue certificates.

This is infrastructure for a finite-state modular certificate in the exceptional
terminal-core problem.  It does not by itself prove the exceptional case: it
verifies candidate regular constraints over paired Stern-Brocot encodings.

Alphabet for paired paths:
  LL, LR, RL, RR : advance both paths
  L_, R_         : advance left path only
  _L, _R         : advance right path only

The Cohn interval state is a pair of 2x2 matrices (L,R) modulo 3*m.  The
current mediant word has matrix L*R, whose trace is 3 times the Markov number.
"""
from __future__ import annotations

import argparse
import json
import math
from collections import deque, Counter
from itertools import zip_longest
from typing import Dict, Iterable, List, Tuple, Optional, Set, Any

Mat = Tuple[int, int, int, int]
CohnState = Tuple[Mat, Mat]
AsyncState = Tuple[int, int, str]

A0: Mat = (2, 1, 1, 1)
B0: Mat = (5, 2, 2, 1)
PAIR_ALPHABET = ("LL", "LR", "RL", "RR", "L_", "R_", "_L", "_R")
SINGLE_ALPHABET = ("L", "R")


def mat_mul(X: Mat, Y: Mat, mod: int) -> Mat:
    a, b, c, d = X
    e, f, g, h = Y
    return ((a * e + b * g) % mod,
            (a * f + b * h) % mod,
            (c * e + d * g) % mod,
            (c * f + d * h) % mod)


def mat_trace(X: Mat) -> int:
    return X[0] + X[3]


def cohn_step(st: CohnState, letter: str, mod: int) -> CohnState:
    L, R = st
    M = mat_mul(L, R, mod)
    if letter == "L":
        return (L, M)
    if letter == "R":
        return (M, R)
    raise ValueError(f"bad single letter {letter!r}")


def cohn_start(mod: int) -> CohnState:
    return (tuple(x % mod for x in A0), tuple(x % mod for x in B0))  # type: ignore


def markov_residue_from_state(st: CohnState, m: int) -> int:
    """Return m_{p/q} mod m from a Cohn interval state.

    The current mediant matrix is L*R modulo 3*m.
    """
    mod = 3 * m
    L, R = st
    M = mat_mul(L, R, mod)
    tr = mat_trace(M) % mod
    if tr % 3 != 0:
        raise ArithmeticError(f"trace {tr} not divisible by 3 modulo {mod}")
    return (tr // 3) % m


def all_cohn_states(m: int) -> Tuple[List[CohnState], Dict[CohnState, int], Dict[Tuple[int, str], int], List[int]]:
    """Enumerate reachable Cohn states modulo 3*m."""
    mod = 3 * m
    start = cohn_start(mod)
    states: List[CohnState] = []
    index: Dict[CohnState, int] = {}
    trans: Dict[Tuple[int, str], int] = {}
    residues: List[int] = []
    q = deque([start])
    index[start] = 0
    while q:
        st = q.popleft()
        i = index[st]
        if i == len(states):
            states.append(st)
            residues.append(markov_residue_from_state(st, m))
        for letter in SINGLE_ALPHABET:
            ns = cohn_step(st, letter, mod)
            if ns not in index:
                index[ns] = len(index)
                q.append(ns)
            trans[(i, letter)] = index[ns]
    return states, index, trans, residues


def load_dfa(path: str) -> Dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        dfa = json.load(f)
    required = {"alphabet", "start", "accept", "transitions"}
    missing = required - set(dfa)
    if missing:
        raise ValueError(f"DFA missing fields {missing}")
    if set(dfa["alphabet"]) - set(PAIR_ALPHABET):
        raise ValueError("DFA alphabet contains symbols outside pair alphabet")
    return dfa


def verify_dfa(m: int, dfa_path: str, max_examples: int = 10) -> Dict[str, Any]:
    """Explore product of two Cohn automata with an external DFA.

    PASS means: no reachable accepting product state has equal residues modulo m.
    This is a certificate for the language represented by the external DFA.
    """
    states, index, trans1, residues = all_cohn_states(m)
    dfa = load_dfa(dfa_path)
    alphabet = tuple(dfa["alphabet"])
    dfa_trans = dfa["transitions"]
    accept = set(dfa["accept"])
    start_dfa = dfa["start"]
    n = len(states)
    start = (0, 0, start_dfa)
    seen: Set[AsyncState] = {start}
    q = deque([start])
    equal_accepts: List[Dict[str, Any]] = []
    accepted = 0
    edges = 0
    while q:
        li, ri, ds = q.popleft()
        if ds in accept:
            accepted += 1
            if residues[li] == residues[ri]:
                if len(equal_accepts) < max_examples:
                    equal_accepts.append({
                        "left_state": li,
                        "right_state": ri,
                        "dfa_state": ds,
                        "residue": residues[li],
                    })
        for sym in alphabet:
            if ds not in dfa_trans or sym not in dfa_trans[ds]:
                continue
            nds = dfa_trans[ds][sym]
            lchar, rchar = sym[0], sym[1]
            nli = li if lchar == "_" else trans1[(li, lchar)]
            nri = ri if rchar == "_" else trans1[(ri, rchar)]
            ns = (nli, nri, nds)
            edges += 1
            if ns not in seen:
                seen.add(ns)
                q.append(ns)
    return {
        "modulus": m,
        "cohn_states": n,
        "product_states_reached": len(seen),
        "product_edges_scanned": edges,
        "accepted_states_reached": accepted,
        "equal_residue_accepting_states": len(equal_accepts),
        "status": "PASS" if not equal_accepts else "FAIL",
        "examples": equal_accepts,
        "dfa_path": dfa_path,
    }


def stern_brocot_path(q: int, p: int) -> str:
    """Canonical L/R path whose current mediant is p/q in [0,1].

    Starts with endpoints 0/1 and 1/1. Empty path represents 1/2.
    """
    if q <= 0 or p < 0 or p > q or math.gcd(q, p) != 1:
        raise ValueError("expected primitive 0 <= p <= q, q > 0")
    if p == 0:
        # Endpoint; not represented as finite mediant in the open Stern-Brocot tree.
        return "END0"
    if p == q:
        return "END1"
    lo_p, lo_q = 0, 1
    hi_p, hi_q = 1, 1
    out: List[str] = []
    while True:
        mp, mq = lo_p + hi_p, lo_q + hi_q
        if mp == p and mq == q:
            return "".join(out)
        # Compare p/q with mp/mq.
        if p * mq < mp * q:
            hi_p, hi_q = mp, mq
            out.append("L")
        else:
            lo_p, lo_q = mp, mq
            out.append("R")


def padded_pair_word(path1: str, path2: str) -> str:
    if path1.startswith("END") or path2.startswith("END"):
        raise ValueError("endpoints not supported in paired word")
    syms = []
    for a, b in zip_longest(path1, path2, fillvalue="_"):
        syms.append(a + b)
    return " ".join(syms)


def residue_by_path(q: int, p: int, m: int) -> int:
    path = stern_brocot_path(q, p)
    if path.startswith("END"):
        raise ValueError("endpoint residue not supported")
    mod = 3 * m
    st = cohn_start(mod)
    for ch in path:
        st = cohn_step(st, ch, mod)
    return markov_residue_from_state(st, m)


def exceptional_pairs(qmax: int, rmax: int) -> Iterable[Tuple[Tuple[int,int], Tuple[int,int], Tuple[int,int]]]:
    """Generate primitive terminal exceptional pairs in a finite box.

    Returns ((q,p), (q2,p2), (r,s)).
    """
    for r in range(2, rmax + 1):
        # r < s, 9/5 < s/r < 15/8 means 9r < 5s and 8s < 15r.
        for s in range(r + 1, rmax + 1):
            if not (9 * r < 5 * s and 8 * s < 15 * r):
                continue
            if math.gcd(r, s) <= 1:
                continue
            dq = r - s
            dp = r
            for q in range(2, qmax + 1):
                q2 = q + dq
                if q2 <= 1 or q2 > qmax:
                    continue
                p_min = max(1, -dp + 1)
                p_max = min(q - 1, q2 - dp - 1)
                for p in range(p_min, p_max + 1):
                    p2 = p + dp
                    if 0 < p2 < q2 and math.gcd(q, p) == 1 and math.gcd(q2, p2) == 1:
                        yield (q, p), (q2, p2), (r, s)


def sample_pairs(qmax: int, rmax: int, moduli: List[int], limit: int) -> Dict[str, Any]:
    first_sep = Counter()
    survivors = []
    total = 0
    examples = []
    for P, Q, rs in exceptional_pairs(qmax, rmax):
        total += 1
        sep = None
        for m in moduli:
            if residue_by_path(P[0], P[1], m) != residue_by_path(Q[0], Q[1], m):
                sep = m
                break
        if sep is None:
            if len(survivors) < limit:
                survivors.append({"P": P, "Q": Q, "r_s": rs})
        else:
            first_sep[sep] += 1
        if len(examples) < limit:
            try:
                examples.append({
                    "P": P,
                    "Q": Q,
                    "r_s": rs,
                    "path_P": stern_brocot_path(P[0], P[1]),
                    "path_Q": stern_brocot_path(Q[0], Q[1]),
                    "paired_word": padded_pair_word(stern_brocot_path(P[0], P[1]), stern_brocot_path(Q[0], Q[1])),
                    "first_separator": sep,
                })
            except Exception:
                pass
    return {
        "qmax": qmax,
        "rmax": rmax,
        "moduli": moduli,
        "total_pairs": total,
        "survivor_count_recorded": len(survivors),
        "survivors_recorded": survivors,
        "first_separator_counts": dict(first_sep),
        "examples": examples,
    }


def make_toy_dfa(path: str) -> None:
    """A toy DFA accepting words that contain at least one asynchronous padding symbol.

    This is only a format/demo DFA. It is deliberately broad and usually fails.
    """
    alphabet = list(PAIR_ALPHABET)
    trans = {"S": {}, "A": {}}
    for sym in alphabet:
        if "_" in sym:
            trans["S"][sym] = "A"
        else:
            trans["S"][sym] = "S"
        trans["A"][sym] = "A"
    dfa = {"alphabet": alphabet, "start": "S", "accept": ["A"], "transitions": trans}
    with open(path, "w", encoding="utf-8") as f:
        json.dump(dfa, f, indent=2, sort_keys=True)


def main() -> None:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("verify-dfa")
    p.add_argument("--modulus", type=int, required=True)
    p.add_argument("--dfa", required=True)
    p.add_argument("--out", required=True)
    p.add_argument("--max-examples", type=int, default=10)

    p = sub.add_parser("sample")
    p.add_argument("--qmax", type=int, default=100)
    p.add_argument("--rmax", type=int, default=50)
    p.add_argument("--moduli", nargs="+", type=int, default=[2,3,5,7,11,13,17,19])
    p.add_argument("--out", required=True)
    p.add_argument("--limit", type=int, default=10)

    p = sub.add_parser("make-toy-dfa")
    p.add_argument("--out", required=True)

    args = ap.parse_args()
    if args.cmd == "verify-dfa":
        rep = verify_dfa(args.modulus, args.dfa, args.max_examples)
        with open(args.out, "w", encoding="utf-8") as f:
            json.dump(rep, f, indent=2, sort_keys=True)
    elif args.cmd == "sample":
        rep = sample_pairs(args.qmax, args.rmax, args.moduli, args.limit)
        with open(args.out, "w", encoding="utf-8") as f:
            json.dump(rep, f, indent=2, sort_keys=True)
    elif args.cmd == "make-toy-dfa":
        make_toy_dfa(args.out)


if __name__ == "__main__":
    main()
