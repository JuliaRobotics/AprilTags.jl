

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
