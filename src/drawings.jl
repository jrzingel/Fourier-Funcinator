# d7402
# Create some nice animations since we know the size of the appropriate circles!
# Render the series


module Drawings
export draw

using Javis
using ..Calculus: Series


struct Wheel
    obj::Object
    radius::Number
    frequency::Number
end


function ground(args...)
    background("white")
    sethue("black")
end

"""Draw part of the curved Fourier approximation line"""
function draw_line(i::Integer, coords::AbstractArray; color="black", action=:stroke, edge="solid")
    sethue(color)
    setdash(edge)
    line(Point(coords[i, 1], coords[i, 2]), Point(coords[i+1, 1], coords[i+1, 2]), action)
end

"""Draw the wheels that make the line"""
function draw_wheel(radius::Real, linept::Point; color="darkblue")
    sethue(color)
    #circle(O, radius, :stroke)
    #println(O, linept)
    line(O, linept, :stroke)
    return O
end


"""Create a video animation of the Fourier series with circles"""
function draw(series::Series; filepath="series.gif", frames=200)
    L = 1  # half the range to interate through

    t = collect(range(-L, L, frames))
    complex = series.f.(t)

    x = real(complex)
    y = imag(complex)

    radii = abs.(series.cn)  # size of the circles
    shift = (length(radii) - 1) ÷ 2

    x *= 250
    y *= -250  # because Javis uses a computer coordinate system
    radii *= 250

    video = Video(500, 500)
    Background(1:frames, ground)

    for i in 1:frames-1
        Object(i:frames, (args...) -> draw_line(i, [x y]))  # draw the line
    end

    objects =  Wheel[]

    loc = radii[shift+1]*Point(0, 1)
    #root = Object(1:frames, (args...) -> draw_wheel(radii[shift+1], loc), O)  # Root circle
    #push!(objects, Wheel(root, radii[shift+1], 0))
    
    cp = 2
    println(radii[shift+1-cp:shift+1+cp])
    for j in 1:cp
        # Positive frequencies
        r = radii[shift+1+j]
        sp = r*Point(0, 1)
        obj = Object(1:frames, (args...) -> draw_wheel(r, sp), loc)
        loc += sp 
        push!(objects, Wheel(obj, r, j*π/L))

        # Negative frequencies
        r = radii[shift+1-j]
        sp = r*Point(0, 1)
        obj = Object(1:frames, (args...) -> draw_wheel(r, sp), loc)
        loc += sp
        push!(objects, Wheel(obj, r, -j*π/L))
        
    end

    println([x.frequency*π for x in objects])
    for j in 2:length(objects)
        act!(objects[j].obj, Action(anim_rotate_around(2π*objects[j].frequency/2, objects[j-1].obj)))
    end


    render(video, pathname=filepath)

end


end # module