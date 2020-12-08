# test the April grid camera calibration functions


using Test
using AprilTags
using FileIO
using Optim

# using ImageView

##

@test "April grid camera calibration test" begin

##

# load the image used for calibration
imgfile = joinpath(dirname(dirname(pathof(AprilTags))), "data/CameraCalibration/taggridphoto.jpg")
img = load(imgfile);

##

# construct the cost function
IMGS = Vector{typeof(img)}()
push!(IMGS, img)

detector = AprilTagDetector()
tags = detector.(IMGS);

##

taglength = 0.0315

# assume obj([fx, fy, cx, cy])
obj = (x) -> calcCalibResidualAprilTags!(IMGS, tags, taglength=taglength, fx=x[1], fy=x[2], cx=x[3], cy=x[4])

## Run the optimization

# fx, cx, cy = size(img, 1), size(img, 1)/2, size(img, 2)/2
# fy = fx

# nearby calibration
fx = 3370.4878918701756 + 5
fy = 3352.8348099534364 + 5
cx = 2005.641610450976  + 5
cy = 1494.8282013012076 + 5
# the physical size of the tag
# taglength = 0.0315

result = optimize(obj, [fx, fy, cx, cy], BFGS())


result.minimizer

## draw the result




##

freeDetector!(detector)

##



end

#