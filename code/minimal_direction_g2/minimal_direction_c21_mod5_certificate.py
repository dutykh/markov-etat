#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Mod-5 certificate for the c=21 family in the minimal exceptional direction.

Family:
    P_t=(2t+43,t+21), Q_t=(2t+33,t+33), t > 0, t == 1 mod 6, t != 0 mod 11.
Claim:
    m(P_t) != m(Q_t) mod 5 for every admissible t.

The script computes Cohn residues modulo 5 from Stern-Brocot paths, verifies
period 132 for the relevant residue functions on a finite range, and emits the
complete residue table for admissible classes modulo 132.
"""
from __future__ import annotations
import json, math
from typing import Tuple

Mat = Tuple[int,int,int,int]
A: Mat = (2,1,1,1)
B: Mat = (5,2,2,1)

def matmul_mod(X: Mat, Y: Mat, m: int) -> Mat:
    a,b,c,d=X; e,f,g,h=Y
    return ((a*e+b*g)%m,(a*f+b*h)%m,(c*e+d*g)%m,(c*f+d*h)%m)

def sb_path(q: int, p: int) -> str:
    if not (q>0 and 0<p<q and math.gcd(q,p)==1):
        raise ValueError((q,p))
    lo_p,lo_q=0,1
    hi_p,hi_q=1,1
    out=[]
    while True:
        mp,mq=lo_p+hi_p, lo_q+hi_q
        if mp==p and mq==q:
            return ''.join(out)
        if p*mq < mp*q:
            hi_p,hi_q=mp,mq
            out.append('L')
        else:
            lo_p,lo_q=mp,mq
            out.append('R')

def cohn_state_mod(q:int,p:int,mod:int=5):
    Mmod=3*mod
    st=(tuple(x%Mmod for x in A), tuple(x%Mmod for x in B))
    for ch in sb_path(q,p):
        L,R=st; M=matmul_mod(L,R,Mmod)
        st=(L,M) if ch=='L' else (M,R)
    return st

def markov_mod(q:int,p:int,mod:int=5) -> int:
    Mmod=3*mod
    L,R=cohn_state_mod(q,p,mod)
    M=matmul_mod(L,R,Mmod)
    tr=(M[0]+M[3])%Mmod
    assert tr%3==0
    return (tr//3)%mod

def residue_pair(t:int):
    P=(2*t+43,t+21)
    Q=(2*t+33,t+33)
    return markov_mod(*P,5), markov_mod(*Q,5)

def admissible(t:int)->bool:
    return t>0 and t%6==1 and t%11!=0

def main():
    table=[]
    for a in range(132):
        if a%6==1 and a%11!=0:
            t=a if a>0 else 132
            rp,rq=residue_pair(t)
            table.append({'class_mod_132':a,'representative_t':t,'m_P_mod_5':rp,'m_Q_mod_5':rq,'separated':rp!=rq})
        elif a%6==1:
            table.append({'class_mod_132':a,'representative_t':a if a>0 else 132,'excluded_by_primitivity':True})
    assert all(row.get('excluded_by_primitivity') or row['separated'] for row in table)

    period_ok=True
    witness_fail=None
    for t in range(1,5000,6):
        if t%11==0 or (t+132)%11==0:
            continue
        if residue_pair(t)!=residue_pair(t+132):
            period_ok=False
            witness_fail=(t,residue_pair(t),residue_pair(t+132))
            break
    report={
        'family':'c=21 minimal exceptional direction',
        'P_t':'(2t+43,t+21)',
        'Q_t':'(2t+33,t+33)',
        'conditions':'t > 0, t == 1 mod 6, t != 0 mod 11',
        'modulus':5,
        'period_mod_t':132,
        'period_sanity_check_to_5000':period_ok,
        'period_sanity_failure':witness_fail,
        'table':table,
        'conclusion':'Every admissible residue class modulo 132 is separated modulo 5.'
    }
    with open('/mnt/data/minimal_direction_c21_mod5_certificate.json','w') as f:
        json.dump(report,f,indent=2)
    print(json.dumps({'period_ok':period_ok,'classes':len(table),'all_separated':all(row.get('excluded_by_primitivity') or row['separated'] for row in table)},indent=2))

if __name__=='__main__':
    main()
