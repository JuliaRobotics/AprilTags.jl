@enum TagFamilies tag36h11 tag36h10 tag25h9 tag16h5

struct AprilTag
    family::String
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

Base.propertynames(x::AprilTagDetector, private::Bool=false) =
    (:nThreads, :quad_decimate, :quad_sigma, :refine_edges, :refine_decode, :refine_pose,
        (private ? fieldnames(typeof(x)) : ())...)

Base.getproperty(x::AprilTagDetector,f::Symbol) = begin
    if f == :nThreads
        getnThreads(x)
    elseif f == :quad_decimate
        getquad_decimate(x)
    elseif f == :quad_sigma
        getquad_sigma(x)
    elseif f == :refine_edges
        getrefine_edges(x)
    elseif f == :refine_decode
        getrefine_decode(x)
    elseif f == :refine_pose
        getrefine_pose(x)
    else
        getfield(x,f)
    end
end

Base.setproperty!(x::AprilTagDetector,f::Symbol, v) = begin
    if f == :nThreads
        setnThreads(x,v)
    elseif f == :quad_decimate
        setquad_decimate(x,v)
    elseif f == :quad_sigma
        setquad_sigma(x,v)
    elseif f == :refine_edges
        setrefine_edges(x,v)
    elseif f == :refine_decode
        setrefine_decode(x,v)
    elseif f == :refine_pose
        setrefine_pose(x,v)
    else
        # Base.setfield!(x,f,v)
        Base.setfield!(x, f, convert(fieldtype(typeof(x), f), v))
    end
end

function Base.show(io::IO, mime::MIME{Symbol("text/plain")}, F::AprilTagDetector)
    println(io, summary(F))
    println(io, "nThreads: ", F.nThreads)
    println(io, "quad_decimate: ", F.quad_decimate)
    println(io, "quad_sigma: ", F.quad_sigma)
    println(io, "refine_edges: ", F.refine_edges)
    println(io, "refine_decode: ", F.refine_decode)
    println(io, "refine_pose: ", F.refine_pose)
end

"""
	AprilTagDetector(tagfamily=tag36h11)
Create a default AprilTag detector with the 36h11 tag family
Create an AprilTag detector with tag family in `tagfamily::TagFamilies
@enum TagFamilies tag36h11 tag36h10 tag25h9 tag16h5`
"""
function AprilTagDetector(tagfamily::TagFamilies = tag36h11)
    #create tag detector
    td = apriltag_detector_create()
    #create tag family
    if tagfamily == tag36h11
        tf = tag36h11_create()
    elseif tagfamily == tag36h10
        tf = tag36h10_create()
    elseif tagfamily == tag25h9
        tf = tag25h9_create()
    elseif tagfamily == tag16h5
        tf = tag16h5_create()
    end

    #add family to detector
    apriltag_detector_add_family(td, tf)

    return AprilTagDetector(td,tf)
end

const U8Types = Union{UInt8, N0f8, Gray{N0f8}}
"""
	AprilTagDetector(img)
Run the april tag detector on a image
"""
function (detector::AprilTagDetector)(image::Array{T, 2}) where T <: U8Types

    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end

    if detector.tf == C_NULL
        error("AprilTags family does not exist")
    end
    #create image8 object for april tags
    image8 = convert(AprilTags.image_u8_t, image)

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

function (detector::AprilTagDetector)(image::Array{ColorTypes.RGB{T}, 2}) where T
    # Converting to greyscale
    image = Gray.(image)
    # Call internal
    return detector(image)
end

"""
	threadcalldetect(detector, image)
Run the april tag detector on a image
"""
function threadcalldetect(detector::AprilTagDetector, image::Array{T, 2}) where T <: U8Types

    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end

    if detector.tf == C_NULL
        error("AprilTags family does not exist")
    end
    #create image8 object for april tags
    image8 = convert(AprilTags.image_u8_t, image)

    # run detector on image
    detections =  threadcall_apriltag_detector_detect(detector.td, image8)

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
function freeDetector!(detector::AprilTagDetector)::Nothing

    if detector.td == C_NULL
        @warn "AprilTags Detector does not exist"
    else
        apriltag_detector_destroy(detector.td)
    end

    if detector.tf == C_NULL
        @warn "AprilTags family does not exist"
    else
        tag36h11_destroy(detector.tf) #gebruik die ene sommer vir almal vir nou, dit lyk inelkgeval dieselfde in c kode
    end

    #TODO: how do I destroy the detector itself, for now just nulls
    # eg. somethin like detector = nothing but modify input
    detector.td = C_NULL
    detector.tf = C_NULL
    return nothing
