"""
    drawTagBox!(image, tag)

Draw a box around the tag.
`imageCol = RGB.(image)
foreach(tag->drawTagBox!(imageCol, tag), tags)
`
"""
function drawTagBox!(image::Array{T,2}, tag::AprilTag; width::Int = 1, drawReticle::Bool = true) where T <: RGB
    cpoints = map(tag -> Point(round.(Int,tag)...),tag.p)
    # Reticle
    if drawReticle
        midx = (cpoints[3].x + cpoints[1].x) / 2
        midy = (cpoints[3].y + cpoints[1].y) / 2
        x1 = Point(round(midx - (cpoints[2].x - cpoints[1].x) / 4), round(midy - (cpoints[2].y - cpoints[1].y) / 4))
        x2 = Point(round(midx + (cpoints[2].x - cpoints[1].x) / 4), round(midy + (cpoints[2].y - cpoints[1].y) / 4))
        y1 = Point(round(midx - (cpoints[4].x - cpoints[1].x) / 4), round(midy - (cpoints[4].y - cpoints[1].y) / 4))
        y2 = Point(round(midx + (cpoints[4].x - cpoints[1].x) / 4), round(midy + (cpoints[4].y - cpoints[1].y) / 4))
        draw!(image, LineSegment( x1, x2), RGB{N0f8}(1.0, 0.0, 0.0))
        draw!(image, LineSegment( y1, y2), RGB{N0f8}(1.0, 0.0, 0.0))
    end
    # Make a box around the tag
    if width <= 1
        draw!(image, LineSegment( cpoints[1], cpoints[2]), RGB{N0f8}(0.0, 0.0, 1.0))
        draw!(image, LineSegment( cpoints[2], cpoints[3]), RGB{N0f8}(0.0, 0.0, 1.0))
        draw!(image, LineSegment( cpoints[3], cpoints[4]), RGB{N0f8}(1.0, 0.0, 0.0))
        draw!(image, LineSegment( cpoints[4], cpoints[1]), RGB{N0f8}(0.0, 1.0, 0.0))
    else
        drawThickLine!(image, cpoints[1], cpoints[2], RGB{N0f8}(0.0, 0.0, 1.0), width)
        drawThickLine!(image, cpoints[2], cpoints[3], RGB{N0f8}(0.0, 0.0, 1.0), width)
        drawThickLine!(image, cpoints[3], cpoints[4], RGB{N0f8}(1.0, 0.0, 0.0), width)
        drawThickLine!(image, cpoints[4], cpoints[1], RGB{N0f8}(0.0, 1.0, 0.0), width)
    end

    return nothing
end

function drawThickLine!(image, startpoint, endpoint, colour, thickness)
    (row, col) = size(image)
    x1 = startpoint.x
    y1 = startpoint.y
    x2 = endpoint.x
    y2 = endpoint.y

    draw!(image, LineSegment(x1,y1,x2,y2), colour)

    if x1 != x2 && (y2-y1)/(x2-x1) < 1
        for tn = 1:thickness
            i = tn ÷ 2

            x1mi = x1-i
            x1pi = x1+i
            y1mi = y1-i
            y1pi = y1+i
            x2mi = x2-i
            x2pi = x2+i
            y2mi = y2-i
            y2pi = y2+i
            #clip to protect bounds
            (x1mi < 1) && (x1mi = 1)
            (y1mi < 1) && (y1mi = 1)
            (x1pi > col) && (x1pi = col)
            (y1pi > row) && (y1pi = row)
            (x2mi < 1) && (x2mi = 1)
            (y2mi < 1) && (y2mi = 1)
            (x2pi > col) && (x2pi = col)
            (y2pi > row) && (y2pi = row)

            iseven(tn) && draw!(image, LineSegment(x1,y1mi,x2,y2mi), colour)
            isodd(tn)  && draw!(image, LineSegment(x1,y1pi,x2,y2pi), colour)
        end
    else
        for tn = 1:thickness
            i = tn ÷ 2

            x1mi = x1-i
            x1pi = x1+i
            y1mi = y1-i
            y1pi = y1+i
            x2mi = x2-i
            x2pi = x2+i
            y2mi = y2-i
            y2pi = y2+i
            #clip to protect bounds
            (x1mi < 1) && (x1mi = 1)
            (y1mi < 1) && (y1mi = 1)
            (x1pi > col) && (x1pi = col)
            (y1pi > row) && (y1pi = row)
            (x2mi < 1) && (x2mi = 1)
            (y2mi < 1) && (y2mi = 1)
            (x2pi > col) && (x2pi = col)
            (y2pi > row) && (y2pi = row)

            iseven(tn) && draw!(image, LineSegment(x1mi,y1,x2mi,y2), colour)
            isodd(tn)  && draw!(image, LineSegment(x1pi,y1,x2pi,y2), colour)
        end
    end
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
    #TODO check that the line stays on the image to avoid bounds errors
    draw!(image, LineSegment(ip0, ip1), RGB{N0f8}(1.0, 0.0, 0.0))
    draw!(image, LineSegment(ip0, ip2), RGB{N0f8}(0.0, 1.0, 0.0))
    draw!(image, LineSegment(ip0, ip3), RGB{N0f8}(0.0, 0.0, 1.0))
    image
end
