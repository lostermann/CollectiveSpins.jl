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

state = sum(exp(1im*i*pi)*CollectiveSpins.reducedspinstate(b, [i]) for i=1:N1)

T = [0:0.05:5;]
tout, rho_t = CollectiveSpins.reducedspin.timeevolution(T, S, state)

F(r) = real(CollectiveSpins.field.intensity(r, S, rho_t[end]))

# Visualize
X = collect(range(-5*R, stop=5*R, length=61))
Y = collect(range(-5*R, stop=5*R, length=61))
Z = 1.5*R
G = [[x1, y1, z1] for z1=Z, y1=Y, x1=X]

using PyPlot
figure(figsize=(5, 5))

I_profile = [F(gr) for gr=G]

contourf(X, Y, I_profile, 100,cmap="viridis")
for i = 1:N1+N1
	alpha_ = abs(dagger(CollectiveSpins.reducedspinstate(b,i))*state)
	plot(Geo[i][1],Geo[i][2],"wo",markersize=6,alpha=0.1+0.9*alpha_)
end

savefig("ring.png", dpi=300)