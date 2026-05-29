#!/usr/bin/env python3
# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
"""
Finite-moduli escape construction for terminal exceptional pairs.

Given a finite set of moduli, this script constructs an infinite-family witness
showing that those moduli cannot separate all terminal exceptional pairs.

It uses the subfamily
    P_T = (13T+2, 1),        path L^(13T)
    Q_T = (7T+2, 7T+1),     path R^(7T)
corresponding to r=7T, h=6T, s=13T.
For any finite modulus set, choose T to be a common period of the Cohn residue
automata for the unary L and R paths modulo each modulus. Then P_T and Q_T
have equal Markov residues modulo every modulus in the set.
"""
from __future__ import annotations
import argparse, json, math, sys
from typing import Tuple, Dict, List

Mat = Tuple[int,int,int,int]
A0: Mat = (2,1,1,1)
B0: Mat = (5,2,2,1)

def mat_mul(X: Mat, Y: Mat, mod: int) -> Mat:
    a,b,c,d = X; e,f,g,h = Y
    return ((a*e+b*g)%mod, (a*f+b*h)%mod, (c*e+d*g)%mod, (c*f+d*h)%mod)

def cohn_start(mod: int) -> Tuple[Mat,Mat]:
    return tuple(x%mod for x in A0), tuple(x%mod for x in B0)  # type: ignore

def cohn_step(state: Tuple[Mat,Mat], letter: str, mod: int) -> Tuple[Mat,Mat]:
    L,R=state; M=mat_mul(L,R,mod)
    if letter=='L': return L,M
    if letter=='R': return M,R
    raise ValueError(letter)

def trace(M: Mat) -> int:
    return M[0]+M[3]

def residue(state: Tuple[Mat,Mat], modulus: int) -> int:
    mod=3*modulus
    L,R=state; M=mat_mul(L,R,mod); tr=trace(M)%mod
    assert tr%3==0
    return (tr//3)%modulus

def period(letter: str, modulus: int, limit: int=10_000_000) -> int:
    mod=3*modulus
    st=cohn_start(mod)
    seen={st:0}
    n=0
    while True:
        st=cohn_step(st,letter,mod); n+=1
        if st in seen:
            if seen[st] != 0:
                raise RuntimeError(f"nonzero preperiod for {letter} mod {modulus}")
            return n
        seen[st]=n
        if n>limit:
            raise RuntimeError(f"period search exceeded {limit} for {letter} mod {modulus}")

def lcm(a:int,b:int)->int:
    return a//math.gcd(a,b)*b

def compute_escape(moduli: List[int]) -> Dict:
    periods=[]
    per_detail={}
    T=1
    for m in moduli:
        pL=period('L',m)
        pR=period('R',m)
        per_detail[str(m)]={'L_period':pL,'R_period':pR}
        periods.extend([pL,pR])
        T=lcm(T,pL); T=lcm(T,pR)
    r=7*T; h=6*T; s=13*T
    P=(13*T+2,1)
    Q=(7*T+2,7*T+1)
    # sanity residue check using periods, but also compute directly by stepping period-efficiently.
    residues={}
    for m in moduli:
        mod=3*m
        stL=cohn_start(mod)
        for _ in range((13*T)%per_detail[str(m)]['L_period']):
            stL=cohn_step(stL,'L',mod)
        stR=cohn_start(mod)
        for _ in range((7*T)%per_detail[str(m)]['R_period']):
            stR=cohn_step(stR,'R',mod)
        residues[str(m)]={'P':residue(stL,m),'Q':residue(stR,m),'equal':residue(stL,m)==residue(stR,m)}
    return {
        'moduli':moduli,
        'periods':per_detail,
        'common_period_T':T,
        'terminal_parameters':{'r':r,'h':h,'s':s,'s_over_r':f'{s}/{r}=13/7'},
        'points':{'P_qp':P,'Q_qp':Q},
        'primitive_endpoints': math.gcd(*P)==1 and math.gcd(*Q)==1,
        'exceptional_window': 4*r<5*h and 8*h<7*r and math.gcd(r,h)>1,
        'residues':residues,
        'all_equal': all(v['equal'] for v in residues.values())
    }

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--moduli',nargs='+',type=int,default=[2,3,5,7,11,13,17,19])
    ap.add_argument('--out',required=True)
    args=ap.parse_args()
    rep=compute_escape(args.moduli)
    with open(args.out,'w') as f: json.dump(rep,f,indent=2,sort_keys=True)
    print(json.dumps({'T':rep['common_period_T'],'P':rep['points']['P_qp'],'Q':rep['points']['Q_qp'],'all_equal':rep['all_equal']},indent=2))
if __name__=='__main__': main()
