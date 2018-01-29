using AprilTags
using Images
using Base.Test


@testset "AprilTags" begin
    image = load(dirname(Base.source_path()) *"/../data/tagtest.jpg")
    refpoints = [[404.5, 176.1],
                [134.0, 216.1],
                [412.0, 130.1]]

    # test wrappers
    #create april tag detector
    td = apriltag_detector_create()

    #create tag family
    tf = tag36h11_create()

    #add family to detector
    apriltag_detector_add_family(td, tf)

    #create image8 opject for april tags
    image8 = convert2image_u8(image)

    # run detector on image
    detections =  apriltag_detector_detect(td, image8)

    # copy detections
    tags = getTagDetections(detections)

    #extract tag centres
    cpoints = map(tag->[tag.c[2],tag.c[1]],tags)

    @test cpoints ≈ refpoints atol=0.5

    apriltag_detections_destroy(detections)
    # Cleanup: free the detector and tag family when done.
    apriltag_detector_destroy(td)
    tag36h11_destroy(tf)

    #
    detector = AprilTagDetector()
    tags2 = detector(image)
    cpoints = map(tag->[tag.c[2],tag.c[1]],tags2)
    freeDetector!(detector)
    @test cpoints ≈ refpoints atol=0.5

end
