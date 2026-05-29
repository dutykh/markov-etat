#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Build bounded finite-language DFA certificates for terminal exceptional pairs.

This is NOT a proof for all terminal exceptional pairs.  It constructs, for a
finite box q<=qmax, r,s<=rmax, a finite family of asynchronous paired-path DFAs,
one for each first separating modulus.  Each DFA accepts exactly the paired
Stern-Brocot encodings of the exceptional pairs in the finite box separated by
that modulus.

The output can be checked with async_pair_certificate_framework.py verify-dfa.
"""
from __future__ import annotations

import argparse, json, math, pathlib, subprocess, sys
from collections import defaultdict
from itertools import zip_longest
from typing import Dict, List, Tuple, Iterable, Any

# Import async framework from same directory.
HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import async_pair_certificate_framework as asyncfw  # type: ignore

ALPHABET = list(asyncfw.PAIR_ALPHABET)


def paired_symbols(path1: str, path2: str) -> List[str]:
    if path1.startswith("END") or path2.startswith("END"):
        raise ValueError("endpoints not supported")
    return [a+b for a,b in zip_longest(path1, path2, fillvalue="_")]


def first_separator(P: Tuple[int,int], Q: Tuple[int,int], moduli: List[int]) -> int | None:
    for m in moduli:
        try:
            if asyncfw.residue_by_path(P[0], P[1], m) != asyncfw.residue_by_path(Q[0], Q[1], m):
                return m
        except Exception:
            return None
    return None


def build_trie_dfa(words: List[List[str]], name: str) -> Dict[str, Any]:
    """Build a deterministic finite acyclic automaton accepting exactly words."""
    transitions: Dict[str, Dict[str,str]] = {"S0": {}}
    accept = set()
    next_id = 1
    for w in words:
        st = "S0"
        for sym in w:
            if sym not in transitions[st]:
                ns = f"S{next_id}"
                next_id += 1
                transitions[st][sym] = ns
                transitions[ns] = {}
            st = transitions[st][sym]
        accept.add(st)
    return {
        "name": name,
        "alphabet": ALPHABET,
        "start": "S0",
        "accept": sorted(accept, key=lambda x: int(x[1:])),
        "transitions": transitions,
        "states": sorted(transitions.keys(), key=lambda x: int(x[1:])),
        "finite_language_size": len(words),
    }


def build(qmax: int, rmax: int, moduli: List[int], outdir: pathlib.Path, verify: bool=False) -> Dict[str, Any]:
    outdir.mkdir(parents=True, exist_ok=True)
    groups: Dict[int, List[List[str]]] = defaultdict(list)
    group_examples: Dict[int, List[Dict[str,Any]]] = defaultdict(list)
    total = 0
    survivors = []
    for P,Q,rs in asyncfw.exceptional_pairs(qmax, rmax):
        total += 1
        sep = first_separator(P,Q,moduli)
        if sep is None:
            if len(survivors) < 50:
                survivors.append({"P": P, "Q": Q, "r_s": rs})
            continue
        pathP = asyncfw.stern_brocot_path(P[0], P[1])
        pathQ = asyncfw.stern_brocot_path(Q[0], Q[1])
        word = paired_symbols(pathP, pathQ)
        groups[sep].append(word)
        if len(group_examples[sep]) < 5:
            group_examples[sep].append({"P":P,"Q":Q,"r_s":rs,"path_P":pathP,"path_Q":pathQ,"word":" ".join(word)})

    dfa_files = []
    verify_reports = []
    for sep, words in sorted(groups.items()):
        dfa = build_trie_dfa(words, f"bounded_exceptional_pairs_first_sep_mod_{sep}")
        f = outdir / f"bounded_exceptional_mod{sep}_q{qmax}_r{rmax}.json"
        with open(f, "w", encoding="utf-8") as fh:
            json.dump(dfa, fh, indent=2, sort_keys=True)
        dfa_files.append({"modulus": sep, "dfa_file": str(f), "words": len(words), "states": len(dfa["states"]), "examples": group_examples[sep]})
        if verify:
            rep_path = outdir / f"verify_mod{sep}_q{qmax}_r{rmax}.json"
            rep = asyncfw.verify_dfa(sep, str(f), max_examples=5)
            with open(rep_path, "w", encoding="utf-8") as fh:
                json.dump(rep, fh, indent=2, sort_keys=True)
            verify_reports.append({"modulus": sep, "report_file": str(rep_path), "status": rep["status"], "accepted_states_reached": rep["accepted_states_reached"], "product_states_reached": rep["product_states_reached"]})
    summary = {
        "qmax": qmax,
        "rmax": rmax,
        "moduli": moduli,
        "total_exceptional_pairs": total,
        "survivors": len(survivors),
        "survivor_examples": survivors,
        "dfa_files": dfa_files,
        "verify_reports": verify_reports,
        "status": "PASS_BOUNDED" if not survivors and all(v.get("status") == "PASS" for v in verify_reports) else "INCOMPLETE_OR_FAIL",
        "note": "This is a bounded finite-language certificate, not a proof for all pairs.",
    }
    summary_file = outdir / f"bounded_exceptional_certificate_summary_q{qmax}_r{rmax}.json"
    with open(summary_file, "w", encoding="utf-8") as fh:
        json.dump(summary, fh, indent=2, sort_keys=True)
    summary["summary_file"] = str(summary_file)
    return summary


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--qmax", type=int, default=80)
    ap.add_argument("--rmax", type=int, default=40)
    ap.add_argument("--moduli", type=str, default="2,3,5,7,11,13,17,19")
    ap.add_argument("--outdir", type=str, default="/mnt/data/bounded_exceptional_certificate")
    ap.add_argument("--verify", action="store_true")
    args = ap.parse_args()
    mods = [int(x) for x in args.moduli.split(',') if x.strip()]
    summary = build(args.qmax, args.rmax, mods, pathlib.Path(args.outdir), verify=args.verify)
    print(json.dumps(summary, indent=2, sort_keys=True))

if __name__ == "__main__":
    main()
