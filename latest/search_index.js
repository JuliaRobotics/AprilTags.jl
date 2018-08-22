var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#AprilTags-1",
    "page": "Home",
    "title": "AprilTags",
    "category": "section",
    "text": "(Image: Build Status)(Image: codecov.io)This package is a ccall wrapper for the AprilTags library tailored for Julia."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "AprilTags.jl can be installed in Julia 0.7 and Julia 1.0 with:#enter \']\' to get the package manager and then type:\n(v0.7) pkg> add AprilTags\n# or\nusing Pkg\nPkg.add(\"AprilTags\")Note that Julia 0.6 is no longer supprted going forward. Please use v0.0.2 for julia 0.6.  "
},

{
    "location": "index.html#Usage-1",
    "page": "Home",
    "title": "Usage",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Examples-1",
    "page": "Home",
    "title": "Examples",
    "category": "section",
    "text": "See examples and test folder for basic AprilTag usage examples."
},

{
    "location": "index.html#Initialization-1",
    "page": "Home",
    "title": "Initialization",
    "category": "section",
    "text": "Initialize a detector with the default (tag36h11) tag family.# Create default detector\ndetector = AprilTagDetector()Some tag detector parameters can be set at this time. The default parameters are the recommended starting point.AprilTags.setnThreads(detector, 4)\nAprilTags.setquad_decimate(detector, 1.0)\nAprilTags.setquad_sigma(detector,0.0)\nAprilTags.setrefine_edges(detector,1)\nAprilTags.setrefine_decode(detector,0)\nAprilTags.setrefine_pose(detector,0)Increase the image decimation if faster processing is required; the trade-off is a slight decrease in detection range. A factor of 1.0 means the full-size input image is used.Some Gaussian blur (quad_sigma) may help with noisy input images."
},

{
    "location": "index.html#Detection-1",
    "page": "Home",
    "title": "Detection",
    "category": "section",
    "text": "Process an input image and return a vector of detections. The input image can be loaded with the Images package.image = load(\"example_image.jpg\")\ntags = detector(image)\n#do something with tags hereThe caller is responsible for freeing the memmory by callingfreeDetector!(detector)"
},

{
    "location": "index.html#Manual-Outline-1",
    "page": "Home",
    "title": "Manual Outline",
    "category": "section",
    "text": "Pages = [\n    \"index.md\"\n    \"func_ref.md\"\n]"
},

{
    "location": "func_ref.html#",
    "page": "Functions",
    "title": "Functions",
    "category": "page",
    "text": ""
},

{
    "location": "func_ref.html#Function-Reference-1",
    "page": "Functions",
    "title": "Function Reference",
    "category": "section",
    "text": "Pages = [\n    \"func_ref.md\"\n]\nDepth = 3"
},

{
    "location": "func_ref.html#AprilTags.AprilTagDetector",
    "page": "Functions",
    "title": "AprilTags.AprilTagDetector",
    "category": "type",
    "text": "AprilTagDetector(tagfamily=tag36h11)\n\nCreate a default AprilTag detector with the 36h11 tag family Create an AprilTag detector with tag family in tagfamily::TagFamilies @enum TagFamilies tag36h11 tag36h10 tag25h9 tag16h5\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.freeDetector!",
    "page": "Functions",
    "title": "AprilTags.freeDetector!",
    "category": "function",
    "text": "freeDetector!(apriltagdetector)\n\nFree the allocated memmory\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.homography_to_pose",
    "page": "Functions",
    "title": "AprilTags.homography_to_pose",
    "category": "function",
    "text": "homography_to_pose(H, fx, fy, cx, cy)\n\nGiven a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag. The focal lengths should be given in pixels\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.drawTagBox!",
    "page": "Functions",
    "title": "AprilTags.drawTagBox!",
    "category": "function",
    "text": "drawTagBox!(image, tag)\n\nDraw a box around the tag. imageCol = RGB.(image) foreach(tag->drawTagBox!(imageCol, tag), tags)\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.drawTagAxes!",
    "page": "Functions",
    "title": "AprilTags.drawTagAxes!",
    "category": "function",
    "text": "drawTagAxes!(image, tag, CameraMatrix)\n\nDraw the tag x, y, and z axes to show the orientation. imageCol = RGB.(image) foreach(tag->drawTagAxes!(imageCol, tag, K), tags)\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.jl-functions-1",
    "page": "Functions",
    "title": "AprilTags.jl functions",
    "category": "section",
    "text": "AprilTags.AprilTagDetector\nAprilTags.freeDetector!\nhomography_to_pose\ndrawTagBox!\ndrawTagAxes!"
},

{
    "location": "func_ref.html#AprilTags.apriltag_detector_create",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_create",
    "category": "function",
    "text": "apriltag_detector_create()\n\nCreate a AprilTag Detector object with all fields set to default value.\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.tag36h11_create",
    "page": "Functions",
    "title": "AprilTags.tag36h11_create",
    "category": "function",
    "text": "tag36h11_create()\n\nCreate a AprilTag family object for tag36h11 with all fields set to default value.\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.tag36h11_destroy",
    "page": "Functions",
    "title": "AprilTags.tag36h11_destroy",
    "category": "function",
    "text": "tag36h11_destroy(tf)\n\nDestroy the AprilTag family object.\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.apriltag_detector_add_family",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_add_family",
    "category": "function",
    "text": "apriltag_detector_add_family(tag_detector, tag_family)\n\nAdd a tag family to an AprilTag Detector object. The caller still \"owns\" the family and a single instance should only be provided to one apriltag detector instance.\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.apriltag_detector_detect",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_detect",
    "category": "function",
    "text": "apriltag_detector_detect(tag_detector, image)\n\nDetect tags from an image and return an array of apriltagdetectiont*. You can use apriltagdetectionsdestroy to free the array and the detections it contains, or call detectiondestroy and zarraydestroy yourself.\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.getAprilTagImage",
    "page": "Functions",
    "title": "AprilTags.getAprilTagImage",
    "category": "function",
    "text": "getAprilTagImage(tagIndex, tagfamily=tag36h11)\n\nReturn an image [Gray{N0f8}] for with tagIndex from tag family in tagfamily::TagFamilies @enum TagFamilies tag36h11 tag36h10 tag25h9 tag16h5\n\n\n\n\n\n"
},

{
    "location": "func_ref.html#Wrappers-1",
    "page": "Functions",
    "title": "Wrappers",
    "category": "section",
    "text": "apriltag_detector_create\ntag36h11_create\ntag36h11_destroy\napriltag_detector_add_family\napriltag_detector_detect\ngetAprilTagImage"
},

{
    "location": "func_ref.html#Index-1",
    "page": "Functions",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
