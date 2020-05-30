using CollectiveSpins

Γ = 1.0
r1(x) = [x, 0., 0.]
r2 = [0., 0., 0.]
e = [0., 0., 1.]
γ(x) = CollectiveSpins.interaction.Gamma(r1(x), r2, e, e, Γ, Γ)

L = [0.:0.05:3.;]

using PyPlot
plot(L, Γ .+ γ.(L), "r")
plot(L, Γ .- γ.(L), "b")
tight_layout()
savefig("two_atoms_s_a_rates.svg")