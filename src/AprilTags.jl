__precompile__()
module AprilTags

function __init__()
    depfile = joinpath(dirname(@__FILE__),"../deps/loadpath.jl")
    isfile(depfile) ? include(depfile) : error("AprilTags.jl not properly installed. Please run: Pkg.build(\"AprilTags\")")
end

using Colors, ImageDraw, FixedPointNumbers
import Base.convert

export
#helpers
AprilTag,
AprilTagDetector,
freeDetector!,
getTagDetections,
homography_to_pose,

# wrappers
apriltag_detector_create,
tag36h11_create,
tag36h11_destroy,

apriltag_detector_add_family,
apriltag_detector_detect,
apriltag_detections_destroy,
apriltag_detector_destroy,

#drawing and plotting
drawTagBox!

include("wrapper.jl")
include("helpers.jl")
include("tagdraw.jl")

end # module
