var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#AprilTags-1",
    "page": "Home",
    "title": "AprilTags",
    "category": "section",
    "text": "(Image: Build Status)(Image: codecov.io)This package is a ccall wrapper for the AprilTags library tailored for Julia."
},

{
    "location": "#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "AprilTags.jl can be installed in Julia 0.7 and Julia 1.0 with:#enter \']\' to get the package manager and then type:\n(v1.0) pkg> add AprilTags\n# or\nusing Pkg\nPkg.add(\"AprilTags\")Note that Julia 0.6 is no longer supprted going forward. Please use v0.0.2 for julia 0.6.  "
},

{
    "location": "#Usage-1",
    "page": "Home",
    "title": "Usage",
    "category": "section",
    "text": ""
},

{
    "location": "#Examples-1",
    "page": "Home",
    "title": "Examples",
    "category": "section",
    "text": "See examples and test folder for basic AprilTag usage examples."
},

{
    "location": "#Initialization-1",
    "page": "Home",
    "title": "Initialization",
    "category": "section",
    "text": "Initialize a detector with the default (tag36h11) tag family.# Create default detector\ndetector = AprilTagDetector()The tag detector parameters can be set as shown bellow. The default parameters are the recommended starting point.detector.nThreads = 4 #number of threads to use\ndetector.quad_decimate =  1.0 #\"Decimate input image by this factor\"\ndetector.quad_sigma = 0.0 #\"Apply low-pass blur to input; negative sharpens\"\ndetector.refine_edges = 1 #\"Set to 1 to spend more time to align edges of tags\"\ndetector.decode_sharpening = 0.25"
},

{
    "location": "#quad_decimate-1",
    "page": "Home",
    "title": "quad_decimate",
    "category": "section",
    "text": "Detection of quads can be done on a lower-resolution image, improving speed at a cost of pose accuracy and a slight decrease in detection rate. Decoding the binary payload is still done at full resolution.   Increase the image decimation if faster processing is required. A factor of 1.0 means the full-size input image is used."
},

{
    "location": "#quad_sigma-1",
    "page": "Home",
    "title": "quad_sigma",
    "category": "section",
    "text": "What Gaussian blur should be applied to the segmented image (used for quad detection?).   Parameter is the standard deviation in pixels. Very noisy images benefit from non-zero values (e.g. 0.8)."
},

{
    "location": "#refine_edges-1",
    "page": "Home",
    "title": "refine_edges",
    "category": "section",
    "text": "When non-zero, the edges of the each quad are adjusted to \"snap to\" strong gradients nearby. This is useful when decimation is employed, as it can increase the quality of the initial quad estimate substantially. Generally recommended to be on (1). Very computationally inexpensive. Option is ignored if quad_decimate = 1."
},

{
    "location": "#decode_sharpening-1",
    "page": "Home",
    "title": "decode_sharpening",
    "category": "section",
    "text": "How much sharpening should be done to decoded images? This can help decode small tags but may or may not help in odd lighting conditions or low light conditions. The default value is 0.25."
},

{
    "location": "#Detection-1",
    "page": "Home",
    "title": "Detection",
    "category": "section",
    "text": "Process an input image and return a vector of detections. The input image can be loaded with the Images package.image = load(\"example_image.jpg\")\ntags = detector(image)\n#do something with tags hereThe caller is responsible for freeing the memmory by callingfreeDetector!(detector)"
},

{
    "location": "#Creating-the-AprilTag-Images-1",
    "page": "Home",
    "title": "Creating the AprilTag Images",
    "category": "section",
    "text": "The AprilTag images can be created using the getAprilTagImage function.   Eg. to create a tag image with id 1 from family \'tag36h11\' run:getAprilTagImage(1, AprilTags.tag36h11)"
},

{
    "location": "#Visualizing-Tags-1",
    "page": "Home",
    "title": "Visualizing Tags",
    "category": "section",
    "text": "Images can be updated to include the tag detections,drawTagBox!(image, tag)Or if the camera matrix K is known, the axes can be shown withdrawTagAxes!(image, tag, K)Furthermore, the tag IDs can also be visualized by first loading a different package:using FreeTypeAbstraction\nusing AprilTags\nusing ImageView\n\n# get an image\nimg_ = drawTags(image, K)\nimshow(img_)\n\n# drawTags!(image, K, tags)"
},

