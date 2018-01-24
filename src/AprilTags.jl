module AprilTags

depfile = joinpath(dirname(@__FILE__),"../deps/loadpath.jl")
isfile(depfile) ? include(depfile) : error("AprilTags.jl not properly installed. Please run: Pkg.build(\"AprilTags\")")


export
#helpers
AprilTag,
AprilTagDetector,
freeDetector!,
convert2image_u8,
getTagDetections,

# wrappers
apriltag_detector_create,
tag36h11_create,
tag36h11_destroy,

apriltag_detector_add_family,
apriltag_detector_detect,
apriltag_detections_destroy,
apriltag_detector_destroy


include("wrapper.jl")
include("helpers.jl")

end # module
