using Images, ImageView
using Video4Linux
using AprilTags
using FixedPointNumbers
# using BenchmarkTools

function showImage!(image, tags, imageCol)
    # Convert image to RGB
    imageCol[:,:] = RGB{N0f8}.(view(img,:,:), view(img,:,:), view(img,:,:))
    # draw color box on tag corners
    foreach(tag->drawTagBox!(imageCol, tag), tags)
    nothing
end

# This colour mapping may be wrong for the PS3eye.
# ycrcb = Video4Linux.YUYV(640,480)
yonly = Video4Linux.YUYVonlyY(640,480)
vidchan = Channel((c::Channel) -> videoproducer(c, yonly, devicename = "/dev/video1",
                                         iomethod = Video4Linux.IO_METHOD_MMAP, N=0 ))
##
# capture one frame
A = take!(vidchan)
# keep pointers to the same memory
img = normedview(A)  # img = Gray{N0f8}.(im1)
imC = RGB.(view(img,:,:), view(img,:,:), view(img,:,:))
canvas = imshow(imC)

# Create default detector
detector = AprilTagDetector()
# @btime tags = detector(img) # 34.076 ms (25 allocations: 602.20 KiB)

# tags = detector(img)
# showImage!(img, tags, imC)
# imshow(canvas["gui"]["canvas"], imC)

i = 0
while isopen(vidchan)
    i += 1
    A = take!(vidchan)
    img[:,:] = normedview(A)
    if i % 10 == 0
        tags = detector(img)
        @show length(tags)
        showImage!(img, tags, imC)
        imshow(canvas["gui"]["canvas"], imC)
        @show 10.0/t
        t = 0.0
    end
end

close(vidchan)
