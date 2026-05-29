#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Certificate for the c=17 family in the minimal exceptional direction.

Family:
    P=(p+t+22,p), Q=(p+t+12,p+12), p=t+17, t=6k+1.
So:
    P_k=(12k+41,6k+18), Q_k=(12k+31,6k+30).
Admissibility:
    k >= 0, k != 2 mod 5, k != 24 mod 29.
Claim:
    Mod 37 separates all admissible k except k mod 290 in
    {9,31,45,65,113,154,176,190,210,258}.
    Mod 5 separates those remaining classes.
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

def markov_mod_christoffel(q:int,p:int,mod:int) -> int:
    if not(q>0 and 0<p<q and math.gcd(q,p)==1):
        raise ValueError((q,p))
    Mmod=3*mod
    Am=tuple(x%Mmod for x in A)
    Bm=tuple(x%Mmod for x in B)
    M=(1,0,0,1)
    prev=0
    for k in range(1,q+1):
        cur=(k*p)//q
        M=matmul_mod(M, Bm if cur>prev else Am, Mmod)
        prev=cur
    tr=(M[0]+M[3])%Mmod
    assert tr%3==0
    return (tr//3)%mod

def Pk(k:int): return (12*k+41,6*k+18)
def Qk(k:int): return (12*k+31,6*k+30)
def admissible(k:int) -> bool:
    return k>=0 and math.gcd(*Pk(k))==1 and math.gcd(*Qk(k))==1

def residue_pair(k:int,mod:int):
    return markov_mod_christoffel(*Pk(k),mod), markov_mod_christoffel(*Qk(k),mod)

def main():
    period=290
    mod37_table=[]
    survivors=[]
    for k in range(period):
        row={'k_mod_290':k}
        if not admissible(k):
            row['excluded_by_primitivity']=True
            mod37_table.append(row)
            continue
        a,b=residue_pair(k,37)
        row.update({'m_P_mod_37':a,'m_Q_mod_37':b,'separated':a!=b})
        if a==b: survivors.append(k)
        mod37_table.append(row)

    mod5_table=[]
    for k in survivors:
        a,b=residue_pair(k,5)
        mod5_table.append({'k_mod_290':k,'m_P_mod_5':a,'m_Q_mod_5':b,'separated':a!=b})

    sanity={}
    for mod in (37,5):
        ok=True; fail=None
        for k in range(0,1000):
            if admissible(k) and admissible(k+period):
                if residue_pair(k,mod)!=residue_pair(k+period,mod):
                    ok=False
                    fail={'k':k,'res_k':residue_pair(k,mod),'res_k_plus_period':residue_pair(k+period,mod)}
                    break
        sanity[str(mod)]={'period_290_ok_to_1000':ok,'failure':fail}

    # Verify stated admissibility congruences.
    adm_ok=True; adm_fail=None
    for k in range(0,2000):
        formula = (k % 5 != 2) and (k % 29 != 24)
        if admissible(k) != formula:
            adm_ok=False
            adm_fail={'k':k,'admissible':admissible(k),'formula':formula,'Pk':Pk(k),'Qk':Qk(k),'gcdP':math.gcd(*Pk(k)),'gcdQ':math.gcd(*Qk(k))}
            break

    report={
        'family':'c=17 minimal exceptional direction',
        'P_k':'(12k+41,6k+18)',
        'Q_k':'(12k+31,6k+30)',
        'admissibility':'k>=0, k != 2 mod 5, k != 24 mod 29',
        'admissibility_sanity':{'ok_to_2000':adm_ok,'failure':adm_fail},
        'period_k':period,
        'period_sanity':sanity,
        'mod37_survivor_classes_mod_290':survivors,
        'mod37_table':mod37_table,
        'mod5_table_for_survivors':mod5_table,
        'all_mod5_survivors_separated':all(row['separated'] for row in mod5_table),
        'conclusion':'Every admissible k is separated modulo 37, except the listed classes, which are separated modulo 5.'
    }
    out='/mnt/data/minimal_direction_c17_mod37_mod5_certificate.json'
    with open(out,'w') as f:
        json.dump(report,f,indent=2)
    print(json.dumps({
        'survivors_mod37':survivors,
        'all_mod5_survivors_separated':report['all_mod5_survivors_separated'],
        'period_sanity':sanity,
        'admissibility_sanity':report['admissibility_sanity']
    },indent=2))

if __name__=='__main__':
    main()
