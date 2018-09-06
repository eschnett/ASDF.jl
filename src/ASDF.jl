module ASDF

using PyCall
using URIParser

const asdf = PyNULL()
function __init__()
    # copy!(asdf, pyimport_conda("asdf", "asdf", "conda-forge"))
    # copy!(asdf, pyimport_conda("asdf", "asdf", "astropy"))
    copy!(asdf, pyimport("asdf"))
end



################################################################################

struct Empty end
const empty = Empty()

const Maybe{T} = Union{Nothing, T}
nothing2tuple(x) = x
nothing2tuple(::Nothing) = ()



################################################################################

const tag2asdftype = Dict{String, Type}()

function makeASDFType(pyobj::PyObject)
    tag = try
        pyobj[:yaml_tag]
    catch
        # Convert to a nice Julia type if possible
        return convert(PyAny, pyobj)
    end
    type_ = get(tag2asdftype, tag, empty)
    if type_ === empty
        @show tag
        @assert false           # for debugging
        return pyobj
    end
    type_(pyobj)::ASDFType
end



################################################################################

struct File
    pyobj::PyObject
end

function File(dict::Dict)       # for convenience
    File(asdf[:AsdfFile](dict))
end

function open(filename::AbstractString)::File
    File(asdf[:open](filename))
end

function close(file::File)::Nothing
    file.pyobj[:close]()
end

function write_to(file::File, filename::AbstractString)::Nothing
    file.pyobj[:write_to](filename)
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
function Base.VersionNumber(obj::Dict)
    VersionNumber(
        obj["major"], obj["minor"], obj["patch"],
        nothing2tuple(obj["prerelease"]), nothing2tuple(obj["build"]))
end



function comments(file::File)::Vector{String}
    file.pyobj[:comments]
end



function tree(file::File)::Tree
    makeASDFType(file.pyobj["tree"]::PyObject)::Tree
end



################################################################################

# id: "http://stsci.edu/schemas/asdf/core/asdf-1.1.0"
# tag: "tag:stsci.edu:asdf/core/asdf-1.1.0"
# title: Top-level schema for every ASDF file.
# additionalProperties: true

"""Top-level schema for every ASDF file"""
struct Tree
    pyobj::PyObject
end
tag2asdftype["tag:stsci.edu:asdf/core/asdf-1.0.0"] = Tree
tag2asdftype["tag:stsci.edu:asdf/core/asdf-1.1.0"] = Tree
additionalProperties(::Tree) = ()

# This constructor must come after the type Tree has been defined
# TODO: Reverse order of types in this file
function File(tree::Tree)
    File(asdf[:AsdfFile](tree.pyobj))
end

function asdf_library(tree::Tree)::Maybe{Software}
    software = get(tree.pyobj, PyObject, "asdf_library", empty)
    if software === empty
        return nothing
    end
    software::PyObject
    makeASDFType(software)::Software
end

# History is apparently not supported by the Python ASDF library



################################################################################

# id: "http://stsci.edu/schemas/asdf/core/software-1.0.0"
# tag: "tag:stsci.edu:schemas/asdf/core/software-1.0.0"
# title: Describes a software package.
# required: [name, version]
# additionalProperties: true

"""Describes a software package"""
struct Software
    pyobj::PyObject
end
tag2asdftype["tag:stsci.edu:asdf/core/software-1.0.0"] = Software
additionalProperties(::Software) = ()

function name(software::Software)
    software.pyobj[:get]("name")::String
end

function author(software::Software)
    software.pyobj[:get]("author")::Maybe{String}
end

function homepage(software::Software)::Maybe{URI}
    homepage = software.pyobj[:get]("homepage", empty)
    if homepage === empty
        return nothing
    end
    URI(homepage)::URI
end

function version(software::Software)::Union{VersionNumber, String}
    version = software.pyobj[:get]("version")::String
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

abstract type Datatype end

@enum ScalarType begin
    int8
    uint8
    int16
    uint16
    int32
    uint32
    int64
    uint64
    float32
    float64
    complex64
    complex128
    bool8
    ascii
    ucs4
end
const string2scalartype = Dict{String, ScalarType}(
    "int8"       => int8,
    "uint8"      => uint8,
    "int16"      => int16,
    "uint16"     => uint16,
    "int32"      => int32,
    "uint32"     => uint32,
    "int64"      => int64,
    "uint64"     => uint64,
    "float32"    => float32,
    "float64"    => float64,
    "complex64"  => complex64,
    "complex128" => complex128,
    "bool8"      => bool8,
    "ascii"      => ascii,
    "ucs4"       => ucs4)
const scalartype2type = Dict{ScalarType, Type}(
    int8       => Int8,
    uint8      => UInt8,
    int16      => Int16,
    uint16     => UInt16,
    int32      => Int32,
    uint32     => UInt32,
    int64      => Int64,
    uint64     => UInt64,
    float32    => Float32,
    float64    => Float64,
    complex64  => ComplexF32,
    complex128 => ComplexF64,
    bool8      => Bool,
    ascii      => String,
    ucs4       => String)

struct ScalarDatatype <: Datatype
    type_::ScalarType
    length::Int                 # only for ascii and ucs4; else -1
    function ScalarDatatype(type_::ScalarType)
        @assert type_ in [
            int8, uint8, int16, uint16, int32, uint32, int64, uint64,
            float32, float64, complex64, complex128,
            bool8]
        new(type_, -1)
    end
    function ScalarDatatype(type_::ScalarType, length::Int)
        @assert type_ in [ascii, ucs4]
        @assert length >= 0
        new(type_, length)
    end
end

