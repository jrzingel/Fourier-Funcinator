# d7339, d7712

using Format

"""Get the right sign for two multiplied numbers"""
function sgn(x::Number, y::Number, p::Function)::String
    # p is the formatter function
    return string(if (x*y<0) "-" else "+" end, p(abs(x*y)))
end

"""Convert the series to a string able to be substituted into Desmos
dp: decimal place rounding of coefficients"""
function todesmos(series::Series; dp=3)::String
    L = 1/2  # t must vary by 2*L to get the full curve.
    p = generate_formatter(string("%.", dp, "f"))
    cn = series.cn
    n = (length(cn)-1) ÷ 2

    θ = p(-n*π/L)
    r = string("(", p(real(cn[1])), "*cos(", θ, "t)", sgn(-1, imag(cn[1]), p), "*sin(", θ, "t)")
    i = string(",", p(real(cn[1])), "*sin(", θ, "t)", sgn(1, imag(cn[1]), p), "*cos(", θ, "t)")

    for (j, c) in enumerate(cn[2:end])
        θ = p((j-n)*π/L)
        r *= string(sgn(1, real(c), p), "*cos(", θ, "t)", sgn(-1, imag(c), p), "*sin(", θ, "t)")
        i *= string(sgn(1, real(c), p), "*sin(", θ, "t)", sgn(1, imag(c), p), "*cos(", θ, "t)")
    end
    return string(r, i, ")") 
end