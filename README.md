# A Cohn-tree reduction of the Frobenius–Markov uniqueness conjecture

> Companion repository: manuscript source and all accompanying computer code.

This repository accompanies the monograph

**_A Cohn-tree reduction of the Frobenius–Markov uniqueness conjecture_**
by **Dr. Denys Dutykh** and **Prof. Laurent Vuillon**.

| Author | Affiliation | Contact |
|--------|-------------|---------|
| **Dr. Denys Dutykh** | Mathematics Department, Khalifa University of Science and Technology, PO Box 127788, Abu Dhabi, UAE | [denys.dutykh@ku.ac.ae](mailto:denys.dutykh@ku.ac.ae) · [www.denys-dutykh.com](https://www.denys-dutykh.com/) |
| **Prof. Laurent Vuillon** | Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, 73000, France | [laurent.vuillon@univ-smb.fr](mailto:laurent.vuillon@univ-smb.fr) · [laurentvuillon.github.io](https://laurentvuillon.github.io/) |

Everything used in the study is openly available here, in the interest of
reproducible research: the manuscript source (Typst), the exploratory scripts,
and — most importantly — the **proof certificates** that can be re-run and
audited line by line.

📄 **Read the manuscript:** [`manuscript/DD-LV-Markov.pdf`](manuscript/DD-LV-Markov.pdf)

---

## Abstract

> We study the Frobenius–Markov uniqueness conjecture through the Cohn-tree
> trace formulation. Using Cohn words, Farey cones, and trace recurrences, we
> prove same-ray monotonicity, dominance exclusion, Vieta gluing, and shifted
> boundary separation. We then show that any unresolved return-reduced
> cross-ray collision reduces to a terminal comparison in the standard Farey
> cone. Known monotonicity theorems for Markov and generalized Markov numbers
> exclude all non-exceptional terminal slopes and the primitive-step
> exceptional case. The remaining obstruction is an explicit terminal
> arithmetic problem in the exceptional slope window. We also prove that no
> fixed finite modular sieve can settle this terminal problem, and we isolate
> endpoint escape families by Fibonacci–Pell intersection. Thus Markov
> uniqueness is reduced to the *Exceptional Terminal Arithmetic Theorem*. As a
> first concrete step beyond this conditional reduction, we further prove the
> Exceptional Terminal Arithmetic Theorem in the minimal primitive exceptional
> direction _(R, H) = (6, 5)_ at multiplier _g = 2_, i.e. for _(r, h) = (12,
> 10)_ — the first solved case inside the genuinely exceptional non-primitive
> terminal region. The full Exceptional Terminal Arithmetic Theorem remains
> open.

**Keywords.** Frobenius–Markov uniqueness conjecture; Markov numbers; Cohn
tree; Cohn words; Farey cones; trace recurrences; monotonicity; Vieta gluing;
Fibonacci–Pell intersection.

---

## What the result is

The **Markov equation** $x^2 + y^2 + z^2 = 3xyz$ has positive-integer solutions
(Markov triples) organised on an infinite binary tree. The largest entry of a
triple is a **Markov number** (1, 2, 5, 13, 29, 34, 89, …). Frobenius's
century-old **uniqueness conjecture** asks whether each Markov number occurs as
the maximum of *exactly one* triple.

This monograph does not prove the conjecture; it **reduces** it. Working inside
the **Cohn-tree trace formulation** — where each tree node is a Cohn matrix
and the Markov number is one third of its trace — the book establishes a chain
of *unconditional* structural results:

1. **Same-ray monotonicity** of Cohn traces along a one-sided ray;
2. **Dominance exclusion** by line monotonicity in a Farey cone;
3. **Boundary ratio monotonicity** via a discrete Wronskian;
4. **Vieta gluing** of divided boundary trace sequences;
5. **Shifted boundary separation** across adjacent Farey cones;
6. **Euclidean recoding** of mixed comparisons down to a *terminal* comparison
   in the standard Farey cone.

Classical monotonicity theorems (Aigner, the slope-ordering results, and
Huang's valley theorem for generalised Markov numbers) then dispatch every
**non-exceptional** terminal slope and the **primitive-step** exceptional case.
What is left is a single, sharply isolated arithmetic statement, the

> **Exceptional Terminal Arithmetic Theorem (ETAT)** — no two distinct
> return-reduced terminal pairs in the exceptional slope window can share a Cohn
> trace.

The book shows the obstruction is *genuinely arithmetic*: **no fixed finite
modular sieve** can settle it (an explicit modular *escape family* $(P_T, Q_T)$
defeats any finite set of moduli), and the exact terminal language is **not
regular** (so no single finite automaton over the Stern–Brocot alphabet can
recognise it). Endpoint-to-endpoint escape families are nonetheless shown to be
harmless, via the Fibonacci–Pell intersection theorem.

Finally, as a first concrete crossing of the exceptional frontier, the book
**proves the ETAT in its minimal exceptional direction** $(R, H) = (6, 5)$ at
the first nonprimitive multiplier $g = 2$, i.e. for $(r, h) = (12, 10)$. After
the Chapter-16 reductions, the equality is confined to seventeen one-parameter
families, sixteen of which are eliminated by **finite congruence certificates**
(against the primes 5, 23, 37, 47) and the central family $c = 5$ by a mod-37
reduction plus a symbolic trace-positivity inequality. These certificates are
machine-checkable and live in this repository (see below).

**Status.** Markov uniqueness is reduced to the ETAT; the ETAT is proved in the
minimal exceptional case; **the full ETAT remains open.**

---

## Repository structure

```
markov-etat/
├── README.md                      ← you are here
├── LICENSE                        ← GNU LGPL v2.1
├── CITATION.cff                   ← how to cite this work
├── requirements.txt               ← dependency notes (Python stdlib only)
├── manuscript/                    ← manuscript source (Typst)
│   ├── DD-LV-Markov.typ           ← the monograph (source)
│   ├── DD-LV-Markov.pdf           ← the monograph (built PDF)
│   ├── refs.bib                   ← bibliography
│   └── Makefile                   ← `make` → DD-LV-Markov.pdf
└── code/                          ← all accompanying code
    ├── README.md                  ← authoritative per-script documentation
    ├── *.py / *.sage / *.magma    ← exploratory scripts (Appendix D)
    ├── outputs/                   ← JSON outputs + bounded-DFA archive
    └── minimal_direction_g2/      ← proof certificates (Chapter 16 / Appendix E)
        ├── README.md              ← certificate-package documentation
        ├── minimal_direction_g2_certificate.py    ← master verifier (PASS/FAIL)
        ├── minimal_direction_g2_certificate.json  ← aggregate certificate
        └── minimal_direction_c*_certificate.{py,json}  ← 17 per-family certificates
```

The two READMEs inside `code/` are the **authoritative** documentation for each
script — its role, canonical invocation, and expected output:

- [`code/README.md`](code/README.md) — exploratory layer (Appendix D).
- [`code/minimal_direction_g2/README.md`](code/minimal_direction_g2/README.md)
  — proof-certificate package (Chapter 16 / Appendix E).

---

## How the code maps to the manuscript

There are **two distinct layers**, and the distinction matters:

| Layer | Manuscript location | Location here | Status |
|-------|--------------------|---------------|--------|
| **Exploratory** scripts | Appendix D ("Computational checks and reproducibility notes") | top level of `code/` + `code/outputs/` | Convention checks, regression tests, false-strategy exposure, empirical evidence. **Not** part of any proof. |
| **Proof certificates** | Chapter 16 + Appendix E | `code/minimal_direction_g2/` | **Proof components.** Each verifies an exact arithmetic statement used in the proof of the minimal exceptional direction theorem. |

A more detailed pointer from individual scripts to the relevant sections is
given in [`code/README.md`](code/README.md).

---

## Reproducing the results

All Python scripts are **pure Python 3 standard library** — no `pip install`
needed (see [Requirements](#requirements)).

### 1. Re-run the proof certificate (the headline check)

```bash
cd code/minimal_direction_g2
python3 minimal_direction_g2_certificate.py
```

Expected output (verified):

```json
{
  "certificate": "minimal_direction_g2",
  "result": "PASS",
  "errors": [],
  "families_checked": 17,
  "matrix_orders_checked": 4
}
```

The master verifier checks the four matrix-order congruences
$(AB)^{M_\ell} \equiv I \pmod{3\ell}$ for $\ell \in \{5, 23, 37, 47\}$,
re-runs all seventeen per-family certificates, validates the central-family
positive margin, and re-computes the SHA-256 hashes of every individual `.py`
and `.json` against the aggregate JSON (tamper-resistance). Any single family
can also be re-run on its own, e.g. `python3 minimal_direction_c5_mod37_recurrence_certificate.py`.

### 2. Build the manuscript

```bash
cd manuscript
make            # → DD-LV-Markov.pdf  (requires `typst`)
```

### 3. Representative exploratory runs

```bash
# Word/trace convention sanity check (expected: no hits, plus Pellian y = 5, 29)
python3 code/one_turn_fixed_arm_sanity_check.py

# Modular sieve over small primes in a finite window
python3 code/exceptional_modular_sieve.py --qmax 100 --rmax 50 --moduli 2,3,5,7,11,13,17

# Register automaton scan (6585 pairs, 0 survivors — a regression test)
python3 code/terminal_exceptional_register_automaton.py scan \
    --qmax 120 --rmax 60 --moduli 2 3 5 7 11 13 17 19 \
    --out code/outputs/terminal_register_scan_120_60_primes19.json
```

The **full** catalogue of scripts, their command-line options, and their
expected outputs is in [`code/README.md`](code/README.md).

---

## What the computations do and do not prove

The proof certificates in `code/minimal_direction_g2/` **are part of the
proof** of the minimal exceptional direction theorem: each verifies an exact
(integer / modular / symbolic-positivity) statement that the argument of
Chapter 16 relies on. They use **exact arithmetic only**; no floating point.

The exploratory scripts in `code/` **do not** prove the ETAT, Markov
uniqueness, or any external ordering theorem. They:

- check that the word and matrix conventions agree on small inputs;
- give reproducible empirical evidence for conjectural sub-claims (e.g. the
  fixed-arm recurrence-order hierarchy);
- expose **false** proof strategies (synchronous pair automata cannot work; no
  fixed finite set of moduli can solve the exceptional terminal problem — this
  one is upgraded to a *theorem* in the manuscript);
- serve as regression tests against future certificate constructions.

The **Magma** and **Sage** drivers (`one_turn_fixed_arm_certificate.{magma,sage}`)
are a *proposed* integral-points certificate and **have not been executed** in
the manuscript's environment; they are documented as such in Appendix D §D.6.

---

## Requirements

- **Python ≥ 3.8** — standard library only; no third-party packages.
- **[Typst](https://typst.app/)** — to build the manuscript (`cd manuscript && make`).
- *Optional:* **Magma** and/or **Sage** — only for the proposed (unexecuted)
  Pellian certificate; not invoked by any Python script or by the build.

See [`requirements.txt`](requirements.txt) for details.

---

## Citation

If you use this work, please cite the monograph. Machine-readable metadata is in
[`CITATION.cff`](CITATION.cff). A BibTeX entry (update once published):

```bibtex
@article{DutykhVuillon2026Markov,
  author  = {Dutykh, Denys and Vuillon, Laurent},
  title   = {A {Cohn}-tree reduction of the {Frobenius}--{Markov} uniqueness conjecture},
  year    = {2026},
  note    = {Preprint. Code and certificates: https://github.com/dutykh/markov-etat}
}
```

---

## License

The code is released under the **GNU Lesser General Public License v2.1**
(see [`LICENSE`](LICENSE)).

---

## Authors and acknowledgements

This work grew out of a long collaboration that began at the LAMA
(*Laboratoire de Mathématiques*, Université Savoie Mont Blanc), where the first
author held a CNRS position from 2008 and the second author was his first
laboratory director. It is offered as a small testimony to a shared conviction:
that with friendship, mutual respect, and genuine curiosity one can cross the
boundaries between mathematical disciplines. There is only one Mathematics.

- **Dr. Denys Dutykh** — Khalifa University of Science and Technology, Abu Dhabi, UAE.
- **Prof. Laurent Vuillon** — Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France.
