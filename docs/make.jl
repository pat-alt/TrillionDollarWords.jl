using TrillionDollarWords
using Documenter

DocMeta.setdocmeta!(
    TrillionDollarWords,
    :DocTestSetup,
    :(using TrillionDollarWords);
    recursive = true,
)

makedocs(;
    modules = [TrillionDollarWords],
    authors = "Patrick Altmeyer",
    repo = "https://github.com/pat-alt/TrillionDollarWords.jl/blob/{commit}{path}#{line}",
    sitename = "TrillionDollarWords.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://pat-alt.github.io/TrillionDollarWords.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = ["Home" => "index.md"],
)

deploydocs(; repo = "github.com/pat-alt/TrillionDollarWords.jl", devbranch = "main")
