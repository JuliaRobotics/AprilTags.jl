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
    "text": "(Image: Build Status)(Image: codecov.io)This package is a ccall wrapper for the AprilTags library."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "This package is not yet registered with JuliaLang/METADATA.jl, but can be easily installed in Julia 0.6 with:Pkg.clone(\"https://github.com/Affie/AprilTags.jl.git\")\nPkg.build(\"AprilTags\")See examples and test folder for usage."
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
    "category": "Type",
    "text": "AprilTagDetector()\n\nCreate a default AprilTag detector with tha 36h11 tag family\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.freeDetector!",
    "page": "Functions",
    "title": "AprilTags.freeDetector!",
    "category": "Function",
    "text": "freeDetector!(apriltagdetector)\n\nFree the allocated memmory\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.jl-functions-1",
    "page": "Functions",
    "title": "AprilTags.jl functions",
    "category": "section",
    "text": "AprilTags.AprilTagDetector\nAprilTags.freeDetector!"
},

{
    "location": "func_ref.html#AprilTags.apriltag_detector_create",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_create",
    "category": "Function",
    "text": "apriltag_detector_create()\n\nCreate a AprilTag Detector object with all fields set to default value.\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.tag36h11_create",
    "page": "Functions",
    "title": "AprilTags.tag36h11_create",
    "category": "Function",
    "text": "tag36h11_create()\n\nCreate a AprilTag family object for tag36h11 with all fields set to default value.\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.tag36h11_destroy",
    "page": "Functions",
    "title": "AprilTags.tag36h11_destroy",
    "category": "Function",
    "text": "tag36h11_destroy(tf)\n\nDestroy the AprilTag family object.\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.apriltag_detector_add_family",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_add_family",
    "category": "Function",
    "text": "apriltag_detector_add_family(tag_detector, tag_family)\n\nAdd a tag family to an AprilTag Detector object. The caller still \"owns\" the family and a single instance should only be provided to one apriltag detector instance.\n\n\n\n"
},

{
    "location": "func_ref.html#AprilTags.apriltag_detector_detect",
    "page": "Functions",
    "title": "AprilTags.apriltag_detector_detect",
    "category": "Function",
    "text": "apriltag_detector_detect(tag_detector, image)\n\nDetect tags from an image and return an array of apriltag_detection_t*. You can use apriltag_detections_destroy to free the array and the detections it contains, or call detection_destroy and zarray_destroy yourself.\n\n\n\n"
},

{
    "location": "func_ref.html#Wrappers-1",
    "page": "Functions",
    "title": "Wrappers",
    "category": "section",
    "text": "apriltag_detector_create\ntag36h11_create\ntag36h11_destroy\napriltag_detector_add_family\napriltag_detector_detect"
},

{
    "location": "func_ref.html#Index-1",
    "page": "Functions",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
