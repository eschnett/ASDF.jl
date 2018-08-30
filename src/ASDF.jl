module ASDF

using PyCall

export asdf
const asdf = PyNULL()
function __init__()
    copy!(asdf, pyimport_conda("asdf", "asdf", "astropy"))
end

function Base.VersionNumber(v::PyObject)
    VersionNumber(v[:major], v[:minor], v[:patch], v[:prerelease], v[:build])
end

end
