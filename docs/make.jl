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

# Only deploy if we're running on GitHub Actions
if get(ENV, "CI", nothing) == "true"
    deploydocs(
        repo = "github.com/technocrat/Werks.jl.git",
        devbranch = "main",
    )
end 