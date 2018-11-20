using Pkg
Pkg.build("AprilTags")
using Documenter, AprilTags

makedocs(
    modules = [AprilTags],
    format = :html,
    sitename = "AprilTags.jl",
    pages = Any[
        "Home" => "index.md",
        "Functions" => "func_ref.md"
    ]
    # html_prettyurls = !("local" in ARGS),
    )


deploydocs(
    repo   = "github.com/JuliaRobotics/AprilTags.jl.git",
    target = "build"
)
