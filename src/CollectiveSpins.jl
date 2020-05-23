module CollectiveSpins

include("system.jl")
include("timeevolution_base.jl")
include("geometry.jl")
include("interaction.jl")
include("quantum.jl")
include("reducedspin.jl")
include("independent.jl")
include("meanfield.jl")
include("mpc.jl")
include("field.jl")

using .system
using .quantum
using .meanfield
using .mpc
using .reducedspin
using .interaction
using .field

end # module
