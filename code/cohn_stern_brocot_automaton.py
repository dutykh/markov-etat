#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Finite-state Cohn/Stern-Brocot residue automaton.

This is a proof-support tool, not the final Markov uniqueness proof.

For a requested modulus m for Markov numbers, the script works modulo 3m
on full Cohn-word matrices.  If W_{p/q} is the lower Christoffel/Cohn word,
then tr(M(W_{p/q})) = 3 m_{p/q}.  Therefore tr(M(W)) modulo 3m determines
m_{p/q} modulo m by exact division by 3.

The Stern-Brocot interval state is a pair (L,R) of Cohn-word matrices for
adjacent endpoints.  The current mediant word has matrix L*R.  The two
Stern-Brocot transitions are
    left:  (L,R) -> (L,L R)
    right: (L,R) -> (L R,R).
This is a deterministic finite automaton modulo 3m.
"""
from __future__ import annotations

import argparse
import json
from collections import deque
from dataclasses import dataclass, asdict
from math import gcd
from typing import Dict, List, Tuple

Matrix = Tuple[int, int, int, int]
State = Tuple[Matrix, Matrix]

A_INT: Matrix = (2, 1, 1, 1)
B_INT: Matrix = (5, 2, 2, 1)


def matmul(X: Matrix, Y: Matrix, N: int) -> Matrix:
    return (
        (X[0] * Y[0] + X[1] * Y[2]) % N,
        (X[0] * Y[1] + X[1] * Y[3]) % N,
        (X[2] * Y[0] + X[3] * Y[2]) % N,
        (X[2] * Y[1] + X[3] * Y[3]) % N,
    )


def trace(X: Matrix, N: int) -> int:
    return (X[0] + X[3]) % N


def normalize(M: Matrix, N: int) -> Matrix:
    return tuple(x % N for x in M)  # type: ignore[return-value]


def markov_residue_from_state(state: State, markov_modulus: int) -> int:
    """Output m_current mod markov_modulus from state (L,R)."""
    N = 3 * markov_modulus
    current = matmul(state[0], state[1], N)
    tr = trace(current, N)
    # The exact trace is a multiple of 3, and its residue modulo 3m is one
    # of 0,3,6,...,3m-3.  Numerical residue should therefore be divisible by 3.
    if tr % 3 != 0:
        raise ArithmeticError(f"Trace residue {tr} not divisible by 3 modulo {N}")
    return (tr // 3) % markov_modulus


def left_transition(state: State, N: int) -> State:
    L, R = state
    M = matmul(L, R, N)
    return (L, M)


def right_transition(state: State, N: int) -> State:
    L, R = state
    M = matmul(L, R, N)
    return (M, R)


@dataclass
class AutomatonReport:
    markov_modulus: int
    matrix_modulus: int
    reachable_states: int
    residue_histogram: Dict[int, int]
    start_residue: int
    sample_transitions: List[Tuple[int, int, int, int]]
    # entries: state_id, left_id, right_id, residue


def build_automaton(markov_modulus: int, transition_sample_limit: int = 20) -> Tuple[AutomatonReport, Dict[State, int], List[Tuple[int, int]]]:
    if markov_modulus <= 1:
        raise ValueError("markov_modulus must be > 1")
    N = 3 * markov_modulus
    start: State = (normalize(A_INT, N), normalize(B_INT, N))
    state_id: Dict[State, int] = {start: 0}
    transitions: List[Tuple[int, int]] = []
    q = deque([start])
    residues: Dict[int, int] = {}

    while q:
        st = q.popleft()
        sid = state_id[st]
        # Ensure transitions list is aligned with ids.
        while len(transitions) <= sid:
            transitions.append((-1, -1))
        lstate = left_transition(st, N)
        rstate = right_transition(st, N)
        for nxt in (lstate, rstate):
            if nxt not in state_id:
                state_id[nxt] = len(state_id)
                q.append(nxt)
        transitions[sid] = (state_id[lstate], state_id[rstate])
        res = markov_residue_from_state(st, markov_modulus)
        residues[res] = residues.get(res, 0) + 1

    sample: List[Tuple[int, int, int, int]] = []
    for sid, (l_id, r_id) in enumerate(transitions[:transition_sample_limit]):
        # Need state by id for residue.
        pass
    id_to_state = [None] * len(state_id)  # type: ignore[var-annotated]
    for st, sid in state_id.items():
        id_to_state[sid] = st
    sample = [
        (sid, transitions[sid][0], transitions[sid][1], markov_residue_from_state(id_to_state[sid], markov_modulus))
        for sid in range(min(transition_sample_limit, len(transitions)))
    ]

    report = AutomatonReport(
        markov_modulus=markov_modulus,
        matrix_modulus=N,
        reachable_states=len(state_id),
        residue_histogram=dict(sorted(residues.items())),
        start_residue=markov_residue_from_state(start, markov_modulus),
        sample_transitions=sample,
    )
    return report, state_id, transitions


def main() -> None:
    parser = argparse.ArgumentParser(description="Build Cohn/Stern-Brocot residue DFA modulo m")
    parser.add_argument("--modulus", type=int, default=5, help="modulus for Markov numbers")
    parser.add_argument("--json-out", type=str, default="")
    args = parser.parse_args()

    report, _states, _transitions = build_automaton(args.modulus)
    text = json.dumps(asdict(report), indent=2, sort_keys=True)
    print(text)
    if args.json_out:
        with open(args.json_out, "w", encoding="utf-8") as f:
            f.write(text + "\n")


if __name__ == "__main__":
    main()
