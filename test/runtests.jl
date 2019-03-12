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
    @test data isa ASDF.NDArray{Int64, 1}
    # Python 3 requires array-like Python object to support a "buffer
    # protocol" as defined in PEP 3118. Apparently, asdf.py's
    # "NDArrayType" does not, hence we disable this test.
    # @test ASDF.isefficient(data)
    @test isequal(collect(data), Int64[i for i in 0:7])

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
    @test typeof(scalar) === Int64
    @test isequal(scalar, 0)

    array1d = tree["array1d"]
    @test array1d isa ASDF.NDArray{Int16, 1}
    @test ASDF.isefficient(array1d)
    @test size(array1d) == (2,)
    @test isequal(collect(array1d), Int16[0, 1])

    array2d = tree["array2d"]
    @test array2d isa ASDF.NDArray{Int32, 2}
    @test ASDF.isefficient(array2d)
    @test size(array2d) == (3, 2)
    @test isequal(collect(array2d), Int32[0 1; 10 11; 20 21])

    array3d = tree["array3d"]
    @test array3d isa ASDF.NDArray{Int64, 3}
    @test ASDF.isefficient(array3d)
    @test size(array3d) == (4, 3, 2)
    @test isequal(collect(array3d)[1,:,:], Int64[0 1; 10 11; 20 21])
    @test isequal(collect(array3d)[2,:,:], Int64[100 101; 110 111; 120 121])
    @test isequal(collect(array3d)[3,:,:], Int64[200 201; 210 211; 220 221])
    @test isequal(collect(array3d)[4,:,:], Int64[300 301; 310 311; 320 321])

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

    data = tree["data"]
    @test data isa ASDF.NDArray{String, 1}
    @test !ASDF.isefficient(data)
    @test size(data) == (2,)
    @test isequal(collect(data), String["", "ascii"])

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
    @test data isa ASDF.NDArray{ComplexF64, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x04030201)
    @test size(data) == (100,)
    @test isequal(collect(data)[1:4], ComplexF64[0, 0, NaN+NaN*im, NaN+Inf*im])

    data = tree["datatype<c8"]
    @test data isa ASDF.NDArray{ComplexF32, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x04030201)
    @test size(data) == (100,)
    @test isequal(collect(data)[1:4], ComplexF32[0, 0, NaN+NaN*im, NaN+Inf*im])

    data = tree["datatype>c16"]
    @test data isa ASDF.NDArray{ComplexF64, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x01020304)
    @test size(data) == (100,)
    @test isequal(collect(data)[1:4], ComplexF64[0, 0, NaN+NaN*im, NaN+Inf*im])

    data = tree["datatype>c8"]
    @test data isa ASDF.NDArray{ComplexF32, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x01020304)
    @test size(data) == (100,)
    @test isequal(collect(data)[1:4], ComplexF32[0, 0, NaN+NaN*im, NaN+Inf*im])

    ASDF.close(file)
end



