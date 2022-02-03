@enum TagFamilies tag36h11 tag25h9 tag16h5

struct AprilTag
    "The family of the tag."
    family::String
    "The decoded ID of the tag."
    id::Int
    """How many error bits were corrected? 
       Note: accepting large numbers of corrected errors leads to greatly increased false positive rates. 
       NOTE: As of this implementation, the detector cannot detect tags with a Hamming distance greater than 2."""
    hamming::Int
    # goodness::Float32
    """A measure of the quality of the binary decoding process: the average difference between the intensity of a data bit versus
       the decision threshold. Higher numbers roughly indicate better decodes. This is a reasonable measure of detection accuracy
       only for very small tags-- not effective for larger tags (where we could have sampled anywhere within a bit cell and still
       gotten a good detection.)"""
    decision_margin::Float32
    """The 3x3 homography matrix describing the projection from an "ideal" tag (with corners at (-1,1), (1,1), (1,-1), and (-1,-1))
	to pixels in the image."""
    H::Matrix{Float64}
    "The center of the detection in image pixel coordinates"
    c::Vector{Float64}
    "The corners of the tag in image pixel coordinates. These always wrap counter-clock wise around the tag."
    p::Vector{Vector{Float64}}
end

mutable struct AprilTagDetector
    #pointers to c managed memmory
    td::Ptr{apriltag_detector_t}
    tf::Ptr{apriltag_family_t}

end

# Base.propertynames(x::AprilTagDetector, private::Bool=false) =
#     (:nThreads, :quad_decimate, :quad_sigma, :refine_edges, :refine_decode, :refine_pose,
#         (private ? fieldnames(typeof(x)) : ())...)

