using Werks
using Documenter

DocMeta.setdocmeta!(Werks, :DocTestSetup, :(using Werks); recursive=true)

makedocs(;
    modules=[Werks],
    authors="Richard Careaga <public@careaga.net>",
    repo="https://github.com/technocrat/Werks.jl/blob/{commit}{path}#{line}",
    sitename="Werks.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://technocrat.github.io/Werks.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API Reference" => "api.md",
        "Function Index" => "function_index.md",
    ],
)

deploydocs(;
    repo="github.com/technocrat/Werks.jl",
    devbranch="main",
) 