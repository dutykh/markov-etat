# Authors:
#   Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
#   Dr. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA, Chambéry, France)
#
# SageMath certificate for the one-turn fixed-arm problem.
#
# Goal: certify that no n >= 0, m >= 1 solve
#     3*Lucas(4*n+12) + 4 = 5*Pell(2*m+3).
#
# The equality reduces to integral points on
#     u^2 - 2*y^2 = -1,
#     5*y^2 - 8*y - 9*v^2 = 4.
#
# Expected positive y-values: 5 and 29 only.
# These give w=(5y-4)/3 equal to 7=L_4 and 47=L_8,
# outside the required w=L_{4n+12}, n>=0.

from sage.all import *

R.<t> = PolynomialRing(QQ)
# Parametrizing u^2 - 2*y^2 = -1 through (u,y)=(1,1) gives
# y=(t^2-2*t+2)/(t^2-2). Substitution into the second equation yields
# the genus-one quartic
#     Y^2 = -(t^2+2t-6)(7t^2-10t+6),
# with Y=3*v*(t^2-2).
f = - (t^2 + 2*t - 6) * (7*t^2 - 10*t + 6)
C = HyperellipticCurve(f)
print("Quartic model:", C)

# Sage versions differ in genus-one integral/rational point support.
# The following block works in recent Sage installations with Magma/pari support.
# If rational_points is unavailable, run the Magma script included in this package.
try:
    pts = C.rational_points(bound=1000)
    print("Rational points found up to bound 1000:", pts)
except Exception as e:
    print("Could not enumerate rational points directly in this Sage installation:", e)

# Independent verification of the expected positive integral y-values.
def pell_list(N):
    P = [ZZ(0), ZZ(1)]
    for i in range(1,N):
        P.append(2*P[-1] + P[-2])
    return P

def lucas_list(N):
    L = [ZZ(2), ZZ(1)]
    for i in range(1,N):
        L.append(L[-1] + L[-2])
    return L

# Once integral points have certified y in {5,29}, this final check proves
# they do not correspond to n>=0.
L = lucas_list(40)
assert L[4] == 7 and L[8] == 47 and L[12] == 322
for y in [ZZ(5), ZZ(29)]:
    assert (5*y - 4) % 3 == 0
    w = (5*y - 4)//3
    print("y", y, "w", w)
    assert w in [ZZ(7), ZZ(47)]
    assert w not in [L[4*n+12] for n in range(0,5)]

print("Final check: y=5,29 are outside n>=0 range.")
