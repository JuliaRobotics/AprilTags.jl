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

    #setters -- just run for now
    AprilTags.setnThreads(detector, 4)
    AprilTags.setquad_decimate(detector, 1.0)
    AprilTags.setquad_sigma(detector,0.0)
    AprilTags.setrefine_edges(detector,1)
    AprilTags.setrefine_decode(detector,1)
    AprilTags.setrefine_pose(detector,1)

    cpoints = map(tag->[tag.c[2],tag.c[1]],tags2)
    freeDetector!(detector)
    @test cpoints ≈ refpoints atol=0.5


    pose = homography_to_pose(tags2[1].H, -520., 520., 320., 240.)
    # TODO create ref pose
    # @test pose ≈ refpose atol=0.1

end
