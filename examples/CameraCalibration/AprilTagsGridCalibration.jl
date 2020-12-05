
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

fx = 2900.0
fy=fx

s = 0.0


##


function _calcCornerProjectionsAprilTags!(cimg_::AbstractMatrix{<:AbstractRGB}, 
                                          tags_::AbstractVector;
                                          taglength::Real=0.0315,
                                          fx::Real=3000.0,
                                          fy::Real=fx,
                                          cx::Real = size(cimg_,1)/2,
                                          cy::Real = size(cimg_,2)/2,
                                          VERT::Int=5,
                                          HORI::Int=8,
                                          boardPattern = reshape(1:(5*8), VERT, HORI),
                                          dodraw = false )
  #
  resid = 0.0

  tl = taglength
  tl_2 = tl/2
  
  K_ = [fx s cx;
        0 fy cy]

  @assert length(tags_) == HORI*VERT "Number of detected tags must equal HORI*VERT=$(HORI*VERT) but only finding $(length(tags_))"
  # loop through all 40 tags
  for j in 1:length(tags_)
    cTt, err1 = AprilTags.tagOrthogonalIteration( tags_[j].p, 
                                                  tags_[j].H, 
                                                  fx, 
                                                  fy, 
                                                  cx, 
                                                  cy, 
                                                  taglength = taglength)  
    #
    cTt_ = [cTt; 0 0 0 1]
    idx = findfirst(x->x==tags_[j].id, boardPattern)
    
    # go through all the tags on the grid, to compare against this one idx tags[j]
    for verid in 1:VERT, horid in 1:HORI
      verz = (verid - idx.I[1])*(2*tl)
      horz = (horid - idx.I[2])*(2*tl)
      
      # reproject the corners
      tC = [-tl_2  tl_2   tl_2 -tl_2;
            tl_2  tl_2  -tl_2 -tl_2;
              0     0     0     0;
              1     1     1     1]
      #
      
      # offset to the specific tag on board
      tC[1,:] .+= horz
      tC[2,:] .+= verz
      
      # get corners in camera frame
      cP_ = (cTt_*tC)[1:3,:]
      # get corners in image reference frame (iPc)
      # do the inverse transform?
      # very basic pinhole camera model 
      iPc_ = cP_[1:2,:]
      for c in 1:4
        iPc_[:,c] .*= fx/cP_[3,c]
      end
      iPc_[1,:] .+= cx
      iPc_[2,:] .+= cy
      
      # get the right tag reference measurement
      j_ = VERT*(horid-1) + verid
      # where are the measured corners
      for c in 1:4
        resid += (tags_[j_].p[c] - iPc_[1:2,c]).^2 |> sum
      end
      
      if dodraw
        # drawing requires Int
        iPc_I = round.(Int, iPc_)
        for c in 1:4
          draw!(cimg_, Cross(Point(iPc_I[1,c],iPc_I[2,c]), 50), RGB{N0f8}(1,0,0))
        end
      end
    end
  end

  #
  return resid
end


# for optimization with option to draw corner images
function _calcCalibResidualAprilTags!(images::AbstractVector{T},
                                      allTags::AbstractVector;
                                      taglength = 0.0315,
                                      VERT = 5,
                                      HORI = 8,
                                      fx::Real=3000.0,
                                      fy::Real=fx,
                                      cx::Real = size(images[1],1) / 2,
                                      cy::Real = size(images[1],2) / 2,
                                      boardPattern = reshape(1:(5*8), VERT, HORI),
                                      dodraw = false  ) where T
  #

  #
  resid = 0.0

  for count in 1:length(images)

    # detect tags in current image
    cimg_ = images[count]
    tags_ = allTags[count]

    # do the actual calculations
    resid += _calcCornerProjectionsAprilTags!(cimg_, tags_,
                                              taglength=taglength,
                                              fx=fx,
                                              fy=fy,
                                              cx=cx,
                                              cy=cy,
                                              VERT=VERT, HORI=HORI,  # excessive
                                              boardPattern=boardPattern,
                                              dodraw=false )
    #
  end
  
  return resid
end



##


arr = Vector{typeof(INITTEST)}()

for i in 1:length(calibfiles)
  push!(arr, load(calibfiles[i]))
end


## quick test


detector = AprilTagDetector()
tags = deepcopy(detector.(arr))
freeDetector!(detector)


#

ARR = []

for tag in tags
  push!(ARR, [(;id=tg.id,p=tg.p, H=tg.H) for tg in tag])
end


##

resid = _calcCalibResidualAprilTags!( arr, ARR, fx=fx )


##



obj = (fx, fy, cx, cy) -> _calcCalibResidualAprilTags!( arr, ARR, fx=fx, fy=fy, cx=cx, cy=cy )[1]

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

SEL = 2

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

