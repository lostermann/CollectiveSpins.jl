using CollectiveSpins, QuantumOptics

# Geometry
N1 = 10
d = 0.1
R = CollectiveSpins.geometry.ring_rd(d, N1)
x = 0.15
ring = CollectiveSpins.geometry.ring(d, N1, distance = true)
Geo = vcat([ ring[i] - [R+x/2, 0., 0.] for i=1:N1 ], [ ring[i] + [R+x/2, 0., 0.] for i=1:N1])
dip = CollectiveSpins.geometry.ring_p_tangential(N1)
Dip = vcat(dip, -dip)
S = CollectiveSpins.SpinCollection(Geo, Dip)

# Q-System
b = CollectiveSpins.ReducedSpinBasis(N1+N1, 1)
Heff = CollectiveSpins.reducedspin.Hamiltonian_nh(b, S, i_s=1, i_e=N1)
states = eigenstates(dense(Heff))[2]

Heff = CollectiveSpins.reducedspin.Hamiltonian_nh(b, S)


projector(psi) = sum(expect(dm(CollectiveSpins.reducedspinstate(b, i)),psi) for i=N1+1:2*N1)


using PyPlot
figure(figsize=(10, 4))
tspan = [0:0.01:50;]

for i = 1:5
	psi0 = states[end-i+1]
	tout,psit = timeevolution.schroedinger(tspan, psi0, Heff)
#	tout,psit = CollectiveSpins.reducedspin.timeevolution(tspan, S, psi0)
	subplot(2,3,i)
	plot(tout,projector.(psit))
	xlabel("t / Γ₀")
	ylabel("2.Ring population")
end

tight_layout()
show()