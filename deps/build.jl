using PyCall

# With conda-forge, the first install sometimes fails with a strange numpy
# problem.
# const asdf = pyimport_conda("asdf", "asdf", "conda-forge")
const asdf = pyimport_conda("asdf", "asdf", "astropy")

version = VersionNumber(asdf[:__version__])
@info "Using Python asdf library version $version"
if version < v"2.0.3"
    @error "This version is unsupported"
    exit(1)
end

# Apparently we need jsonschema>=2.3<=2.6, but sometimes jsonschema
# 3.0.1 will be installed. I assume that someone should fix the
# "asdf.py" package instead.
const jsonschema = pyimport_conda("jsonschema", "jsonschema>=2.3<=2.6")
