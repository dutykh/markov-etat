# Minimal exceptional direction g=2 certificate package

**Authors of the manuscript:** Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE) and Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France).

This directory contains the proof-certificate scripts and JSON outputs that support Chapter 16 of *A Cohn-tree reduction of the Frobenius–Markov uniqueness conjecture*. The certificate proves the minimal exceptional terminal case:

- primitive direction: `(R, H) = (6, 5)`,
- first nonprimitive step: `g = 2`,
- terminal parameters: `(r, h) = (12, 10)`, equivalently `s = r + h = 22`,
- terminal pair: `P = (p + t + 22, p)`, `Q = (p + t + 12, p + 12)`.

After the reductions of Chapter 16, any possible equality is contained in one of the seventeen one-parameter families

    P_{c, k} = (12k + c + 24, 6k + c + 1),
    Q_{c, k} = (12k + c + 14, 6k + c + 13),

with odd `c` and `-11 ≤ c ≤ 21`. The certificate verifies that every admissible family is separated:

- the sixteen non-central families (`c ∈ {-11, -9, …, 19, 21} \ {5}`) are separated by finite congruence certificates against one or two of the primes `5, 23, 37, 47`;
- the central family `c = 5` is separated by a mod-37 congruence reduction to one survivor class `k ≡ 15 (mod 17)`, followed by a symbolic trace-positivity argument against a degree-16 polynomial inequality.

Together with the reductions of §16.2 (parity + mod-3) and §16.3 (return-reduced reduction to seventeen families), this completes the proof of the Exceptional Terminal Arithmetic Theorem for `(R, H) = (6, 5)`, `g = 2`.

## How to run

From this directory, run:

```bash
python3 minimal_direction_g2_certificate.py
```

The expected output is a short JSON object with `"result": "PASS"`. The aggregate verifier checks:

1. the four matrix-order congruences `(AB)^{M_ℓ} ≡ I (mod 3ℓ)` for `ℓ ∈ {5, 23, 37, 47}`,
2. the presence and `PASS` status of all 17 individual family reports,
3. SHA-256 hashes of every individual `.py` and `.json` against the values recorded in the aggregate JSON,
4. the positive symbolic margin in the central `c = 5` report.

Each individual family verifier can also be run directly:

```bash
python3 minimal_direction_c<X>_<moduli>_certificate.py
```

regenerating the detailed finite residue table for that family.

## Files in this directory

- `minimal_direction_g2_certificate.py` — master aggregate verifier.
- `minimal_direction_g2_certificate.json` — aggregate certificate, containing the matrix-order data, family-summary table, central-family report (mod-37 survivors, Stern–Brocot paths, polynomial coefficients, positive margin), and SHA-256 hashes of every individual file.
- `minimal_direction_c<X>_<moduli>_certificate.py` (16 files) — individual c-family verifiers, one per `c ∈ {-11, -9, …, 21}` other than `c = 5`. The filename `<moduli>` records which Cohn-residue primes that family uses (e.g. `mod37_mod5` means the primary modulus is 37 with auxiliary modulus 5).
- `minimal_direction_c<X>_<moduli>_certificate.json` (16 files) — individual JSON outputs containing the residue tables, period, admissibility exclusions, survivor classes, and PASS status for each family.
- `minimal_direction_c5_mod37_recurrence_certificate.py` / `.json` — the central-family verifier, which combines a mod-37 reduction with the symbolic-positivity recurrence argument.

## Underlying matrix-order congruences

The certificates rely on the following four congruences of the twist matrix `W = AB`:

    W^4  ≡ I (mod 15),
    W^24 ≡ I (mod 69),
    W^12 ≡ I (mod 111),
    W^24 ≡ I (mod 141).

These are checked directly by the master verifier (via `matpow_mod`) for every run.

## Cross-references in the manuscript

The verification protocol and the certified statement are described in Appendix E of the manuscript:

- §E.5 records the per-family certificate-data table (`<tab:certificate-summary>` in §16.5 contains the full detail).
- §E.6 specifies the verification algorithm for non-central families.
- §E.7 records the central-family argument with the explicit positive margin.
- §E.8 describes this directory layout.
- §E.10 documents the independent verification protocol.

## Notes

All computations are exact integer arithmetic. No floating-point is used by the verifier (a single `positive_margin_decimal_approx` field is provided in the JSON for human readability only; the rational `positive_margin_numerator / positive_margin_denominator` pair is the authoritative datum).
