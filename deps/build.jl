using PyCall

# We're choosing `asdf 2.5` here since this is the newest version
# supported by `ASDF.jl`. Newer versions of `asdf` appear to be
# missing the `yaml_tag` property that we use to determine the type of
# the object.

# With conda-forge, the first install sometimes fails with a strange numpy
# problem.
const asdf = pyimport_conda("asdf", "asdf 2.5", "conda-forge")
# const asdf = pyimport_conda("asdf", "asdf 2.5", "astropy")

version = VersionNumber(asdf.__version__)
@info "Using Python asdf library version $version"
if version < v"2.0.3"
    @error "This version is too old and unsupported"
    exit(1)
end
if version > v"2.5"
    @error "This version is too new and not yet supported (pull requests welcome)"
    exit(1)
end
