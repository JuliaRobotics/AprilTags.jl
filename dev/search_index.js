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
    "location": "#Example-1",
    "page": "Home",
    "title": "Example",
    "category": "section",
    "text": "An easy (synthetic) verification example to test:using AprilTags\nusing Images\n\ndetector = AprilTagDetector()\n\nprojImg = zeros(Gray{N0f8}, 480,640)\ntag0 = kron(getAprilTagImage(0), ones(Gray{N0f8}, 4,4))\nprojImg[221:260,301:340] = tag0\nprojImg\n\n# `img[i,j]` implies `width == x == j`, and `height == y == i`, top left corner `(0,0)`\nfx = 1000.\nfy = 1000.\ncx = 320.\ncy = 240.\n\nK = [fx 0  cx;\n      0 fy cy]\n\ntags = detector(projImg)\n\nimCol = RGB.(projImg)\nforeach(tag->drawTagBox!(imCol, tag), tags)\n\ntaglength = 0.1\n(tags, poses) = detectAndPose(detector, projImg, fx, fy, cx, cy, taglength)\n\nposes[1]results3×4 Array{Float64,2}:\n  0.996868    0.00273632   0.079042   -0.000300523\n  0.00256118  0.99776     -0.0668423  -0.000417185\n -0.0790478   0.0668353    0.994628    3.1166[copied from an issue discussion]"
},

{
    "location": "#AprilTags.calcCalibResidualAprilTags!",
    "page": "Home",
    "title": "AprilTags.calcCalibResidualAprilTags!",
    "category": "function",
    "text": "calcCalibResidualAprilTags!(images, allTags; tagList, taglength, VERT, HORI, f_width, f_height, c_width, c_height, s, boardPattern, dodraw)\n\n\nGrid of AprilTags calibration helper function.  This function sets up a squared cost to be minimized  by any method, including Optim.opimize.  The cost function is constructed by assuming a grid of 40 AprilTags are of equal size and on a common co-planar surface like a computer screen.  \n\nThe cost function is constructed by predicting from each tag detection individually where the corners of all  other 39 tags should be on the co-planar surface.  The discrepanc_height between the predicted and detected tag  positions are square accumulated. \n\nNotes\n\nAssume regular spacing grid of 40 AprilTags 36h11, ids=1:40,\ndown 1:5 by 8 columns 1:5:40 across where taglength and spacing gap are equal.\nSee grid file at AprilTags/data/CameraCalibration/AprilTagGrid1to40.png\nCurrent implementation requires all 40 tags to be visible and detected\nContributions welcome to allow a few missed detections.\nTake pictures of the grid with the camera you want to calibrate, making sure all tags are clearly visible.\nCombinations of the grid nearer and further, centered and slanted around the edges of the field of view are best.\nAny number of images can be used, the more the better.  \nNote that half a doen high-res images might take up to 20 mins or so to optimize.\nJulia Images.jl follows the common `::Array column-major–-i.e. vertical-major–-index convention\nThat is img[vertical, horizontal]\nSee https://evizero.github.io/Augmentor.jl/images/#Vertical-Major-vs-Horizontal-Major-1\nThis function has the ability to draw the predicted tag corners, see keyword dodraw=true.\nThis is not a copy of any other AprilCal or such software, this was newly written code out of pure frustration when getting stuff to work.  The more native Julia code the better, because Julia is much more mobile and versatile than any of the other calibration software out there.  See DevNotes below for roadmap of features to add,  contributions welcome.\n\nExample\n\nAlso see AprilTags/examples/AprilTagsGridClibration.jl.\n\nThis example shows how a series of photos of the tag grid image (just use your computer screen, not a projector)  can be used to calibrate a camera.  This example only shows the basic pinhole parameters, although more are possible,  see keyword arguments for which calibration parameters are available.  The latter part shows how to draw crosses to see before and after result.  \n\nusing AprilTags\nusing FileIO\n\n# where are the photos of the calibration files\nfilepaths = [photo1.jpg; photo2.jpg;...]\n# load the images into memory\nimgs = load.(filepaths)\n\n# It\'s imporant that you measure and specif_height the tag length correctly here\n# 30 mm is just a guess, insert your own correct tag measurements here.\ntaglength = 0.03\n\n# rough guess of what calibration parameters might be\n# x,y <==> rows,colums\nc_width = size(imgs[1],2) / 2 # columns across in Images.jl\nc_height = size(imgs[1],1) / 2 # rows down in Images.jl\nf_width = size(imgs[1],1)\nf_height=f_width\n\n#  detect the tags and duplicate the memory before freeing the detector\ndetector = AprilTagDetector()\ntags = detector.(imgs) .|> deepcopy\n# remember to free detector later\n\n# setup the cost function, you can add more parameters here if you like\nobj = (f_width, f_height, c_width, c_height) -> calcCalibResidualAprilTags!( imgs, tags, taglength=taglength, f_width=f_width, f_height=f_height, c_width=c_width, c_height=c_height, dodraw=false )\nobj_ = (fc_wh) -> obj(fc_wh...)\n\n# check that it works\nobj_([f_width, f_height, c_width, c_height])\n\n## Bring in the Optim.jl optimization routines\nusing Optim\n\n# Run the optimization. BFGS is slower by more precise, it\'s okay to mix and match as coarse and fine optimization stages\nresult = optimize(obj_, [f_width; f_height; c_width; c_height], BFGS(), Optim.Options(x_tol=1e-8))\n\n# see the optimized calibration parameters\n@show f_width_, f_height_, c_width_, c_height_ = (result.minimizer...,)\n\n## show the before and after images to visually confirm things are working\nusing ImageView\n\n# bad calibration\nimg1_before = deepcopy(imgs[1])\ncalcCornerProjectionsAprilTags!(img1_before, taglength=taglength, f_width=f_width, f_height=f_height, c_width=c_width, c_height=c_height, dodraw=true)\nimshow(img1_before)\n\n# new calibration\nimg1_after = deepcopy(imgs[1])\ncalcCornerProjectionsAprilTags!(img1_after, taglength=taglength, f_width=f_width_, f_height=f_height_, c_width=c_width_, c_height=c_height_, dodraw=true)\nimshow(img1_after)\n\n# free the detector memory\nfreeDetector!(detector) # could also use a deepcopy to duplicate the memory to a secondary location and free the primary immediately\n\nDevNotes\n\nFIXME common JuliaRobotics/CameraModels.jl package shoudl be made\nTODO Radial distortion parameters should be added, see https://en.wikipedia.org/wiki/Distortion_(optics)\nTODO allow missed detections on grid of 40 tags\nTODO auto-detect the grid so that any grid can be used (still assuming regular spacing)\n\nRelated\n\ncalcCornerProjectionsAprilTags!\n\n\n\n\n\n"
},

