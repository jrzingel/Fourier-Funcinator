# To startup the development session do the following
# - Create a new REPL.
# - Activate the correct project, update, etc
# - Start revise "using Revise"
# - Add project dependencies "using Fourier"
# - Run this code (Play button)

# Activate @debug
using Fourier
ENV["JULIA_DEBUG"] = Fourier


p = Fourier.load("james.svg")
s = Fourier.series(p, 30)
println(Fourier.todesmos(s))
