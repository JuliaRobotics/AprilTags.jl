
struct AprilTag
    family::Symbol
    id::Int
    hamming::Int
    goodness::Float32
    decision_margin::Float32
    H::Matrix{Float64}
    c::Vector{Float64}
    p::Vector{Vector{Float64}}
end

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

    # copy and return detections julia struct
    tags = AprilTags.copyAprilTagDetections(detections)
    # copy and return detections c struct
    # tags = getTagDetections(detections)

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


function copyAprilTagDetections(detections::Ptr{zarray})
    detzarray = unsafe_load(detections)
    if detzarray.size > 0
        apriltags = Vector{AprilTag}(detzarray.size)
        for i=1:detzarray.size
            pointer_to_apriltag_detection_t = unsafe_load(convert(Ptr{Ptr{AprilTags.apriltag_detection_t}}, detzarray.data),i)
            dettag = unsafe_load(pointer_to_apriltag_detection_t)

            #TODO: implement tag family stuff, hardcode a family for now as a symbol
            family = :tag36h11

            #Reading homography of tag 1 (transpose for c row major and deepcopy since memory is destoyed by c)
            voidpointertoH = Base.unsafe_convert(Ptr{Void}, dettag.H)
            # pointer to H matrix
            nrows = unsafe_load(Ptr{UInt32}(voidpointertoH),1)
            ncols = unsafe_load(Ptr{UInt32}(voidpointertoH),2)
            H = deepcopy(unsafe_wrap(Array, Ptr{Cdouble}(voidpointertoH+8), (3,3))')

            #convert tuples to arrays
            tagc = collect(dettag.c)
            tagp = [collect(i) for i in dettag.p]

            apriltags[i] = AprilTags.AprilTag(family, dettag.id, dettag.hamming, dettag.goodness, dettag.decision_margin, H, tagc, tagp)

        end
        return apriltags
    else
        return nothing
    end
end


"""
    homography_to_pose(H, fx, fy, cx, cy)
Given a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag.
The focal lengths should be given in pixels
"""
function homography_to_pose(H::Matrix{Float64}, fx::Float64, fy::Float64, cx::Float64, cy::Float64)
    # Note that every variable that we compute is proportional to the scale factor of H.
    R31 = H[3, 1]
    R32 = H[3, 2]
    TZ  = H[3, 3]
    R11 = (H[1, 1] - cx*R31) / fx
    R12 = (H[1, 2] - cx*R32) / fx
    TX  = (H[1, 3] - cx*TZ)  / fx
    R21 = (H[2, 1] - cy*R31) / fy
    R22 = (H[2, 2] - cy*R32) / fy
    TY  = (H[2, 3] - cy*TZ)  / fy

    # compute the scale by requiring that the rotation columns are unit length
    # (Use geometric average of the two length vectors we have)
    length1 = sqrt(R11*R11 + R21*R21 + R31*R31)
    length2 = sqrt(R12*R12 + R22*R22 + R32*R32)
    s = 1.0 / sqrt(length1 * length2)

    # get sign of S by requiring the tag to be in front the camera
    # we assume camera looks in the -Z direction.
    if (TZ > 0)
        s *= -1.0
    end

    R31 *= s
    R32 *= s
    TZ  *= s
    R11 *= s
    R12 *= s
    TX  *= s
    R21 *= s
    R22 *= s
    TY  *= s

    # now recover [R13 R23 R3] by noting that it is the cross product of the other two columns.
    R13 = R21*R32 - R31*R22
    R23 = R31*R12 - R11*R32
    R33 = R11*R22 - R21*R12

    # Improve rotation matrix by applying polar decomposition.
    if (true)
        # do polar decomposition. This makes the rotation matrix
        # "proper", but probably increases the reprojection error. An
        # iterative alignment step would be superior.
        R = [R11 R12 R13;
             R21 R22 R23;
             R31 R32 R33]

        U, S, V = svd(R)
        R = U * V
    end

    return  [R    [TX;
                   TY;
                   TZ];
            [0 0 0 1.0]]
end
