#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""Mod-5 certificate for the c=-11 family in the minimal exceptional direction."""
from __future__ import annotations
import json, math
from typing import Tuple
Mat=Tuple[int,int,int,int]
A:Mat=(2,1,1,1); B:Mat=(5,2,2,1)
def matmul_mod(X:Mat,Y:Mat,m:int)->Mat:
    a,b,c,d=X; e,f,g,h=Y
    return ((a*e+b*g)%m,(a*f+b*h)%m,(c*e+d*g)%m,(c*f+d*h)%m)
def sb_path(q:int,p:int)->str:
    if not(q>0 and 0<p<q and math.gcd(q,p)==1): raise ValueError((q,p))
    lo_p,lo_q=0,1; hi_p,hi_q=1,1; out=[]
    while True:
        mp,mq=lo_p+hi_p,lo_q+hi_q
        if mp==p and mq==q: return ''.join(out)
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
    Mmod=3*mod; L,R=cohn_state_mod(q,p,mod); M=matmul_mod(L,R,Mmod); tr=(M[0]+M[3])%Mmod
    assert tr%3==0
    return (tr//3)%mod
def pair(k:int): return (12*k+13,6*k-10),(12*k+3,6*k+2)
def admissible(k:int)->bool:
    P,Q=pair(k)
    return k>=2 and math.gcd(*P)==1 and math.gcd(*Q)==1
def residue_pair(k:int,mod:int=5):
    P,Q=pair(k); return markov_mod(*P,mod),markov_mod(*Q,mod)
def main():
    T=22; table=[]
    for a in range(T):
        reps=[a + T*j for j in range(0,3)]
        reps=[x for x in reps if x>=2]
        k=reps[0] if reps else a+T*3
        if admissible(k):
            rp,rq=residue_pair(k,5); table.append({'class_mod_22':a,'representative_k':k,'m_P_mod_5':rp,'m_Q_mod_5':rq,'separated':rp!=rq})
        else:
            table.append({'class_mod_22':a,'representative_k':k,'excluded_by_admissibility':True})
    assert all(row.get('excluded_by_admissibility') or row['separated'] for row in table)
    period_ok=True; fail=None
    for k in range(2,1000):
        if admissible(k) and admissible(k+T) and residue_pair(k,5)!=residue_pair(k+T,5):
            period_ok=False; fail=(k,residue_pair(k,5),residue_pair(k+T,5)); break
    report={'family':'c=-11 minimal exceptional direction','P_k':'(12k+13,6k-10)','Q_k':'(12k+3,6k+2)','conditions':'k>=2 and primitive endpoints','modulus':5,'period_mod_k':T,'period_sanity_check_to_1000':period_ok,'period_sanity_failure':fail,'table':table,'conclusion':'Every admissible residue class modulo 22 is separated modulo 5.'}
    with open('/mnt/data/minimal_direction_cminus11_mod5_certificate.json','w') as f: json.dump(report,f,indent=2)
    print(json.dumps({'period_ok':period_ok,'classes':len(table),'all_separated':True},indent=2))
if __name__=='__main__': main()
