using Images, ImageView
using Video4Linux
using AprilTags
using FixedPointNumbers
# using BenchmarkTools

function showImage!(image, tags, imageCol)
    # Convert image to RGB
    imageCol[:,:] = RGB{N0f8}.(view(img,:,:), view(img,:,:), view(img,:,:))
    # draw color box on tag corners
    foreach(tag->drawTagBox!(imageCol, tag, width=3, drawReticle=false), tags)
    nothing
end

#Use this colour mapping for the PS3eye.
# ycrcb = Video4Linux.YUYV(640,480)
yonly = Video4Linux.YUYVonlyY(640,480)
vidchan = Channel((c::Channel) -> videoproducer(c, yonly, devicename = "/dev/video1",
                                         iomethod = Video4Linux.IO_METHOD_MMAP, N=0 ))
##
# capture one frame
A = take!(vidchan)
# keep pointers to the same memory
img = normedview(A)  # img = Gray{N0f8}.(im1)
@time imC = RGB.(view(img,:,:), view(img,:,:), view(img,:,:))
@time imCV = colorview(RGB,img,img,img)
canvas = imshow(imC)

# Create default detector
detector = AprilTagDetector()
# settings that influence detector speed/quality
AprilTags.setnThreads(detector, 4)
AprilTags.setquad_decimate(detector, 1.0)
AprilTags.setquad_sigma(detector,0.0)
AprilTags.setrefine_edges(detector,0)
AprilTags.setrefine_decode(detector,0)
AprilTags.setrefine_pose(detector,0)
# @btime tags = detector(img) # 34.076 ms (25 allocations: 602.20 KiB)

# tags = detector(img)
# showImage!(img, tags, imC)
# imshow(canvas["gui"]["canvas"], imC)

@async begin
    i = 0
    starttime = Dates.value(now())
    while isopen(vidchan)
        i += 1
        A = take!(vidchan)
        img[:,:] = normedview(A)

        tags = detector(img)
        showImage!(img, tags, imC)
        ImageView.imshow!(canvas["gui"]["canvas"], imC, canvas["annotations"])

        if i % 10 == 0
            @show length(tags)
            framerate = round(10/(Dates.value(now())-starttime)*1000,1)
            println("frames $(framerate) per second")
            starttime = Dates.value(now())
        end
    end
end
##
stopVideoProducer()
