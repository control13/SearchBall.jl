import Pkg

Pkg.activate(Pkg.dir("SearchBall"))
Pkg.add(Pkg.PackageSpec(url="https://github.com/control13/Chipmunk.jl"))
println("Chipmunk wurde hinzugefügt")
