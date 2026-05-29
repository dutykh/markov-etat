#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Pair-automaton modular certificate framework for Cohn/Christoffel residues.

This is a proof-support tool.  It verifies statements of the following form:

    For every pair of Stern-Brocot paths accepted by a finite constraint DFA,
    the two corresponding Markov residues are NOT equal modulo m.

The Cohn/Stern-Brocot residue automaton works modulo 3m on full Cohn-word
matrices.  If W is the Cohn word for p/q, then tr(M(W)) = 3*m_{p/q}; hence
tr(M(W)) modulo 3m determines m_{p/q} modulo m.

A final exceptional-terminal proof would provide one or several finite
constraint DFAs whose accepted path-pairs cover all remaining exceptional
terminal pairs, each assigned to a modulus that separates the residues.
This script verifies the residue-separation part of such a certificate.
"""
from __future__ import annotations

import argparse
import json
from collections import deque
from dataclasses import dataclass, asdict
from typing import Dict, Iterable, List, Tuple, Set, Optional, Any

Matrix = Tuple[int, int, int, int]
State = Tuple[Matrix, Matrix]
PairSymbol = str  # one of LL, LR, RL, RR

A_INT: Matrix = (2, 1, 1, 1)
B_INT: Matrix = (5, 2, 2, 1)
ALPHABET: Tuple[PairSymbol, ...] = ("LL", "LR", "RL", "RR")


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


def left_transition(state: State, N: int) -> State:
    L, R = state
    M = matmul(L, R, N)
    return (L, M)


def right_transition(state: State, N: int) -> State:
    L, R = state
    M = matmul(L, R, N)
    return (M, R)


def residue_from_state(state: State, markov_modulus: int) -> int:
    N = 3 * markov_modulus
    current = matmul(state[0], state[1], N)
    tr = trace(current, N)
    if tr % 3 != 0:
        raise ArithmeticError(f"trace residue {tr} not divisible by 3 modulo {N}")
    return (tr // 3) % markov_modulus


@dataclass
class SingleResidueAutomaton:
    markov_modulus: int
    matrix_modulus: int
    states: List[State]
    transitions: List[Tuple[int, int]]
    residues: List[int]


def build_single_automaton(markov_modulus: int) -> SingleResidueAutomaton:
    if markov_modulus <= 1:
        raise ValueError("markov_modulus must be > 1")
    N = 3 * markov_modulus
    start: State = (normalize(A_INT, N), normalize(B_INT, N))
    state_id: Dict[State, int] = {start: 0}
    states: List[State] = [start]
    transitions: List[Tuple[int, int]] = []
    q = deque([start])

    while q:
        st = q.popleft()
        sid = state_id[st]
        while len(transitions) <= sid:
            transitions.append((-1, -1))
        for nxt in (left_transition(st, N), right_transition(st, N)):
            if nxt not in state_id:
                state_id[nxt] = len(states)
                states.append(nxt)
                q.append(nxt)
        transitions[sid] = (
            state_id[left_transition(st, N)],
            state_id[right_transition(st, N)],
        )

    residues = [residue_from_state(st, markov_modulus) for st in states]
    return SingleResidueAutomaton(markov_modulus, N, states, transitions, residues)


@dataclass
class ConstraintDFA:
    """A DFA over pair symbols LL, LR, RL, RR."""
    states: List[str]
    start: str
    accepting: Set[str]
    transitions: Dict[Tuple[str, PairSymbol], str]

    @staticmethod
    def from_json(data: Dict[str, Any]) -> "ConstraintDFA":
        states = list(data["states"])
        start = data["start"]
        accepting = set(data["accepting"])
        transitions: Dict[Tuple[str, PairSymbol], str] = {}
        raw = data["transitions"]
        # accepted formats: {state: {symbol: next}} or {"state,symbol": next}
        if all(isinstance(v, dict) for v in raw.values()):
            for st, mp in raw.items():
                for sym, nxt in mp.items():
                    transitions[(st, sym)] = nxt
        else:
            for key, nxt in raw.items():
                st, sym = key.split(",")
                transitions[(st, sym)] = nxt
        for st in states:
            for sym in ALPHABET:
                if (st, sym) not in transitions:
                    raise ValueError(f"missing transition for {st} {sym}")
        return ConstraintDFA(states, start, accepting, transitions)


def pair_step(auto: SingleResidueAutomaton, pair_state: Tuple[int, int], sym: PairSymbol) -> Tuple[int, int]:
    a, b = pair_state
    l1, r1 = auto.transitions[a]
    l2, r2 = auto.transitions[b]
    return ((l1 if sym[0] == "L" else r1), (l2 if sym[1] == "L" else r2))


@dataclass
class VerificationReport:
    markov_modulus: int
    single_states: int
    explored_product_states: int
    accepting_product_states: int
    bad_equal_residue_states: int
    bad_examples: List[Dict[str, Any]]
    status: str


def verify_constraint_dfa(markov_modulus: int, constraint: ConstraintDFA, max_bad_examples: int = 10) -> VerificationReport:
    auto = build_single_automaton(markov_modulus)
    start = (0, 0, constraint.start)  # residue-state ids for path1,path2,constraint state
    seen = {start}
    q = deque([start])
    accepting_count = 0
    bad_count = 0
    bad_examples: List[Dict[str, Any]] = []

    while q:
        s1, s2, cst = q.popleft()
        if cst in constraint.accepting:
            accepting_count += 1
            if auto.residues[s1] == auto.residues[s2]:
                bad_count += 1
                if len(bad_examples) < max_bad_examples:
                    bad_examples.append({
                        "state1": s1,
                        "state2": s2,
                        "constraint_state": cst,
                        "residue": auto.residues[s1],
                    })
        for sym in ALPHABET:
            ns1, ns2 = pair_step(auto, (s1, s2), sym)
            ncst = constraint.transitions[(cst, sym)]
            nxt = (ns1, ns2, ncst)
            if nxt not in seen:
                seen.add(nxt)
                q.append(nxt)

    status = "PASS" if bad_count == 0 else "FAIL"
    return VerificationReport(
        markov_modulus=markov_modulus,
        single_states=len(auto.states),
        explored_product_states=len(seen),
        accepting_product_states=accepting_count,
        bad_equal_residue_states=bad_count,
        bad_examples=bad_examples,
        status=status,
    )


def make_example_constraint_dfa() -> ConstraintDFA:
    """Toy DFA: accepts pairs whose last read symbol is LR.

    This is NOT the exceptional-terminal language.  It is included to test the
    verifier and demonstrate the certificate format.
    """
    states = ["start", "last_LR", "other"]
    trans: Dict[Tuple[str, PairSymbol], str] = {}
    for st in states:
        for sym in ALPHABET:
            trans[(st, sym)] = "last_LR" if sym == "LR" else "other"
    return ConstraintDFA(states, "start", {"last_LR"}, trans)


def save_example_constraint(path: str) -> None:
    dfa = make_example_constraint_dfa()
    data = {
        "states": dfa.states,
        "start": dfa.start,
        "accepting": sorted(dfa.accepting),
        "transitions": {
            st: {sym: dfa.transitions[(st, sym)] for sym in ALPHABET}
            for st in dfa.states
        },
    }
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, sort_keys=True)
        f.write("\n")


def main() -> None:
    parser = argparse.ArgumentParser(description="Verify a pair-path DFA against Cohn residues modulo m")
    parser.add_argument("--modulus", type=int, default=2)
    parser.add_argument("--constraint-json", type=str, default="")
    parser.add_argument("--write-example-constraint", type=str, default="")
    parser.add_argument("--json-out", type=str, default="")
    args = parser.parse_args()

    if args.write_example_constraint:
        save_example_constraint(args.write_example_constraint)
        print(f"wrote example constraint DFA to {args.write_example_constraint}")
        return

    if args.constraint_json:
        with open(args.constraint_json, "r", encoding="utf-8") as f:
            data = json.load(f)
        constraint = ConstraintDFA.from_json(data)
    else:
        constraint = make_example_constraint_dfa()

    report = verify_constraint_dfa(args.modulus, constraint)
    text = json.dumps(asdict(report), indent=2, sort_keys=True)
    print(text)
    if args.json_out:
        with open(args.json_out, "w", encoding="utf-8") as f:
            f.write(text + "\n")


if __name__ == "__main__":
    main()
