using PyCall

try
    pyimport("pip")
catch
    get_pip = joinpath(dirname(@__FILE__), "get-pip.py")
    download("https://bootstrap.pypa.io/get-pip.py", get_pip)
    run(`$(PyCall.python) $get_pip --user`)
    run(`$(PyCall.python) -m pip install --upgrade pip`)
end

pyimport_conda("astropy_helpers", "astropy-helpers", "astropy")
pyimport_conda("numpy", "numpy")
# run(`$(PyCall.python) -m pip install --user astropy_helpers`)
run(`$(PyCall.python) -m pip install --user git+https://github.com/spacetelescope/asdf.git@6705cd6fd1b040ded28d8c58b9aa62be87f5584e`)
