# AprilTags

[![Build Status](https://travis-ci.org/JuliaRobotics/AprilTags.jl.svg?branch=master)](https://travis-ci.org/JuliaRobotics/AprilTags.jl)

[![codecov.io](http://codecov.io/github/JuliaRobotics/AprilTags.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaRobotics/AprilTags.jl?branch=master)

This package is a ccall wrapper for the [AprilTags](https://april.eecs.umich.edu/software/apriltag.html) library tailored for Julia.

## Installation
AprilTags.jl can be installed in Julia 0.7 and Julia 1.0 with:
```julia
#enter ']' to get the package manager and then type:
(v0.7) pkg> add AprilTags
# or
using Pkg
Pkg.add("AprilTags")
```
Note that Julia 0.6 is no longer supprted going forward. Please use v0.0.2 for julia 0.6.  

## Usage
### Examples
See examples and test folder for basic AprilTag usage examples.

### Initialization
Initialize a detector with the default (tag36h11) tag family.
```julia
# Create default detector
detector = AprilTagDetector()
```
The tag detector parameters can be set as shown bellow.
The default parameters are the recommended starting point.
```julia
detector.nThreads = 4 #number of threads to use
detector.quad_decimate =  1.0 #"Decimate input image by this factor"
detector.quad_sigma = 0.0 #"Apply low-pass blur to input; negative sharpens"
detector.refine_edges = 1 #"Set to 1 to spend more time to align edges of tags"
detector.refine_decode = 0 #"Set to 1 to spend more time to decode tags"
detector.refine_pose = 0 #"Set to 1 to spend more time to precisely localize tags"
```    

#### quad_decimate
Detection of quads can be done on a lower-resolution image, improving speed at a cost of pose accuracy and a slight decrease in detection rate. Decoding the binary payload is still done at full resolution.  
Increase the image decimation if faster processing is required. A factor of 1.0 means the full-size input image is used.

#### quad_sigma
What Gaussian blur should be applied to the segmented image (used for quad detection?).  
Parameter is the standard deviation in pixels. Very noisy images benefit from non-zero values (e.g. 0.8).

#### refine_edges
When non-zero, the edges of the each quad are adjusted to "snap to" strong gradients nearby. This is useful when decimation is employed, as it can increase the quality of the initial quad estimate substantially. Generally recommended to be on (1). Very computationally inexpensive. Option is ignored if quad_decimate = 1.

#### refine_decode
When non-zero, detections are refined in a way intended to increase the number of detected tags. Especially effective for very small tags near the resolution threshold (e.g. 10px on a side).

#### refine_pose
When non-zero, detections are refined in a way intended to increase the accuracy of the extracted pose. This is done by maximizing the contrast around the black and white border of the tag. This generally increases the number of successfully detected tags, though not as effectively (or quickly) as refine_decode.  
This option must be enabled in order for "goodness" to be computed.

### Detection
Process an input image and return a vector of detections.
The input image can be loaded with the `Images` package.
```julia
image = load("example_image.jpg")
tags = detector(image)
#do something with tags here
```

The caller is responsible for freeing the memmory by calling
```julia
freeDetector!(detector)
```

### Creating the AprilTag Images
The AprilTag images can be created using the `getAprilTagImage` function.  
Eg. to create a tag image with id 1 from family 'tag36h11' run:
```julia
getAprilTagImage(1, AprilTags.tag36h11)
```

## Manual Outline
```@contents
Pages = [
    "index.md"
    "func_ref.md"
]
```
