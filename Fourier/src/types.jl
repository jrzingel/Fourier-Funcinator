# d7721

struct Series
    cn::AbstractVector  # The fourier coefficients
    f::Function         # Function created from coefficients (sum)
end

mutable struct Path
    x::AbstractVector
    y::AbstractVector
end