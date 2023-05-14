# d7399, d7712
# Calculate the complex Fourier series of a given function

using Statistics


"""Normalise (and recenter) a path from 0-1"""
function normalise!(p::Path)
    p.x .-= mean(p.x)
    p.x /= abs(argmax(abs2, p.x))
    p.y .-= mean(p.y)
    p.y /= abs(argmax(abs2, p.y))
end


"""Numerically integrate under the given points. Rescale from [a,b]"""
function integrate(y::AbstractVector, a::Number, b::Number)::Number
    # Uses Simpson's rule
    s = y[1] + y[end]
    for (i, v) in enumerate(y[2:end-1])
        if i % 2 != 0  # odd index
            s += 2*v
        else
            s += 4*v
        end
    end
    return (b-a)/(3*length(y)) * s
end


"""Calculate the Fourier series from a series of points
n : Number of positive complex terms (2n+1 actual terms)
The given function plots the series from [-1/2, 1/2]"""
function series(path::Path, n::Integer)::Series

    normalise!(path)  # Convert to complex
    p = vec(path.x + im*path.y)

    xrange = range(-1, 1, size(path.x, 1))
    cn = zeros(Complex, n*2+1)

    # Calculate each coefficient by integration (integrate over all points in the path)
    for k in -n:1:n
        cn[k+n+1] = integrate(
            [p[i] * exp(-k*π*im*x) for (i, x) in enumerate(xrange)],
            -1, 1)
    end
    cn /= 2  # Normalisation. Assume L=1
    ∑(x) = sum([  # Calculate the sum from the coefficients
        cn[i+n+1] * exp(i*π*im*x) for i in -n:1:n
    ])
    return Series(cn, ∑)
end

