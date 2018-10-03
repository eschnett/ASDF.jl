`ASDF <https://github.com/eschnett/ASDF>`_
==========================================

A Julia library for the `Advanced Scientific Data Format (ASDF) <https://asdf-standard.readthedocs.io/en/latest/index.html>`_.

|Build Status (Travis)|
|Build Status (Appveyor)|
|Coverage Status (Coveralls)|

.. |Build Status (Travis)| image:: https://travis-ci.org/eschnett/ASDF.jl.svg?branch=master
   :target: https://travis-ci.org/eschnett/ASDF.jl
.. |Build status (Appveyor)| image:: https://ci.appveyor.com/api/projects/status/4voe93gewdi9i0pq/branch/master?svg=true
   :target: https://ci.appveyor.com/project/eschnett/asdf-jl/branch/master
.. |Coverage Status (Coveralls)| image:: https://coveralls.io/repos/github/eschnett/ASDF.jl/badge.svg?branch=master
   :target: https://coveralls.io/github/eschnett/ASDF.jl?branch=master

Overview
========

The Advanced Scientific Data Format (ASDF) is a file format for scientific data. This package provides a Julia implementation for reading and writing ASDF files, based on the `asdf <https://github.com/spacetelescope/asdf>`_ Python package and the `PyCall <https://github.com/JuliaPy/PyCall.jl>`_ Julia package.

The ASDF file format is based on the human-readable YAML standard, extended with efficient binary blocks to store array data. Basic arithmetic types (Bool, Int, Float, Complex) and strings are supported out of the box. Other types (structures) need to be declared to be supported.

ASDF supports arbitrary array strides, both C (Python) and Fortran (Julia) memory layouts, as well as compression. The YAML metadata can contain arbitrary information corresponding to scalars, arrays, or dictionaries.

The ASDF file format targets a similar audience as the HDF5 format.

Examples
========

Writing a file
---------------

Here we create a few simple data items and write them into an ASDF file:

::

    julia> using ASDF

    julia> # Define some data
    julia> s = "Hello, World!"
    julia> dict = Dict("a" => 1, "b" => 2.0, "c" => "cee")
    julia> arr = Float32[i+j for i in 1:10, j in 1:10]

    julia> # Create the ASDF tree
    julia> tree = Dict{String, Any}(
               "comment" => s,
               "table" => dict,
               "data" => arr)
    julia> # Write the file
    julia> ASDF.write_to(ASDF.File(tree), "example.asdf")

This creates a file `example.asdf`. The beginning of the file is human-readable and is a properly formatted YAML document. Note that the triple dashes `---` indicate the beginning and the triple dots `...` indicate the end of a YAML document:

::

    #ASDF 1.0.0
    #ASDF_STANDARD 1.2.0
    %YAML 1.1
    %TAG ! tag:stsci.edu:asdf/
    --- !core/asdf-1.1.0
    asdf_library: !core/software-1.0.0 {author: Space Telescope Science Institute, homepage: 'http://github.com/spacetelescope/asdf',
      name: asdf, version: 2.1.0}
    history:
      extensions:
      - !core/extension_metadata-1.0.0
        extension_class: asdf.extension.BuiltinExtension
        software: {name: asdf, version: 2.1.0}
    comment: Hello, World!
    data: !core/ndarray-1.0.0
      source: 0
      datatype: float32
      byteorder: little
      shape: [10, 10]
      strides: [4, 40]
    table: {a: 1, b: 2.0, c: cee}
    ...

The file contains some metadata, including version numbers of the ASDF standard and the software used to create the file. This is followed by the data items `comment`, `data`, and `table` that we created. The actual array data is stored in binary after the triple dots. (It is also possible to store arrays in a human-readable form, but this becomes inefficient for large arrays.)

The `examples` directoy of this Julia packages contains several example ASDF files taken from the ASDF standard.

Reading from file
-----------------

Reading this file yields the data back:

::

    julia> using ASDF

    julia> # Read the file that was written earlier
    julia> tree = ASDF.tree(ASDF.open("example.asdf"))

    julia> # Look at all items in the ASDF tree:
    julia> keys(tree)
    Set(["history", "data", "table", "asdf_library", "comment"])

    julia> # Extract the comment
    julia> tree["comment"]
    "Hello, World!"

    julia> # Extract the lookup table
    julia> tree["table"]
    Dict{Any,Any} with 3 entries:
      "c" => "cee"
      "b" => 2.0
      "a" => 1

    julia> # Extract the array
    julia> typeof(tree["data"])
    ASDF.NDArray{Float32,2,PyCall.PyArray{Float32,2}}

    julia> collect(tree["data"])
    10×10 Array{Float32,2}:
      2.0   3.0   4.0   5.0   6.0   7.0   8.0   9.0  10.0  11.0
      3.0   4.0   5.0   6.0   7.0   8.0   9.0  10.0  11.0  12.0
      4.0   5.0   6.0   7.0   8.0   9.0  10.0  11.0  12.0  13.0
      5.0   6.0   7.0   8.0   9.0  10.0  11.0  12.0  13.0  14.0
      6.0   7.0   8.0   9.0  10.0  11.0  12.0  13.0  14.0  15.0
      7.0   8.0   9.0  10.0  11.0  12.0  13.0  14.0  15.0  16.0
      8.0   9.0  10.0  11.0  12.0  13.0  14.0  15.0  16.0  17.0
      9.0  10.0  11.0  12.0  13.0  14.0  15.0  16.0  17.0  18.0
     10.0  11.0  12.0  13.0  14.0  15.0  16.0  17.0  18.0  19.0
     11.0  12.0  13.0  14.0  15.0  16.0  17.0  18.0  19.0  20.0

The ASDF package ensures that arrays are not copied when they are written to or read from a file. When writing, ASDF creates a numpy array (via the PyCall package) that shares the same data as the Julia array. When reading, ASDF creates an object of type `NDArray` (which is a subtype of `AbstractArray`) that efficiently refers to a `numpy` array (again via the PyCall package). An `NDArray` can be converted to regular Julia `Array` by copying it via calling `collect`.
