# d7721
# Extract the curve from a SVG image

using LightXML

"""Return the last point in a path"""
function last(p::Path)::Vector
    return vec([p.x[end], p.y[end]])
end

"""Sample points in a function"""
function sample(f::Function, δ::Number)::Path
    # Assumes function is one dimensional and varys completly from 0-1
    p = hcat(f.(0:δ:1)...)  # ... is needed to expand [1] to 1
    return Path(p[1, :], p[2, :])
end

"""Concatenate paths"""
function Base.:+(p1::Path, p2::Path)::Path
    #@debug vcat(p1.x, p2.x)
    return Path(vcat(p1.x, p2.x), vcat(p1.y, p2.y))
end

"""Load a SVG image and extract the path"""
function load(file::String; step=0.01, inverty=true)::Path
    pic = parse_file(file)

    g = root(pic)["g"]

    @assert length(g) == 1 "Can only process one curve"
    cmd = attribute(find_element(g[1], "path"), "d")  # find the path command

    # Process the command
    p = Path([0], [0])  # Assume the path starts at the origin
    @assert isletter(cmd[1]) "Path does not begin with a command"
    curve = cmd[1]
    for char in cmd[2:end]
        if isletter(char) # Have reached the end of a command
                p = merge(curve, p, step)
                curve = char
        else
            curve *= char  # add the digit
        end
    end
    if inverty; p.y *= -1 end  # computer graphics go upside down
    return p
end

"""Merge a path with a SVG command"""
function merge(curve::String, oldpath::Path, step::Number)
    # In SVG graphics (0,0) is considered to be the upmost left points
    # UPPERCASE commands indicate absolute coordinates, whereas lowercase commands are relative to last position
    # Reference: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d

    # SVG graphics provide perfect curves. These are sampled in steps of 'step'

    c = uppercase(curve[1])
    pos = last(oldpath)
    coords = parse.(Float64, split(curve[2:end], '+'))
    coords = reshape(coords, (2, :))'

    #@debug c coords
    if c == 'M' # Move command
        @assert size(coords, 1) == 1 "Expected one point to move to"
        #@debug typeof([coords[1, 1];])
        p = Path([coords[1, 1]], [coords[1, 2]])
        return oldpath + p
    
    elseif c == 'Q' # Belzier Quadratic Curve
        # Reference: https://en.wikipedia.org/wiki/B%C3%A9zier_curve
        @assert size(coords, 1) == 2 "Expected two control points"
        BQ(t) = (1-t)*((1-t)*pos + t*coords[1, :]) + t*((1-t)*coords[1, :] + t*coords[2, :])

        sampled = sample(BQ, step)
        return oldpath + sampled

    elseif c == 'C' # Belzier Cubic Curve
        @assert size(coords, 1) == 3 "Expected three control points"
        BC(t) = (1-t)^3*pos + 3(1-t)^2*t*coords[1, :] + 3(1-t)*t^2*coords[2, :] + t^3*coords[3, :]

        sampled = sample(BC, step)
        return oldpath + sampled

    else
        @error "Unknown command : " * c
        return oldpath
    end
end


