using CollectiveSpins

# Create the initial state in a system of 5 independent spins
theta = 0.
phi = 0.
N = 5

s_initial = CollectiveSpins.independent.blochstate(phi, theta, N)

# Time evolution with 5 different decay rates
T = [0:0.05:2;] # time span
gammas = [1., 2., 3., 4., 5.] # decay rates

tout, s_t = CollectiveSpins.independent.timeevolution(T, gammas, s_initial)

# Visualize the 5 <dz> expectation values
using PyPlot

SZ = CollectiveSpins.independent.sz.(s_t)

plot(tout, SZ)
xlabel(L"\Gamma t")
ylabel(L"\langle \sigma^z_i \rangle")
tight_layout()
savefig("independent.svg")
