# Computational supplement for *A Cohn-tree reduction of the Frobenius–Markov uniqueness conjecture*

**Authors of the manuscript:** Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE) and Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France).

This directory contains the Python, Magma, and Sage scripts that
accompany the manuscript. Two layers should be distinguished:

- The **exploratory** scripts at the top level of `code/` (with their
  outputs in `code/outputs/`) underlie Appendix D ("Computational
  checks and reproducibility notes"). None of these computations
  proves the Exceptional Terminal Arithmetic Theorem (ETAT); they
  support the reduction, test conjectural subclaims, and document
  false proof strategies.
- The **proof-certificate** package at `code/minimal_direction_g2/`
  underlies Chapter 16 and Appendix E. Unlike the Appendix-D scripts,
  the certificates in that subdirectory are *proof components*: their
  finite residue tables, primitivity exclusions, matrix-order
  congruences, and symbolic positive margin are used in the formal
  proof of the minimal exceptional direction theorem.

## Folder layout

```
code/
├── README.md                                       — this file
├── async_pair_certificate_framework.py             — product BFS over paired Cohn states × external DFA
├── bounded_exceptional_dfa_builder.py              — builds a trie DFA from a finite sample of pairs
├── cohn_stern_brocot_automaton.py                  — Cohn/SB residue automaton modulo 3m
├── exceptional_certificate_builder.py              — certificate search driver for small windows
├── exceptional_modular_sieve.py                    — modular sieve over small primes
├── exceptional_modular_sieve_fast.py               — faster variant of the modular sieve
├── finite_moduli_escape.py                         — explicit escape family (P_T, Q_T) for §12
├── fixed_arm_family_analyzer.py                    — verifies linear recurrences for fixed-arm families
├── one_turn_fixed_arm_sanity_check.py              — recurrence sanity check + finite-box search
├── one_turn_fixed_arm_certificate.magma            — proposed Magma integral-points certificate
├── one_turn_fixed_arm_certificate.sage             — proposed Sage integral-points certificate
├── pair_automaton_certificate_framework.py         — synchronous paired-DFA framework (deprecated)
├── terminal_exceptional_register_automaton.py      — register semantics for terminal exceptional words
├── minimal_direction_g2/                           — Chapter 16 / Appendix E proof-certificate package
│   ├── README.md                                   — package documentation, run instructions, file index
│   ├── minimal_direction_g2_certificate.py         — master aggregate verifier (PASS / FAIL output)
│   ├── minimal_direction_g2_certificate.json       — aggregate JSON: matrix orders, family summary, central margin, SHA-256 hashes
│   ├── minimal_direction_c*_certificate.py         — 17 individual c-family verifiers (16 non-central + 1 central c=5)
│   └── minimal_direction_c*_certificate.json       — 17 individual JSON certificates (residue tables, periods, survivor classes)
└── outputs/                                        — JSON outputs and the bounded-DFA archive (Appendix D, exploratory)
    ├── async_sample_report_80_40.json
    ├── bounded_exceptional_certificate_80_40.zip
    ├── bounded_exceptional_certificate_summary_q80_r40.json
    ├── certificate_search_report_250_100.json
    ├── certificate_search_report_250_100_primes47.json
    ├── cohn_automaton_mod5.json
    ├── cohn_automaton_mod17.json
    ├── cohn_automaton_state_summary.json
    ├── example_async_padding_dfa.json
    ├── example_async_verify_mod2.json
    ├── finite_moduli_escape_primes19.json
    ├── finite_moduli_escape_primes47.json
    ├── fixed_arm_family_report.json
    ├── one_turn_fixed_arm_sanity_output.json
    ├── terminal_param_scan_80_80_60_60_primes19.json
    └── terminal_register_scan_120_60_primes19.json
```

## Conventions used in all scripts

All scripts use the Cohn matrices

    A = [[2, 1], [1, 1]],     B = [[5, 2], [2, 1]],

and compute the Markov number associated to a primitive lattice point
`(q, p)` via the central Christoffel word `z_{p/q}` (the lower
Christoffel word with the leading `A` and trailing `B` stripped), using

    m_{p/q} = a^T M(z_{p/q}) a,    a = (2, 1)^T.

Modular computations work modulo `3 m` on full Cohn-word matrices,
because `tr(M(W_{p/q})) = 3 m_{p/q}`. The Markov residue modulo `m` is
recovered from the trace residue modulo `3 m` by exact division by 3.

## Roles and canonical invocations

### 1. Sanity checks for the word/trace conventions

```
python3 one_turn_fixed_arm_sanity_check.py
```

Verifies the affine recurrence
`X_{n+1} = 7 X_n − X_{n−1} − 4` for `X_n = (3 L_{4n+12} + 4) / 5` and
the homogeneous recurrence `Y_{m+1} = 6 Y_m − Y_{m−1}` for
`Y_m = Pe_{2m+3}`, and searches for hits in a box `n ≤ 300, m ≤ 350`.
Expected output: **no hits**, plus two Pellian-system hits at
`y = 5, 29` (both outside `n ≥ 0`).

### 2. Cohn–Stern–Brocot residue automaton

```
python3 cohn_stern_brocot_automaton.py --modulus 5 --json-out outputs/cohn_automaton_mod5.json
python3 cohn_stern_brocot_automaton.py --modulus 17 --json-out outputs/cohn_automaton_mod17.json
```

Builds the deterministic finite automaton whose state is a pair
`(L, R)` of `SL₂(ℤ/3mℤ)` matrices, with transitions
`L: (L, R) → (L, LR)` and `R: (L, R) → (LR, R)`. Reports the reachable
state count and the residue histogram at the current mediant.

### 3. Modular sieve for terminal exceptional pairs

```
python3 exceptional_modular_sieve.py --qmax 100 --rmax 50 --moduli 2,3,5,7,11,13,17
```

Scans primitive terminal exceptional pairs in a finite window and
reports any pair surviving the small-prime sieve. The faster variant
(`exceptional_modular_sieve_fast.py`) uses the same logic with cached
residues.

### 4. Asynchronous pair / register automata

```
python3 async_pair_certificate_framework.py sample --qmax 80 --rmax 40 \
    --moduli 2 3 5 7 11 13 17 19 \
    --out outputs/async_sample_report_80_40.json
python3 terminal_exceptional_register_automaton.py scan \
    --qmax 120 --rmax 60 --moduli 2 3 5 7 11 13 17 19 \
    --out outputs/terminal_register_scan_120_60_primes19.json
```

The asynchronous framework uses the alphabet
`LL, LR, RL, RR, L_, R_, _L, _R` to encode paired Stern-Brocot paths
of possibly different lengths. The register automaton additionally
carries the exact lattice coordinates `(q, p), (q', p')` so that the
terminal exceptional conditions `4r < 5h`, `8h < 7r`, `gcd(r, h) > 1`
can be checked exactly. Running the register scan with
`qmax = 120, rmax = 60` checks 6585 primitive terminal exceptional
pairs and leaves no survivors — a regression test against the small
primes, not a proof.

### 5. The modular escape family `(P_T, Q_T)`

```
python3 finite_moduli_escape.py --moduli 2 3 5 7 11 13 17 19 \
    --out outputs/finite_moduli_escape_primes19.json
```

Computes the lcm `T` of the unary `L`- and `R`-periods of the Cohn
automaton modulo each modulus, then constructs
`P_T = (13 T + 2, 1)` (along the `L`-arm) and
`Q_T = (7 T + 2, 7 T + 1)` (along the `R`-arm). The terminal
parameters are `r = 7 T`, `h = 6 T`, `s = 13 T`, with
`s / r = 13 / 7 ∈ (9 / 5, 15 / 8)`, `gcd(r, h) = T > 1`. The script
verifies that the Markov residues of `P_T` and `Q_T` are equal modulo
every modulus in the input set. This is the empirical witness for the
no-fixed-finite-modulus theorem in §12 of the manuscript.

### 6. Fixed-arm recurrence hierarchy

```
python3 fixed_arm_family_analyzer.py --kmax 6 --ncount 24 --out outputs/fixed_arm_family_report.json
```

For each `k = 1, …, 6`, computes the Markov sequence
`X_n(k) = m_{path(L^{n+1} R^k)}` and uses rational Gaussian
elimination to guess and verify a linear recurrence in `n`. Empirical
output (verified for `k ≤ 6`):

| k | type        | order | coefficient list (palindromic) |
|---|-------------|-------|--------------------------------|
| 1 | affine      | 2     | −4, 7, −1                      |
| 2 | homogeneous | 4     | 21, −56, 21, −1                |
| 3 | affine      | 4     | 792, 54, −331, 54, −1          |
| 4 | homogeneous | 6     | 144, −2640, 6930, −2640, 144, −1 |
| 5 | affine      | 6     | −1094400, 376, −17720, 106690, −17720, 376, −1 |
| 6 | homogeneous | 8     | 987, −124033, 2232594, −5847270, 2232594, −124033, 987, −1 |

Order = 2k + 2, with parity-alternating affine/homogeneous and
palindromic coefficient lists. This is an empirical observation,
verified for `k ≤ 6`; we have not proved the pattern in general.

### 7. The one-turn Pellian certificate (proposed, not executed)

```
magma one_turn_fixed_arm_certificate.magma
sage  one_turn_fixed_arm_certificate.sage
```

The one-turn fixed-arm equality
`m_{2 / (2 n + 5)} = m_{(m + 1) / (m + 2)}` reduces to
`3 L_{4 n + 12} + 4 = 5 Pe_{2 m + 3}`, which on setting
`y = Pe_{2 m + 3}` becomes the simultaneous Pellian system

    u² − 2 y² = −1,
    5 y² − 8 y − 9 v² = 4,

with `w = (5 y − 4) / 3 = L_{4 n + 12}` and `v = F_{4 n + 12}`. The
Magma and Sage scripts ask their respective integral-points routines
to enumerate the solutions on this affine genus-one curve. The
expected positive `y`-values are `y = 5, 29`, corresponding to
`w = 7, 47 = L_4, L_8`, hence to `n = −2, −1` — outside the required
range `n ≥ 0`.

**These scripts have not been executed in the manuscript's working
environment.** They are a proposed verification module and are
described in Appendix D §D.6 as such.

### 8. Bounded DFA certificates

```
python3 bounded_exceptional_dfa_builder.py --qmax 80 --rmax 40 ...
```

Converts a bounded sample of terminal exceptional pairs into a finite
trie DFA, grouped by first separating modulus. The archive
`outputs/bounded_exceptional_certificate_80_40.zip` contains the
trie data for the window `q ≤ 80, r ≤ 40`. Bounded certificates are
useful regression tests; they do not prove the infinite theorem.

## What the computations do and do not prove

The computations in this directory:

* check that the word and matrix conventions used in the manuscript
  agree on small inputs;
* furnish reproducible empirical evidence for conjectural sub-claims
  (the recurrence-order hierarchy, the absence of small-modulus
  surprises in finite windows);
* expose false proof strategies (synchronous pair automata over
  Stern-Brocot symbols cannot work — the exact terminal language is
  not regular; no fixed finite set of moduli can solve the
  exceptional terminal problem — proved as a theorem in §12);
* provide regression tests against future certificate constructions.

They do **not** prove the Exceptional Terminal Arithmetic Theorem,
Markov uniqueness, or any of the external ordering theorems cited in
Appendix C.

## Reproducibility

Scripts are pure Python 3 (no third-party dependencies). The Magma and
Sage scripts require their respective installations; they are not
executed by `make` or by the typesetting toolchain.
