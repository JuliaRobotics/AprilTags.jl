using AprilTags
using ImageCore
using FileIO
using ImageMagick
using ImageDraw
using ColorTypes
using FixedPointNumbers
using Test


@testset "AprilTags" begin
    # To test without extra dependancies
    # image = rand(UInt8, 480,640)
    # image[50:79,50:79]     = kron(reinterpret(UInt8,getAprilTagImage(0)), ones(UInt8, 3,3))
    # image[150:179,150:179] = kron(reinterpret(UInt8,getAprilTagImage(1)), ones(UInt8, 3,3))
    # image[250:279,250:279] = kron(reinterpret(UInt8,getAprilTagImage(2)), ones(UInt8, 3,3))
    # image = Gray.(reinterpret(N0f8, image))
    #
    #
    # imageCol = RGB.(image)
    # refpoints = [[63.9, 63.9],
    #             [163.9, 163.9],
    #             [263.9, 263.9]]

    image = load(dirname(Base.source_path()) *"/../data/tagtest.jpg")
    imageCol = load(dirname(Base.source_path()) *"/../data/colortag.jpg")
    refpoints = [[404.5, 176.1],
                 [134.0, 216.1],
                 [412.0, 130.1]]

    @testset "Low-level API" begin
        # test wrappers
        #create april tag detector
        td = apriltag_detector_create()

        #create tag family
        tf = tag36h11_create()

        #add family to detector
        apriltag_detector_add_family(td, tf)

        #create image8 object for april tags
        image8 = convert(AprilTags.image_u8_t, image)

        # run detector on image
        detections = apriltag_detector_detect(td, image8)

        # copy detections
        tags = getTagDetections(detections)

        #extract tag centres
        cpoints = map(tag->[tag.c[2],tag.c[1]],tags)
        @test cpoints ≈ refpoints atol=0.5

        # test convertions
        image8_from_u8 = convert(AprilTags.image_u8_t, reinterpret(UInt8, image)[:,:])
        @test image8_from_u8.width == image8.width
        @test image8_from_u8.height == image8.height
        @test image8_from_u8.stride == image8.stride
        #TODO: maybe add test for content of pointer

        apriltag_detections_destroy(detections)
        # Cleanup: free the detector and tag family when done.
        apriltag_detector_destroy(td)
        tag36h11_destroy(tf)
    end

    @testset "High-level API" begin
        # test the high level convenience functions
        detector = AprilTagDetector()
        tags2 = detector(image)

        @test length(detector(gray.(image))) == 3
        @test length(detector(reinterpret(UInt8,image)[:,:])) == 3

        tagsth = AprilTags.threadcalldetect(detector, image)
        @test length(tagsth) == 3

        #test on random image, should detect zero tags
        @test length(detector(rand(Gray{N0f8},100,100))) == 0

        #setters -- just run for now
        detector.nThreads = 4
        detector.quad_decimate = 1.0
        detector.quad_sigma = 0.0
        detector.refine_edges = 1
        detector.refine_decode = 1
        detector.refine_pose = 1

        #getters -- compare with set values just now
        @test detector.nThreads == 4
        @test detector.quad_decimate == 1.0
        @test detector.quad_sigma == 0.0
        @test detector.refine_edges == 1
        @test detector.refine_decode == 1
        @test detector.refine_pose == 1

        #test @show overload
        @test sprint((t,s)->show(t,"text/plain",s), detector) == "AprilTagDetector\nnThreads: 4\nquad_decimate: 1.0\nquad_sigma: 0.0\nrefine_edges: 1\nrefine_decode: 1\nrefine_pose: 1\n"

        cpoints = map(tag->[tag.c[2],tag.c[1]],tags2)
        freeDetector!(detector)
        @test cpoints ≈ refpoints atol=0.5


        pose = homography_to_pose(tags2[1].H, -520., 520., 320., 240.)
        # TODO create better ref pose
        refpose = [0.65  0.12 -0.75  -5.43;
                   0.39 -0.90  0.19  -6.20;
                  -0.65 -0.41 -0.63 -19.62;
                   0.0   0.0   0.0    1.0]
        @test pose[1:3,1:3] ≈ refpose[1:3,1:3] atol = 0.05
        @test pose[1:3,4] ≈ refpose[1:3,4] atol = 0.1

        #test drawing functions
        fx = 524.040
        fy = 524.040
        cy = 319.254
        cx = 251.227
        K = [fx 0  cx;
              0 fy cy]
        imCol = RGB.(image)
        foreach(tag->drawTagBox!(imCol, tag), tags2)
        # test one pixel to be correctly drawn
        t1xy = round.(Int,tags2[1].p[1])
        @test imCol[t1xy[2],t1xy[1]] == RGB{N0f8}(0.0, 1.0, 0.0)
        #thicker lines also
        foreach(tag->drawTagBox!(imCol,tag, width = 2, drawReticle = false), tags2)
        foreach(tag->drawTagBox!(imCol,tag, width = 3, drawReticle = true), tags2)
        #TODO: verify that drawing is correct

        # test for bounds error in drawing functions with thicker lines
        foreach(tag->drawTagBox!(imCol,tag, width = 1000, drawReticle = true), tags2)

        foreach(tag->drawTagAxes!(imCol,tag, K), tags2)
        #TODO: verify that drawing tag axis is correct

        # test constructors for other families
        detector2 = AprilTagDetector(AprilTags.tag25h9)
        freeDetector!(detector2)

        detector2 = AprilTagDetector(AprilTags.tag16h5)
        freeDetector!(detector2)

        detector2 = AprilTagDetector(AprilTags.tag36h11)
        freeDetector!(detector2)

        detector2 = AprilTagDetector(AprilTags.tag36h10)
        freeDetector!(detector2)

        reftag36h11_0 = Gray{N0f8}[ 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 0.0 1.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0;
                                    1.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0 0.0 1.0;
                                    1.0 0.0 0.0 1.0 1.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 0.0 1.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 0.0 0.0 1.0 0.0 1.0 1.0 0.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
        @test reftag36h11_0 == getAprilTagImage(0)

        reftag36h10_0 = Gray{N0f8}[ 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0;
                                    1.0 0.0 1.0 0.0 0.0 1.0 0.0 0.0 0.0 1.0;
                                    1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 0.0 1.0;
                                    1.0 0.0 0.0 1.0 1.0 0.0 1.0 0.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 1.0 1.0 1.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
        @test reftag36h10_0 == getAprilTagImage(0, AprilTags.tag36h10)

        reftag16h5_0 = Gray{N0f8}[  1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 1.0 0.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 1.0 1.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 1.0 0.0 1.0;
                                    1.0 0.0 1.0 0.0 1.0 1.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
        @test reftag16h5_0 == getAprilTagImage(0, AprilTags.tag16h5)

        reftag25h9_0 = Gray{N0f8}[  1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0;
                                    1.0 0.0 0.0 1.0 0.0 1.0 1.0 0.0 1.0;
                                    1.0 0.0 1.0 0.0 0.0 1.0 0.0 0.0 1.0;
                                    1.0 0.0 1.0 1.0 1.0 1.0 1.0 0.0 1.0;
                                    1.0 0.0 1.0 0.0 0.0 0.0 1.0 0.0 1.0;
                                    1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
                                    1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
        @test reftag25h9_0 == getAprilTagImage(0, AprilTags.tag25h9)

    end

    include("homography.jl")

    @testset "Errors" begin
        #testing freed detectors errors
        detector = AprilTagDetector()
        freeDetector!(detector)
        @test_throws ErrorException tags = detector(image)
        @test_throws ErrorException tags = AprilTags.threadcalldetect(detector, image)
        @test_throws ErrorException AprilTags.setnThreads(detector, 4)
        @test_throws ErrorException AprilTags.setquad_decimate(detector, 1.0)
        @test_throws ErrorException AprilTags.setquad_sigma(detector,0.0)
        @test_throws ErrorException AprilTags.setrefine_edges(detector,1)
        @test_throws ErrorException AprilTags.setrefine_decode(detector,1)
        @test_throws ErrorException AprilTags.setrefine_pose(detector,1)

        @test_throws ErrorException AprilTags.getnThreads(detector)
        @test_throws ErrorException AprilTags.getquad_decimate(detector)
        @test_throws ErrorException AprilTags.getquad_sigma(detector)
        @test_throws ErrorException AprilTags.getrefine_edges(detector)
        @test_throws ErrorException AprilTags.getrefine_decode(detector)
        @test_throws ErrorException AprilTags.getrefine_pose(detector)

        @test freeDetector!(detector) == nothing
        #testing NULL tag families errors
        detector = AprilTagDetector()
        detector.tf = C_NULL
        @test_throws ErrorException tags = detector(image)
        @test_throws ErrorException tags = AprilTags.threadcalldetect(detector, image)
        @test freeDetector!(detector) == nothing
    end

    @testset "Color Image Conversion" begin
        detector = AprilTagDetector()
        tags = detector(imageCol)
        @test length(tags) == 1
        freeDetector!(detector)
    end
end
