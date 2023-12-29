using BiomassNative
using Documenter

DocMeta.setdocmeta!(BiomassNative, :DocTestSetup, :(using BiomassNative); recursive=true)

makedocs(;
    modules=[BiomassNative],
    authors="Renilson Lisboa Júnior <renilsonlisboajunior@gmail.com> and contributors",
    repo="https://github.com/renilsonlisboa/BiomassNative.jl/blob/{commit}{path}#{line}",
    sitename="BiomassNative.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://renilsonlisboa.github.io/BiomassNative.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/renilsonlisboa/BiomassNative.jl",
    devbranch="main",
)
