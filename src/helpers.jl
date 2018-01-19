

mutable struct AprilTagDetector
    #pointers to c managed memmory
    td::Ptr{apriltag_detector_t}
    tf::Ptr{apriltag_family_t}

end

"""
	AprilTagDetector()
Create a default AprilTag detector with tha 36h11 tag family
"""
function AprilTagDetector()
    #create tag detector
    td = apriltag_detector_create()
    #create tag family 36h11 by default
    tf = tag36h11_create()
    #add family to detector
    apriltag_detector_add_family(td, tf)


    return AprilTagDetector(td,tf)

end

"""
	AprilTagDetector(img)
Run the april tag detector on a image
"""
function (detector::AprilTagDetector)(image)

    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end

    if detector.tf == C_NULL
        error("AprilTags family does not exist")
    end
    #create image8 opject for april tags
    image8 = convert2image_u8(image)

    # run detector on image
    detections =  apriltag_detector_detect(detector.td, image8)

    # copy and return detections
    tags = getTagDetections(detections)

    #distroy detections memmory
    apriltag_detections_destroy(detections)

    return tags

end

"""
	freeDetector!(apriltagdetector)
Free the allocated memmory
"""
function freeDetector!(detector::AprilTagDetector)

    apriltag_detector_destroy(detector.td)
    tag36h11_destroy(detector.tf) #gebruik die ene sommer vir almal vir nou, dit lyk inelkgeval dieselfde in c kode

    #TODO: how do I destroy the detector itself, for now just nulls
    # eg. somethin like detector = nothing but modify input
    detector.td = C_NULL
    detector.tf = C_NULL
    return nothing
end


# TODO overload convert
function convert2image_u8(image)
#create image8 opject for april tags
    (rows,cols) = size(image)
    imbuf = reinterpret(UInt8, image'[:])
    return AprilTags.image_u8_t(Int32(cols), Int32(rows), Int32(cols), Base.unsafe_convert(Ptr{UInt8}, imbuf))
end


function getTagDetections(detections::Ptr{zarray})
    detzarray = unsafe_load(detections)
    if detzarray.size > 0
        dettags = Vector{AprilTags.apriltag_detection_t}(detzarray.size)
        for i=1:detzarray.size
            pointer_to_apriltag_detection_t = unsafe_load(convert(Ptr{Ptr{AprilTags.apriltag_detection_t}}, detzarray.data),i)
            dettags[i] = unsafe_load(pointer_to_apriltag_detection_t)
        end
        return dettags
    else
        return nothing
    end
end
