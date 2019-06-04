# @show LOAD_PATH
# push!(LOAD_PATH, expanduser("~/doc/SearchBall/"))
# @show LOAD_PATH
import SearchBall; const sb = SearchBall

# config = "five_vs_five1"
config = "startposition01"
# config = "one_vs_many1"
# config = "symmetric1"
# config = "test"
# config = "2dlinNN"
# config = "2dlinNN01"
# config = "two_vs_three"

#TODO: make runnable from everywhere
configFile = joinpath(pwd(), "configs", string(config, ".config"))
configFile = joinpath("/home/tobias/doc/SearchBall/SearchBall.jl/", "configs", string(config, ".config"))
configFile = normpath(configFile)
sb.main(configFile)
