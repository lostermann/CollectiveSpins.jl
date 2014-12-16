using quantumoptics, collectivespins

# System parameters
const γ = 1.
const e_dipole = [0,0,1.]
const T = [0:0.05:5]

const system = SpinCollection(geometry.chain(0.2, 3), e_dipole, γ)
const N = length(system.spins)

# Initial state (Bloch state)
const phi = 0.
const theta = pi/2.

const sx0 = cos(phi)*sin(theta)
const sy0 = sin(phi)*sin(theta)
const sz0 = cos(theta)


# Quantum: master equation
Ψ₀ = collectivespins.quantum.blochstate(phi,theta,N)
ρ₀ = Ψ₀⊗dagger(Ψ₀)
@time tout, ρ_t = collectivespins.quantum.timeevolution(T, system, ρ₀)

# Meanfield
state0 = collectivespins.meanfield.blochstate(phi,theta,N)
@time tout, state_mf_t = collectivespins.meanfield.timeevolution(T, system, state0)
@time tout, state_mf_t = collectivespins.meanfield.timeevolution(T, system, state0)

# Meanfield + Correlations
state0 = collectivespins.meanfield2.blochstate(phi,theta,N)
@time tout, state_cor_t = collectivespins.meanfield2.timeevolution(T, system, state0)
@time tout, state_cor_t = collectivespins.meanfield2.timeevolution(T, system, state0)


# Expectation values
sx_indep = exp(-0.5*γ*T)*sx0
sy_indep = exp(-0.5*γ*T)*sy0
sz_indep = 1 - exp(-γ*T)*(1-sz0)

sx_mf = map(s->(collectivespins.meanfield.sx(s)[1]), state_mf_t)
sy_mf = map(s->(collectivespins.meanfield.sy(s)[1]), state_mf_t)
sz_mf = map(s->(collectivespins.meanfield.sz(s)[1]), state_mf_t)

sx_cor = map(s->(collectivespins.meanfield2.sx(s)[1]), state_cor_t)
sy_cor = map(s->(collectivespins.meanfield2.sy(s)[1]), state_cor_t)
sz_cor = map(s->(collectivespins.meanfield2.sz(s)[1]), state_cor_t)

rhop_t = map(x->ptrace(x, [2:N]), ρ_t)
sx_master = expect(sigmax, rhop_t)
sy_master = expect(sigmay, rhop_t)
sz_master = expect(sigmaz, rhop_t)


# Visualization
using PyCall
@pyimport matplotlib.pyplot as plt

#name = "cube_atoms=8_d=22925"
#name = "cube_atoms=8_d=0627"
name = "cube_atoms=8_d=015"
# name = "chain_atoms=8_d=07"

plt.figure(figsize=(6,4))
plt.plot(T, -sz_master, lw=3.0, color="darkorange", label="Collective")
plt.plot(T, -sz_indep, lw=3.0, color="gray", label="Independent")
#plt.plot(T_smf, -sz_smf, label="symmetric meanfield")
plt.plot(T, -sz_mf, "-", lw=1.5, color="navy", label="Mean-field")
plt.plot(T, -sz_cor, "-", lw=1.5, color="green", label="Correlations")
plt.ylabel("\$-\\langle\\sigma_z\\rangle\$")
plt.ylim(-1,1)
plt.legend()
#plt.savefig("images/$(name)_sigmaz_timeevolution.pdf")

plt.figure(figsize=(6,4))
plt.plot(T, sx_master, lw=3.0, color="darkorange", label="Collective")
plt.plot(T, sx_indep, lw=3.0, color="gray", label="Independent")
#plt.plot(T_smf, sx_smf, label="symmetric meanfield")
plt.plot(T, sx_mf, "-", lw=1.5, color="navy", label="Mean-field")
plt.plot(T, sx_cor, "-", lw=1.5, color="green", label="Correlations")
plt.ylabel("\$\\langle\\sigma_x\\rangle\$")
plt.ylim(-1,1)
plt.legend()
#plt.savefig("images/$(name)_sigmax_timeevolution.pdf")

plt.figure(figsize=(6,4))
plt.plot(T, sy_master, lw=3.0, color="darkorange", label="Collective")
plt.plot(T, sy_indep, lw=3.0, color="gray", label="Independent")
#plt.plot(T_smf, sy_smf, label="symmetric meanfield")
plt.plot(T, sy_mf, "-", lw=1.5, color="navy", label="Mean-field")
plt.plot(T, sy_cor, "-", lw=1.5, color="green", label="Correlations")
plt.ylabel("\$\\langle\\sigma_y\\rangle\$")
plt.ylim(-1,1)
plt.legend()
#plt.savefig("images/$(name)_sigmay_timeevolution.pdf")

# plt.figure(figsize=(6,4))
# plt.plot(T, error_mf, lw=1.2, color="navy", label="Mean-field")
# plt.plot(T, error_cor, lw=1.2, color="green", label="Correlation")
# plt.xlabel("Time [\$\\gamma^{-1}\$]")
# plt.ylabel("Error (Trace distance)")
# plt.ylim(0,1)
# plt.legend()
# plt.savefig("images/$(name)_error_timeevolution.pdf")

plt.show()
#println("⦑H⟩ = ", trunc(real(exp), 3))
#println("⦑H⟩ = ", trunc(real(exp_mean), 3))