{
    "location": "#Example-from-Tests-1",
    "page": "Home",
    "title": "Example from Tests",
    "category": "section",
    "text": "# see data/tagtest.jpg\n\ndetector = AprilTagDetector()\nfx = 524.040\nfy = 524.040\ncx = 251.227\ncy = 319.254\ntaglength = 0.172\n(tags, poses) = detectAndPose(detector, image, fx, fy, cx, cy, taglength)\n# TODO test here\n@test all(isapprox.(poses[1], [ 0.657276  -0.43653   0.614354  -0.236778;\n                                0.180276   0.882573  0.434242   0.268374;\n                               -0.731771  -0.174663  0.65879    1.65107],\n                              atol = 0.01))\nfreeDetector!(detector)"
},

{
    "location": "#Manual-Outline-1",
    "page": "Home",
    "title": "Manual Outline",
    "category": "section",
    "text": "Pages = [\n    \"index.md\"\n    \"func_ref.md\"\n]"
},

{
    "location": "func_ref/#",
    "page": "Functions",
    "title": "Functions",
    "category": "page",
    "text": ""
},

{
    "location": "func_ref/#Function-Reference-1",
    "page": "Functions",
    "title": "Function Reference",
    "category": "section",
    "text": "Pages = [\n    \"func_ref.md\"\n]\nDepth = 3"
},

{
    "location": "func_ref/#AprilTags.AprilTagDetector",
    "page": "Functions",
    "title": "AprilTags.AprilTagDetector",
    "category": "type",
    "text": "AprilTagDetector(tagfamily=tag36h11)\n\nCreate a default AprilTag detector with the 36h11 tag family Create an AprilTag detector with tag family in tagfamily::TagFamilies @enum TagFamilies tag36h11 tag25h9 tag16h5\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.freeDetector!",
    "page": "Functions",
    "title": "AprilTags.freeDetector!",
    "category": "function",
    "text": "freeDetector!(apriltagdetector)\n\nFree the allocated memmory\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.homography_to_pose",
    "page": "Functions",
    "title": "AprilTags.homography_to_pose",
    "category": "function",
    "text": "homography_to_pose(H, fx, fy, cx, cy, [taglength = 2.0])\n\nGiven a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag. The focal lengths should be given in pixels. The returned units are those of the tag size, therefore the translational components should be scaled with the tag size. Note: the tag coordinates are from (-1,-1) to (1,1), i.e. the tag size has lenght of 2 units. Optionally, the tag length (in metre) can be passed to return a scaled value.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.homographytopose",
    "page": "Functions",
    "title": "AprilTags.homographytopose",
    "category": "function",
    "text": "homographytopose(H, fx, fy, cx, cy, [taglength = 2.0])\n\nGiven a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag. The focal lengths should be given in pixels. The returned units are those of the tag size, therefore the translational components should be scaled with the tag size. Note: the tag coordinates are from (-1,-1) to (1,1), i.e. the tag size has length of 2 units. Optionally, the tag length (in metre) can be passed to return a scaled value. The camara coordinate system: camera looking in positive Z axis with x to the right and y down.\n\nNotes\n\nImages.jl uses the Julia column major (i.e. vertical major) convention, that is size(img) == (480, 640)\nThis is opposite from the ccall wrapped AprilTags library underneath – see example below.\nReturns ::Matrix{Float64}\n\nExample\n\n[cx, cy] == [640, 480] ./ 2 == [320, 240]\n# similarly for this function call `fx,fy` follows the same as `cx,cy`, but this is different from Images.jl convention.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.drawTagBox!",
    "page": "Functions",
    "title": "AprilTags.drawTagBox!",
    "category": "function",
    "text": "drawTagBox!(image, tag)\n\nDraw a box around the tag. imageCol = RGB.(image) foreach(tag->drawTagBox!(imageCol, tag), tags)\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.drawTagAxes!",
    "page": "Functions",
    "title": "AprilTags.drawTagAxes!",
    "category": "function",
    "text": "drawTagAxes!(image, tag, CameraMatrix)\n\nDraw the tag x, y, and z axes to show the orientation. imageCol = RGB.(image) foreach(tag->drawTagAxes!(imageCol, tag, K), tags)\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.getAprilTagImage",
    "page": "Functions",
    "title": "AprilTags.getAprilTagImage",
    "category": "function",
    "text": "getAprilTagImage(tagIndex, tagfamily=tag36h11)\n\nReturn an image [Gray{N0f8}] for with tagIndex from tag family in tagfamily::TagFamilies @enum TagFamilies tag36h11 tag25h9 tag16h5\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.threadcalldetect",
    "page": "Functions",
    "title": "AprilTags.threadcalldetect",
    "category": "function",
    "text": "threadcalldetect(detector, image)\n\nRun the april tag detector on a image\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.detectAndPose",
    "page": "Functions",
    "title": "AprilTags.detectAndPose",
    "category": "function",
    "text": "detectAndPose(detector, image, fx, fy, cx, cy, taglength)\n\nDetect tags and calcuate the pose on them.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.tagOrthogonalIteration",
    "page": "Functions",
    "title": "AprilTags.tagOrthogonalIteration",
    "category": "function",
    "text": "tagOrthogonalIteration\n\nRun the orthoganal iteration algorithm on the poses. See apriltag_pose.h [2]: Lu, G. D. Hager and E. Mjolsness, \"Fast and globally convergent pose estimation from video images,\" in IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 22, no. 6, pp. 610-622, June 2000. doi: 10.1109/34.862199\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.jl-functions-1",
    "page": "Functions",
    "title": "AprilTags.jl functions",
    "category": "section",
    "text": "AprilTags.AprilTagDetector\nAprilTags.freeDetector!\nhomography_to_pose\nhomographytopose\ndrawTagBox!\ndrawTagAxes!\ngetAprilTagImage\nthreadcalldetect\ndetectAndPose\ntagOrthogonalIteration"
},

