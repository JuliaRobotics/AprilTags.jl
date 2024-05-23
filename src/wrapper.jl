## header

mutable struct pthread_attr_t
    _pthread_attr_t::NTuple{56, UInt8}
end

const pthread_attr_t = pthread_attr_t

mutable struct pthread_mutex_t
    _pthread_mutex_t::NTuple{40, UInt8}
end

mutable struct pthread_mutexattr_t
    _pthread_mutexattr_t::NTuple{4, UInt8}
end

mutable struct pthread_cond_t
    _pthread_cond_t::NTuple{48, UInt8}
end

mutable struct pthread_condattr_t
    _pthread_condattr_t::NTuple{4, UInt8}
end

const pthread_key_t = UInt32
const pthread_once_t = Cint

mutable struct pthread_rwlock_t
    _pthread_rwlock_t::NTuple{56, UInt8}
end

mutable struct pthread_rwlockattr_t
    _pthread_rwlockattr_t::NTuple{8, UInt8}
end

const pthread_spinlock_t = Cint

mutable struct pthread_barrier_t
    _pthread_barrier_t::NTuple{32, UInt8}
end

mutable struct pthread_barrierattr_t
    _pthread_barrierattr_t::NTuple{4, UInt8}
end

mutable struct random_data
    fptr::Ptr{Int32}
    rptr::Ptr{Int32}
    state::Ptr{Int32}
    rand_type::Cint
    rand_deg::Cint
    rand_sep::Cint
    end_ptr::Ptr{Int32}
end

mutable struct drand48_data
    __x::NTuple{3, UInt16}
    __old_x::NTuple{3, UInt16}
    __c::UInt16
    __init::UInt16
    __a::Culonglong
end


mutable struct matd_t
    nrows::UInt32
    ncols::UInt32
    data::Ptr{Cdouble}
end

mutable struct matd_svd_t
    U::Ptr{matd_t}
    S::Ptr{matd_t}
    V::Ptr{matd_t}
end

mutable struct matd_plu_t
    singular::Cint
    piv::Ptr{UInt32}
    pivsign::Cint
    lu::Ptr{matd_t}
end

mutable struct matd_chol_t
    is_spd::Cint
    u::Ptr{matd_t}
end

const uint8_t = Cuchar
const uint16_t = UInt16
const uint32_t = UInt32
const uint64_t = Culong
const int_least8_t = UInt8
const int_least16_t = Int16
const int_least32_t = Cint
const int_least64_t = Clong
const uint_least8_t = Cuchar
const uint_least16_t = UInt16
const uint_least32_t = UInt32
const uint_least64_t = Culong
const int_fast8_t = UInt8
const int_fast16_t = Clong
const int_fast32_t = Clong
const int_fast64_t = Clong
const uint_fast8_t = Cuchar
const uint_fast16_t = Culong
const uint_fast32_t = Culong
const uint_fast64_t = Culong
const intptr_t = Clong
const uintptr_t = Culong
const intmax_t = Clong
const uintmax_t = Culong

mutable struct image_u8
    width::Int32
    height::Int32
    stride::Int32
    buf::Ptr{UInt8}
end

const image_u8_t = image_u8

mutable struct image_u8x3
    width::Int32
    height::Int32
    stride::Int32
    buf::Ptr{UInt8}
end

const image_u8x3_t = image_u8x3

mutable struct image_u8x4
    width::Int32
    height::Int32
    stride::Int32
    buf::Ptr{UInt8}
end

const image_u8x4_t = image_u8x4

mutable struct image_f32
    width::Int32
    height::Int32
    stride::Int32
    buf::Ptr{Cfloat}
end

const image_f32_t = image_f32

mutable struct image_u32
    width::Int32
    height::Int32
    stride::Int32
    buf::Ptr{UInt32}
end

const image_u32_t = image_u32

mutable struct image_u8_lut
    scale::Cfloat
    nvalues::Cint
    values::Ptr{UInt8}
end

const image_u8_lut_t = image_u8_lut

mutable struct zarray
    el_sz::Csize_t
    size::Cint
    alloc::Cint
    data::Ptr{UInt8}
    zarray() = new()
end

const zarray_t = zarray

mutable struct workerpool
end

const workerpool_t = Nothing

const va_list = Cint

mutable struct timezone
    tz_minuteswest::Cint
    tz_dsttime::Cint
end


mutable struct _pthread_cleanup_buffer
    __routine::Ptr{Nothing}
    __arg::Ptr{Nothing}
    __canceltype::Cint
    __prev::Ptr{_pthread_cleanup_buffer}
end

mutable struct quad
    p::NTuple{4, NTuple{2, Cfloat}}
    reversed_border::Bool
    H::Ptr{matd_t}
    Hinv::Ptr{matd_t}
end

mutable struct timeprofile
    utime::Int64
    stamps::Ptr{zarray_t}
