
export calcCalibResidualAprilTags!, calcCornerProjectionsAprilTags!


function _calcCornerProjectionsAprilTag!( cimg_, tags_, idx, horid, verid, tl, tl_2, cTt_,
                                          f_width, f_height, c_width, c_height,
                                          HORI::Int, VERT::Int;
                                          dodraw::Bool=false    )
  #
  resid = 0.0

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
  # very basic pinhole camera model 
  iPc_ = cP_[1:2,:]
  for c in 1:4
    # inverse camera transform? should more than just f_width
    iPc_[:,c] .*= f_width/cP_[3,c]
  end
  iPc_[1,:] .+= c_width
  iPc_[2,:] .+= c_height
  
  # get the right tag reference measurement
  j_ = VERT*(horid-1) + verid
  # where are the measured corners
  for c in 1:4
    resid += (tags_[j_].p[c] - iPc_[1:2,c]).^2 |> sum
  end
  
  # also draw the new positions if desired
  if dodraw
    # drawing requires Int
    iPc_I = round.(Int, iPc_)
    for c in 1:4
      # consolidate all drawing functions in the same prior src file
      _drawCrossOnImg!(cimg_, (iPc_I[1,c],iPc_I[2,c]), 50, RGB{N0f8}(1,0,0))
    end
  end

  return resid
end


"""
    $SIGNATURES

April grid calibration helper function to assemble the cost for a single image.
This function can also be used to draw the corner points on images 
to show how the cost function is constructed as well as the calibration performance.
See [`calcCalibResidualAprilTags!`](@ref) for details.
"""
function calcCornerProjectionsAprilTags!(cimg_::AbstractMatrix{<:Colorant}, 
                                          tags_::AbstractVector;
                                          tagList::AbstractVector=1:length(tags_),
                                          taglength::Real=0.0315,
                                          f_width::Real = size(cimg_,1),
                                          f_height::Real = f_width,
                                          c_width::Real = size(cimg_,2)/2,
                                          c_height::Real = size(cimg_,1)/2,
                                          s::Real=0.0,
                                          VERT::Int=5,
                                          HORI::Int=8,
                                          boardPattern = reshape(1:(VERT*HORI), VERT, HORI),
                                          dodraw = false )
  #
  resid = 0.0

  tl = taglength
  tl_2 = tl/2
  
  # FIXME use standard CameraModels.jl package
  K_ = [f_width s c_width;
        0 f_height c_height]

  @assert length(tags_) == HORI*VERT "Number of detected tags must equal HORI*VERT=$(HORI*VERT) but only finding $(length(tags_))"
  # loop through all 40 tags
  for j in tagList
    cTt, err1 = AprilTags.tagOrthogonalIteration( tags_[j].p, 
                                                  tags_[j].H, 
                                                  f_width,
                                                  f_height,
                                                  c_width, 
                                                  c_height, 
                                                  taglength = taglength)  
    #
    cTt_ = [cTt; 0 0 0 1]
    idx = findfirst(x->x==tags_[j].id, boardPattern)
    
    # go through all the tags on the grid, to compare against this one idx tags[j]
    for verid in 1:VERT, horid in 1:HORI
      resid += _calcCornerProjectionsAprilTag!( cimg_, tags_, idx, horid, verid, tl, tl_2, cTt_,
                                                f_width, f_height, c_width, c_height,
                                                HORI, VERT;
                                                dodraw=dodraw    )
    end
  end

  #
  return resid
end