end


# # TODO overload convert
# function convert2image_u8(image)::image_u8_t
# #create image8 opject for april tags
#     (rows,cols) = size(image)
#     imbuf = reinterpret(UInt8, image'[:])
#     return AprilTags.image_u8_t(Int32(cols), Int32(rows), Int32(cols), Base.unsafe_convert(Ptr{UInt8}, imbuf))
# end
function convert(::Type{image_u8_t}, image::Array{UInt8, 2})
#create image8 opject for april tags
    (rows,cols) = size(image)
    imbuf = image'[:]
    return AprilTags.image_u8_t(Int32(cols), Int32(rows), Int32(cols), Base.unsafe_convert(Ptr{UInt8}, imbuf))
end
# TODO maybe add for AbstractArray types such as ReinterpretArray
# function convert(::Type{image_u8_t}, image::AbstractArray{UInt8, 2})
# #create image8 opject for april tags
#     @show (rows,cols) = size(image)
#     imbuf = image'[:]
#     return AprilTags.image_u8_t(Int32(cols), Int32(rows), Int32(cols), Base.unsafe_convert(Ptr{UInt8}, imbuf))
# end

function convert(::Type{image_u8_t}, image::Array{T, 2}) where T <: U8Types
#create image8 opject for april tags
    (rows,cols) = size(image)
    imbuf = reinterpret(UInt8, image'[:])
    return AprilTags.image_u8_t(Int32(cols), Int32(rows), Int32(cols), Base.unsafe_convert(Ptr{UInt8}, imbuf))
end


function getTagDetections(detections::Ptr{zarray})::Vector{AprilTags.apriltag_detection}
    detzarray = unsafe_load(detections)
    if detzarray.size > 0
        dettags = Vector{AprilTags.apriltag_detection_t}(undef,detzarray.size)
        for i=1:detzarray.size
            pointer_to_apriltag_detection_t = unsafe_load(convert(Ptr{Ptr{AprilTags.apriltag_detection_t}}, detzarray.data),i)
            dettags[i] = unsafe_load(pointer_to_apriltag_detection_t)

        end
        return dettags
    else
        return Vector{AprilTags.apriltag_detection}()
    end
end


function copyAprilTagDetections(detections::Ptr{zarray})::Vector{AprilTag}
    detzarray = unsafe_load(detections)
    if detzarray.size > 0
        apriltags = Vector{AprilTag}(undef,detzarray.size)
        for i=1:detzarray.size
            pointer_to_apriltag_detection_t = unsafe_load(convert(Ptr{Ptr{AprilTags.apriltag_detection_t}}, detzarray.data),i)
            dettag = unsafe_load(pointer_to_apriltag_detection_t)

            #TODO: implement more tag family stuff, just return family name as a string for now
            family = unsafe_string(unsafe_load(dettag.family).name)

            #Reading homography of tag 1 (transpose for c row major and deepcopy since memory is destoyed by c)
            voidpointertoH = Base.unsafe_convert(Ptr{Nothing}, dettag.H)
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
        return Vector{AprilTag}()
    end
end

"""
	getAprilTagImage(tagIndex, tagfamily=tag36h11)
Return an image [Gray{N0f8}] for with tagIndex from tag family in `tagfamily::TagFamilies
@enum TagFamilies tag36h11 tag36h10 tag25h9 tag16h5`
"""
function  getAprilTagImage(tagIndex::Int, tagfamily::TagFamilies = tag36h11)
    #create tag family
    if tagfamily == tag36h11
        tf = tag36h11_create()
    elseif tagfamily == tag36h10
        tf = tag36h10_create()
    elseif tagfamily == tag25h9
        tf = tag25h9_create()
    elseif tagfamily == tag16h5
        tf = tag16h5_create()
    end

    tagptr = AprilTags.apriltag_to_image(tf, Int32(tagIndex))
    tagimg = unsafe_load(tagptr)
    imgbuf = deepcopy(unsafe_wrap(Array, tagimg.buf, (Int(tagimg.stride),Int(tagimg.height)))')

    return reinterpret(Gray{N0f8},imgbuf[1:tagimg.height,1:tagimg.width])
end



##Setters
function setnThreads(detector, nthreads::Integer)::Nothing
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    if 0 < nthreads < 100 # basic bound check
        unsafe_store!(Ptr{Int32}(detector.td), Int32(nthreads), 1) #first Int
    end
    return nothing
end

function setquad_decimate(detector, quad_decimate)::Nothing
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    unsafe_store!(Ptr{Cfloat}(detector.td), Float32(quad_decimate), 2)
    return nothing
end

function setquad_sigma(detector, quad_sigma)::Nothing
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    unsafe_store!(Ptr{Cfloat}(detector.td), Float32(quad_sigma), 3)
    return nothing
end

function setrefine_edges(detector, refine_edges::Integer)::Nothing
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    unsafe_store!(Ptr{Int32}(detector.td), Int32(refine_edges), 4)
    return nothing
end


function setrefine_decode(detector, refine_decode::Integer)::Nothing
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    unsafe_store!(Ptr{Int32}(detector.td), Int32(refine_decode), 5)
    return nothing
end

function setrefine_pose(detector, refine_pose::Integer)::Nothing
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    unsafe_store!(Ptr{Int32}(detector.td), Int32(refine_pose), 6)
    return nothing
end

##Getters
function getnThreads(detector)::Int32
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    return unsafe_load(Ptr{Int32}(detector.td), 1) #first Int
end

function getquad_decimate(detector)::Float32
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    return unsafe_load(Ptr{Cfloat}(detector.td), 2)
end

function getquad_sigma(detector)::Float32
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    return unsafe_load(Ptr{Cfloat}(detector.td), 3)
end

function getrefine_edges(detector)::Int32
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    return unsafe_load(Ptr{Int32}(detector.td), 4)
end


function getrefine_decode(detector)::Int32
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    return unsafe_load(Ptr{Int32}(detector.td), 5)
end

function getrefine_pose(detector)::Int32
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    return unsafe_load(Ptr{Int32}(detector.td), 6)
end


"""
    homography_to_pose(H, fx, fy, cx, cy, [taglength = 2.0])
Given a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag.
The focal lengths should be given in pixels.
The returned units are those of the tag size,
therefore the translational components should be scaled with the tag size.
Note: the tag coordinates are from (-1,-1) to (1,1), i.e. the tag size has lenght of 2 units.
Optionally, the tag length (in metre) can be passed to return a scaled value.
"""
function homography_to_pose(H::Matrix{Float64}, fx::Float64, fy::Float64, cx::Float64, cy::Float64; taglength::Float64 = 2.0)::Matrix{Float64}
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
        R = U * V'
    end

    return  [R    [TX*taglength/2.0;
                   TY*taglength/2.0;
                   TZ*taglength/2.0];
            [0 0 0 1.0]]
end


"""
    homographytopose(H, fx, fy, cx, cy, [taglength = 2.0])
Given a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag.
The focal lengths should be given in pixels.
The returned units are those of the tag size,
therefore the translational components should be scaled with the tag size.
Note: the tag coordinates are from (-1,-1) to (1,1), i.e. the tag size has lenght of 2 units.
Optionally, the tag length (in metre) can be passed to return a scaled value.
The camara coordinate system: camera looking in positive Z axis with x to the right and y down.
"""
function homographytopose(H::Matrix{Float64}, fx::Float64, fy::Float64, cx::Float64, cy::Float64; taglength::Float64 = 2.0)::Matrix{Float64}
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
    # we assume camera looks in the +Z direction.
    if (TZ < 0)
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
        R = U * V'
    end

    return  [R    [TX*taglength/2.0;
                   TY*taglength/2.0;
                   TZ*taglength/2.0];
            [0 0 0 1.0]]
end
