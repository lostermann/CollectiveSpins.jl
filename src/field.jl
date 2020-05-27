module field

using QuantumOptics, LinearAlgebra
using ..system, ..meanfield, ..mpc, ..quantum

"""
    field.greenstensor(r)
    
    Calculate the (scaled) Green's Tensor at a position in R3.
    
    Arguments:
    * `r`: vector in R3
"""
function greenstensor(r::Vector)
    @assert length(r)== 3 # 3D vectors
    n = normalize(r)
    x = 2*pi*norm(r) # Everything in units of lambda
    
    G = exp(1.0im*x)*((1.0/x + 1.0im/x^2 - 1.0/x^3)*Matrix(1.0I, 3, 3)
            - kron(transpose(n), n)*(1.0/x + 3.0im/x^2 - 3.0/x^3))
    
    return G
end

"""
    field.intensity(S, state)
    
    Arguments:
    * `S`: SpinCollection System
    * `state`: system state (Independent, Meanfield, MPC or Quantum)
"""
function intensity(r::Vector{Float64}, S::SpinCollection, state::Union{Vector, ProductState, MPCState, StateVector, DenseOpType})
    N = length(S.spins)
    @assert length(r) == 3

    if isa(state, ProductState)
     @assert N == state.N
     SM = 0.5*(meanfield.sx(state) - 1im*meanfield.sy(state))
    return norm(sum(greenstensor(r-S.spins[i].position)*S.polarizations[i]*SM[i] for i=1:N))^2
    elseif isa(state, MPCState)
        @assert N == state.N
        SM = 0.5*(mpc.sx(state) - 1im*mpc.sy(state))
        return norm(sum(greenstensor(r-S.spins[i].position)*S.polarizations[i]*SM[i] for i=1:N))^2
    elseif (isa(state, StateVector) || isa(state, DenseOpType))
        sm(i) = embed(quantum.basis(S), i, sigmam(SpinBasis(1//2)))
        e(r, i) = greenstensor(r - S.spins[i].position) * S.polarizations[i]
    intensity = sum(dot(e(r, i), e(r, j))*dagger(sm(i))*sm(j) for i=1:N, j=1:N)
    return expect(intensity, state)
    end
end

end # module
