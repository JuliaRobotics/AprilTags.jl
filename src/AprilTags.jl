module AprilTags

depfile = joinpath(dirname(@__FILE__),"../deps/loadpath.jl")
isfile(depfile) ? include(depfile) : error("AprilTags.jl not properly installed. Please run: Pkg.build(\"AprilTags\")")


include("wrapper.jl")
end # module
