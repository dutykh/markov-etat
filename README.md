<!-- Author: Dr. Denys Dutykh (Mathematics Department, Khalifa University of Science and Technology, Abu Dhabi, UAE) -->

# markov-etat: a Cohn-tree reduction of the Frobenius–Markov uniqueness conjecture

This repository accompanies the monograph *A Cohn-tree reduction of the Frobenius–Markov uniqueness conjecture* by
Denys Dutykh and Laurent Vuillon (submitted, 2026). It holds the Typst source of the monograph with its PDF,
[`manuscript/DD-LV-Markov.pdf`](manuscript/DD-LV-Markov.pdf), and all the code that accompanies it: the exploratory
scripts of Appendix D, and the exact arithmetic checks of Chapter 16 and Appendix E, which are part of the proof of
the minimal exceptional case and can be re-run and read line by line. Everything runs with the Python standard
library alone, in the interest of reproducible research.

## Abstract

> We study the Frobenius–Markov uniqueness conjecture through the Cohn-tree trace formulation. Using Cohn words,
> Farey cones, and trace recurrences, we prove same-ray monotonicity, dominance exclusion, Vieta gluing, and shifted
> boundary separation. We then show that any unresolved return-reduced cross-ray collision reduces to a terminal
> comparison in the standard Farey cone. Known monotonicity theorems for Markov and generalized Markov numbers
> exclude all non-exceptional terminal slopes and the primitive-step exceptional case. The remaining obstruction is an
> explicit terminal arithmetic problem in the exceptional slope window. We also prove that no fixed finite modular
> sieve can settle this terminal problem, and we isolate endpoint escape families by Fibonacci–Pell intersection.
> Thus Markov uniqueness is reduced to the *Exceptional Terminal Arithmetic Theorem*. As a first concrete step beyond
> this conditional reduction, we further prove the Exceptional Terminal Arithmetic Theorem in the minimal primitive
> exceptional direction `(R, H) = (6, 5)` at multiplier `g = 2`, i.e. for `(r, h) = (12, 10)`, the first solved case
> inside the genuinely exceptional non-primitive terminal region. The full Exceptional Terminal Arithmetic Theorem
> remains open.

**Keywords.** Frobenius–Markov uniqueness conjecture; Markov numbers; Cohn tree; Cohn words; Farey cones; trace
recurrences; monotonicity; Vieta gluing; Fibonacci–Pell intersection.

## What the result is

The Markov equation

```text
x² + y² + z² = 3xyz
```

has positive-integer solutions, the Markov triples, organised on an infinite binary tree. The largest entry of a
triple is a Markov number (1, 2, 5, 13, 29, 34, 89, ...). Frobenius's century-old uniqueness conjecture asks whether
each Markov number occurs as the maximum of exactly one triple.

This monograph does not prove the conjecture; it reduces it. Working inside the Cohn-tree trace formulation, where
each node of the tree is a Cohn matrix and the Markov number is one third of its trace, the book establishes a chain
of unconditional structural results: the same-ray monotonicity of Cohn traces along a one-sided ray, dominance
exclusion by line monotonicity in a Farey cone, boundary ratio monotonicity through a discrete Wronskian, the Vieta
gluing of divided boundary trace sequences, shifted boundary separation across adjacent Farey cones, and the
Euclidean recoding of mixed comparisons down to a terminal comparison in the standard Farey cone.

Classical monotonicity theorems (Aigner, the slope-ordering results, and Huang's valley theorem for generalised Markov
numbers) then dispatch every non-exceptional terminal slope and the primitive-step exceptional case. What is left is
a single, sharply isolated arithmetic statement, the Exceptional Terminal Arithmetic Theorem (ETAT): no two distinct
return-reduced terminal pairs in the exceptional slope window can share a Cohn trace.

The book shows that the obstruction is genuinely arithmetic. No fixed finite modular sieve can settle it, since an
explicit modular escape family `(P_T, Q_T)` defeats any finite set of moduli, and the exact terminal language is not
regular, so no single finite automaton over the Stern–Brocot alphabet can recognise it. Endpoint-to-endpoint escape
families are nonetheless shown to be harmless, through the Fibonacci–Pell intersection theorem.

