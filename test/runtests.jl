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
    @test typeof(data) === ASDF.NDArray{Int64, 1}
    @test isequal(collect(data), [0, 1, 2, 3, 4, 5, 6, 7])

    ASDF.close(file)
end



@testset "array" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "array.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    scalar = tree["scalar"]
    @test typeof(scalar) === Int
    @test isequal(scalar, 0)

    array1d = tree["array1d"]
    @test typeof(array1d) === ASDF.NDArray{Int16, 1}
    @test size(array1d) == (2,)
    @test isequal(collect(array1d), Int16[0, 1])

    array2d = tree["array2d"]
    @test typeof(array2d) === ASDF.NDArray{Int32, 2}
    @test size(array2d) == (3, 2)
    @test isequal(collect(array2d), Int32[0 1; 10 11; 20 21])

    array3d = tree["array3d"]
    @test typeof(array3d) === ASDF.NDArray{Int64, 3}
    @test size(array3d) == (4, 3, 2)
    @test isequal(collect(array3d)[1,:,:], Int64[0 1; 10 11; 20 21])
    @test isequal(collect(array3d)[2,:,:], Int64[100 101; 110 111; 120 121])
    @test isequal(collect(array3d)[3,:,:], Int64[200 201; 210 211; 220 221])
    @test isequal(collect(array3d)[4,:,:], Int64[300 301; 310 311; 320 321])

    ASDF.close(file)
end



@testset "complex" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "complex.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["datatype<c16"]
    @test typeof(data) === ASDF.NDArray{ComplexF64, 1}
    @test size(data) == (100,)
    @test isequal(collect(data)[1:4], ComplexF64[0, 0, NaN+NaN*im, NaN+Inf*im])

    data = tree["datatype<c8"]
    @test typeof(data) === ASDF.NDArray{ComplexF32, 1}
    @test size(data) == (100,)
    @test isequal(collect(data)[1:4], ComplexF32[0, 0, NaN+NaN*im, NaN+Inf*im])

    data = tree["datatype>c16"]
    @test typeof(data) === ASDF.NDArray{ComplexF64, 1}
    @test size(data) == (100,)
    @test isequal(collect(data)[1:4], ComplexF64[0, 0, NaN+NaN*im, NaN+Inf*im])

    data = tree["datatype>c8"]
    @test typeof(data) === ASDF.NDArray{ComplexF32, 1}
    @test size(data) == (100,)
    @test isequal(collect(data)[1:4], ComplexF32[0, 0, NaN+NaN*im, NaN+Inf*im])

    ASDF.close(file)
end
