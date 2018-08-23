using Images
#Additional required packages to run this example.
#Pkg.add("Images")

using AprilTags
using Dates

# Simple method to show the image with the tags
function showImage(image, tags)
    # Convert image to RGB
    imageCol = RGB.(image)
    #traw color box on tag corners
    foreach(tag->drawTagBox!(imageCol, tag), tags)
    imageCol
end


##
# Create default detector
detector = AprilTagDetector()

#Run against a file
image = load(dirname(Base.source_path()) *"/../data/tagtest.jpg")

@sync begin
    starttime = Dates.value(now())
    #call detector in thread
    @async global t1 = @timed begin
        println("time before detector $(Dates.value(now())-starttime) ms")
        global tags = threadcalldetect(detector, image)
        # ↑ comment --- compare with this --- uncomment ↓
        # global tags = detector(image)
        println("time after detector $(Dates.value(now())-starttime) ms")

        @show length(tags)
    end
    #carry on doing something else
    @async global t2 = @timed begin
        println("time starting other $(Dates.value(now())-starttime) ms")
        imageCol = load(dirname(Base.source_path()) *"/../data/colortag.jpg")
        A = randn(2000,2000)
        randsum = sum(A*A')
        println("time finished other $(Dates.value(now())-starttime) ms")
        @show randsum
    end
end

    println("time for detector: $(t1[2]) seconds")
    println("time for other: $(t2[2]) seconds")
    println()

showImage(image, tags)



## clean up detector once finished
freeDetector!(detector)
