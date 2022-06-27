# d7399
# Desmos tools

using Format


"""Convert the vectors to a format pasteable into desmos"""
function todesmos(a0::Number, an::AbstractArray, bn::AbstractArray)::String
    eq = string("y=", a0)
    for (i, a) in enumerate(an)
        eq *= string("+", a, "*cos(", i*pi/L, "x)")
    end
    for (i, b) in enumerate(bn)
        eq *= string("+", b, "*sin(", i*pi/L, "x)")
    end
    return eq
end


"""Get the right sign for two numbers"""
function sgn(x::Number, y::Number, p::Function)::String
    # p is the formatter function
    s = ""
    if x < 0
        if y < 0
            s = "+"
        else
            s = "-"
        end
    elseif y < 0
        s = "-"
    else
        s = "+"
    end
    return string(s, p(abs(x*y)))
end


function todesmos(cn::Array{ComplexF64}, L::Number; dp=3)::String
    p = generate_formatter(string("%.", dp, "f"))
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

function todesmos(series::Series; dp=3)::String
    return todesmos(series.cn, 1; dp=dp)
end