# d7399
# Convert a .svg shape file to a series of coordinates

module SVGTools
export processdrawing

using LightXML


struct Curve
    final::Array{Float64}
    points::Union{Array{Float64}, Nothing}
end


"""Load the SVG file and extract the path from it. Assumes that there is only one path present"""
function loadSVG(file::String)::String
    pic = parse_file(file)
    picroot = root(pic)

    g = picroot["g"]
    @assert length(g) == 1 "Only can process one line"

    path = find_element(g[1], "path")
    return attribute(path, "d")
end


"""Convert the path (d) to a series of points"""
function tocoords(d::String; step = 0.01, inverty=true)::Array{Float64}
    command = ""
    pos = [0, 0]
    path = reshape([], 0, 2)  # empty to begin with
    for c in d
        if isletter(c)
            if command != ""
                curve = process(command, pos, step)
                pos = curve.final
                if curve.points !== nothing
                    path = vcat(path, curve.points)
                end
            end
            command = c
        else
            command *= c
        end
    end
    if inverty; path[:, 2] *= -1 end  # computer graphics go upsidedown
    return path
end


"""Convert from a string of coords to some numbers"""
function parsecoords(coords::String)::Array{Float64}
    # Return as nx2 matrix of points
    r = parse.(Float64, split(coords, '+'))
    return reshape(r, (2, :))'  # need to do it this way as reshape goes vertically, then horizontally
end


function process(command::String, pos::AbstractVector, step::Float64)::Curve
    return process(command, hcat(pos), step)  # use horizontal rows instead of vectors
end


"""Process a SVG command"""
function process(command::String, pos::AbstractArray, step::Float64)::Curve
    # (0,0) is considered to be the top left points
    # Uppercase is absolute coord, lowercase is relative to last pos (unimplemented)
    # Reference: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d
    @assert isletter(command[1]) "Command is not specified"
    c = uppercase(command[1])

    coords = parsecoords(command[2:end])
    if islowercase(command[1])
        coords += repeat(pos, size(coords, 1))  # shift relative
    end

    @debug command[1] coords

    if c == 'M'
        # Move command
        @assert size(coords, 1) == 1 "Only simple movements allowed"
        return Curve(coords[1, :], nothing)

    elseif c == 'Q'
        # Quadratic Bezier Curve
        # Reference: https://en.wikipedia.org/wiki/B%C3%A9zier_curve
        @assert size(coords, 1) == 2 "Must have exactly three points"
        BQ(t) = (1-t)*((1-t)*vec(pos) + t*coords[1, :]) + t*((1-t)*coords[1, :] + t*coords[2, :])

        pts = zeros(floor(Integer, 1/step)+1, 2)
        for (i,t) in enumerate(0:step:1)
            pts[i, :] = hcat(BQ(t))
        end
        return Curve(coords[2, :], pts)

    elseif c == 'C'
        # Cubic Bezier Curve
        @assert size(coords, 1) == 3 "Must have exactly four points"
        BC(t) = (1-t)^3*vec(pos) + 3(1-t)^2*t*coords[1, :] + 3(1-t)*t^2*coords[2, :] + t^3*coords[3, :]

        pts = zeros(floor(Integer, 1/step)+1, 2)
        for (i,t) in enumerate(0:step:1)
            pts[i, :] = hcat(BC(t))
        end
        return Curve(coords[3, :], pts)

    else
        @error "Unknown command " * c
        return Curve(pos, nothing)
    end

end


"""Function that runs the rest of the methods: from svg to points"""
function processdrawing(path::String; step=0.01)::Array{Float64}
    tocoords(loadSVG(path); step=step)
end

end # module
