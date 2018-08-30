using Test
using URIParser

using ASDF

const pkgpath = joinpath(dirname(pathof(ASDF)), "..")



@testset "basic" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "basic.asdf"))
    @test typeof(file) === ASDF.File
    
    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"
    
    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree
    
    asdf_library = ASDF.asdf_library(tree)
    @test typeof(asdf_library) === ASDF.Software
    @test ASDF.name(asdf_library) == "asdf"
    @test ASDF.author(asdf_library) == "Space Telescope Science Institute"
    @test ASDF.homepage(asdf_library) ==
        URI("http://github.com/spacetelescope/asdf")
    @test ASDF.version(asdf_library) == v"1.0.0"
    
    data = tree["data"]
    @test isequal(data, [0, 1, 2, 3, 4, 5, 6, 7])
    
    ASDF.close(file)
end



@testset "ascii" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "ascii.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    asdf_library = ASDF.asdf_library(tree)
    @test typeof(asdf_library) === ASDF.Software
    @test ASDF.name(asdf_library) == "asdf"
    @test ASDF.author(asdf_library) == "Space Telescope Science Institute"
    @test ASDF.homepage(asdf_library) ==
        URI("http://github.com/spacetelescope/asdf")
    @test ASDF.version(asdf_library) == v"1.0.0"

    data = tree["data"]
    @test typeof(data) === ASDF.NDArray
    #@test isequal(data, [0, 1, 2, 3, 4, 5, 6, 7])
    @show data
    
    ASDF.close(file)
end
