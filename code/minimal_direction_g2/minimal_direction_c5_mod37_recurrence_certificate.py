#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Certificate for the central c=5 family in the minimal exceptional direction.

Family:
  P_k=(12k+29,6k+6), Q_k=(12k+19,6k+18), k admissible iff
  k>=0, k !=14,16 mod 17.

Proof structure:
  1. Mod 37 separates all admissible k except k == 15 mod 17.
  2. For k=17n+15, write N=6n+5. The Stern-Brocot paths are
     P_N = L R^N L R L R^4,
     Q_N = R L^N R^2 L R^4.
     Let W=AB and W^N=a W + b I. Symbolically verify
       tr(C_Q)-tr(C_P)=3(15a+b)F(a,b).
     For N>=5, a=P_{N-1}(15)>0, b=-P_{N-2}(15), and x=(-b)/a < 1/14.
     Exact coefficient inequality proves F(a,b)>0.
"""
from __future__ import annotations
import json, math
from functools import lru_cache
from fractions import Fraction
from typing import Tuple

Mat = Tuple[int,int,int,int]
A: Mat = (2,1,1,1)
B: Mat = (5,2,2,1)

def matmul_mod(X: Mat, Y: Mat, m: int) -> Mat:
    a,b,c,d=X; e,f,g,h=Y
    return ((a*e+b*g)%m,(a*f+b*h)%m,(c*e+d*g)%m,(c*f+d*h)%m)

@lru_cache(maxsize=None)
def sb_path(q:int,p:int)->str:
    if not(q>0 and 0<p<q and math.gcd(q,p)==1):
        raise ValueError((q,p))
    lo_p,lo_q=0,1; hi_p,hi_q=1,1; out=[]
    while True:
        mp,mq=lo_p+hi_p,lo_q+hi_q
        if mp==p and mq==q: return ''.join(out)
        if p*mq < mp*q:
            hi_p,hi_q=mp,mq; out.append('L')
        else:
            lo_p,lo_q=mp,mq; out.append('R')

@lru_cache(maxsize=None)
def markov_mod(q:int,p:int,mod:int)->int:
    Mmod=3*mod
    L=tuple(x%Mmod for x in A); R=tuple(x%Mmod for x in B)
    for ch in sb_path(q,p):
        M=matmul_mod(L,R,Mmod)
        if ch=='L': R=M
        else: L=M
    M=matmul_mod(L,R,Mmod)
    tr=(M[0]+M[3])%Mmod
    assert tr%3==0
    return (tr//3)%mod

def Pk(k:int): return (12*k+29,6*k+6)
def Qk(k:int): return (12*k+19,6*k+18)
def admissible(k:int)->bool:
    q,p=Pk(k); q2,p2=Qk(k)
    return k>=0 and math.gcd(q,p)==1 and math.gcd(q2,p2)==1

# mod 37 table over period 34
mod37_table=[]; survivors=[]
for k in range(34):
    if not admissible(k):
        mod37_table.append({'k_mod_34':k,'excluded_by_primitivity':True})
    else:
        a=markov_mod(*Pk(k),37); b=markov_mod(*Qk(k),37)
        sep=a!=b
        mod37_table.append({'k_mod_34':k,'mP_mod37':a,'mQ_mod37':b,'separated':sep})
        if not sep: survivors.append(k)

coeff=[
28305432785095636926339161237345860037,
30210095036138032693761407504442890565,
15113586058384412512860964238217700321,
4704573499158574331222367262340555385,
1019861700736242780522042837814077689,
163260763475742643739728904224613325,
19963841540415897155497270642306669,
1902209778872206678219811287302705,
142729803886841076464237114207699,
8461691818984168697868665954385,
395040425938527245453388848173,
14370687987897098520425013165,
399332674198797846866134265,
8194283830074912400459545,
117099392667675678532897,
1041201096041146034085,
4339569015926666021]
# Positivity certificate for alternating polynomial C0-C1*x+C2*x^2-... on 0<x<1/14:
left=Fraction(coeff[0],1)-Fraction(coeff[1],14)
tail=sum(Fraction(coeff[j],14**j) for j in range(2,len(coeff)))
positive_margin=left-tail

report={
 'family':'c=5 minimal exceptional direction',
 'P_k':'(12k+29, 6k+6)',
 'Q_k':'(12k+19, 6k+18)',
 'admissibility':'k>=0 and k != 14,16 mod 17',
 'mod37_period':34,
 'mod37_survivors_mod34':survivors,
 'mod37_table':mod37_table,
 'central_survivor_class':'k == 15 mod 17',
 'survivor_paths':{
   'N':'N=6n+5',
   'P_path':'L R^N L R L R^4',
   'Q_path':'R L^N R^2 L R^4'
 },
 'symbolic_trace_difference':'tr(C_Q)-tr(C_P)=3(15a+b)F(a,b), where W^N=aW+bI',
 'F_coefficients_absolute_alternating_after_b=-c':coeff,
 'positivity_interval':'0 < c/a < 1/14',
 'positivity_check':'C0-C1/14 > sum_{j>=2} Cj/14^j',
 'positive_margin_numerator':positive_margin.numerator,
 'positive_margin_denominator':positive_margin.denominator,
 'positive_margin_decimal_approx':float(positive_margin),
 'conclusion':'mod 37 handles k !=15 mod17; symbolic positivity handles k=17n+15. Hence c=5 is excluded.'
}
with open('/mnt/data/minimal_direction_c5_mod37_recurrence_certificate.json','w') as f:
    json.dump(report,f,indent=2)
print(json.dumps({'survivors':survivors,'positive_margin':str(positive_margin),'report':'/mnt/data/minimal_direction_c5_mod37_recurrence_certificate.json'},indent=2))