Finally, as a first concrete crossing of the exceptional frontier, the book proves the ETAT in its minimal
exceptional direction `(R, H) = (6, 5)` at the first nonprimitive multiplier `g = 2`, that is for
`(r, h) = (12, 10)`. After the reductions of Chapter 16, an equality is confined to seventeen one-parameter families
of terminal pairs, one for each odd `c` between −11 and 21:

```text
P_k = (12k + c + 24, 6k + c + 1),     Q_k = (12k + c + 14, 6k + c + 13),     c odd,  −11 ⩽ c ⩽ 21.
```

Sixteen of these families are eliminated by finite congruence certificates against the primes 5, 23, 37 and 47, and
the central family `c = 5` by a reduction modulo 37 followed by a symbolic trace-positivity inequality. These checks
use exact integer arithmetic only, and they live in this repository (see below).

**Status.** Markov uniqueness is reduced to the ETAT; the ETAT is proved in the minimal exceptional case; the full
ETAT remains open.

## Contents

```
markov-etat/
├── README.md                      ← you are here
├── LICENSE                        ← GNU LGPL v2.1
├── CITATION.cff                   ← how to cite this work
├── requirements.txt               ← dependency notes (Python standard library only)
├── manuscript/                    ← manuscript source (Typst)
│   ├── DD-LV-Markov.typ           ← the monograph (source)
│   ├── DD-LV-Markov.pdf           ← the monograph (built PDF)
│   ├── refs.bib                   ← bibliography
│   └── Makefile                   ← `make` → DD-LV-Markov.pdf
└── code/                          ← all accompanying code
    ├── README.md                  ← documentation of every script
    ├── *.py / *.sage / *.magma    ← exploratory scripts (Appendix D)
    ├── outputs/                   ← JSON outputs and the bounded-DFA archive
    └── minimal_direction_g2/      ← exact checks of the minimal direction (Chapter 16 / Appendix E)
        ├── README.md              ← documentation of the checks
        ├── minimal_direction_g2_certificate.py    ← master check (PASS/FAIL)
        ├── minimal_direction_g2_certificate.json  ← aggregate record
        └── minimal_direction_c*_certificate.{py,json}  ← 17 per-family checks and their reports
```

The two READMEs inside `code/` document each script, its role, its canonical invocation and its expected output:
[`code/README.md`](code/README.md) for the exploratory layer (Appendix D), and
[`code/minimal_direction_g2/README.md`](code/minimal_direction_g2/README.md) for the exact checks of Chapter 16 and
Appendix E.

## How the code maps to the manuscript

There are two distinct layers, and the distinction matters:

| Layer | Manuscript location | Location here | Status |
|-------|--------------------|---------------|--------|
| **Exploratory** scripts | Appendix D ("Computational checks and reproducibility notes") | top level of `code/` and `code/outputs/` | Convention checks, regression tests, false-strategy exposure, empirical evidence. **Not** part of any proof. |
| **Proof certificates** | Chapter 16 and Appendix E | `code/minimal_direction_g2/` | **Proof components.** Each verifies an exact arithmetic statement used in the proof of the minimal exceptional direction theorem. |

A more detailed pointer from individual scripts to the relevant sections is given in
[`code/README.md`](code/README.md).

## Quick start

