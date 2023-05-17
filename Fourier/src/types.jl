# d7721

using Javis

struct Series
    cn::AbstractVector  # The fourier coefficients
    f::Function         # Function created from coefficients (sum)
end

mutable struct Path
    x::AbstractVector
    y::AbstractVector
end

struct Wheel
    obj::Object
    r::Number       # Radius
    freq::Number    # angular frequency (ω)
end