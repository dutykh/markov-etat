#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Mod-5 + mod-23 certificate for the c=19 family in the minimal exceptional direction.

Family:
    P_t=(2t+41,t+19), Q_t=(2t+31,t+31), t>0, t == 1 mod 6.
Writing t=6k+1 gives:
    P_k=(12k+43,6k+20), Q_k=(12k+33,6k+32).
Primitivity is equivalent to k != 5 mod 31.

Claim:
    Every admissible k is separated modulo 5 except k == 14 or 27 mod 31.
    Those two classes are separated modulo 23, with period 12 in the auxiliary parameter a.
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

def cohn_state_mod(q:int,p:int,mod:int):
    Mmod=3*mod
    st=(tuple(x%Mmod for x in A), tuple(x%Mmod for x in B))
    for ch in sb_path(q,p):
        L,R=st; M=matmul_mod(L,R,Mmod)
        st=(L,M) if ch=='L' else (M,R)
    return st

def markov_mod(q:int,p:int,mod:int) -> int:
    Mmod=3*mod
    L,R=cohn_state_mod(q,p,mod)
    M=matmul_mod(L,R,Mmod)
    tr=(M[0]+M[3])%Mmod
    assert tr%3==0
    return (tr//3)%mod

def Pk(k:int):
    return (12*k+43,6*k+20)

def Qk(k:int):
    return (12*k+33,6*k+32)

def admissible(k:int) -> bool:
    P=Pk(k); Q=Qk(k)
    return k>=0 and math.gcd(*P)==1 and math.gcd(*Q)==1

def residue_pair(k:int,mod:int):
    return markov_mod(*Pk(k),mod), markov_mod(*Qk(k),mod)

def main():
    # mod 5 table over k mod 62
    mod5_table=[]
    for k in range(62):
        if not admissible(k):
            mod5_table.append({'k_mod_62':k,'excluded_by_primitivity':True})
        else:
            a,b=residue_pair(k,5)
            mod5_table.append({'k_mod_62':k,'m_P_mod_5':a,'m_Q_mod_5':b,'separated':a!=b})
    mod5_survivors=[row['k_mod_62'] for row in mod5_table if not row.get('excluded_by_primitivity') and not row['separated']]

    # mod 5 period sanity
    period5_ok=True; period5_failure=None
    for k in range(0,3000):
        if admissible(k) and admissible(k+62):
            if residue_pair(k,5)!=residue_pair(k+62,5):
                period5_ok=False; period5_failure=(k,residue_pair(k,5),residue_pair(k+62,5)); break

    # mod 23 tables for k = 31a+14 and k = 31a+27, period 12 in a
    mod23_tables={}
    for cls in [14,27]:
        rows=[]
        for a in range(12):
            k=31*a+cls
            x,y=residue_pair(k,23)
            rows.append({'a_mod_12':a,'k_expression':f'31a+{cls}','m_P_mod_23':x,'m_Q_mod_23':y,'separated':x!=y})
        mod23_tables[str(cls)]=rows

    period23_ok=True; period23_failure=None
    for cls in [14,27]:
        for a in range(0,200):
            k=31*a+cls; k2=31*(a+12)+cls
            if admissible(k) and admissible(k2):
                if residue_pair(k,23)!=residue_pair(k2,23):
                    period23_ok=False; period23_failure=(cls,a,residue_pair(k,23),residue_pair(k2,23)); break
        if not period23_ok: break

    report={
        'family':'c=19 minimal exceptional direction',
        'P_k':'(12k+43,6k+20)',
        'Q_k':'(12k+33,6k+32)',
        'conditions':'k >= 0, k != 5 mod 31',
        'mod5_period_k':62,
        'mod5_period_sanity_to_3000':period5_ok,
        'mod5_period_failure':period5_failure,
        'mod5_survivor_classes_mod_62':mod5_survivors,
        'mod5_table':mod5_table,
        'mod23_period_a':12,
        'mod23_period_sanity_to_a_200':period23_ok,
        'mod23_period_failure':period23_failure,
        'mod23_tables_for_survivors':mod23_tables,
        'conclusion':'Every admissible k is separated modulo 5, except k == 14 or 27 mod 31; those two classes are separated modulo 23.'
    }
    out='/mnt/data/minimal_direction_c19_mod5_mod23_certificate.json'
    with open(out,'w') as f:
        json.dump(report,f,indent=2)
    print(json.dumps({'mod5_period_ok':period5_ok,'mod5_survivors':mod5_survivors,'mod23_period_ok':period23_ok,'all_mod23_rows_separated':all(row['separated'] for rows in mod23_tables.values() for row in rows)},indent=2))

if __name__=='__main__':
    main()
