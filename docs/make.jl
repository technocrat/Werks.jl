using Documenter

# Workaround for precompilation issues
include("../src/Werks.jl")
using .Werks

makedocs(
    sitename = "Werks.jl",
    format = Documenter.HTML(),
    modules = [Werks],
    pages = [
        "Home" => "index.md",
        "API Reference" => "api.md",
        "Function Index" => "function_index.md",
    ],
)

# Create .nojekyll file to disable Jekyll processing on GitHub Pages
open(joinpath(@__DIR__, "build", ".nojekyll"), "w") do io
    write(io, "")
end

# Only deploy if we're running on GitHub Actions
if get(ENV, "CI", nothing) == "true"
    deploydocs(
        repo = "github.com/technocrat/Werks.jl.git",
        devbranch = "main",
        versions = ["stable" => "v^", "v#.#"],
        forcepush = true,
    )
end 