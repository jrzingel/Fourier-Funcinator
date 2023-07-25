# To startup the development session do the following
# - Create a new REPL.
# - Activate the correct project, update, etc
# - Start revise "using Revise" (if wanting a dev environment)
# - Add project dependencies "using Fourier"
# - Run this code (Play button in VS code)

# Activate @debug
#=
using Revise
using Fourier
ENV["JULIA_DEBUG"] = Fourier
=#

fname = "ship"

p = Fourier.load(fname * ".svg")
s = Fourier.series(p, 30)


# To output a pasteable function for desmos.com use
println(Fourier.todesmos(s))

# Otherwise to generate a .gif animation
Fourier.animate_series(s, fname=fname*".gif", frames=600)
