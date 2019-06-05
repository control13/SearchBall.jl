import Pkg

Pkg.activate(Pkg.dir("SearchBall"))
Pkg.add(PackageSpec(url="https://github.com/control13/Chipmunk.jl"))
println("Chipmunk wurde hinzugefügt")
