using Images, ImageView
using AprilTags
using FixedPointNumbers
# Package Video4Linux is currently unregistered, and should be installed with:
# Pkg.clone("https://github.com/Affie/Video4Linux.jl.git")
# Pkg.build("Video4Linux")
using Video4Linux

function showImage!(image, tags, imageCol)
    # Convert image to RGB
    imageCol[:,:] = RGB{N0f8}.(view(img,:,:), view(img,:,:), view(img,:,:))
    # draw color box on tag corners
    foreach(tag->drawTagBox!(imageCol, tag, width=3, drawReticle=false), tags)
    nothing
end

#Use this colour mapping when using the PS3eye.
#NOTE on Video4Linux:
#No automatic video device setup is currently performed by Video4Linux
#There are utilities to make this easy eg: qv4l2 (install with: sudo apt-get install qv4l2)
#qv4l2 provides a gui of the ioctl of the device.
#Settings such as frame size and capture format can easily be changed.
yonly = Video4Linux.YUYVonlyY(640,480)
#create a video channel that produces image frames
vidchan = Channel((c::Channel) -> videoproducer(c, yonly, devicename = "/dev/video1",
                                         iomethod = Video4Linux.IO_METHOD_MMAP, N=0 ))
##
# capture one frame
A = take!(vidchan)
# keep pointers to the same memory, preallocate variables
img = normedview(A)
imC = RGB.(view(img,:,:), view(img,:,:), view(img,:,:))
#create a new canvas for displaying the image
canvas = imshow(imC)

# Create default detector
detector = AprilTagDetector()
# settings that influence detector speed/quality
# see april tag documentation for more information on these settings
AprilTags.setnThreads(detector, 4)
AprilTags.setquad_decimate(detector, 1.0)
AprilTags.setquad_sigma(detector,0.0)
AprilTags.setrefine_edges(detector,0)
AprilTags.setrefine_decode(detector,0)
AprilTags.setrefine_pose(detector,0)

# start asyncronious task to read video channel, detect tags and display detections
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

## to finish and close the video device
stopVideoProducer()
