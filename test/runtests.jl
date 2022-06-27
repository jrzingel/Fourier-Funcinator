# d7399
# Run some tests making sure everything works
# Run this file to run all the tests

using Test, Fourier

@test true == true


# Test SVGtools.jl
function test_SVGtools()
    m = "M96.8312+198.649"
    c = "C94.6434+198.649+111.564+196.329+115.117+195.325"
    coords = Fourier.parsecoords(c[2:end])

    @testset "parsing d attribute" begin
        @test size(coords, 1) == 3
        @test size(coords, 2) == 2
        @test coords[1, 2] == 198.649 
    end
end


test_SVGtools();