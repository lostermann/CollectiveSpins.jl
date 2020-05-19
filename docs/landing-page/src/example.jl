using CollectiveSpins

# Define geometry of system
N = 20     # Number of spins
a = 0.3   # spin-spin distance
geometry = CollectiveSpins.geometry.chain(a, N)

# Create system consisting of N spins in the defined geometry
e = [0,0,1]   # Quantization axis
system = CollectiveSpins.SpinCollection(geometry, e)

# Initial quantum state
phi = 0.
theta = pi/2
Ψ0 = CollectiveSpins.mpc.blochstate(phi, theta, N)

# Perform time evolution according to master equation
T = [0:0.05:5.;]
tout, ρt = CollectiveSpins.mpc.timeevolution(T, system, Ψ0, dt=0.01)

# Plot <sz> and <sx> expectations values ofr all N spins
using PyPlot
SZ = [CollectiveSpins.mpc.sz(ρ) for ρ in ρt]
SX = [CollectiveSpins.mpc.sx(ρ) for ρ in ρt]

subplot(211)
plot(tout, SZ)
xlabel("Time")
ylabel("SZ")

subplot(212)
plot(tout, SX)
xlabel("Time")
ylabel("SX")

tight_layout()
savefig("example.svg")