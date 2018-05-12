"""
    drawTagBox!(image, tag)

Draw a box around the tag.
`imageCol = RGB.(image)
foreach(tag->drawTagBox!(imageCol, tag), tags)
`
"""
function drawTagBox!(image::Array{T,2}, tag::AprilTag) where T <: RGB

    cpoints = map(tag -> Point(round.(Int,tag)...),tag.p)
      # Make a box around the tag
    draw!(image, LineSegment( cpoints[1], cpoints[2]), RGB{N0f8}(0.0, 0.0, 1.0))
    draw!(image, LineSegment( cpoints[2], cpoints[3]), RGB{N0f8}(0.0, 0.0, 1.0))
    draw!(image, LineSegment( cpoints[3], cpoints[4]), RGB{N0f8}(1.0, 0.0, 0.0))
    draw!(image, LineSegment( cpoints[4], cpoints[1]), RGB{N0f8}(0.0, 1.0, 0.0))
    return nothing
end


"""
    drawTagAxes!(image, tag, CameraMatrix)

Draw the tag x, y, and z axes to show the orientation.
`imageCol = RGB.(image)
foreach(tag->drawTagAxes!(imageCol, tag, K), tags)
`
"""
function drawTagAxes!(image::Array{T,2}, tag::AprilTag, K::Array{Float64,2}) where T <: RGB

    Kp = [K [0;0]; 0.0 0.0 1.0 0.0]
    pose = AprilTags.homography_to_pose(tag.H, K[1,1], K[2,2], K[1,3], K[2,3])

    # calculate and project
    p0 = Kp*pose[:,4]
    p0 /= p0[3]

    p1 = Kp*(pose[:,4] + pose[:,1])
    p1 /= p1[3]

    p2 = Kp*(pose[:,4] + pose[:,2])
    p2 /= p2[3]

    p3 = Kp*(pose[:,4] + pose[:,3])
    p3 /= p3[3]


    ip0 = Point(round.(Int,p0[1:2])...)
    ip1 = Point(round.(Int,p1[1:2])...)
    ip2 = Point(round.(Int,p2[1:2])...)
    ip3 = Point(round.(Int,p3[1:2])...)
    draw!(image, LineSegment(ip0, ip1), RGB{N0f8}(1.0, 0.0, 0.0))
    draw!(image, LineSegment(ip0, ip2), RGB{N0f8}(0.0, 1.0, 0.0))
    draw!(image, LineSegment(ip0, ip3), RGB{N0f8}(0.0, 0.0, 1.0))
    image
end