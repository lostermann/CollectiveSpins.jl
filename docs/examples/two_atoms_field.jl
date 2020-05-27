using CollectiveSpins, QuantumOptics

# Quantum States
u = spinup(SpinBasis(1//2))
d = spindown(SpinBasis(1//2))
s = 1/sqrt(2)*(u ⊗ d + d ⊗ u)
a = 1/sqrt(2)*(u ⊗ d - d ⊗ u)

# System
x = 0.1
g = [[-x/2., 0., 0.], [x/2., 0., 0.]]
dip = [1., 0., 0.]
S = CollectiveSpins.SpinCollection(g, dip)

Fs(r) = CollectiveSpins.field.intensity(r, S, s)
Fa(r) = CollectiveSpins.field.intensity(r, S, a)


# Create grid and field data
L = collect(range(-35., stop=35., length=200))
Ps = [Fs([L[i], L[j], 1.5]) for j=1:length(L), i=1:length(L)]
Pa = [Fa([L[i], L[j], 1.5]) for j=1:length(L), i=1:length(L)]

# Visualize
using PyPlot
figure(figsize=(10,4))
subplot(121)
contour(L, L, Ps,500, colors="yellow")
colorbar(pad = 0.01)
contourf(L, L, Ps,cmap="viridis")
plot([-x/2,x/2], [0.0,0.0],"wo",markeredgecolor="k")
title("Superradiance")
subplot(122)
contour(L, L, Pa, 500, colors="cyan")
colorbar(pad = 0.01)
contourf(L, L, Pa,cmap="viridis")
plot([-x/2,x/2], [0.0,0.0],"wo",markeredgecolor="k")
title("Subradiance")

savefig("field.png", dpi=300)