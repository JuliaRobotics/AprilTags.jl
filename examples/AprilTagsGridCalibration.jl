
##

using FreeTypeAbstraction
using AprilTags
using Images, ImageView
using FileIO
using Optim

using ImageDraw, Colors, FixedPointNumbers



##

calibfiles = [
  ENV["HOME"]*"/data/cameracalib/CommonData/IMG_2909.jpg";
  ENV["HOME"]*"/data/cameracalib/CommonData/IMG_2910.jpg";
  ENV["HOME"]*"/data/cameracalib/CommonData/IMG_2911.jpg";
  ENV["HOME"]*"/data/cameracalib/CommonData/IMG_2913.jpg";
  ENV["HOME"]*"/data/cameracalib/CommonData/IMG_2914.jpg";
  ENV["HOME"]*"/data/cameracalib/CommonData/IMG_2916.jpg";
  ENV["HOME"]*"/data/cameracalib/CommonData/IMG_2920.jpg";
]


##


INITTEST = load(calibfiles[1])


c_height = size(INITTEST,1) / 2
c_width = size(INITTEST,2) / 2
f_height = size(INITTEST,1)
f_width=f_height

s = 0.0

taglength = 0.03


##


arr = Vector{typeof(INITTEST)}()

for i in 1:length(calibfiles)
  push!(arr, load(calibfiles[i]))
end


## quick test


detector = AprilTagDetector()
tags = detector.(arr)


#

ARR = []

for tag in tags
  push!(ARR, [(;id=tg.id,p=tg.p, H=tg.H) for tg in tag])
end


##

resid = calcCalibResidualAprilTags!( arr, ARR, f_height=f_height, taglength=taglength )


##



obj = (f_height, f_width, c_height, c_width) -> calcCalibResidualAprilTags!( arr, ARR, f_height=f_height, f_width=f_width, c_height=c_height, c_width=c_width, taglength=taglength )[1]

obj_ = (fc_heighty) -> obj(fc_heighty...)



##

# check that it works
obj_([f_height, f_width, c_height, c_width])

# start with any available parameters
# f_height_, f_width_, c_height_, c_width_ = f_height, f_width, c_height, c_width

##


result = optimize(obj_, [f_height_; f_width_ ;c_height_ ;c_width_ ], BFGS())


## current best guess

# iPhone 8 rear camera (coarse calibration)
# f_height_ = 3346.1894
# f_width_ = 3346.1894
# c_height_ = 2021.11068
# c_width_ = 1471.0241

# f_height_ = 3371.2553294118493
# f_width_ = 3353.696574041437
# c_height_ = 2007.7796750349364
# c_width_ = 1496.4523912712611

f_height_ = 3370.4878918701756
f_width_ = 3352.8348099534364
c_height_ = 2005.641610450976
c_width_ = 1494.8282013012076

minim = obj(f_height_, f_width_, c_height_, c_width_)


## draw what is going on

SEL = 1

cimg_ = deepcopy(arr[SEL])
_calcCornerProjectionsAprilTags!( cimg_, ARR[SEL],
                                  taglength=0.0315,
                                  f_height=f_height_,
                                  f_width=f_width_,
                                  c_height=c_height_,
                                  c_width=c_width_,
                                  dodraw=true )
#

##


imshow(cimg_)


##



freeDetector!(detector)

##
