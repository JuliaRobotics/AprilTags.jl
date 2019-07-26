__precompile__()
module AprilTags

depfile = joinpath(dirname(@__FILE__),"../deps/deps.jl")
isfile(depfile) ? include(depfile) : error("AprilTags.jl not properly installed. Please run: Pkg.build(\"AprilTags\")")

function __init__()
    check_deps()
end

using LinearAlgebra, Statistics
using Colors, ImageDraw, FixedPointNumbers
import Base.convert

export
#helpers
AprilTag,
AprilTagDetector,
freeDetector!,
getTagDetections,
homography_to_pose,
homographytopose,
threadcalldetect,
getAprilTagImage,
detectAndPose,
tagOrthogonalIteration,
# wrappers
apriltag_detector_create,
tag36h11_create,
tag36h11_destroy,

apriltag_detector_add_family,
apriltag_detector_detect,
apriltag_detections_destroy,
apriltag_detector_destroy,
threadcall_apriltag_detector_detect,

#drawing and plotting
drawTagBox!,
drawTagAxes!

include("wrapper.jl")
include("helpers.jl")
include("tagdraw.jl")

end # module