"""
    $SIGNATURES

Grid of AprilTags calibration helper function.  This function sets up a squared cost to be minimized 
by any method, including `Optim.opimize`.  The cost function is constructed by assuming a grid of 40 AprilTags
are of equal size and on a common co-planar surface like a computer screen.  

The cost function is constructed by predicting from each tag detection individually where the corners of all 
other 39 tags should be on the co-planar surface.  The discrepanc_height between the predicted and detected tag 
positions are square accumulated. 

### Notes
- Assume regular spacing grid of 40 AprilTags 36h11, ids=1:40,
  - down 1:5 by 8 columns 1:5:40 across where taglength and spacing gap are equal.
  - See grid file at AprilTags/data/CameraCalibration/AprilTagGrid1to40.png
- Current implementation requires all 40 tags to be visible and detected
  - Contributions welcome to allow a few missed detections.
- Take pictures of the grid with the camera you want to calibrate, making sure all tags are clearly visible.
  - Combinations of the grid nearer and further, centered and slanted around the edges of the field of view are best.
  - Any number of images can be used, the more the better.  
  - Note that half a doen high-res images might take up to 20 mins or so to optimize.
- Julia Images.jl follows the common ``::Array` column-major---i.e. vertical-major---index convention
  - That is `img[vertical, horizontal]`
  - See https://evizero.github.io/Augmentor.jl/images/#Vertical-Major-vs-Horizontal-Major-1
- This function has the ability to draw the predicted tag corners, see keyword `dodraw=true`.
- This is not a copy of any other AprilCal or such software, this was newly written code out of pure frustration
  when getting stuff to work.  The more native Julia code the better, because Julia is much more mobile and versatile
  than any of the other calibration software out there.  See DevNotes below for roadmap of features to add, 
  contributions welcome.

### Example

Also see `AprilTags/examples/AprilTagsGridClibration.jl`.

This example shows how a series of photos of the tag grid image (just use your computer screen, not a projector) 
can be used to calibrate a camera.  This example only shows the basic pinhole parameters, although more are possible, 
see keyword arguments for which calibration parameters are available.  The latter part shows how to draw crosses
to see before and after result.  
```julia
using AprilTags
using FileIO

# where are the photos of the calibration files
filepaths = ["photo1.jpg"; "photo2.jpg";...]
# load the images into memory
imgs = load.(filepaths)

# It's imporant that you measure and specify the tag length correctly here
# 30 mm is just a guess, insert your own correct tag measurements here.
taglength = 0.03

# rough guess of what calibration parameters might be
# img[rows,columns] <==> img[height, width]
c_width = size(imgs[1],2) / 2 # columns across in Images.jl
c_height = size(imgs[1],1) / 2 # rows down in Images.jl
f_width = size(imgs[1],1)
f_height=f_width

#  detect the tags and duplicate the memory before freeing the detector
detector = AprilTagDetector()
tags = detector.(imgs) .|> deepcopy
# remember to free detector later

# setup the cost function, you can add more parameters here if you like
obj = (f_width, f_height, c_width, c_height) -> calcCalibResidualAprilTags!( imgs, tags, taglength=taglength, f_width=f_width, f_height=f_height, c_width=c_width, c_height=c_height, dodraw=false )
obj_ = (fc_wh) -> obj(fc_wh...)

# check that it works
obj_([f_width, f_height, c_width, c_height])

## Bring in the Optim.jl optimization routines
using Optim

# Run the optimization. BFGS is slower by more precise, it's okay to mix and match as coarse and fine optimization stages
result = optimize(obj_, [f_width; f_height; c_width; c_height], BFGS(), Optim.Options(x_tol=1e-8))

# see the optimized calibration parameters
@show f_width_, f_height_, c_width_, c_height_ = (result.minimizer...,)

## show the before and after images to visually confirm things are working
using ImageView

# bad calibration
img1_before = deepcopy(imgs[1])
calcCornerProjectionsAprilTags!(img1_before, taglength=taglength, f_width=f_width, f_height=f_height, c_width=c_width, c_height=c_height, dodraw=true)
imshow(img1_before)

# new calibration
img1_after = deepcopy(imgs[1])
calcCornerProjectionsAprilTags!(img1_after, taglength=taglength, f_width=f_width_, f_height=f_height_, c_width=c_width_, c_height=c_height_, dodraw=true)
imshow(img1_after)

# free the detector memory
freeDetector!(detector) # could also use a deepcopy to duplicate the memory to a secondary location and free the primary immediately
```

### DevNotes
- FIXME common JuliaRobotics/CameraModels.jl package shoudl be made
- TODO Radial distortion parameters should be added, see https://en.wikipedia.org/wiki/Distortion_(optics)
- TODO allow missed detections on grid of 40 tags
- TODO auto-detect the grid so that any grid can be used (still assuming regular spacing)

### Related

[`calcCornerProjectionsAprilTags!`](@ref)
"""
function calcCalibResidualAprilTags!( images::AbstractVector,
                                      allTags::AbstractVector;
                                      tagList::AbstractVector=1:length(allTags),
                                      taglength = 0.0315,
                                      VERT = 5,
                                      HORI = 8,
                                      f_width::Real=size(images[1],2),
                                      f_height::Real=f_width,
                                      c_width::Real = size(images[1],2) / 2,
                                      c_height::Real = size(images[1],1) / 2,
                                      s::Real=0.0,
                                      boardPattern = reshape(1:(VERT*HORI), VERT, HORI),
                                      dodraw = false  )
  #

  #
  resid = 0.0

  for count in 1:length(images)

    # detect tags in current image
    cimg_ = images[count]
    tags_ = allTags[count]

    # do the actual calculations
    resid += calcCornerProjectionsAprilTags!( cimg_, tags_,
                                              tagList=tagList,
                                              taglength=taglength,
                                              f_width=f_width,
                                              f_height=f_height,
                                              c_width=c_width,
                                              c_height=c_height,
                                              s=s,
                                              VERT=VERT, HORI=HORI,
                                              boardPattern=boardPattern,
                                              dodraw=false )
    #
  end
  
  return resid
end