{
    "location": "func_ref/#AprilTags.apriltag_detector_create",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_create",
    "category": "function",
    "text": "apriltag_detector_create()\n\nCreate a AprilTag Detector object with all fields set to default value.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.tag36h11_create",
    "page": "Functions",
    "title": "AprilTags.tag36h11_create",
    "category": "function",
    "text": "tag36h11_create()\n\nCreate a AprilTag family object for tag36h11 with all fields set to default value.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.tag36h11_destroy",
    "page": "Functions",
    "title": "AprilTags.tag36h11_destroy",
    "category": "function",
    "text": "tag36h11_destroy(tf)\n\nDestroy the AprilTag family object.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.apriltag_detector_add_family",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_add_family",
    "category": "function",
    "text": "apriltag_detector_add_family(tag_detector, tag_family)\n\nAdd a tag family to an AprilTag Detector object. The caller still \"owns\" the family and a single instance should only be provided to one apriltag detector instance.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.apriltag_detector_detect",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_detect",
    "category": "function",
    "text": "apriltag_detector_detect(tag_detector, image)\n\nDetect tags from an image and return an array of apriltagdetectiont*. You can use apriltagdetectionsdestroy to free the array and the detections it contains, or call detectiondestroy and zarraydestroy yourself.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.threadcall_apriltag_detector_detect",
    "page": "Functions",
    "title": "AprilTags.threadcall_apriltag_detector_detect",
    "category": "function",
    "text": "threadcall_apriltag_detector_detect(tag_detector, image)\n\nExperimental call apriltagdetectordetect in a seperate thread using the experimantal @threadcall Detect tags from an image and return an array of apriltagdetectiont*. You can use apriltagdetectionsdestroy to free the array and the detections it contains, or call detectiondestroy and zarraydestroy yourself.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#Wrappers-1",
    "page": "Functions",
    "title": "Wrappers",
    "category": "section",
    "text": "apriltag_detector_create\ntag36h11_create\ntag36h11_destroy\napriltag_detector_add_family\napriltag_detector_detect\nthreadcall_apriltag_detector_detect"
},

{
    "location": "func_ref/#Index-1",
    "page": "Functions",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
