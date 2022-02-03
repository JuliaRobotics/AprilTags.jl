using AprilTags
using Documenter

makedocs(
    modules = [AprilTags],
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
    ),
    sitename = "AprilTags.jl",
    pages = Any[
        "Home" => "index.md",
        "Functions" => "func_ref.md"
    ]
    )


deploydocs(
    repo   = "github.com/JuliaRobotics/AprilTags.jl.git",
    target = "build"
    )
