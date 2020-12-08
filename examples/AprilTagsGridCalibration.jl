
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


cx = size(INITTEST,1) / 2
cy = size(INITTEST,2) / 2
fx = size(INITTEST,1)
fy=fx

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

resid = calcCalibResidualAprilTags!( arr, ARR, fx=fx, taglength=taglength )


##



obj = (fx, fy, cx, cy) -> calcCalibResidualAprilTags!( arr, ARR, fx=fx, fy=fy, cx=cx, cy=cy, taglength=taglength )[1]

obj_ = (fcxy) -> obj(fcxy...)



##

# check that it works
obj_([fx, fy, cx, cy])

# start with any available parameters
# fx_, fy_, cx_, cy_ = fx, fy, cx, cy

##


result = optimize(obj_, [fx_; fy_ ;cx_ ;cy_ ], BFGS())


## current best guess

# iPhone 8 rear camera (coarse calibration)
# fx_ = 3346.1894
# fy_ = 3346.1894
# cx_ = 2021.11068
# cy_ = 1471.0241

# fx_ = 3371.2553294118493
# fy_ = 3353.696574041437
# cx_ = 2007.7796750349364
# cy_ = 1496.4523912712611

fx_ = 3370.4878918701756
fy_ = 3352.8348099534364
cx_ = 2005.641610450976
cy_ = 1494.8282013012076

minim = obj(fx_, fy_, cx_, cy_)


## draw what is going on

SEL = 1

cimg_ = deepcopy(arr[SEL])
_calcCornerProjectionsAprilTags!( cimg_, ARR[SEL],
                                  taglength=0.0315,
                                  fx=fx_,
                                  fy=fy_,
                                  cx=cx_,
                                  cy=cy_,
                                  dodraw=true )
#

##


imshow(cimg_)


##



freeDetector!(detector)

##