end

const timeprofile_t = timeprofile

#TODO: untested
mutable struct apriltag_family
    ncodes::UInt32
    codes::Ptr{UInt64}
    width_at_border::Cint
    total_width::Cint
    reversed_border::Bool
    nbits::UInt32
    bit_x::Ptr{UInt32}
    bit_y::Ptr{UInt32}
    h::UInt32
    name::Cstring
    impl::Ptr{Nothing}
end

const apriltag_family_t = apriltag_family

mutable struct apriltag_quad_thresh_params
    min_cluster_pixels::Cint
    max_nmaxima::Cint
    cos_critical_rad::Cfloat
    max_line_fit_mse::Cfloat
    min_white_black_diff::Cint
    deglitch::Cint
end


mutable struct apriltag_detector
# #############################################################################
# User-configurable parameters.
    # How many threads should be used?
    nthreads::Cint
    # // detection of quads can be done on a lower-resolution image,
    # // improving speed at a cost of pose accuracy and a slight
    # // decrease in detection rate. Decoding the binary payload is
    # // still done at full resolution. .
    quad_decimate::Cfloat
    #  What Gaussian blur should be applied to the segmented image
    #  (used for quad detection?)  Parameter is the standard deviation
    #  in pixels.  Very noisy images benefit from non-zero values
    #  (e.g. 0.8).
    quad_sigma::Cfloat
    #  When non-zero, the edges of the each quad are adjusted to "snap
    #  to" strong gradients nearby. This is useful when decimation is
    #  employed, as it can increase the quality of the initial quad
    #  estimate substantially. Generally recommended to be on (1).
    #  Very computationally inexpensive. Option is ignored if quad_decimate = 1.
    refine_edges::Cint

    # How much sharpening should be done to decoded images? This
    # can help decode small tags but may or may not help in odd
    # lighting conditions or low light conditions.
    #
    # The default value is 0.25.
    decode_sharpening::Cdouble

    #  When non-zero, write a variety of debugging images to the
    #  current working directory at various stages through the
    #  detection process. (Somewhat slow).
    # int debug;
    debug::Cint

    # qtp::apriltag_quad_thresh_params
        min_cluster_pixels::Cint
        max_nmaxima::Cint
        critical_rad::Cfloat
        max_line_fit_mse::Cfloat
        min_white_black_diff::Cint
        deglitch::Cint


    tp::Ptr{timeprofile_t}
    nedges::UInt32
    nsegments::UInt32
    nquads::UInt32
    tag_families::Ptr{zarray_t}
    wp::Ptr{workerpool_t}

    # mutex::pthread_mutex_t
        mutex::NTuple{40, UInt8}

    apriltag_detector() = new()
end

const apriltag_detector_t = apriltag_detector

mutable struct apriltag_detection
    family::Ptr{apriltag_family_t}
    id::Cint
    hamming::Cint
    # goodness::Cfloat
    decision_margin::Cfloat
    H::Ptr{matd_t}
    c::NTuple{2, Cdouble}
    p::NTuple{4, NTuple{2, Cdouble}}
    apriltag_detection() = new()
end

const apriltag_detection_t = apriltag_detection

# Tag families constructors and destructors
"""
	tag36h11_create()
Create a AprilTag family object for tag36h11 with all fields set to default value.
"""
function tag36h11_create()
    ccall((:tag36h11_create, libapriltag), Ptr{apriltag_family_t}, ())
end

"""
	tag36h11_destroy(tf)
Destroy the AprilTag family object.
"""
function tag36h11_destroy(tf)
    ccall((:tag36h11_destroy, libapriltag), Nothing, (Ptr{apriltag_family_t},), tf)
end

#NOTE Not in apriltag 3
# function tag36h10_create()
#     ccall((:tag36h10_create, libapriltag), Ptr{apriltag_family_t}, ())
# end
#
# function tag36h10_destroy(tf)
#     ccall((:tag36h10_destroy, libapriltag), Nothing, (Ptr{apriltag_family_t},), tf)
# end

function tag25h9_create()
    ccall((:tag25h9_create, libapriltag), Ptr{apriltag_family_t}, ())
end

function tag25h9_destroy(tf)
    ccall((:tag25h9_destroy, libapriltag), Nothing, (Ptr{apriltag_family_t},), tf)
end

#NOTE Not in apriltag 3
# function tag25h7_create()
#     ccall((:tag25h7_create, libapriltag), Ptr{apriltag_family_t}, ())
# end

# function tag25h7_destroy(tf)
#     ccall((:tag25h7_destroy, libapriltag), Nothing, (Ptr{apriltag_family_t},), tf)
# end

function tag16h5_create()
    ccall((:tag16h5_create, libapriltag), Ptr{apriltag_family_t}, ())
end

