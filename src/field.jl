module field

using QuantumOpticsBase, LinearAlgebra
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
    
    G = exp(1im*x)*(1/x+1/x^2-1/x^3)*Matrix(1.0I, 3, 3)
            - kron(n, n)*(1/x + 3im/x^2-3/x^3)
    
    return G
end

"""
    field.amplitude(S, state)
    
    Arguments:
    * `S`: SpinCollection System
    * `state`: system state (Independent, Meanfield, MPC or Quantum)
"""
function amplitude(S::SpinCollection, state::Union{Vector, ProductState, MPCState, QuantumOpticsBase.Basis})
    N = length(S.spins)
    @assert N == state.N

    if isa(state, ProductState)
     SM = 0.5*(meanfield.sx(state) - 1im*meanfield.sy(state))
    elseif isa(state, MPCState)
        SM = 0.5*(mpc.sx(state) - 1im*mpc.sy(state))
    end

    function E(r::Vector{Float64})
        @assert length(r) == 3
        return sum(greenstensor(r-S.spins[i].position)*S.polarizations[i]*SM[i] for i=1:N)
    end

    return E
end

"""
    field.intensity(S, state)
   
    Return the field intesnity as a funciton of a point in R3.
 
    Arguments:
    * `S`: SpinCollection system
    * `state`: State
"""
function intensity(S::SpinCollection, state::Union{Vector, ProductState, MPCState, QuantumOpticsBase.Basis})
    E = amplitude(S, state)
    
    function F(r::Vector{Float64})
        @assert length(r) == 3
        return norm(E(r))^2
    end
    
    return F
end

end # module