Base.propertynames(x::AprilTagDetector, private::Bool=false) =
    (:nThreads, :quad_decimate, :quad_sigma, :refine_edges, :decode_sharpening,
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
    elseif f == :decode_sharpening
        getdecode_sharpening(x)
    # elseif f == :refine_decode
    #     getrefine_decode(x)
    # elseif f == :refine_pose
    #     getrefine_pose(x)
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
    elseif f == :decode_sharpening
        setdecode_sharpening(x,v)
    # elseif f == :refine_decode
    #     setrefine_decode(x,v)
    # elseif f == :refine_pose
    #     setrefine_pose(x,v)
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
    println(io, "decode_sharpening: ", F.decode_sharpening)
    # println(io, "refine_decode: ", F.refine_decode)
    # println(io, "refine_pose: ", F.refine_pose)
end

"""
	AprilTagDetector(tagfamily=tag36h11)
Create a default AprilTag detector with the 36h11 tag family
Create an AprilTag detector with tag family in `tagfamily::TagFamilies
@enum TagFamilies tag36h11 tag25h9 tag16h5`
"""
function AprilTagDetector(tagfamily::TagFamilies = tag36h11)
    #create tag detector
    td = apriltag_detector_create()
    #create tag family
    if tagfamily == tag36h11
        tf = tag36h11_create()
    # elseif tagfamily == tag36h10
    #     tf = tag36h10_create()
    elseif tagfamily == tag25h9
        tf = tag25h9_create()
    elseif tagfamily == tag16h5
        tf = tag16h5_create()
    end

    #add family to detector
    apriltag_detector_add_family(td, tf)

    #Register finalizer and return detector
    return finalizer(d->freeDetector!(d, false), AprilTagDetector(td,tf))
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
function freeDetector!(detector::AprilTagDetector, verbose::Bool=true)

    if detector.td == C_NULL
        verbose && @warn("AprilTags Detector does not exist")
    else
        apriltag_detector_destroy(detector.td)
    end

    if detector.tf == C_NULL
        verbose && @warn("AprilTags family does not exist")
    else
        # use this one for now, c code is similar
        tag36h11_destroy(detector.tf) 
    end

    #TODO: how do I destroy the detector itself, for now just nulls
    # eg. somethin like detector = nothing but modif_height input
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

            # apriltags[i] = AprilTags.AprilTag(family, dettag.id, dettag.hamming, dettag.goodness, dettag.decision_margin, H, tagc, tagp)
            apriltags[i] = AprilTags.AprilTag(family, dettag.id, dettag.hamming, dettag.decision_margin, H, tagc, tagp)

        end
        return apriltags
    else
        return Vector{AprilTag}()
    end
end

"""
	getAprilTagImage(tagIndex, tagfamily=tag36h11)
Return an image [Gray{N0f8}] for with tagIndex from tag family in `tagfamily::TagFamilies
@enum TagFamilies tag36h11 tag25h9 tag16h5`
"""
function  getAprilTagImage(tagIndex::Int, tagfamily::TagFamilies = tag36h11; blackborder=true)
    #create tag family
    if tagfamily == tag36h11
        tf = tag36h11_create()
    # elseif tagfamily == tag36h10
    #     tf = tag36h10_create()
    elseif tagfamily == tag25h9
        tf = tag25h9_create()
    elseif tagfamily == tag16h5
        tf = tag16h5_create()
    end

    tagptr = AprilTags.apriltag_to_image(tf, Int32(tagIndex))
    tagimg = unsafe_load(tagptr)
    imgbuf = deepcopy(unsafe_wrap(Array, tagimg.buf, (Int(tagimg.stride),Int(tagimg.height)))')

    #FIXME???? this puts the border back to fit with how apriltags2 worked
    tagimg = imgbuf[1:tagimg.height,1:tagimg.width]
    if blackborder
        tagimg[1:end,1] .= 0xff
        tagimg[1:end,end] .= 0xff
        tagimg[1,1:end] .= 0xff
        tagimg[end,1:end] .= 0xff

        tagimg[2:end-1,2] .= 0x00
        tagimg[2:end-1,end-1] .= 0x00
        tagimg[2,2:end-1] .= 0x00
        tagimg[end-1,2:end-1] .= 0x00
    end

    return reinterpret(Gray{N0f8},tagimg)
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

function setdecode_sharpening(detector, decode_sharpening::Float64)::Nothing
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    unsafe_store!(Ptr{Cdouble}(detector.td), decode_sharpening, 3)
    return nothing
end

#NOTE nie meer beskikbaar nie
# function setrefine_decode(detector, refine_decode::Integer)::Nothing
#     if detector.td == C_NULL
#         error("AprilTags Detector does not exist")
#     end
#     unsafe_store!(Ptr{Int32}(detector.td), Int32(refine_decode), 5)
#     return nothing
# end
#
# function setrefine_pose(detector, refine_pose::Integer)::Nothing
#     if detector.td == C_NULL
#         error("AprilTags Detector does not exist")
#     end
#     unsafe_store!(Ptr{Int32}(detector.td), Int32(refine_pose), 6)
#     return nothing
# end

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

function getdecode_sharpening(detector)::Float64
    if detector.td == C_NULL
        error("AprilTags Detector does not exist")
    end
    return unsafe_load(Ptr{Cdouble}(detector.td), 3)
end
#NOTE  bestaan nie meer nie
# function getrefine_decode(detector)::Int32
#     if detector.td == C_NULL
#         error("AprilTags Detector does not exist")
#     end
#     return unsafe_load(Ptr{Int32}(detector.td), 5)
# end
#
# function getrefine_pose(detector)::Int32
#     if detector.td == C_NULL
#         error("AprilTags Detector does not exist")
#     end
#     return unsafe_load(Ptr{Int32}(detector.td), 6)
# end




"""
    homography_to_pose(H, f_width, f_height, c_width, c_height, [taglength = 2.0])

Given a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag.

Notes
- Images.jl uses `::Array` in Julia as column-major (i.e. vertical major) convention, that is `size(img) == (480, 640)`
  - Axes start top left-corner of the image plane (i.e. the image-frame):
  - `width` is from left to right,
  - `height` is from top downward.
- The low-level `ccall` wrapped C-library underneath uses the convention (i.e. the camera-frame): 
  - `fx == f_width`, 
  - `cy == c_height`, and
  - C-library camara coordinate system: camera looking along positive Z axis with `x` to the right and `y` down.
    - C-library internally follows: https://docs.opencv.org/3.4/d9/d0c/group__calib3d.html
- The focal lengths should be given in pixels.
- The returned units are those of the tag size, therefore the translational components should be scaled with the tag size.
- The tag coordinates are from (-1,-1) to (1,1), i.e. the tag size has length of 2 units.
  - Optionally, the tag length (in metre) can be passed to return a scaled value.
- Returns `::Matrix{Float64}`

Related

`homographytopose`
"""
function homography_to_pose(H::Matrix{Float64}, 
                            f_width::Float64, 
                            f_height::Float64, 
                            c_width::Float64, 
                            c_height::Float64; 
                            taglength::Float64 = 2.0)
    # Note that every variable that we compute is proportional to the scale factor of H.
    R31 = H[3, 1]
    R32 = H[3, 2]
    TZ  = H[3, 3]
    R11 = (H[1, 1] - c_width*R31) / f_width
    R12 = (H[1, 2] - c_width*R32) / f_width
    TX  = (H[1, 3] - c_width*TZ)  / f_width
    R21 = (H[2, 1] - c_height*R31) / f_height
    R22 = (H[2, 2] - c_height*R32) / f_height
    TY  = (H[2, 3] - c_height*TZ)  / f_height

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
    homographytopose(H, f_width, f_height, c_width, c_height, [taglength = 2.0])

Given a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag.

Notes
- Images.jl uses `::Array` in Julia as column-major (i.e. vertical major) convention, that is `size(img) == (480, 640)`
  - Axes start top left-corner of the image plane (i.e. the image-frame):
  - `width` is from left to right,
  - `height` is from top downward.
- The low-level `ccall` wrapped C-library underneath uses the convention (i.e. the camera-frame): 
  - `fx == f_width`, 
  - `cy == c_height`, and
  - C-library camara coordinate system: camera looking along positive Z axis with `x` to the right and `y` down.
    - C-library internally follows: https://docs.opencv.org/3.4/d9/d0c/group__calib3d.html
- The focal lengths should be given in pixels.
- The returned units are those of the tag size, therefore the translational components should be scaled with the tag size.
- The tag coordinates are from (-1,-1) to (1,1), i.e. the tag size has length of 2 units.
  - Optionally, the tag length (in metre) can be passed to return a scaled value.
- Returns `::Matrix{Float64}`
```

Related:

`homography_to_pose`
"""
function homographytopose(  H::Matrix{Float64}, 
                            f_width::Float64, 
                            f_height::Float64, 
                            c_width::Float64, 
                            c_height::Float64; 
                            taglength::Float64 = 2.0)
    # Note that every variable that we compute is proportional to the scale factor of H.
    R31 = H[3, 1]
    R32 = H[3, 2]
    TZ  = H[3, 3]
    R11 = (H[1, 1] - c_width*R31) / f_width
    R12 = (H[1, 2] - c_width*R32) / f_width
    TX  = (H[1, 3] - c_width*TZ)  / f_width
    R21 = (H[2, 1] - c_height*R31) / f_height
    R22 = (H[2, 2] - c_height*R32) / f_height
    TY  = (H[2, 3] - c_height*TZ)  / f_height

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


"""
    $SIGNATURES

Detect tags and calcuate the pose on them.
"""
function detectAndPose( detector::AprilTagDetector, 
                        image::Array{T,2}, 
                        f_width, 
                        f_height, 
                        c_width, 
                        c_height, 
                        taglength ) where T <: U8Types
    #
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

    detzarray = unsafe_load(detections)
    if detzarray.size > 0
        poses = Vector{Matrix{Float64}}(undef,detzarray.size)
        for i=1:detzarray.size
            det = unsafe_load(convert(Ptr{Ptr{AprilTags.apriltag_detection_t}}, detzarray.data),i)

            detinfo = AprilTags.apriltag_detection_info_t(det, taglength, f_width, f_height, c_width, c_height)

            pose_p = AprilTags.apriltag_pose_t()

            AprilTags.estimate_pose_for_tag_homography(detinfo, pose_p)

            matR = unsafe_load(pose_p.R)
            R = Matrix{Float64}(undef,3,3)
            for i = 1:9
                R[i] = unsafe_load(convert(Ptr{Cdouble},pose_p.R),i+1)
            end

            t = Vector{Float64}(undef,3)
            for i = 1:3
                t[i] = unsafe_load(convert(Ptr{Cdouble},pose_p.t),i+1)
            end

            poses[i] = [R t]

        end

    else
        poses = Vector{Matrix{Float64}}()
    end

    #distroy detections memmory
    apriltag_detections_destroy(detections)

    return tags, poses
end

"""
    $SIGNATURES

Higher level API to estimate the pose based on orthogonal vectors in the pose estimate.  This is a
higher accuracy function that [`homographytopose`](@ref).

Notes
- The low level C-library uses the convention `fx==f_width`.
"""
function estimateTagPoseOrthogonalIteration(tag::AprilTag, 
                                            f_width::Float64, 
                                            f_height::Float64, 
                                            c_width::Float64, 
                                            c_height::Float64; 
                                            taglength::Float64 = 2.0, 
                                            nIters::Int = 50)
    #
    Ki = [[1/f_width  0    -c_width/f_width];
          [0     1/f_height -c_height/f_height];
          [0     0     1]]
    scale = taglength/2.0

    p = (Matd3x1([-scale, scale, 0]),
         Matd3x1([ scale, scale, 0]),
         Matd3x1([ scale,-scale, 0]),
         Matd3x1([-scale,-scale, 0]))

    v = (Matd3x1(Ki*[tag.p[1];1]), Matd3x1(Ki*[tag.p[2];1]), Matd3x1(Ki*[tag.p[3];1]), Matd3x1(Ki*[tag.p[4];1]))

    M = AprilTags.homographytopose(tag.H, f_width, f_height, c_width, c_height, taglength=taglength)

    R = (Matd3x3(M[1:3,1:3]), )
    t = (Matd3x1(M[1:3,4]), )

    err1 = AprilTags.orthogonal_iteration(v, p, t, R, 4, 50)

    R2p = AprilTags.fix_pose_ambiguities(v, p, t[1], R[1], 4)
    R2 = (unsafe_load(R2p), )

    t2 = (Matd3x1([0.,0,0]), )
    if R2 != C_NULL
        err2 = AprilTags.orthogonal_iteration(v, p, t2, R2, 4, 50)
    else
        err2 = 1e9
    end

    # pack a bit better
    sol1R = Matrix{Float64}(undef,3,3)
    sol1R'[:] .= R[1].data

    sol1t = [t[1].data...]

    sol2R = Matrix{Float64}(undef,3,3)
    sol2R'[:] .= R2[1].data

    sol2t = [t2[1].data...]


    return [sol1R sol1t], err1, [sol2R sol2t], err2
end


function calculate_F(v)
    outer_product = v*v'
    inner_product = v'*v
    outer_product /= inner_product[1]
    return outer_product
end


"""
    $SIGNATURES

Utility function that iterates to make vectors orthogonal?
"""
function orthogonalIteration(v, p, t, R, n_points=4, n_steps=50)

    p_mean = mean(p)

    p_res = [pp - p_mean for pp in p]

    # Compute M1_inv.
    F = calculate_F.(v)

    avg_F = mean(F)

    M1 = I - avg_F
    M1_inv = inv(M1)

    prev_error = 1e9

    # Iterate.
    for i=1:n_steps
        # Calculate translation.
        M2 = [0.,0,0]
        for j=1:n_points
            M2 += (F[j] - I) * R * p[j]   #(M - M)*M*M,
        end
        M2 /= n_points

        t = M1_inv * M2

        #calcutate rotation
        q = Vector{Vector{Float64}}(undef, 4)

        for j=1:n_points
            q[j] = F[j]*(R*p[j] + t)   #"M*(M*M+M)"
        end
        q_mean = mean(q)

        M3 = zeros(3,3)
        for j=1:n_points
            M3 += (q[j] - q_mean) * p_res[j]'  #"(M-M)*M'", q[j], q_mean, p_res[j]
        end
        M3_svd = svd(M3)

        R = M3_svd.U * M3_svd.V' #"M*M'", M3_svd.U, M3_svd.V

        err = 0.0

        for j = 1:4
            err_vec =  (I - F[j]) * (R*p[j] + t)  #("(M-M)(MM+M)", I3, F[i], *R, p[i], *t);
            err +=  err_vec'*err_vec #("M'M", err_vec, err_vec));
        end

        prev_error = err

    end

    return [R t], prev_error
end

"""
    $SIGNATURES

Run the orthoganal iteration algorithm on the poses. 

Notes
- See apriltag_pose.h
- [2]: Lu, G. D. Hager and E. Mjolsness, "Fast and globally convergent pose estimation from video images," 
  in IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 22, no. 6, pp. 610-622, June 2000. 
  doi: 10.1109/34.862199
- The low level C-library uses `fx=f_width`.
"""
function tagOrthogonalIteration(corners::Union{<:AbstractVector,<:Tuple},
                                H::Matrix{<:Real}, 
                                f_width::Real, 
                                f_height::Real, 
                                c_width::Real, 
                                c_height::Real; 
                                taglength::Real = 2.0, 
                                nIters::Int = 50 )
    #
    Ki = [[1/f_width  0    -c_width/f_width];
          [0     1/f_height -c_height/f_height];
          [0     0     1]]
    scale = taglength/2.0

    p = [[-scale, scale, 0],
         [ scale, scale, 0],
         [ scale,-scale, 0],
         [-scale,-scale, 0]]

    v = [Ki*[corners[1]...;1], Ki*[corners[2]...;1], Ki*[corners[3]...;1], Ki*[corners[4]...;1]]

    # must have floats before doing ccall
    M = homographytopose(H, float(f_width), float(f_height), float(c_width), float(c_height), taglength=taglength)

    R = M[1:3,1:3]
    t = M[1:3,4]

    return AprilTags.orthogonalIteration(v, p, t, R, 4, nIters)
end

tagOrthogonalIteration( tag::AprilTag, 
                        f_width::Float64, 
                        f_height::Float64, 
                        c_width::Float64, 
                        c_height::Float64; 
                        taglength::Float64 = 2.0, 
                        nIters::Int = 50 ) = tagOrthogonalIteration(tag.p, tag.H, f_width, f_height, c_width, c_height, taglength=taglength, nIters=nIters)
#
