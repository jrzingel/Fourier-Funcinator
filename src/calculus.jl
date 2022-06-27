# d7399
# Calculus methods (and Fourier series calculation)

module Calculus
export fourier, trig_fourier

using Statistics

struct RealSeries
    a0::Number
    an::AbstractArray
    bn::AbstractArray
    f::Function
end

struct Series  # for a complex Fourier series
    cn::AbstractArray
    f::Function
end


"""Numerically integrate f from a to b"""
function integrate(f::Function, a::Number, b::Number)::Number
    # Using simpsons rule
    n = 1000  # use 1000 pts
    x = range(a, b, n)  
    return(integrate(f.(x), a, b))
end


"""Numerically integrate all points of y"""
function integrate(y::AbstractArray, a::Number, b::Number)::Number
    # Use simpsons rule
    s = y[1] + y[end]
    for (i, v) in enumerate(y[2:end-1])
        if i % 2 != 0  # opposite due to indexing change by y[2:end-1]
            s += 2*v
        else
            s += 4*v
        end
    end
    return (b-a)/(3*length(y)) * s
end


"""Calculate the fourier approximation using trigonometric identities"""
function trig_fourier(f::Function, L::Number, n::Integer)::RealSeries
    a0 = integrate(f, -L, L) / (2*L)  # Find a_0
    an = [integrate(x -> f(x)*cos(n*pi*x/L), -L, L) for n in 1:1:n]/L  # Find a_n
    bn = [integrate(x -> f(x)*sin(n*pi*x/L), -L, L) for n in 1:1:n]/L  # Find b_n

    ∑(x) = a0 + sum([a*cos(i*pi*x/L) for (i,a) in enumerate(an)]) + sum([b*sin(j*pi*x/L) for (j,b) in enumerate(bn)])

    return RealSeries(a0, an, bn, ∑)
end


"""Calculate complex fourier series"""
function fourier(f::Function, L::Number, n::Integer)::Series
    cn = [integrate(x -> f(x)*exp(i*π*-im*x/L), -L, L) for i in -n:1:n]/(2*L)  # need /2 as no 2π in numerator
    ∑(x) = sum([cn[i+n+1]*exp(i*π*im*x/L) for i in -n:1:n])

    return Series(cn, ∑)
end


"""Convert a matrix to complex vector"""
function tocomplex(x::AbstractArray)::AbstractVector
    return vec(x[:, 1] + im*x[:, 2])
end


"""Normalise so largest number is 1"""
function normalise!(x::AbstractArray)
    x[:, 1] .-= mean(x[:, 1])
    x[:, 1] ./= argmax(abs2, x[:, 1])
    x[:, 2] .-= mean(x[:, 2])
    x[:, 2] ./= argmax(abs2, x[:, 2])
end


"""Calculate complex fourier series from a series of points"""
function fourier(path::AbstractArray, n::Integer)::Series
    # L = 1 by default. (Then change to 1/2)
    normalise!(path)
    p = tocomplex(path)
    xvals = range(-1, 1, size(path, 1))

    cn = zeros(Complex, n*2+1)

    for k in -n:1:n
        cn[k+n+1] = integrate([p[i]*exp(k*π*-im*x) for (i, x) in enumerate(xvals)], -1, 1)
    end

    cn /= 2

    ∑(x) = sum([cn[i+n+1]*exp(i*π*im*x) for i in -n:1:n])  # x ∈ [0, 1]
    return Series(cn, ∑)
end

end  # module
