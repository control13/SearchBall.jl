using LightGraphs, SimpleWeightedGraphs, GraphPlot

g = SimpleWeightedGraph(3)

add_edge!(g, 1, 2, 0.5)
add_edge!(g, 1, 3, 2.5)
add_edge!(g, 2, 3, 0.8)

gplot(g, nodelabel=vertices(g), edgelabel=weight.(collect(edges(g))))
