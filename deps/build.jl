using PyCall

# With conda-forge, the first install sometimes fails with a strange numpy
# problem.
# const asdf = pyimport_conda("asdf", "asdf", "conda-forge")
const asdf = pyimport_conda("asdf", "asdf", "astropy")

version = VersionNumber(asdf.__version__)
@info "Using Python asdf library version $version"
if version < v"2.0.3"
    @error "This version is unsupported"
    exit(1)
end
