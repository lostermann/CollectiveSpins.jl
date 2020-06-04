using CollectiveSpins, QuantumOptics

# System
N = 25
d = 0.33
pos = CollectiveSpins.geometry.chain(d, N)
S = CollectiveSpins.SpinCollection(pos, [1., 0., 0.])

# Basis and State
b = CollectiveSpins.ReducedSpinBasis(N, 1)
Heff = CollectiveSpins.reducedspin.Hamiltonian_nh(b, S)
psi = eigenstates(dense(Heff))[2][end]

# Grid and Field
I_exp(r) = CollectiveSpins.field.intensity(r, S, psi)

x = collect(range(-5.0, stop=N*d+5.0, length=80))
y = collect(range(-10.0, stop=10.0, length=80))
z = 3*d
G =[[x1, y1, z1] for z1=z, y1=y, x1=x];

I_profile = [real(I_exp(g)) for g=G]

# Visualize
using PyPlot
figure(figsize=(8, 3))
contourf(x, y, I_profile, 200,cmap="viridis")
for i = 1:N
	alpha_ = abs.(dagger(CollectiveSpins.reducedspinstate(b,[i]))*psi)
	plot(pos[i][1],pos[i][2],"wo",markersize=5,alpha=3*alpha_)
end
xlabel(L"$x / \lambda_0$")
ylabel(L"y / \lambda_0")
title("Most Subradiant State in a Chain of 25 Atoms")
tight_layout()

savefig("chain_25.png", dpi=300)