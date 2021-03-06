module AprilTags

using AprilTags_jll
using Requires
using DocStringExtensions
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
include("additionalutils.jl")
include("calibrationutils.jl")

function __init__()
    # conditional requirement
    @require FreeTypeAbstraction="663a7486-cb36-511b-a19d-713bb74d65c9" include("tagtext.jl")
end

end # module