All Python scripts use the Python 3 standard library only, so nothing needs to be installed (see
[Requirements](#requirements)).

### 1. The exact checks of the minimal exceptional direction

```bash
cd code/minimal_direction_g2
python3 minimal_direction_g2_certificate.py
```

The expected output is

```json
{
  "certificate": "minimal_direction_g2",
  "result": "PASS",
  "errors": [],
  "families_checked": 17,
  "matrix_orders_checked": 4
}
```

This master script recomputes the four matrix-order congruences of the twist matrix `W = AB` modulo `3ℓ` for
`ℓ ∈ {5, 23, 37, 47}`,

```text
W⁴ ≡ I (mod 15),    W²⁴ ≡ I (mod 69),    W¹² ≡ I (mod 111),    W²⁴ ≡ I (mod 141),
```

checks that the aggregate record `minimal_direction_g2_certificate.json` lists the seventeen
families with the status PASS, recomputes the SHA-256 hashes of the seventeen family scripts and of their JSON
reports and compares them with the recorded values, so that no file has changed since the record was made, and
checks that the recorded margin of the central family `c = 5` is positive. It reads the reports of the families
rather than recomputing them.

The residue tables themselves are recomputed by the seventeen family scripts `minimal_direction_c*_certificate.py`,
one per family, for instance `python3 minimal_direction_c5_mod37_recurrence_certificate.py`. Each of them writes its
report into the folder `/mnt/data/`, whose name is fixed in the script, before printing its summary, so on a machine
without a writable folder of that name it stops with an error at that step. Where that folder exists, every family
script reproduces its shipped report byte for byte, the slowest in about eight seconds. Changing the path in the
shipped scripts would change the hashes that the master script compares, so a different folder is best set in a
copy of the script.

### 2. Build the manuscript

```bash
cd manuscript
make            # → DD-LV-Markov.pdf  (requires `typst`)
```

### 3. Representative exploratory runs

```bash
# Word/trace convention sanity check (expected: no hits, plus Pellian y = 5, 29)
python3 code/one_turn_fixed_arm_sanity_check.py

# Modular sieve over small primes in a finite window (6585 pairs, no survivor)
python3 code/exceptional_modular_sieve.py --qmax 100 --rmax 50 --moduli 2,3,5,7,11,13,17

# Register automaton scan (15714 pairs, no survivor; a regression test)
python3 code/terminal_exceptional_register_automaton.py scan \
    --qmax 120 --rmax 60 --moduli 2 3 5 7 11 13 17 19 \
    --out code/outputs/terminal_register_scan_120_60_primes19.json
```

Each of these runs takes less than a second, and the register scan rewrites its shipped output identically. The full
catalogue of scripts, their command-line options, and their expected outputs is in [`code/README.md`](code/README.md).

## What the computations do and do not prove

The checks in `code/minimal_direction_g2/` are part of the proof of the minimal exceptional direction theorem: each
verifies an exact statement (integer, modular, or of symbolic positivity) on which the argument of Chapter 16 relies.
They use exact arithmetic only, with no floating point.

The exploratory scripts in `code/` do not prove the ETAT, Markov uniqueness, or any external ordering theorem. They
check that the word and matrix conventions agree on small inputs, give reproducible empirical evidence for
conjectural sub-claims such as the fixed-arm recurrence-order hierarchy, and expose false proof strategies:
synchronous pair automata cannot work, and no fixed finite set of moduli can solve the exceptional terminal problem,
a statement that the manuscript upgrades to a theorem. They also serve as regression tests against future
constructions of certificates.

The Magma and Sage drivers (`one_turn_fixed_arm_certificate.{magma,sage}`) are a proposed integral-points certificate
and have not been executed in the manuscript's environment; they are documented as such in Appendix D, §D.6.

## Requirements

Python 3.8 or later, with its standard library only, runs every script (see [`requirements.txt`](requirements.txt)).
[Typst](https://typst.app/) builds the manuscript (`cd manuscript && make`; version 0.15.1 builds it in a few
seconds). Magma or Sage is needed only for the proposed, unexecuted Pellian certificate, which no Python script and no
build invokes.

## How to cite

The monograph is under review. Until it is published, please cite the software:

D. Dutykh and L. Vuillon, A Cohn-tree reduction of the Frobenius–Markov uniqueness conjecture (code and
certificates), software, version 1.0.0 (2026).

https://github.com/dutykh/markov-etat

The button "Cite this repository" in the right-hand column of this page gives the same reference, read from
`CITATION.cff`.

## Licence

The code is released under the GNU Lesser General Public License, version 2.1 (see [`LICENSE`](LICENSE)).

## Authors and acknowledgements

| Author | Affiliation | Contact |
|--------|-------------|---------|
| **Dr. Denys Dutykh** | Mathematics Department, Khalifa University of Science and Technology, PO Box 127788, Abu Dhabi, UAE | [denys.dutykh@ku.ac.ae](mailto:denys.dutykh@ku.ac.ae) · [www.denys-dutykh.com](https://www.denys-dutykh.com/) |
| **Prof. Laurent Vuillon** | Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, 73000, France | [laurent.vuillon@univ-smb.fr](mailto:laurent.vuillon@univ-smb.fr) · [laurentvuillon.github.io](https://laurentvuillon.github.io/) |

This work grew out of a long collaboration that began at the LAMA (*Laboratoire de Mathématiques*, Université Savoie
Mont Blanc), where the first author held a CNRS position from 2008 and the second author was his first laboratory
director. It is offered as a small testimony to a shared conviction: that with friendship, mutual respect, and genuine
curiosity one can cross the boundaries between mathematical disciplines. There is only one Mathematics.
