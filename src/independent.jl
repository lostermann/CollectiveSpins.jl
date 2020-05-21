module independent

using QuantumOpticsBase
using ..interaction, ..system

import ..integrate

# Define Spin 1/2 operators
spinbasis = SpinBasis(1//2)
sigmax_ = sigmax(spinbasis)
sigmay_ = sigmay(spinbasis)
sigmaz_ = sigmaz(spinbasis)
sigmap_ = sigmap(spinbasis)
sigmam_ = sigmam(spinbasis)
I_spin = identityoperator(spinbasis)


"""
    independent.blochstate(phi, theta[, N=1])

Product state of `N` single spin Bloch states.

All spins have the same azimuthal angle `phi` and polar angle `theta`.
"""
function blochstate(phi::Vector{T1}, theta::Vector{T2}) where {T1<:Real, T2<:Real}
    N = length(phi)
    @assert length(theta)==N
    state = zeros(Float64, 3*N)
    state[0*N+1:1*N] = cos(phi).*sin(theta)
    state[1*N+1:2*N] = sin(phi).*sin(theta)
    state[2*N+1:3*N] = cos(theta)
    return state
end

function blochstate(phi::Real, theta::Real, N::Int=1)
    state = zeros(Float64, 3*N)
    state[0*N+1:1*N] = ones(Float64, N)*cos(phi)*sin(theta)
    state[1*N+1:2*N] = ones(Float64, N)*sin(phi)*sin(theta)
    state[2*N+1:3*N] = ones(Float64, N)*cos(theta)
    return state
end

"""
    independent.dim(state)

Number of spins described by this state.
"""
function dim(state::Vector{Float64})
    N, rem = divrem(length(state), 3)
    @assert rem==0
    return N
end

"""
    independent.splitstate(state)

Split state into sx, sy and sz parts.
"""
function splitstate(state::Vector{Float64})
    N = dim(state)
    return view(state, 0*N+1:1*N), view(state, 1*N+1:2*N), view(state, 2*N+1:3*N)
end

"""
    independent.densityoperator(sx, sy, sz)
    independent.densityoperator(state)

Create density operator from independent sigma expectation values.
"""
function densityoperator(sx::Number, sy::Number, sz::Number)
    return 0.5*(identityoperator(spinbasis) + sx*sigmax_ + sy*sigmay_ + sz*sigmaz_)
end
function densityoperator(state::Vector{Float64})
    N = dim(state)
    sx, sy, sz = splitstate(state)
    if N>1
        return DenseOperator(reduce(tensor, [densityoperator(sx[i], sy[i], sz[i]) for i=1:N]))
    else
        return DenseOperator(densityoperator(sx[i], sy[i], sz[i]))
    end
end

"""
    independent.sx(state)

Sigma x expectation values of state.
"""
sx(state::Vector{Float64}) = view(state, 1:dim(state))

"""
    independent.sy(state)

Sigma y expectation values of state.
"""
sy(state::Vector{Float64}) = view(state, dim(state)+1:2*dim(state))

"""
    independent.sz(state)

Sigma z expectation values of state.
"""
sz(state::Vector{Float64}) = view(state, 2*dim(state)+1:3*dim(state))


"""
    independent.timeevolution(T, gamma, state0)

Independent time evolution.

# Arguments
* `T`: Points of time for which output will be generated.
* `gamma`: Single spin decay rate.
* `state0`: Initial state.
"""
function timeevolution(T, gammas::Vector{Float64}, state0::Vector{Float64}; kwargs...)
    N = dim(state0)
    
    @assert length(gammas) == N
    
    function f(ds::Vector{Float64}, s::Vector{Float64}, p, t)
        sx, sy, sz = splitstate(s)
        dsx, dsy, dsz = splitstate(ds)
        @inbounds for k=1:N
            dsx[k] = -0.5*gammas[k]*sx[k]
            dsy[k] = -0.5*gammas[k]*sy[k]
            dsz[k] = -gammas[k]*(1+sz[k])
        end
    end

    fout_(t::Float64, u::Vector{Float64}) = deepcopy(u)

    return integrate(T, f, state0, fout_; kwargs...)
end

timeevolution(T, gamma::Number, state0::Vector{Float64}; kwargs...) = timeevolution(T, [gamma for i=1:dim(state0)], state0; kwargs...)
"""
    independent.timeevolution(T, S::SpinCollection, state0)

Independent time evolution.

# Arguments
* `T`: Points of time for which output will be generated.
* `S`: SpinCollection describing the system.
* `state0`: Initial state.
"""
timeevolution(T, S::system.SpinCollection, state0::Vector{Float64}) = timeevolution(T, S.gammas, state0)

end # module
