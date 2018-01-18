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

const workerpool_t = Void

const va_list = Cint

mutable struct timezone
    tz_minuteswest::Cint
    tz_dsttime::Cint
end


mutable struct _pthread_cleanup_buffer
    __routine::Ptr{Void}
    __arg::Ptr{Void}
    __canceltype::Cint
    __prev::Ptr{_pthread_cleanup_buffer}
end

mutable struct quad
    p::NTuple{4, NTuple{2, Cfloat}}
    H::Ptr{matd_t}
    Hinv::Ptr{matd_t}
end

mutable struct timeprofile
    utime::Int64
    stamps::Ptr{zarray_t}
end

const timeprofile_t = timeprofile

mutable struct apriltag_family
    ncodes::UInt32
    codes::Ptr{UInt64}
    black_border::UInt32
    d::UInt32
    h::UInt32
    name::Cstring
    impl::Ptr{Void}
end

const apriltag_family_t = apriltag_family

mutable struct apriltag_quad_thresh_params
    min_cluster_pixels::Cint
    max_nmaxima::Cint
    critical_rad::Cfloat
    max_line_fit_mse::Cfloat
    min_white_black_diff::Cint
    deglitch::Cint
end

mutable struct apriltag_detector
    nthreads::Cint
    quad_decimate::Cfloat
    quad_sigma::Cfloat
    refine_edges::Cint
    refine_decode::Cint
    refine_pose::Cint
    debug::Cint
    qtp::apriltag_quad_thresh_params
    tp::Ptr{timeprofile_t}
    nedges::UInt32
    nsegments::UInt32
    nquads::UInt32
    tag_families::Ptr{zarray_t}
    wp::Ptr{workerpool_t}
    mutex::pthread_mutex_t

    apriltag_detector() = new()
end

const apriltag_detector_t = apriltag_detector

mutable struct apriltag_detection
    family::Ptr{apriltag_family_t}
    id::Cint
    hamming::Cint
    goodness::Cfloat
    decision_margin::Cfloat
    H::Ptr{matd_t}
    c::NTuple{2, Cdouble}
    p::NTuple{4, NTuple{2, Cdouble}}
    apriltag_detection() = new()
end

const apriltag_detection_t = apriltag_detection


## functions
# AprilTags.zarray_get(detections, Int32(0), Ref(apdet))
# function zarray_get(detections, size, detect)
# assert(za != NULL);
# assert(p != NULL);
# assert(idx >= 0);
# assert(idx < za->size);
#
# memcpy(p, &za->data[idx*za->el_sz], za->el_sz);

# function zarray_get(za::zarray_t, idx::Int, p::apriltag_detection_t)
#     # unsafe_copy!(,  Base.unsafe_convert(Ptr{Void}, Ref(za)), za.el_sz)
#     p = unsafe_load( Base.unsafe_convert(Ptr{AprilTags.apriltag_detection_t}, detzarray.data),  idx)
#
# end


function tag36h11_create()
    ccall((:tag36h11_create, :libapriltag), Ptr{apriltag_family_t}, ())
end


function apriltag_detector_create()
    ccall((:apriltag_detector_create, :libapriltag), Ptr{apriltag_detector_t}, ())
end


function apriltag_detector_add_family_bits(td, fam, bits_corrected::Cint)
    ccall((:apriltag_detector_add_family_bits, :libapriltag), Void, (Ptr{apriltag_detector_t}, Ptr{apriltag_family_t}, Cint), td, fam, bits_corrected)
end

function apriltag_detector_add_family(td, fam)
    # ccall((:apriltag_detector_add_family, :libapriltag), Void, (Ptr{apriltag_detector_t}, Ptr{apriltag_family_t}), td, fam)
    apriltag_detector_add_family_bits(td, fam, Int32(2))
end

function apriltag_detector_remove_family(td, fam)
    ccall((:apriltag_detector_remove_family, :libapriltag), Void, (Ptr{apriltag_detector_t}, Ptr{apriltag_family_t}), td, fam)
end

function apriltag_detector_clear_families(td)
    ccall((:apriltag_detector_clear_families, :libapriltag), Void, (Ptr{apriltag_detector_t},), td)
end

function apriltag_detector_destroy(td)
    ccall((:apriltag_detector_destroy, :libapriltag), Void, (Ptr{apriltag_detector_t},), td)
end

function apriltag_detector_detect(td, im_orig)
    ccall((:apriltag_detector_detect, :libapriltag), Ptr{zarray_t}, (Ptr{apriltag_detector_t}, Ptr{image_u8_t}), td, Ref(im_orig))
end

function apriltag_detection_destroy(det)
    ccall((:apriltag_detection_destroy, :libapriltag), Void, (Ptr{apriltag_detection_t},), det)
end

function apriltag_detections_destroy(detections)
    ccall((:apriltag_detections_destroy, :libapriltag), Void, (Ptr{zarray_t},), detections)
end

function apriltag_to_image(fam, idx::Cint)
    ccall((:apriltag_to_image, :libapriltag), Ptr{image_u8_t}, (Ptr{apriltag_family_t}, Cint), fam, idx)
end
