using Images, ImageDraw, ImageMagick
#Additional required packages to run this example.
#Pkg.add("Images")
#Pkg.add("ImageMagick")

using AprilTags

#-------------------------------------------------------------------------------
## Example AprilTags.jl detection from an image using the default setup

# Simple method to show the image with the tags
function showImage(image, tags, K)
    # Convert image to RGB
    imageCol = RGB.(image)
    #traw color box on tag corners
    foreach(tag->drawTagBox!(imageCol, tag, width = 2, drawReticle = false), tags)
    foreach(tag->drawTagAxes!(imageCol,tag, K), tags)
    imageCol
end

fx = 524.040
fy = 524.040
cy = 319.254
cx = 251.227
K = [-fx 0  cx;
      0 fy cy]

detector = nothing
try
    # Create default detector
    global detector = AprilTagDetector()

    # 1. Run against a file
    global image = load(dirname(Base.source_path()) *"/../data/tagtest.jpg");
    global tags = detector(image)
    showImage(image, tags, K)

    # 2. Run against an image from memory
    file = open(dirname(Base.source_path()) *"/../data/tagtest.jpg")
    imgBytes = read(file)
    close(file)
    # Here's where we pretend it came from a stream
    image = readblob(imgBytes) #ImageMagick function
    tags = detector(image)
    showImage(image, tags, K)
finally
    ## free memmory
    freeDetector!(detector)
end

##-------------------------------------------------------------------------------
detections = nothing
td = nothing
tf = nothing

try
    # 3. Use low-level methods and direct access to wrapper
    global image = load(dirname(Base.source_path()) *"/../data/tagtest.jpg")
    # Create april tag detector
    global td = apriltag_detector_create()
    # Create tag family
    global tf = tag36h11_create()
    # add family to detector
    apriltag_detector_add_family(td, tf)
    # create image8 object for april tags
    image8 = convert(AprilTags.image_u8, image)
    # run detector on image
    global detections =  apriltag_detector_detect(td, image8)
    # copy detections
    global tags = getTagDetections(detections)
    # Reading homography of tag 1 (deepcopy since memory is destoyed by c)
    voidpointertoH = Base.unsafe_convert(Ptr{Nothing}, tags[1].H)
    # pointer to H matrix
    nrows = unsafe_load(Ptr{UInt32}(voidpointertoH),1)
    ncols = unsafe_load(Ptr{UInt32}(voidpointertoH),2)
    H = deepcopy(unsafe_wrap(Array, Ptr{Cdouble}(voidpointertoH+8), (3,3)))

finally
    # Cleanup: free the detector and tag family when done.
    apriltag_detections_destroy(detections)
    apriltag_detector_destroy(td)
    tag36h11_destroy(tf)
end
