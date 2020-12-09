# test the April grid camera calibration functions


using Test
using AprilTags
using FileIO
using Optim

# using ImageView

##

@testset "April grid camera calibration test" begin

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

# assume obj([f_width, f_height, c_width, c_height])
obj = (fc_wh) -> calcCalibResidualAprilTags!(IMGS, tags, 
                                            taglength=taglength, 
                                            f_width =fc_wh[1], 
                                            f_height=fc_wh[2], 
                                            c_width =fc_wh[3], 
                                            c_height=fc_wh[4]  )
#


## Run the optimization

# f_width, c_width, c_height = size(img, 1), size(img, 1)/2, size(img, 2)/2
# f_height = f_width

# nearby calibration
f_width  = 3370.4878918701756 # + 5
f_height = 3352.8348099534364 # + 5
c_width  = 2005.641610450976  # + 5
c_height = 1494.8282013012076 # + 5
# the physical size of the tag
# taglength = 0.0315

result = optimize(obj, [f_width, f_height, c_width, c_height], BFGS(), Optim.Options(iterations = 10, x_tol=1e-6, show_trace=true))


result.minimizer

## draw the result

SEL = 1

cimg_ = deepcopy(IMGS[SEL])
calcCornerProjectionsAprilTags!( cimg_, tags[SEL],
                                  taglength=0.0315,
                                  f_width=f_width,
                                  f_height=f_height,
                                  c_width=c_width,
                                  c_height=c_height,
                                  dodraw=true )
#

imshow(cimg_)



##

freeDetector!(detector)

##



end

#