{
    "location": "#AprilTags.calcCornerProjectionsAprilTags!",
    "page": "Home",
    "title": "AprilTags.calcCornerProjectionsAprilTags!",
    "category": "function",
    "text": "calcCornerProjectionsAprilTags!(cimg_, tags_; tagList, taglength, f_width, f_height, c_width, c_height, s, VERT, HORI, boardPattern, dodraw)\n\n\nApril grid calibration helper function to assemble the cost for a single image. This function can also be used to draw the corner points on images  to show how the cost function is constructed as well as the calibration performance. See calcCalibResidualAprilTags! for details.\n\n\n\n\n\n"
},

{
    "location": "#Camera-Calibration-1",
    "page": "Home",
    "title": "Camera Calibration",
    "category": "section",
    "text": "Using a AprilTag grid, it is possible to take a series of photographs for estimating the camera intrinsic calibration parameters:<p align=\"center\">\n<img src=\"https://user-images.githubusercontent.com/6412556/101559167-930a5800-398e-11eb-934d-e880c014c873.png\" width=\"600\" border=\"0\" />\n</p>See the Calibration example file for more details, as well as function documentation:calcCalibResidualAprilTags!\ncalcCornerProjectionsAprilTags!"
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
    "text": "homography_to_pose(H, f_width, f_height, c_width, c_height, [taglength = 2.0])\n\nGiven a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag.\n\nNotes\n\nImages.jl uses ::Array in Julia as column-major (i.e. vertical major) convention, that is size(img) == (480, 640)\nAxes start top left-corner of the image plane (i.e. the image-frame):\nwidth is from left to right,\nheight is from top downward.\nThe low-level ccall wrapped C-library underneath uses the convention (i.e. the camera-frame): \nfx == f_width, \ncy == c_height, and\nC-library camara coordinate system: camera looking along positive Z axis with x to the right and y down.\nC-library internally follows: https://docs.opencv.org/3.4/d9/d0c/group__calib3d.html\nThe focal lengths should be given in pixels.\nThe returned units are those of the tag size, therefore the translational components should be scaled with the tag size.\nThe tag coordinates are from (-1,-1) to (1,1), i.e. the tag size has length of 2 units.\nOptionally, the tag length (in metre) can be passed to return a scaled value.\nReturns ::Matrix{Float64}\n\nRelated\n\nhomographytopose\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.homographytopose",
    "page": "Functions",
    "title": "AprilTags.homographytopose",
    "category": "function",
    "text": "homographytopose(H, f_width, f_height, c_width, c_height, [taglength = 2.0])\n\nGiven a 3x3 homography matrix and the camera model (focal length and centre), compute the pose of the tag.\n\nNotes\n\nImages.jl uses ::Array in Julia as column-major (i.e. vertical major) convention, that is size(img) == (480, 640)\nAxes start top left-corner of the image plane (i.e. the image-frame):\nwidth is from left to right,\nheight is from top downward.\nThe low-level ccall wrapped C-library underneath uses the convention (i.e. the camera-frame): \nfx == f_width, \ncy == c_height, and\nC-library camara coordinate system: camera looking along positive Z axis with x to the right and y down.\nC-library internally follows: https://docs.opencv.org/3.4/d9/d0c/group__calib3d.html\nThe focal lengths should be given in pixels.\nThe returned units are those of the tag size, therefore the translational components should be scaled with the tag size.\nThe tag coordinates are from (-1,-1) to (1,1), i.e. the tag size has length of 2 units.\nOptionally, the tag length (in metre) can be passed to return a scaled value.\nReturns ::Matrix{Float64}\n\n```\n\nRelated:\n\nhomography_to_pose\n\n\n\n\n\n"
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
    "text": "detectAndPose(detector, image, f_width, f_height, c_width, c_height, taglength)\n\n\nDetect tags and calcuate the pose on them.\n\n\n\n\n\n"
},

{
    "location": "func_ref/#AprilTags.tagOrthogonalIteration",
    "page": "Functions",
    "title": "AprilTags.tagOrthogonalIteration",
    "category": "function",
    "text": "tagOrthogonalIteration(corners, H, f_width, f_height, c_width, c_height; taglength, nIters)\n\n\nRun the orthoganal iteration algorithm on the poses. \n\nNotes\n\nSee apriltag_pose.h\n[2]: Lu, G. D. Hager and E. Mjolsness, \"Fast and globally convergent pose estimation from video images,\"  in IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 22, no. 6, pp. 610-622, June 2000.  doi: 10.1109/34.862199\nThe low level C-library uses fx=f_width.\n\n\n\n\n\n"
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