@testset "compressed" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "compressed.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["bzp2"]
    @test data isa ASDF.NDArray{Int64, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (128,)
    @test isequal(collect(data), Int64[i for i in 0:127])

    data = tree["zlib"]
    @test data isa ASDF.NDArray{Int64, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (128,)
    @test isequal(collect(data), Int64[i for i in 0:127])

    ASDF.close(file)
end



@testset "exploded" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "exploded.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["data"]
    @test data isa ASDF.NDArray{Int64, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (8,)
    @test isequal(collect(data), Int64[i for i in 0:7])

    ASDF.close(file)
end



@testset "float" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "float.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["datatype<f4"]
    @test data isa ASDF.NDArray{Float32, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x04030201)
    @test size(data) == (10,)
    @test isequal(collect(data), Float32[
        0.0, -0.0, NaN, Inf, -Inf, -3.4028234663852886e+38,
        3.4028234663852886e+38, 1.1920928955078125e-07, 5.960464477539063e-08,
        1.1754943508222875e-38])

    data = tree["datatype<f8"]
    @test data isa ASDF.NDArray{Float64, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x04030201)
    @test size(data) == (10,)
    @test isequal(collect(data), Float64[
        0.0, -0.0, NaN, Inf, -Inf, -1.7976931348623157e+308,
        1.7976931348623157e+308, 2.220446049250313e-16, 1.1102230246251565e-16,
        2.2250738585072014e-308])

    data = tree["datatype>f4"]
    @test data isa ASDF.NDArray{Float32, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x01020304)
    @test size(data) == (10,)
    @test isequal(collect(data), Float32[
        0.0, -0.0, NaN, Inf, -Inf, -3.4028234663852886e+38,
        3.4028234663852886e+38, 1.1920928955078125e-07, 5.960464477539063e-08,
        1.1754943508222875e-38])

    data = tree["datatype>f8"]
    @test data isa ASDF.NDArray{Float64, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x01020304)
    @test size(data) == (10,)
    @test isequal(collect(data), Float64[
        0.0, -0.0, NaN, Inf, -Inf, -1.7976931348623157e+308,
        1.7976931348623157e+308, 2.220446049250313e-16, 1.1102230246251565e-16,
        2.2250738585072014e-308])

    ASDF.close(file)
end



@testset "int" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "int.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["datatype<i1"]
    @test data isa ASDF.NDArray{Int8, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (3,)
    @test isequal(collect(data), Int8[127, -128, 0])

    data = tree["datatype<i2"]
    @test data isa ASDF.NDArray{Int16, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x04030201)
    @test size(data) == (3,)
    @test isequal(collect(data), Int16[32767, -32768, 0])

    data = tree["datatype<i4"]
    @test data isa ASDF.NDArray{Int32, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x04030201)
    @test size(data) == (3,)
    @test isequal(collect(data), Int32[2147483647, -2147483648, 0])

    data = tree["datatype<u1"]
    @test data isa ASDF.NDArray{UInt8, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (2,)
    @test isequal(collect(data), UInt8[255, 0])

    data = tree["datatype<u2"]
    @test data isa ASDF.NDArray{UInt16, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x04030201)
    @test size(data) == (2,)
    @test isequal(collect(data), UInt16[65535, 0])

    data = tree["datatype<u4"]
    @test data isa ASDF.NDArray{UInt32, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x04030201)
    @test size(data) == (2,)
    @test isequal(collect(data), UInt32[4294967295, 0])

    data = tree["datatype>i1"]
    @test data isa ASDF.NDArray{Int8, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (3,)
    @test isequal(collect(data), Int8[127, -128, 0])

    data = tree["datatype>i2"]
    @test data isa ASDF.NDArray{Int16, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x01020304)
    @test size(data) == (3,)
    @test isequal(collect(data), Int16[32767, -32768, 0])

    data = tree["datatype>i4"]
    @test data isa ASDF.NDArray{Int32, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x01020304)
    @test size(data) == (3,)
    @test isequal(collect(data), Int32[2147483647, -2147483648, 0])

    data = tree["datatype>u1"]
    @test data isa ASDF.NDArray{UInt8, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (2,)
    @test isequal(collect(data), UInt8[255, 0])

    data = tree["datatype>u2"]
    @test data isa ASDF.NDArray{UInt16, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x01020304)
    @test size(data) == (2,)
    @test isequal(collect(data), UInt16[65535, 0])

    data = tree["datatype>u4"]
    @test data isa ASDF.NDArray{UInt32, 1}
    @test ASDF.isefficient(data) == (ENDIAN_BOM == 0x01020304)
    @test size(data) == (2,)
    @test isequal(collect(data), UInt32[4294967295, 0])

    ASDF.close(file)
end



@testset "shared" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "shared.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["data"]
    @test data isa ASDF.NDArray{Int64, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (8,)
    @test isequal(collect(data), Int64[i for i in 0:7])

    data = tree["subset"]
    @test data isa ASDF.NDArray{Int64, 1}
    @test ASDF.isefficient(data)
    @test size(data) == (4,)
    @test isequal(collect(data), Int64[i for i in 1:2:7])

    ASDF.close(file)
end



@testset "stream" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "stream.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["my_stream"]
    @test data isa ASDF.NDArray{Float64, 2}
    @test ASDF.isefficient(data)
    @test size(data) == (8, 8)
    @test isequal(collect(data), Float64[i for i in 0:7, j in 0:7])

    ASDF.close(file)
end



@testset "unicode_bmp" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "unicode_bmp.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["datatype<U"]
    @test data isa ASDF.NDArray{String, 1}
    @test !ASDF.isefficient(data)
    @test size(data) == (2,)
    @test isequal(collect(data), String["", "Æʩ"])

    data = tree["datatype>U"]
    @test data isa ASDF.NDArray{String, 1}
    @test !ASDF.isefficient(data)
    @test size(data) == (2,)
    @test isequal(collect(data), String["", "Æʩ"])

    ASDF.close(file)
end



@testset "unicode_spp" begin
    file = ASDF.open(joinpath(pkgpath, "examples", "unicode_spp.asdf"))
    @test typeof(file) === ASDF.File

    @test ASDF.comments(file) == ["ASDF_STANDARD 1.0.0"]
    @test ASDF.file_format_version(file) == v"1.0.0"
    @test ASDF.version(file) == v"1.0.0"

    tree = ASDF.tree(file)
    @test typeof(tree) === ASDF.Tree

    data = tree["datatype<U"]
    @test data isa ASDF.NDArray{String, 1}
    @test !ASDF.isefficient(data)
    @test size(data) == (2,)
    @test isequal(collect(data), String["", "\U00010020"])

    data = tree["datatype>U"]
    @test data isa ASDF.NDArray{String, 1}
    @test !ASDF.isefficient(data)
    @test size(data) == (2,)
    @test isequal(collect(data), String["", "\U00010020"])

    ASDF.close(file)
end



@testset "output" begin
    mktempdir() do dir

        # Create a file
        tree = Dict{String, Any}(
            "scalarb" => true,
            "scalari" => 12345678,
            "scalarf" => 1234.5678,
            "scalarc" => 12.34+56.78im,
            "scalars" => String(Char[i for i in 0:300]),
            "array1d" => Int8[i for i in 1:2],
            "array2d" => Int16[i+10j for i in 1:2, j in 1:3],
            "array3d" => Int32[i+10j+100k for i in 1:2, j in 1:3, k in 1:4],
            "strings" => String["hello", "world"])
        file = ASDF.File(tree)
        ASDF.write_to(file, joinpath(dir, "output.asdf"))

        # Read the file back in
        file2 = ASDF.open(joinpath(dir, "output.asdf"))
        tree2 = ASDF.tree(file2)

        # Compare content
        ignored_keys = Set(["asdf_library", "history"])
        @test setdiff(keys(tree2), ignored_keys) == keys(tree)
        for (key, value) in tree
            if !(key in ignored_keys)
                if typeof(value) <: AbstractArray
                    @test isequal(collect(tree2[key]), value)
                else
                    @test isequal(tree2[key], value)
                end
            end
        end
    end
end
