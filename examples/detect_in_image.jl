using Images
using AprilTags

##
cd(dirname(@__FILE__))

image = load("../data/tagtest.jpg")

#create april tag detector
td = AprilTags.apriltag_detector_create()

#create tag family
tf = AprilTags.tag36h11_create()

#add family to detector
AprilTags.apriltag_detector_add_family(td, tf)

#create image8 opject for april tags TODO: put in function
imbuf = reinterpret(UInt8, image'[:])
image8 = AprilTags.image_u8_t(Int32(640), Int32(480), Int32(640), Base.unsafe_convert(Ptr{UInt8}, imbuf))

# run detector on image
detections =  AprilTags.apriltag_detector_detect(td, Ref(image8))

# copy detections TODO: put in function
detzarray = unsafe_load(detections)

#TODO: not working yet
dettag = nothing
for i = 1:detzarray.size
    #TODO: wrap in function
    dettag = unsafe_load( Base.unsafe_convert(Ptr{AprilTags.apriltag_detection_t}, detzarray.data),  idx)

    # use detected tags here
end


##
#clean up C

apriltag_detections_destroy(detections)

# The caller is responsible for freeing detections by calling
apriltag_detections_destroy()

# Cleanup: free the detector and tag family when done.
apriltag_detector_destroy(td)
tag36h11_destroy(tf)
