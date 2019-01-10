# AprilTags

[![Build Status](https://travis-ci.org/JuliaRobotics/AprilTags.jl.svg?branch=master)](https://travis-ci.org/JuliaRobotics/AprilTags.jl)
[![codecov.io](http://codecov.io/github/JuliaRobotics/AprilTags.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaRobotics/AprilTags.jl?branch=master)
[![docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliarobotics.github.io/AprilTags.jl/latest/)

This package is a ccall wrapper for the [AprilTags](https://april.eecs.umich.edu/software/apriltag.html) library tailored for Julia.

# Installation

AprilTags.jl can be installed in Julia 0.7 and 1.0 with:
```julia
#enter ']' to get the package manager and then type:
(v0.7) pkg> add AprilTags
# or
using Pkg
Pkg.add("AprilTags")
```
Please see v0.0.2 for julia 0.6 support.

See [documentation](https://juliarobotics.github.io/AprilTags.jl/latest/), examples, and test folder for usage.

## Examples

To run the examples cd to the project directory and call:

`(v1.0) pkg> activate .`

`(AprilTags Examples) pkg> instantiate`
