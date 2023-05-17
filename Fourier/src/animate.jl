# d7722
# Render some wheels as they trace out the fourier transformation

using Javis


function ground(args...)
    background("white")
    sethue("black")
end

"""Draw a line from i to i+1"""
function drawline(i::Integer, coords::AbstractArray; color="black", action=:stroke, edge="solid")
    sethue(color)
    setdash(edge)
    line(
        Point(coords[i,1], coords[i,2]),
        Point(coords[i+1,1], coords[i+1,2]), action
    )
end

function norm(p::Point)::Number
    return sqrt(p.x^2 + p.y^2)
end

"""Draw a wheel.
radius = circle
r = line radius
dir = opp direction of the line"""
function drawwheel(radius::Number, r::Number, dir::Point; p=O, color="darkblue", edge="solid")
    setopacity(0.3)
    sethue(color)
    circle(p, radius, :stroke)
    setdash(edge)
    line(p, p-r*dir, :stroke)
    return p
end

"""Initilise a new wheel"""
function newwheel(segments::AbstractArray, i::Integer, lastpt::Point, L, scale) 
    cn = segments[i, 1]
    n = real(segments[i, 2])
    r = abs(cn) * scale/2
    θ = angle(cn)
    ll = Point(r*cos(θ), -r*sin(θ))  # - to flip for computer graphics
    dir = Point(cos(θ), -sin(θ))
    rr = i%length(segments[:,1])==0 ? 0 : abs(segments[i+1, 1])*scale/2  # previous wheel's radius (ignore last)
    o = Object((args...) -> drawwheel(rr, r, dir), lastpt+ll)
    ω = π * n / L  
    return Wheel(o, r, ω), lastpt+ll
end

"""Draw path (and add pos to the path)"""
function path!(points, pos, color)
    setopacity(1.0)
    sethue(color)
    push!(points, pos)
    circle.(points, 1, :fill)
end

function animate_series(series::Series; fname=Nothing, screen=600, frames=200, L=1/2)
    # Must vary f from -L to L to view the full image
    t = collect(range(-1, 1, frames))  # vector
    c = series.f.(t)
    x = real(c) * (screen/2)
    y = imag(c) * -1 * (screen/2)

    video = Video(screen, screen)
    Background(1:frames, ground)

    # add origin
    Object((args...) -> circle(O, 2, :fill))

    # construct wheels
    whls = Wheel[]
    lastpt = O
    offset = (length(series.cn)+1) ÷ 2  # integer division

    # Upgraded method. n=0 first, then by decreasing radius
    segments = hcat(series.cn, -offset+1:1:offset-1)

    desc = sortperm(abs2.(segments[:,1]))  # descending order
    segments = segments[vcat(desc[1], reverse(desc[2:end])), :]

    #=
    segments = hcat(series.cn, -offset+1:1:offset-1)  # Wheels sorted largest to smallest
    #sort!(segments, dims=1, by=x -> abs2(x[1]), rev=true)
    segments = segments[sortperm(abs2.(segments[:,1]), rev=true),:]
    =#

    #= OLD METHOD
    # Add constant wheel
    r = abs(series.cn[offset]) * scale/2
    θ = angle(series.cn[offset])   
    o = Object((args...) -> drawwheel(r), O) 
    lastpt += Point(r*cos(θ), -r*sin(θ))  # - to flip for computer graphics
    push!(whls, Wheel(o, r, 0))
    @debug (0) r θ lastpt
    
    i = 0
    for row in eachrow(segments) 
        i += 1
        # cn[i+n+1] * exp(i*π*im*x) for i in -n:1:n (x vary from -1 to 1)
        n = real(row[2])
        if n != 0.0
            rr = abs(row[1]) * scale/2
            θ = angle(row[1]) #* exp(im*-1*π*n)) # -1 is where x should vary from 
            lastpt += Point(rr*cos(θ), -rr*sin(θ))  # - to flip for computer graphics
            o = Object((args...) -> drawwheel(rr), lastpt) 
            #Object((args...) -> drawaxle(O, lastpt), O)
            
            ω = π * n / L
            push!(whls, Wheel(o, rr, ω))
            @debug (i, n) rr r θ ω/π lastpt
        end
    end
    =#

    for i in 1:length(series.cn)
        w, lastpt = newwheel(segments, i, lastpt, L, screen)
        push!(whls, w)
    end

    # Render the line
    trace = Point[]
    for i in 1:frames-1
        #Object(i:frames, (args...) -> drawline(i, [x y]))
        Object(1:frames, (args...) -> drawline(i, [x y], edge="dashed")) 
    end
    Object(1:frames, (args...) -> path!(trace, pos(whls[end].obj), "red"))

    # Rotate the wheels
    prevwheel = whls[1]
    for w in whls[2:end]
        act!(w.obj, Action(anim_rotate_around(w.freq, prevwheel.obj)))
        prevwheel = w
    end

    render(video, pathname= fname != Nothing ? fname : "series.gif")
end

