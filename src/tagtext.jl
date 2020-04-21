# text and tags and images

"""
    drawTagNumber!(::Array{<:RGB,2},::AprilTag,face=FTFont(..);sz::Float64=0.6)

Draw on array image the tag number at center of each tag with size scaling `sz`.

Example
```julia
foreach(tag->drawTagNumber!(imageCol, tag)
```
"""
function drawTagNumber!(image::Array{T,2},
                        tag::AprilTag,
                        face=FTFont(joinpath(dirname(dirname(pathof(FreeTypeAbstraction))),"test","hack_regular.ttf") );
                        sz::Float64=0.6 ) where T <: RGB
  #
  pminx = round(Int, minimum((x->x[1]).(tag.p)) )
  pminy = round(Int, minimum((x->x[2]).(tag.p)) )
  pmaxx = round(Int, maximum((x->x[1]).(tag.p)) )
  pmaxy = round(Int, maximum((x->x[2]).(tag.p)) )
  centx = round(Int,0.5*(pmaxx+pminx))
  centy = round(Int,0.5*(pmaxy+pminy))
  text = "$(tag.id)"
  szz = round(Int, sz*6.0/(length(text)+10.0)*(pmaxx-pminx+pmaxy-pminy))
  renderstring!(image, text, face, szz, centy,centx, halign=:hcenter,valign=:vcenter)
end
