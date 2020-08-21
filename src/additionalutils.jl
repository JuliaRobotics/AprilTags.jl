# Functionality that may be loaded more than one

export drawTags!, drawTags


"""
    drawTags!

Draw axes and tag IDs on an image based on detections in `tags`.

Notes
- Will self detect tags, or requires user to pass in `tags` detections.
"""
function drawTags!(imageCol::AbstractArray{<:AbstractRGB,2}, 
                   K::AbstractArray{<:Real,2},
                   tags::AbstractArray{AprilTag,1} = AprilTagDetector()(imageCol),
                   drawReticle::Bool = false )
  #
  # draw the tag number for each tag
  if @isdefined(drawTagID!)
    foreach(x->drawTagID!(imageCol, x),tags)
  end
  #draw color box on tag corners
  foreach(tag->drawTagBox!(imageCol, tag, width = 2, drawReticle = drawReticle), tags)
  foreach(tag->drawTagAxes!(imageCol,tag, K), tags)
  imageCol
end

"""
    drawTags

Draw axes and tag IDs on an image based on detections in `tags`.

Notes
- Will self detect tags, or requires user to pass in `tags` detections.
"""
drawTags(imageCol::AbstractArray{<:AbstractRGB,2},K::AbstractArray{<:Real,2},tags::AbstractArray{AprilTag,1}=AprilTagDetector()(imageCol),drawReticle::Bool=false ) = drawTags!(RGB.(imageCol),K,tags,drawReticle)
# Convert image to RGB
# imageCol = RGB.(image)


#