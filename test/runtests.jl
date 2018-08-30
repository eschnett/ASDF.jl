using Test

using ASDF

const pkgpath = joinpath(dirname(pathof(ASDF)), "..")



const basic = asdf[:open](joinpath(pkgpath, "examples", "basic.asdf"))

@test basic[:comments] == ["ASDF_STANDARD 1.0.0"]
@test VersionNumber(basic[:file_format_version]) == v"1.0.0"
@test VersionNumber(basic[:version]) == v"1.0.0"

@test basic[:tree]["asdf_library"] == Dict(
    "name"     => "asdf",
    "author"   => "Space Telescope Science Institute",
    "homepage" => "http://github.com/spacetelescope/asdf",
    "version"  => "1.0.0")
@test basic[:tree]["data"] == [0, 1, 2, 3, 4, 5, 6, 7]



const ascii_ = asdf[:open](joinpath(pkgpath, "examples", "ascii.asdf"))

@test ascii_[:comments] == ["ASDF_STANDARD 1.0.0"]
@test VersionNumber(ascii_[:file_format_version]) == v"1.0.0"
@test VersionNumber(ascii_[:version]) == v"1.0.0"

@test ascii_[:tree]["asdf_library"] == Dict(
    "name"     => "asdf",
    "author"   => "Space Telescope Science Institute",
    "homepage" => "http://github.com/spacetelescope/asdf",
    "version"  => "1.0.0")
# @test ascii_[:tree]["data"] == [0, 1, 2, 3, 4, 5, 6, 7]
