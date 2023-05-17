# To startup the development session do the following
# - Create a new REPL.
# - Activate the correct project, update, etc
# - Start revise "using Revise"
# - Add project dependencies "using Fourier"
# - Run this code (Play button)

# Activate @debug
using Revise
using Fourier
ENV["JULIA_DEBUG"] = Fourier


p = Fourier.load("spiral.svg")
s = Fourier.series(p, 20)
#println(Fourier.todesmos(s))

println("Creating new series")
Fourier.animate_series(s, fname="spiral.gif")
