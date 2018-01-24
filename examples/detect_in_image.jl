using Images, ImageDraw

using AprilTags

#-------------------------------------------------------------------------------
## Example AprilTags.jl detection from an image using the default setup


cd(dirname(@__FILE__))

image = load("../data/tagtest.jpg")

# create default detector and run on image
detector = AprilTagDetector()
tags = detector(image)

# do some plotting
cpoints = map(tag->CartesianIndex(round.(Int,[tag.c[2],tag.c[1]])...),tags)
length = 3
foreach(point->draw!(image, LineSegment( point - CartesianIndex(0,length), point + CartesianIndex(0,length))), cpoints)
foreach(point->draw!(image, LineSegment( point - CartesianIndex(length,0), point + CartesianIndex(length,0))), cpoints)
image

## free memmory
freeDetector!(detector)



#-------------------------------------------------------------------------------
## Example Using the wrappers directly

cd(dirname(@__FILE__))

image = load("../data/tagtest.jpg")

#create april tag detector
td = apriltag_detector_create()

#create tag family
tf = tag36h11_create()

#add family to detector
apriltag_detector_add_family(td, tf)

#create image8 object for april tags
image8 = convert2image_u8(image)

# run detector on image
detections =  apriltag_detector_detect(td, image8)

# copy detections
tags = getTagDetections(detections)

#Readign homography of tag 1 (deepcopy since memory is destoyed by c)
voidpointertoH = Base.unsafe_convert(Ptr{Void}, tags[1].H)
# pointer to H matrix
nrows = unsafe_load(Ptr{UInt32}(voidpointertoH),1)
ncols = unsafe_load(Ptr{UInt32}(voidpointertoH),2)
H = deepcopy(unsafe_wrap(Array, Ptr{Cdouble}(voidpointertoH+8), (3,3)))


#extract tag centres and draw some crosses on it
cpoints = map(tag->CartesianIndex(round.(Int,[tag.c[2],tag.c[1]])...),tags)
length = 3
foreach(point->draw!(image, LineSegment( point - CartesianIndex(0,length), point + CartesianIndex(0,length))), cpoints)
foreach(point->draw!(image, LineSegment( point - CartesianIndex(length,0), point + CartesianIndex(length,0))), cpoints)
image


apriltag_detections_destroy(detections)

#
#clean up C

# Cleanup: free the detector and tag family when done.
apriltag_detector_destroy(td)
tag36h11_destroy(tf)



##
