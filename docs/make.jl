using Documenter, SearchBall

makedocs(
    format = :html,
    # assets = [""],
    sitename = "SearchBall Documentation",
    authors = "Tobias Jagla",
    pages = [
        "Home" => "index.md",
        "GUI" => "gui.md",
        "Strategies" => "strategies.md",
        "Simulation" => "simulation.md",
        "Algorithms" => "algorithms.md"
    ]
)

# deploydocs(
#     repo = "github.com/control13/SearchBall.jl.git",
#     target = "build",
#     julia = "0.6",
#     deps   = nothing,
#     make   = nothing
# )

