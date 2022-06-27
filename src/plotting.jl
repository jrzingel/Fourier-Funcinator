# d7399
# Plotting methods

module Plotting
export makeanimation, draw, render

using Plots
using ..Calculus: RealSeries, Series

plotlyjs()  # use the js backend

"""Animate math function"""
function makeanimation(f::Function, n::Integer, L::Number; step=0.1)::Animation
    # n = Number of terms to calculate
    # L = what t/x needs to vary by to display the entire plot (default from -L to L)
    #
    # Can be thought of as REAL x → COMPLEX y
    # Or as PARAMETERISED REAL t → REAL (x, y)
    x = -L:step:L
    series = fourier(f, L, n)
    y = series.f.(x)
    return makeanimation(x, y; L=L)
end


"""Make the animation"""
function makeanimation(x::AbstractArray, y::AbstractArray; L=1)::Animation
    # Support for y to be complex, but not x
    m = max(maximum(real.(y)), maximum(imag.(y)))
    anim = @animate for i ∈ 1:length(x)
        rai = plot(x[1:i], [real(y[1:i]), imag(y[1:i])], label=["real" "imaginary"], xlims=(-1, 1), ylims=(-m, m))
        ri = plot(real(y[1:i]), imag(y[1:i]))
        plot(rai, ri, layout=(1,2))
    end
    return anim
end


"""Animate the series"""
function makeanimation(series::Series; step=0.005)::Animation
    t = -1:step:1
    y = series.f.(t)
    return makeanimation(t, y)
end


"""Just the draw gif"""
function draw(series::Series; step=0.01, fps=15)
    t = -1:step:1
    y = series.f.(t)
    anim = @animate for i ∈ 1:length(t)
        plot(real(y[1:i]), imag(y[1:i]), label="", xlims=(-1,1), ylims=(-1, 1))
    end
    render(anim, fps)
end


"""Render animation"""
function render(anim::Animation, fps::Integer)
    gif(anim; fps=fps)
end

end # module
