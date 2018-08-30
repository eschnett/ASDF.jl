module ASDF

using PyCall
using URIParser

const asdf = PyNULL()
function __init__()
    copy!(asdf, pyimport_conda("asdf", "asdf", "astropy"))
end



################################################################################

struct Empty end
const empty = Empty()

const Maybe{T} = Union{Nothing, T}



################################################################################

const tagged_types = Dict{String, Type}()
function wrap(obj::Any)
    obj
end
function wrap(pyobj::PyObject)
    tag = try
        pyobj[:yaml_tag]
    catch
        @assert false           # for debugging
        return pyobj
    end
    type_ = get(tagged_types, tag, empty)
    if type_ === empty
        @show tag
        @assert false           # for debugging
        return pyobj
    end
    type_(pyobj)
end



################################################################################

struct File
    pyobj::PyObject
end

function open(filename::AbstractString)::File
    File(asdf[:open](filename))
end

function close(file::File)::Nothing
    file.pyobj[:close]()
end



function file_format_version(file::File)::VersionNumber
    VersionNumber(file.pyobj[:file_format_version])
end

function version(file::File)::VersionNumber
    VersionNumber(file.pyobj[:version])
end

function Base.VersionNumber(obj::PyObject)
    VersionNumber(
        obj[:major], obj[:minor], obj[:patch], obj[:prerelease], obj[:build])
end



function comments(file::File)::Vector{String}
    file.pyobj[:comments]
end



function tree(file::File)::Tree
    Tree(file.pyobj[:tree])
end



################################################################################

# id: "http://stsci.edu/schemas/asdf/core/asdf-1.1.0"
# tag: "tag:stsci.edu:asdf/core/asdf-1.1.0"
# title: Top-level schema for every ASDF file.
# additionalProperties: true

struct Tree
    pyobj::Dict{Any, Any}
end
# tagged_types["tag:stsci.edu:asdf/core/asdf-1.1.0"] = Tree

function Base.getindex(tree::Tree, key::String)
    wrap(tree.pyobj[key])
end
function Base.get(tree::Tree, key::String, default)
    # get(tree.pyobj, key, default)
    value = get(tree.pyobj, key, empty)
    if value === empty
        return default
    end
    wrap(value)
end
function Base.setindex!(tree::Tree, value, key::String)
    tree.pyobj[key] = value
end

function asdf_library(tree::Tree)::Maybe{Software}
    software = get(tree.pyobj, "asdf_library", empty)
    if software === empty
        return nothing
    end
    Software(software)
end

# History is apparently not supported by the Python ASDF library



################################################################################

# id: "http://stsci.edu/schemas/asdf/core/software-1.0.0"
# tag: "tag:stsci.edu:schemas/asdf/core/software-1.0.0"
# title: Describes a software package.
# required: [name, version]
# additionalProperties: true

struct Software
    pyobj::Dict{Any, Any}
end
# tagged_types["tag:stsci.edu:schemas/asdf/core/software-1.0.0"] = Software

function Base.getindex(software::Software, key::String)
    software.pyobj[key]
end
function Base.get(software::Software, key::String, default)
    get(software.pyobj, key, default)
end
function Base.setindex!(software::Software, value, key::String)
    software.pyobj[key] = value
end

function name(software::Software)::String
    software.pyobj["name"]
end

function author(software::Software)::Maybe{String}
    get(software.pyobj, "author", nothing)
end

function homepage(software::Software)::Maybe{URI}
    homepage = get(software.pyobj, "homepage", empty)
    if homepage === empty
        return nothing
    end
    URI(homepage)
end

function version(software::Software)::Union{VersionNumber, String}
    version = software.pyobj["version"]
    try
        VersionNumber(version)
    catch
        version
    end
end



################################################################################

# id: "http://stsci.edu/schemas/asdf/core/ndarray-1.0.0"
# tag: "tag:stsci.edu:asdf/core/ndarray-1.0.0"
# title: An *n*-dimensional array.

struct NDArray{T, D} <: DenseArray{T, D}
    pyobj::PyObject
end
tagged_types["tag:stsci.edu:asdf/core/ndarray-1.0.0"] = NDArray

function NDArray(pyobj::PyObject)
    D = length(pyobj[:shape])
    T = Int
    NDArray{T, D}(pyobj)
end

function Base.getindex(arr::NDArray{T, D}, i::NTuple{D, Int}) where {T, D}
    @boundscheck checkindex(Bool, axes(arr), i)
    arr.pyobj[i...]::T
end
function Base.getindex(arr::NDArray{T, D}, i::NTuple{D, I}) where {
        T, D, I<:Integer}
    arr.pyobj[NTuple{D, Int}(i)]
end
function Base.getindex(arr::NDArray{T, D}, i::CartesianIndex{D}) where {T, D}
    arr[Tuple(i)]
end
function Base.getindex(arr::NDArray, i::Integer...)
    arr[i]
end

Base.IteratorSize(::Type{<:NDArray{T, D}}) where {T, D} = HasShape{D}()
Base.eltype(::Type{NDArray{T, D}}) where {T, D} = T
function Base.ndims(arr::NDArray{T, D}) where {T, D}
    D::Int
end
function Base.size(arr::NDArray{T, D}) where {T, D}
    arr.pyobj[:shape]::NTuple{D, Int}
end
function Base.size(arr::NDArray, d::Int)
    size(arr)[d]
end
function Base.axes(arr::NDArray{T, D}) where {T, D}
    Base.OneTo.(size(arr))::NTuple{D, OneTo{Int}}
end
function Base.axes(arr::NDArray, d::Int)
    axes(arr)[d]
end
function Base.eachindex(arr::NDArray)
    
end
@generated function size2stride(size::NTuple{D, Int}) where {D}
    quote
        str = 1
        $(((quote
                $(Symbol("str", d)) = str
                str *= sidz[d]
            end) for d in D:-1:1)...)
        tuple($((Symbol("str", d) for d in 1:D)...))::NTuple{D, Int}
    end
end
function Base.strides(arr::NDArray)
    size2stride(size(arr))
end
function Base.stride(arr::NDArray, d::Int)
    strides(arr)[d]
end



################################################################################

end
