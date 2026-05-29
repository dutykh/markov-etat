#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Certificate for the c=15 family in the minimal exceptional direction.

Family:
    P=(p+t+22,p), Q=(p+t+12,p+12), p=t+15, t=6k+1.
So:
    P_k=(12k+39,6k+16), Q_k=(12k+29,6k+28).
Admissibility:
    k >= 0, k != 2 mod 7.
Claim:
    Mod 37 separates all admissible k except k mod 378 in
    {33,35,109,131,165,169,222,224,298,320,354,358}.
    Mod 23 separates all lifts of those remaining classes modulo 756.
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
        raise ValueError((q,p,math.gcd(q,p)))
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

def Pk(k:int): return (12*k+39,6*k+16)
def Qk(k:int): return (12*k+29,6*k+28)
def admissible(k:int) -> bool:
    return k>=0 and math.gcd(*Pk(k))==1 and math.gcd(*Qk(k))==1

def residue_pair(k:int,mod:int):
    return markov_mod_christoffel(*Pk(k),mod), markov_mod_christoffel(*Qk(k),mod)

def main():
    period37=378
    mod37_table=[]
    survivors=[]
    for k in range(period37):
        row={'k_mod_378':k}
        if not admissible(k):
            row['excluded_by_primitivity']=True
            mod37_table.append(row)
            continue
        a,b=residue_pair(k,37)
        row.update({'m_P_mod_37':a,'m_Q_mod_37':b,'separated':a!=b})
        if a==b: survivors.append(k)
        mod37_table.append(row)

    mod23_table=[]
    for base in survivors:
        for k in (base, base+period37):
            a,b=residue_pair(k,23)
            mod23_table.append({'k_mod_756':k,'base_mod_378':base,'m_P_mod_23':a,'m_Q_mod_23':b,'separated':a!=b})

    sanity={}
    for mod, period in ((37,period37),(23,756)):
        ok=True; fail=None
        for k in range(0,120):
            if admissible(k) and admissible(k+period):
                if residue_pair(k,mod)!=residue_pair(k+period,mod):
                    ok=False
                    fail={'k':k,'period':period,'res_k':residue_pair(k,mod),'res_k_plus_period':residue_pair(k+period,mod)}
                    break
        sanity[str(mod)]={'period_ok_to_120':ok,'failure':fail}

    adm_ok=True; adm_fail=None
    for k in range(0,2000):
        formula=(k%7)!=2
        if admissible(k)!=formula:
            adm_ok=False
            adm_fail={'k':k,'admissible':admissible(k),'formula':formula,'Pk':Pk(k),'Qk':Qk(k),'gcdP':math.gcd(*Pk(k)),'gcdQ':math.gcd(*Qk(k))}
            break

    report={
        'family':'c=15 minimal exceptional direction',
        'P_k':'(12k+39,6k+16)',
        'Q_k':'(12k+29,6k+28)',
        'admissibility':'k>=0, k != 2 mod 7',
        'admissibility_sanity':{'ok_to_2000':adm_ok,'failure':adm_fail},
        'period_mod_37':period37,
        'period_mod_23':756,
        'period_sanity':sanity,
        'mod37_survivor_classes_mod_378':survivors,
        'mod37_table':mod37_table,
        'mod23_table_for_survivor_lifts':mod23_table,
        'all_mod23_survivor_lifts_separated':all(row['separated'] for row in mod23_table),
        'conclusion':'Every admissible k is separated modulo 37, except the listed classes, whose lifts modulo 756 are separated modulo 23.'
    }
    out='/mnt/data/minimal_direction_c15_mod37_mod23_certificate.json'
    with open(out,'w') as f:
        json.dump(report,f,indent=2)
    print(json.dumps({
        'survivors_mod37':survivors,
        'all_mod23_survivor_lifts_separated':report['all_mod23_survivor_lifts_separated'],
        'period_sanity':sanity,
        'admissibility_sanity':report['admissibility_sanity']
    },indent=2))

if __name__=='__main__':
    main()