function tag16h5_destroy(tf)
    ccall((:tag16h5_destroy, libapriltag), Nothing, (Ptr{apriltag_family_t},), tf)
end

function tagStandard41h12_create()
    ccall((:tagStandard41h12_create, libapriltag), Ptr{apriltag_family_t}, ())
end

function tagStandard41h12_destroy(tf)
    ccall((:tagStandard41h12_destroy, libapriltag), Nothing, (Ptr{apriltag_family_t},), tf)
end

# # this family segfaults for `apriltag_detector_add_family(td, tf)
# function tagStandard52h13_create()
#     ccall((:tagStandard52h13_create, libapriltag), Ptr{apriltag_family_t}, ())
# end
#
# function tagStandard52h13_destroy(tf)
#     ccall((:tagStandard52h13_destroy, libapriltag), Nothing, (Ptr{apriltag_family_t},), tf)
# end

# # circular tags are problematic because they require a mask of white pixels around the circle
# function tagCircle49h12_create()
#     ccall((:tagCircle49h12_create, libapriltag), Ptr{apriltag_family_t}, ())
# end
#
# function tagCircle49h12_destroy(tf)
#     ccall((:tagCircle49h12_destroy, libapriltag), Nothing, (Ptr{apriltag_family_t},), tf)
# end

"""
	apriltag_detector_create()
Create a AprilTag Detector object with all fields set to default value.
"""
function apriltag_detector_create()
    ccall((:apriltag_detector_create, libapriltag), Ptr{apriltag_detector_t}, ())
end


function apriltag_detector_add_family_bits(td, fam, bits_corrected::Cint)
    ccall((:apriltag_detector_add_family_bits, libapriltag), Nothing, (Ptr{apriltag_detector_t}, Ptr{apriltag_family_t}, Cint), td, fam, bits_corrected)
end

"""
	apriltag_detector_add_family(tag_detector, tag_family)
Add a tag family to an AprilTag Detector object.
The caller still "owns" the family and a single instance should only be provided to one apriltag detector instance.
"""
function apriltag_detector_add_family(td, fam)
    # ccall((:apriltag_detector_add_family, libapriltag), Nothing, (Ptr{apriltag_detector_t}, Ptr{apriltag_family_t}), td, fam)
    apriltag_detector_add_family_bits(td, fam, Int32(2))
end

function apriltag_detector_remove_family(td, fam)
    ccall((:apriltag_detector_remove_family, libapriltag), Nothing, (Ptr{apriltag_detector_t}, Ptr{apriltag_family_t}), td, fam)
end

function apriltag_detector_clear_families(td)
    ccall((:apriltag_detector_clear_families, libapriltag), Nothing, (Ptr{apriltag_detector_t},), td)
end

function apriltag_detector_destroy(td)
    ccall((:apriltag_detector_destroy, libapriltag), Nothing, (Ptr{apriltag_detector_t},), td)
end

"""
	apriltag_detector_detect(tag_detector, image)
Detect tags from an image and return an array of apriltag_detection_t*.
You can use apriltag_detections_destroy to free the array and the detections it contains, or call
detection_destroy and zarray_destroy yourself.
"""
function apriltag_detector_detect(td, im_orig)
    ccall((:apriltag_detector_detect, libapriltag), Ptr{zarray_t}, (Ptr{apriltag_detector_t}, Ptr{image_u8_t}), td, Ref(im_orig))
end

"""
	threadcall_apriltag_detector_detect(tag_detector, image)
*Experimental* call apriltag_detector_detect in a seperate thread using the experimantal `@threadcall`
Detect tags from an image and return an array of apriltag_detection_t*.
You can use apriltag_detections_destroy to free the array and the detections it contains, or call
detection_destroy and zarray_destroy yourself.
"""
function threadcall_apriltag_detector_detect(td, im_orig)
    @threadcall((:apriltag_detector_detect, libapriltag), Ptr{zarray_t}, (Ptr{apriltag_detector_t}, Ptr{image_u8_t}), td, Ref(im_orig))
end


function apriltag_detection_destroy(det)
    ccall((:apriltag_detection_destroy, libapriltag), Nothing, (Ptr{apriltag_detection_t},), det)
end

function apriltag_detections_destroy(detections)
    ccall((:apriltag_detections_destroy, libapriltag), Nothing, (Ptr{zarray_t},), detections)
end

function apriltag_to_image(fam, idx::Cint)
    ccall((:apriltag_to_image, libapriltag), Ptr{image_u8_t}, (Ptr{apriltag_family_t}, Cint), fam, idx)
end


#common

# matd_t *homography_to_pose(const matd_t *H, double fx, double fy, double cx, double cy)
function homography_to_pose(H, fx, fy, cx, cy)
    ccall((:homography_to_pose, libapriltag), Ptr{matd_t}, (Ptr{matd_t}, Cdouble, Cdouble, Cdouble, Cdouble), H, fx, fy, cx, cy)
