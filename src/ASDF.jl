module ASDF

export asdf

using PyCall

const asdf = PyNULL()

function __init__()
    copy!(asdf, pyimport_conda("asdf", "asdf", "astropy"))
end

function Base.VersionNumber(v::PyObject)
    VersionNumber(v[:major], v[:minor], v[:patch])
end

end
