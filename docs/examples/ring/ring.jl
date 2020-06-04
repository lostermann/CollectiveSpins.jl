using CollectiveSpins, QuantumOptics

# Geometry
N1 = 10
d = 0.1
R = CollectiveSpins.geometry.ring_rd(d, N1)
x = 0.1
ring = CollectiveSpins.geometry.ring(d, N1, distance = true)
Geo = vcat([ ring[i] - [R+x/2, 0., 0.] for i=1:N1 ], [ ring[i] + [R+x/2, 0., 0.] for i=1:N1])
dip = [[-sin(2*pi*j/N1), cos(2*pi*j/N1), 0] for j=0:(N1-1)]
Dip = vcat(dip, dip)
S = CollectiveSpins.SpinCollection(Geo, Dip)

# Q-System
b = CollectiveSpins.ReducedSpinBasis(N1+N1, 1)

state = normalize!(sum(exp(1im*i*pi)*CollectiveSpins.reducedspinstate(b, [i]) for i=1:N1))

T = [0:0.05:100;]
tout, rho_t = CollectiveSpins.reducedspin.timeevolution(T, S, state)

# Export Data for each Frame
X = collect(range(-5*R, stop=5*R, length=61))
Y = collect(range(-5*R, stop=5*R, length=61))
Z = 1.5*R
G = [[x1, y1, z1] for z1=Z, y1=Y, x1=X]

using JLD

Threads.@threads for k=1:length(tout)
	F(r) = real(CollectiveSpins.field.intensity(r, S, rho_t[k]))
	I_profile = [F(gr) for gr=G]

	alpha_ = Float64[]
	for i = 1:N1+N1
		push!(alpha_, real(expect(dm(CollectiveSpins.reducedspinstate(b,[i])), rho_t[k])))
	end

	save("$k.jld", "X", X, "Y", Y, "I_profile", I_profile, "Geo", Geo, "N1", N1, "alpha_", alpha_, "t", tout[k])
end
