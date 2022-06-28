# d7399
# Plotting methods

module Plotting
export draw, drawsubplots

using Plots
using ..Calculus: RealSeries, Series, fourier

plotlyjs()  # use the js backend

"""Animate math function with subplots"""
function drawsubplots(f::Function, n::Integer, L::Number; step=0.1)
    # n = Number of terms to calculate
    # L = what t/x needs to vary by to display the entire plot (default from -L to L)
    #
    # Can be thought of as REAL x → COMPLEX y
    # Or as PARAMETERISED REAL t → REAL (x, y)
    x = -L:step:L
    series = fourier(f, L, n)
    y = series.f.(x)
    return drawsubplots(x, y; L=L)
end


"""Animate the series"""
function drawsubplots(series::Series; step=0.005)
    t = -1:step:1
    y = series.f.(t)
    return drawsubplots(t, y)
end


"""Make the animated plot with Real/Complex subplots"""
function drawsubplots(x::AbstractArray, y::AbstractArray; L=1, fps=15)
    # Support for y to be complex, but not x
    m = max(maximum(real.(y)), maximum(imag.(y)))
    anim = @animate for i ∈ 1:length(x)
        rai = plot(x[1:i], [real(y[1:i]), imag(y[1:i])], label=["real" "imaginary"], xlims=(-1, 1), ylims=(-m, m))
        ri = plot(real(y[1:i]), imag(y[1:i]))
        plot(rai, ri, layout=(1,2))
    end
    gif(anim; fps=fps)
end


"""Just draw the gif using the plot backend"""
function draw(series::Series; step=0.01, fps=15)
    t = -1:step:1
    y = series.f.(t)
    anim = @animate for i ∈ 1:length(t)
        plot(real(y[1:i]), imag(y[1:i]), label="", xlims=(-1,1), ylims=(-1, 1))
    end
    gif(anim; fps=fps)
end

end # module