end


"""
    $TYPEDEF

new pose estimation from apriltag 3

Notes:
- This low-level `ccall` wrapped C-library type uses the convention (i.e. the camera-frame):
  - `fx == f_width`, 
  - `cy == c_height`, and
  - C-library camara coordinate system: camera looking along positive Z axis with `x` to the right and `y` down.
    - C-library internally follows: https://docs.opencv.org/3.4/d9/d0c/group__calib3d.html
- Images.jl uses `::Array` in Julia as column-major (i.e. vertical major) convention, that is `size(img) == (480, 640)`
  - Axes start top left-corner of the image plane (i.e. the image-frame):
  - `width` is from left to right,
  - `height` is from top downward.
"""
mutable struct apriltag_detection_info_t
    det::Ptr{apriltag_detection_t}
    tagsize::Cdouble
    fx::Cdouble
    fy::Cdouble
    cx::Cdouble
    cy::Cdouble
end

mutable struct apriltag_pose_t
    R::Ptr{matd_t}
    t::Ptr{matd_t}
    apriltag_pose_t() = new()
end

#special matd_t to help with construction and usage
mutable struct Matd4x4
    nrows::UInt32
    ncols::UInt32
    data::NTuple{16,Cdouble}
    Matd4x4() = new(4,4,NTuple{16,Cdouble}(Matrix{Float64}(undef,4,4)))
    Matd4x4(M::Matrix{Float64}) = new(4,4,NTuple{16,Cdouble}(M'))#TODO test if order is correct
end

mutable struct Matd3x3
    nrows::UInt32
    ncols::UInt32
    data::NTuple{9,Cdouble}
    Matd3x3() = new(3,3,NTuple{9,Cdouble}(Matrix{Float64}(undef,3,3)))
    Matd3x3(M::Matrix{Float64}) = new(3,3,NTuple{9,Cdouble}(M'))#TODO test if order is correct
end

mutable struct Matd3x1
    nrows::UInt32
    ncols::UInt32
    data::NTuple{3,Cdouble}
    Matd3x1() = new(3,1,NTuple{3,Cdouble}(Matrix{Float64}(undef,3,1)))
    Matd3x1(V::Vector{Float64}) = new(3,1,NTuple{3,Cdouble}(V))
end

# void estimate_pose_for_tag_homography(apriltag_detection_info_t* info, apriltag_pose_t* pose);
function estimate_pose_for_tag_homography(info, pose)
    ccall((:estimate_pose_for_tag_homography, libapriltag), Nothing, (Ptr{apriltag_detection_info_t}, Ptr{apriltag_pose_t}), Ref(info), Ref(pose))
end

# double orthogonal_iteration(matd_t** v, matd_t** p, matd_t** t, matd_t** R, int n_points, int n_steps)
function orthogonal_iteration(v::NTuple{4,Matd3x1}, p::NTuple{4,Matd3x1}, t::NTuple{1,Matd3x1}, R::NTuple{1,Matd3x3}, n_points::Int, n_steps::Int)
# function orthogonal_iteration(v, p, t, R, n_points::Int, n_steps::Int)

    vp = Base.unsafe_convert(Ptr{Nothing}, Ref(v))
    pp = Base.unsafe_convert(Ptr{Nothing}, Ref(p))
    tp = Base.unsafe_convert(Ptr{Nothing}, Ref(t))
    Rp = Base.unsafe_convert(Ptr{Nothing}, Ref(R))

    ccall((:orthogonal_iteration, libapriltag), Cdouble,
            (Ptr{Ptr{matd_t}}, Ptr{Ptr{matd_t}}, Ptr{Ptr{matd_t}}, Ptr{Ptr{matd_t}}, Cint, Cint),
            vp, pp, tp, Rp, n_points, n_steps)
end

# matd_t* fix_pose_ambiguities(matd_t** v, matd_t** p, matd_t* t, matd_t* R, int n_points) {
function fix_pose_ambiguities(v::NTuple{4,Matd3x1}, p::NTuple{4,Matd3x1}, t::Matd3x1, R::Matd3x3, n_points::Int)

    vp = Base.unsafe_convert(Ptr{Nothing}, Ref(v))
    pp = Base.unsafe_convert(Ptr{Nothing}, Ref(p))
    tp = Base.unsafe_convert(Ptr{Nothing}, Ref(t))
    Rp = Base.unsafe_convert(Ptr{Nothing}, Ref(R))

    ccall((:fix_pose_ambiguities, libapriltag), Ptr{Matd3x3},
            (Ptr{Ptr{matd_t}}, Ptr{Ptr{matd_t}}, Ptr{matd_t}, Ptr{matd_t}, Cint),
            vp, pp, tp, Rp, n_points)
end
