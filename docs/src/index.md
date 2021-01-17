# AprilTags

[![Build Status](https://travis-ci.org/JuliaRobotics/AprilTags.jl.svg?branch=master)](https://travis-ci.org/JuliaRobotics/AprilTags.jl)

[![codecov.io](http://codecov.io/github/JuliaRobotics/AprilTags.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaRobotics/AprilTags.jl?branch=master)

This package is a ccall wrapper for the [AprilTags](https://april.eecs.umich.edu/software/apriltag.html) library tailored for Julia.

## Installation
AprilTags.jl can be installed in Julia 0.7 and Julia 1.0 with:
```julia
#enter ']' to get the package manager and then type:
(v1.0) pkg> add AprilTags
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
detector.decode_sharpening = 0.25
```    

#### quad_decimate
Detection of quads can be done on a lower-resolution image, improving speed at a cost of pose accuracy and a slight decrease in detection rate. Decoding the binary payload is still done at full resolution.  
Increase the image decimation if faster processing is required. A factor of 1.0 means the full-size input image is used.

#### quad_sigma
What Gaussian blur should be applied to the segmented image (used for quad detection?).  
Parameter is the standard deviation in pixels. Very noisy images benefit from non-zero values (e.g. 0.8).

#### refine_edges
When non-zero, the edges of the each quad are adjusted to "snap to" strong gradients nearby. This is useful when decimation is employed, as it can increase the quality of the initial quad estimate substantially. Generally recommended to be on (1). Very computationally inexpensive. Option is ignored if quad_decimate = 1.

#### decode_sharpening
How much sharpening should be done to decoded images? This can help decode small tags but may or may not help in odd lighting conditions or low light conditions. The default value is 0.25.

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

## Visualizing Tags

Images can be updated to include the tag detections,
```julia
drawTagBox!(image, tag)
```

Or if the camera matrix `K` is known, the axes can be shown with
```julia
drawTagAxes!(image, tag, K)
```

Furthermore, the tag IDs can also be visualized by first loading a different package:
```julia
using FreeTypeAbstraction
using AprilTags
using ImageView

# get an image
img_ = drawTags(image, K)
imshow(img_)

# drawTags!(image, K, tags)
```

## Example

An easy (synthetic) verification example to test:

```julia
using AprilTags
using Images

detector = AprilTagDetector()

projImg = zeros(Gray{N0f8}, 480,640)
tag0 = kron(getAprilTagImage(0), ones(Gray{N0f8}, 4,4))
projImg[221:260,301:340] = tag0
projImg

fx = 1000.
fy = 1000.
cx = 320.
cy = 240.

K = [fx 0  cx;
      0 fy cy]

tags = detector(projImg)

imCol = RGB.(projImg)
foreach(tag->drawTagBox!(imCol, tag), tags)

taglength = 0.1
(tags, poses) = detectAndPose(detector, projImg, fx, fy, cx, cy, taglength)

poses[1]
```
results
```
3×4 Array{Float64,2}:
  0.996868    0.00273632   0.079042   -0.000300523
  0.00256118  0.99776     -0.0668423  -0.000417185
 -0.0790478   0.0668353    0.994628    3.1166
```
[copied from an issue discussion]

## Camera Calibration

Using a AprilTag grid, it is possible to take a series of photographs for estimating the camera intrinsic calibration parameters:
```@raw html
<p align="center">
<img src="https://user-images.githubusercontent.com/6412556/101559167-930a5800-398e-11eb-934d-e880c014c873.png" width="600" border="0" />
</p>
```

See the [Calibration example](https://github.com/JuliaRobotics/AprilTags.jl/blob/master/examples/AprilTagsGridCalibration.jl) file for more details, as well as function documentation:

```@docs
calcCalibResidualAprilTags!
```

## Manual Outline
```@contents
Pages = [
    "index.md"
    "func_ref.md"
]
```
