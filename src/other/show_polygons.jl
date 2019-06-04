using Plots
plotly()

p1 = P2[[9.0, 2.93166], [9.0, 3.66587], [4.19113, 3.27867], [4.20168, 2.97916]]
p2 = P2[[4.07356, 3.05364], [4.19125, 3.27868], [0.0, 2.94463], [0.0, 1.51997], [6.24798, 3.02374], [6.19429, 3.31842]]

x1, y1 = Plots.unzip(p1)
x2, y2 = Plots.unzip(p2)

plot(Shape(x1, y1), fillcolor=:red, label="A")
plot!(Shape(x2, y2), fillcolor=:blue, alpha=0.5, label="B")
xticks!(0.0:0.1:9.0)
yticks!(0.0:0.1:6.0)
