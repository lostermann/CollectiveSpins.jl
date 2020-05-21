import OrdinaryDiffEq, DiffEqCallbacks

"""
integrate(T, f, state0, fout; alg=OrdinaryDiffEq.DP5(), callback=nothing, kwargs...)

Generic integration function that handles time integration via the DifferentialEquations package.

# Arguments:

* `T`: Vector of time steps
* `f`: Integrating function
* `state0`: Initial condition
``fout`: return function
* `alg`: Set the algorithm that is used by DifferentialEquations
* `callback`: callback function to DifferentialEquations
* `kwargs...`: furhter keyword arguments passed on to the solver
"""
function integrate(T::Vector{Float64}, f:: Function, state0::S, fout::Function;
                    alg::OrdinaryDiffEq.OrdinaryDiffEqAlgorithm = OrdinaryDiffEq.DP5(),
                    callback = nothing, kwargs...) where S

    if isa(state0, Vector{Float64})
        x0 = state0
    else
        x0 = state0.data
    end
    
    fout_diff(u::Vector{Float64}, t::Float64, integrator) = fout(t, S(deepcopy(u)))        

    out_type = pure_inference(fout, Tuple{eltype(T),typeof(state0)})
    out = DiffEqCallbacks.SavedValues(Float64,out_type)
    scb = DiffEqCallbacks.SavingCallback(fout_diff,out,saveat=T,
                                        save_everystep=false,
                                        save_start = false)

    prob = OrdinaryDiffEq.ODEProblem(f, x0, (T[1], T[end]))

    full_cb = OrdinaryDiffEq.CallbackSet(callback, scb)

    sol = OrdinaryDiffEq.solve(prob, alg;
            reltol=1.0e-6,
            abstol=1.0e-8,
            save_everystep = false,
            save_start = false,
            save_end = false,
            callback=full_cb,
            kwargs...)

    out.t, out.saveval

end

Base.@pure pure_inference(fout,T) = Core.Compiler.return_type(fout, T)
