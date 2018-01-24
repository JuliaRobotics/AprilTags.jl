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
    repo   = "github.com/Affie/AprilTags.jl.git",
    target = "build",
    deps   = nothing,
    make   = nothing,
    julia  = "0.6",
    osname = "linux"
)




# deploydocs(
#     deps   = Deps.pip("mkdocs", "python-markdown-math", "mkdocs-material"),
#     repo   = "github.com/Affie/Video4Linux.jl.git",
#     julia  = "release",
# )
