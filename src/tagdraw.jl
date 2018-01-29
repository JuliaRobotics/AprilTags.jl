using Images, ImageDraw

"""
    drawTagBox!(image, tag)

Draw a box around the tag.
`imageCol = RGB.(image)
foreach(tag->drawTagBox!(imageCol, tag), tags)
`
"""
function drawTagBox!(image, tag)

    cpoints = map(tag -> Point(round.(Int,tag)...),tag.p)
      # Make a box around the tag
    draw!(image, LineSegment( cpoints[1], cpoints[2]), RGB{N0f8}(0.0, 0.0, 1.0))
    draw!(image, LineSegment( cpoints[2], cpoints[3]), RGB{N0f8}(0.0, 0.0, 1.0))
    draw!(image, LineSegment( cpoints[3], cpoints[4]), RGB{N0f8}(1.0, 0.0, 0.0))
    draw!(image, LineSegment( cpoints[4], cpoints[1]), RGB{N0f8}(0.0, 1.0, 0.0))
    return nothing
end
