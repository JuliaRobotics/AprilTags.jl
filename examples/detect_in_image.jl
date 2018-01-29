using Images, ImageDraw, ImageMagick

using AprilTags

# A few constants
IMGBOXSIZE = 10
IMGBOXCOL = RGB{N0f8}(1.0, 0.4, 0.4)

#-------------------------------------------------------------------------------
## Example AprilTags.jl detection from an image using the default setup

# Simple method to show the image with the tags
function showImage(image, tags)
    # Convert image to
    imageCol = RGB.(image)
    # Show the captured tags
    cpoints = map(tag->CartesianIndex(round.(Int,[tag.c[2],tag.c[1]])...),tags)
    # Make a box around the tag
    drawBox = (imageCol, point, boxSize) -> begin
        draw!(imageCol, LineSegment( point - CartesianIndex(boxSize,boxSize), point + CartesianIndex(-boxSize,boxSize)), IMGBOXCOL)
        draw!(imageCol, LineSegment( point - CartesianIndex(-boxSize,boxSize), point + CartesianIndex(boxSize,boxSize)), IMGBOXCOL)
        draw!(imageCol, LineSegment( point - CartesianIndex(boxSize,boxSize), point + CartesianIndex(boxSize,-boxSize)), IMGBOXCOL)
        draw!(imageCol, LineSegment( point - CartesianIndex(boxSize,-boxSize), point + CartesianIndex(boxSize,boxSize)), IMGBOXCOL)
    end
    foreach(point->drawBox(imageCol, point, IMGBOXSIZE), cpoints)
    foreach(point->drawBox(imageCol, point, IMGBOXSIZE-1), cpoints)
    imageCol
end

try
    # Create default detector
    detector = AprilTagDetector()

    # 1. Run against a file
    image = load(dirname(Base.source_path()) *"/../data/tagtest.jpg")
    tags = detector(image)
    showImage(image, tags)

    # 2. Run against an image from memory
    file = open(dirname(Base.source_path()) *"/../data/tagtest.jpg")
    imgBytes = read(file)
    close(file)
    # Here's where we pretend it came from a stream
    image = readblob(imgBytes) #ImageMagick function
    tags = detector(image)
    showImage(image, tags)
finally
    ## free memmory
    freeDetector!(detector)
end

#-------------------------------------------------------------------------------

try
    # 3. Use low-level methods and direct access to wrapper
    image = load(dirname(Base.source_path()) *"/../data/tagtest.jpg")
    # Create april tag detector
    td = apriltag_detector_create()
    # Create tag family
    tf = tag36h11_create()
    # add family to detector
    apriltag_detector_add_family(td, tf)
    # create image8 object for april tags
    image8 = convert2image_u8(image)
    # run detector on image
    detections =  apriltag_detector_detect(td, image8)
    # copy detections
    tags = getTagDetections(detections)
    # Reading homography of tag 1 (deepcopy since memory is destoyed by c)
    voidpointertoH = Base.unsafe_convert(Ptr{Void}, tags[1].H)
    # pointer to H matrix
    nrows = unsafe_load(Ptr{UInt32}(voidpointertoH),1)
    ncols = unsafe_load(Ptr{UInt32}(voidpointertoH),2)
    H = deepcopy(unsafe_wrap(Array, Ptr{Cdouble}(voidpointertoH+8), (3,3)))

    # Show the image
    showImage(image, tags)
finally
    # Cleanup: free the detector and tag family when done.
    apriltag_detections_destroy(detections)
    apriltag_detector_destroy(td)
    tag36h11_destroy(tf)
end
