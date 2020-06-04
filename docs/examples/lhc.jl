using CollectiveSpins, QuantumOptics

lhc1 = 0.3*CollectiveSpins.geometry.lhc1()
lhc1_p = CollectiveSpins.geometry.lhc1_p()
S = CollectiveSpins.SpinCollection(lhc1, lhc1_p)

N = length(lhc1)
No = 32
Ni = 6
M = 1
b = CollectiveSpins.ReducedSpinBasis(N, M)

ψs = 1/sqrt(32)*sum(CollectiveSpins.reducedspin.reducedspinstate(b, j) for j=1:No)
ψa = 1/sqrt(32)*sum((-1)^j*CollectiveSpins.reducedspin.reducedspinstate(b, j) for j=1:No)
T = [0:0.01:20;]
touts, rhos = CollectiveSpins.reducedspin.timeevolution(T, S, ψs)
touta, rhoa = CollectiveSpins.reducedspin.timeevolution(T, S, ψa)

SZouter = sum(CollectiveSpins.reducedspin.reducedsigmaz(b, j) for j=1:No)
SZinner = sum(CollectiveSpins.reducedspin.reducedsigmaz(b, j) for j=No+1:No+Ni)

OuterS = [ (expect(SZouter, rho)+No)/2. for rho=rhos ]
InnerS = [ real(expect(SZinner, rho)+Ni)/2. for rho=rhos ]
OuterA = [ real(expect(SZouter, rho)+No)/2. for rho=rhoa ]
InnerA = [ (expect(SZinner, rho)+Ni)/2. for rho=rhoa ]

using PyPlot
figure(figsize=(10,4))
subplot(121)
title("Outer Ring")
ylim([0., 1.05])
xlabel(L"$t / \Gamma$")
plot(touts, OuterS,"r", lw=1.5)
plot(touta, OuterA, "b", lw=1.5)

subplot(122)
title("Inner Ring")
xlabel(L"$t / \Gamma$")
ylim([0., 0.0105])
plot(touts, InnerS, "r", lw=1.5)
plot(touta, InnerA, "b", lw=1.5)

savefig("lhc.png")