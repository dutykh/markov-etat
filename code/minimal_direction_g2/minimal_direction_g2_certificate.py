#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Aggregate verifier for the minimal exceptional direction g=2 certificate.

This script verifies the aggregate JSON certificate for the theorem:
    (R,H)=(6,5), g=2, equivalently (r,h)=(12,10).

It checks:
  1. the matrix-order congruences used to justify the periods;
  2. the presence and PASS status of all 17 c-families;
  3. positive symbolic margin in the central c=5 family;
  4. optional SHA-256 hashes of individual files if present.

The individual family scripts included in the same directory regenerate the detailed
finite residue tables.
"""
from __future__ import annotations
import json, os, hashlib, sys
from typing import Tuple

Mat = Tuple[int,int,int,int]
A: Mat = (2,1,1,1)
B: Mat = (5,2,2,1)
W: Mat = (12,5,7,3)
IDENTITY = (1,0,0,1)
EXPECTED_CS = [-11,-9,-7,-5,-3,-1,1,3,5,7,9,11,13,15,17,19,21]


def matmul_mod(X: Mat, Y: Mat, m: int) -> Mat:
    a,b,c,d = X
    e,f,g,h = Y
    return ((a*e+b*g)%m, (a*f+b*h)%m, (c*e+d*g)%m, (c*f+d*h)%m)


def matpow_mod(M: Mat, n: int, m: int) -> Mat:
    X = IDENTITY
    M = tuple(x % m for x in M)
    while n:
        if n & 1:
            X = matmul_mod(X, M, m)
        M = matmul_mod(M, M, m)
        n //= 2
    return X


def sha256(path: str) -> str:
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    here = os.path.dirname(os.path.abspath(__file__))
    cert_path = os.path.join(here, 'minimal_direction_g2_certificate.json')
    with open(cert_path, 'r') as f:
        cert = json.load(f)

    errors = []

    # Check matrix orders.
    for item in cert.get('matrix_orders', []):
        mod = int(item['modulus'])
        power = int(item['power'])
        got = list(matpow_mod(W, power, mod))
        if got != [1,0,0,1]:
            errors.append(f"Matrix order failed: W^{power} mod {mod} = {got}")
        if got != item.get('matrix_power_result'):
            errors.append(f"Stored matrix power mismatch for modulus {mod}, power {power}")

    # Check all c families exist and are marked PASS.
    summary = cert.get('family_summary', [])
    got_cs = sorted(int(row['c']) for row in summary)
    if got_cs != EXPECTED_CS:
        errors.append(f"Family list mismatch: expected {EXPECTED_CS}, got {got_cs}")
    for row in summary:
        if row.get('status') != 'PASS':
            errors.append(f"Family c={row.get('c')} not PASS: {row.get('status')}")
        # Verify hashes if individual files are present.
        for field, fnamefield in [('sha256_script','script'),('sha256_json','json')]:
            expected = row.get(field)
            fname = row.get(fnamefield)
            if expected and fname:
                path = os.path.join(here, fname)
                if os.path.exists(path):
                    actual = sha256(path)
                    if actual != expected:
                        errors.append(f"Hash mismatch for {fname}: expected {expected}, got {actual}")

    # Check central positivity data.
    central = cert.get('family_reports', {}).get('5', {})
    num = int(central.get('positive_margin_numerator', 0))
    den = int(central.get('positive_margin_denominator', 1))
    if not (num > 0 and den > 0):
        errors.append('Central c=5 positivity margin is not positive')
    surv = central.get('mod37_survivors_mod34', [])
    if surv not in ([15,32], [15, 32]):
        errors.append(f"Unexpected c=5 mod37 survivors: {surv}")

    result = {
        'certificate': 'minimal_direction_g2',
        'result': 'FAIL' if errors else 'PASS',
        'errors': errors,
        'families_checked': len(summary),
        'matrix_orders_checked': len(cert.get('matrix_orders', [])),
    }
    print(json.dumps(result, indent=2))
    return 1 if errors else 0


if __name__ == '__main__':
    raise SystemExit(main())