function ScalarDatatype(type_::String, length...)
    ScalarDatatype(string2scalartype[type_], length...)
end

function julia_type(scalardatatype::ScalarDatatype)
    scalartype2type[scalardatatype.type_]
end

@enum Byteorder big little

struct Field
    name::Maybe{String}
    datatype::Datatype
    byteorder::Maybe{Byteorder}
    shape::Maybe{Vector{Int}}
end

struct DatatypeList <: Datatype
    types::Vector{Field}
end

function Datatype(dtype::PyObject)
    if dtype[:names] !== nothing
        # fields = []
        # for name in dtype.names:
        #     field = dtype.fields[name][0]
        #     d = {}
        #     d['name'] = name
        #     field_dtype, byteorder = numpy_dtype_to_asdf_datatype(field)
        #     d['datatype'] = field_dtype
        #     if include_byteorder:
        #         d['byteorder'] = byteorder
        #     if field.shape:
        #         d['shape'] = list(field.shape)
        #     fields.append(d)
        # return fields, numpy_byteorder_to_asdf_byteorder(dtype.byteorder)
        @assert false

    elseif dtype[:subdtype] !== nothing
        # return numpy_dtype_to_asdf_datatype(dtype.subdtype[0])
        @assert false

    elseif dtype[:name] in keys(string2scalartype)
        return ScalarDatatype(dtype[:name])

    elseif dtype[:name] == "bool"
        return ScalarDatatype(bool8)

    elseif startswith(dtype[:name], "string") ||
            startswith(dtype[:name], "bytes")
        return ScalarDatatype(ascii, Int(dtype[:itemsize]))

    elseif startswith(dtype[:name], "unicode") ||
            startswith(dtype[:name], "str")
        return ScalarDatatype(ucs4, Int(dtype[:itemsize]) ÷ 4)

    end
    @assert false
end



"""An *n*-dimensional array"""
struct NDArray{T, D} <: DenseArray{T, D}
    pyobj::PyObject
end
tag2asdftype["tag:stsci.edu:asdf/core/ndarray-1.0.0"] = NDArray

function NDArray(pyobj::PyObject)
    D = length(pyobj[:shape])
    T = julia_type(Datatype(pyobj[:dtype]))
    NDArray{T, D}(pyobj)
end

Base.convert

function Base.getindex(arr::NDArray{T, D}, i::NTuple{D, Int}) where {T, D}
    @boundscheck @assert all(checkindex(Bool, axes(arr)[d], i[d]) for d in 1:D)
    pycall(arr.pyobj[:__getitem__], T, i)::T
end
function Base.getindex(arr::NDArray{T, D}, i::NTuple{D, I}) where {T, D, I}
    arr[NTuple{D, Int}(i)]
end
function Base.getindex(arr::NDArray{T, D}, i::CartesianIndex{D}) where {T, D}
    arr[Tuple(i)]
end
function Base.getindex(arr::NDArray, i...)
    arr[i]
end

function Base.size(arr::NDArray{T, D}) where {T, D}
    NTuple{D, Int}(arr.pyobj[:shape]::NTuple{D, Int64})
end
function Base.axes(arr::NDArray{T, D}) where {T, D}
    map(sz -> Base.Slice(0:sz-1),
        size(arr))::NTuple{D, Base.Slice{UnitRange{Int}}}
end
function Base.eachindex(::IndexCartesian, arr::NDArray)
    CartesianIndices(axes(arr))
end
function Base.eachindex(::IndexLinear, arr::NDArray)
    axes(arr, 1)
end
function Base.strides(arr::NDArray)
    Base.size_to_strides(1, reverse(size(arr))...)
end

Base.IteratorSize(::Type{<:NDArray{T, D}}) where {T, D} = HasShape{D}()
function Base.iterate(arr::NDArray)
    iter = eachindex(arr)
    res = iterate(iter)
    if res === nothing
        return nothing
    end
    idx, state = res
    arr[idx], state
end
function Base.iterate(arr::NDArray, state)
    iter = eachindex(arr)
    res = iterate(iter, state)
    if res === nothing
        return nothing
    end
    idx, state = res
    arr[idx], state
end



################################################################################

const ASDFType = Union{Tree, Software, NDArray}

function Base.getindex(obj::ASDFType, key::String)
    additionalProperties(obj)   # check
    makeASDFType(get(obj.pyobj, PyObject, key))
end
function Base.get(obj::ASDFType, key::String, default)
    additionalProperties(obj)   # check
    value = get(obj.pyobj, PyObject, key, empty)
    if value === empty
        return default
    end
    makeASDFType(value)::ASDFType
end
function Base.setindex!(obj::ASDFType, value::ASDFType, key::String)
    additionalProperties(obj)   # check
    obj.pyobj[key] = value.pyobj
end
function Base.delete!(obj::ASDFType, key::String)
    additionalProperties(obj)   # check
    delete!(obj.pyobj, key)
    obj
end

function Base.length(obj::ASDFType)
    Int(obj.pyobj[:__len__]())
end
function Base.keys(obj::ASDFType)
    iter = obj.pyobj[:keys]()[:__iter__]()
    keys = String[]
    while true
        try
            key = iter[:__next__]()
            push!(keys, key)
        catch
            # TODO: Check for Python StopIteration exception
            break
        end
    end
    Set(keys)
end
function Base.iterate(obj::ASDFType)
    Base.iterate(obj, obj.pyobj[:__iter__]())
end
function Base.iterate(obj::ASDFType, iter)
    try
        iter[:__next__](), iter
    catch
        # TODO: Check for Python StopIteration exception
        nothing
    end
end

end
