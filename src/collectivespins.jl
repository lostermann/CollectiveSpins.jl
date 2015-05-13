module collectivespins

export Spin, SpinCollection, CavityMode, CavitySpinCollection,
        geometry

include("system.jl")
include("geometry.jl")
include("interaction.jl")
include("effective_interaction.jl")
include("effective_interaction_simple.jl")
include("effective_interaction_noisy.jl")
include("rotatedeffective_interaction.jl")
include("independent.jl")
include("quantum.jl")
include("meanfield.jl")
include("mpc.jl")
include("io.jl")

using .system
using .quantum
using .meanfield
using .mpc

end # module
