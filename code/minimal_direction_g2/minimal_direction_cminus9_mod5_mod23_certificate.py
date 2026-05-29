#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Mod-5 plus mod-23 certificate for the c=-9 family in the minimal exceptional direction.

Family with t=6k+1:
    P_k=(12k+15,6k-8), Q_k=(12k+5,6k+4).
Admissibility: k>=2 and k not congruent to 22 mod 31.
Claim: mod 5 separates all admissible classes except k congruent 0 or 13 mod 31; those survivors are separated modulo 23 with period 12 in the lift parameter.
"""
from __future__ import annotations
import json, math
from typing import Tuple

Mat=Tuple[int,int,int,int]
A:Mat=(2,1,1,1)
B:Mat=(5,2,2,1)

def matmul_mod(X:Mat,Y:Mat,m:int)->Mat:
    a,b,c,d=X; e,f,g,h=Y
    return ((a*e+b*g)%m,(a*f+b*h)%m,(c*e+d*g)%m,(c*f+d*h)%m)

def sb_path(q:int,p:int)->str:
    if not (q>0 and 0<p<q and math.gcd(q,p)==1):
        raise ValueError((q,p))
    lo_p,lo_q=0,1
    hi_p,hi_q=1,1
    out=[]
    while True:
        mp,mq=lo_p+hi_p,lo_q+hi_q
        if mp==p and mq==q:
            return ''.join(out)
        if p*mq < mp*q:
            hi_p,hi_q=mp,mq; out.append('L')
        else:
            lo_p,lo_q=mp,mq; out.append('R')

def cohn_state_mod(q:int,p:int,mod:int):
    Mmod=3*mod
    st=(tuple(x%Mmod for x in A), tuple(x%Mmod for x in B))
    for ch in sb_path(q,p):
        L,R=st; M=matmul_mod(L,R,Mmod)
        st=(L,M) if ch=='L' else (M,R)
    return st

def markov_mod(q:int,p:int,mod:int)->int:
    Mmod=3*mod
    L,R=cohn_state_mod(q,p,mod)
    M=matmul_mod(L,R,Mmod)
    tr=(M[0]+M[3])%Mmod
    assert tr%3==0
    return (tr//3)%mod

def points(k:int):
    return (12*k+15,6*k-8),(12*k+5,6*k+4)

def admissible(k:int)->bool:
    P,Q=points(k)
    return k>=2 and math.gcd(*P)==1 and math.gcd(*Q)==1

def residue_pair(k:int,mod:int):
    P,Q=points(k)
    return markov_mod(*P,mod), markov_mod(*Q,mod)

def rep_for_class(a:int,period:int)->int:
    k=a
    while k<2 or not admissible(k):
        k += period
        if k > period*10+100:
            return -1
    return k

def main():
    period5=62
    table5=[]; survivors=[]
    for a in range(period5):
        if a%31==22:
            table5.append({'class_mod_62':a,'excluded_by_primitivity':True})
            continue
        k=rep_for_class(a,period5)
        rp,rq=residue_pair(k,5)
        separated=rp!=rq
        if not separated:
            survivors.append(a)
        table5.append({'class_mod_62':a,'representative_k':k,'m_P_mod_5':rp,'m_Q_mod_5':rq,'separated':separated})
    assert survivors==[0,13,31,44]

    aux=[]
    for base in [0,13]:
        rows=[]
        for aa in range(12):
            k=31*aa+base
            if k<2:
                k += 31*12
            assert admissible(k)
            rp,rq=residue_pair(k,23)
            rows.append({'a_mod_12':aa,'k_class':'31a+%d'%base,'representative_k':k,'m_P_mod_23':rp,'m_Q_mod_23':rq,'separated':rp!=rq})
        assert all(r['separated'] for r in rows)
        aux.append({'base_class_mod_31':base,'period_in_a':12,'rows':rows})

    # sanity checks
    period5_ok=True; fail5=None
    for k in range(2,5000):
        if admissible(k) and admissible(k+period5):
            if residue_pair(k,5)!=residue_pair(k+period5,5):
                period5_ok=False; fail5=(k,residue_pair(k,5),residue_pair(k+period5,5)); break
    period23_ok=True; fail23=None
    for base in [0,13]:
        for a in range(0,200):
            k=31*a+base
            if k<2 or not admissible(k) or not admissible(k+31*12):
                continue
            if residue_pair(k,23)!=residue_pair(k+31*12,23):
                period23_ok=False; fail23=(base,a,k,residue_pair(k,23),residue_pair(k+31*12,23)); break
        if not period23_ok: break

    report={
        'family':'c=-9 minimal exceptional direction',
        'P_k':'(12k+15,6k-8)',
        'Q_k':'(12k+5,6k+4)',
        'conditions':'k>=2, k not congruent to 22 mod 31',
        'primary':{'modulus':5,'period_mod_k':62,'period_ok':period5_ok,'period_failure':fail5,'survivors_mod_62':survivors,'table':table5},
        'auxiliary':{'modulus':23,'period_in_lift_parameter_a':12,'period_ok':period23_ok,'period_failure':fail23,'blocks':aux},
        'conclusion':'All admissible classes are separated modulo 5 or modulo 23.'
    }
    with open('/mnt/data/minimal_direction_cminus9_mod5_mod23_certificate.json','w') as f:
        json.dump(report,f,indent=2)
    print(json.dumps({'period5_ok':period5_ok,'period23_ok':period23_ok,'survivors':survivors,'all_aux_separated':True},indent=2))

if __name__=='__main__':
    main()
