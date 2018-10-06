# using Conda
# using PyCall
#
# if PyCall.conda
#     # Check whether asdf is already installed
#     try
#         pyimport("asdf")
#     catch
#         # Install asdf
#         Conda.add_channel("conda-forge")
#
#         # The first install sometimes fails with a strange numpy
#         # problem. We thus run it as throw-away command. Note that
#         # calling `Conda.add` aborts on errors, so we have to use this
#         # lower-level equivalent.
#         try
#             Conda.runconda(`install -y asdf`)
#         catch
#         end
#     end
# end



using PyCall

const asdf = pyimport_conda("asdf", "asdf", "conda-forge")
# const asdf = pyimport_conda("asdf", "asdf", "astropy")

version = VersionNumber(asdf[:__version__])
@info "Using Python asdf library version $version"
if version < v"2.0.3"
    @error "This version is unsupported"
    exit(1)
end



# using PyCall
#
# try
#     pyimport("pip")
# catch
#     get_pip = joinpath(dirname(@__FILE__), "get-pip.py")
#     download("https://bootstrap.pypa.io/get-pip.py", get_pip)
#     run(`$(PyCall.python) $get_pip --user`)
#     run(`$(PyCall.python) -m pip install --upgrade pip`)
# end
#
# run(`$(PyCall.python) -m pip install --user astropy_helpers`)
# run(`$(PyCall.python) -m pip install --user git+https://github.com/spacetelescope/asdf.git@6705cd6fd1b040ded28d8c58b9aa62be87f5584e`)
