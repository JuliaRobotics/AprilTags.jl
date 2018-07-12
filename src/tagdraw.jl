"""
    drawTagBox!(image, tag)

Draw a box around the tag.
`imageCol = RGB.(image)
foreach(tag->drawTagBox!(imageCol, tag), tags)
`
"""
function drawTagBox!(image::Array{T,2}, tag::AprilTag, width=1) where T <: RGB
    cpoints = map(tag -> Point(round.(Int,tag)...),tag.p)
    # Reticle
    midx = (cpoints[3].x + cpoints[1].x) / 2
    midy = (cpoints[3].y + cpoints[1].y) / 2
    x1 = Point(round(midx - (cpoints[2].x - cpoints[1].x) / 4), round(midy - (cpoints[2].y - cpoints[1].y) / 4))
    x2 = Point(round(midx + (cpoints[2].x - cpoints[1].x) / 4), round(midy + (cpoints[2].y - cpoints[1].y) / 4))
    y1 = Point(round(midx - (cpoints[4].x - cpoints[1].x) / 4), round(midy - (cpoints[4].y - cpoints[1].y) / 4))
    y2 = Point(round(midx + (cpoints[4].x - cpoints[1].x) / 4), round(midy + (cpoints[4].y - cpoints[1].y) / 4))
    draw!(image, LineSegment( x1, x2), RGB{N0f8}(1.0, 0.0, 0.0))
    draw!(image, LineSegment( y1, y2), RGB{N0f8}(1.0, 0.0, 0.0))

    # Make a box around the tag
    for i in 1:width
        draw!(image, LineSegment( cpoints[1], cpoints[2]), RGB{N0f8}(0.0, 0.0, 1.0))
        draw!(image, LineSegment( cpoints[2], cpoints[3]), RGB{N0f8}(0.0, 0.0, 1.0))
        draw!(image, LineSegment( cpoints[3], cpoints[4]), RGB{N0f8}(1.0, 0.0, 0.0))
        draw!(image, LineSegment( cpoints[4], cpoints[1]), RGB{N0f8}(0.0, 1.0, 0.0))
        # Expand it
        cpoints[1] = Point(cpoints[1].x-1, cpoints[1].y-1)
        cpoints[2] = Point(cpoints[2].x+1, cpoints[2].y-1)
        cpoints[3] = Point(cpoints[3].x+1, cpoints[3].y+1)
        cpoints[4] = Point(cpoints[4].x-1, cpoints[4].y+1)
    end
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
