
##for debugging
# cd(dirname(@__FILE__))
run(`make clean -C apriltag-2016-12-01/`)

# Make c library
run(`make -C apriltag-2016-12-01/`)

# set linker path to library
libpath = joinpath(dirname(@__FILE__),"apriltag-2016-12-01")


#create a file to push to the DL_LOAD_PATH when module loads,
f = open("loadpath.jl", "w")

write(f,"# This is an automatically generated file, do not edit.\n")
write(f,"using Libdl\n")
write(f,"push!(Libdl.DL_LOAD_PATH, \"$(libpath)\")")

close(f)
