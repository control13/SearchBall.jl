import CSV
import DataFrames; const df = DataFrames
import Plots; const pl = Plots
import ColorSchemes; const cs = ColorSchemes
pl.plotly()

# data = CSV.read("/home/tobias/doc/students/Bachelor_Michelle-Tavernaro/Results/output/startposition.csv")
data = CSV.read("/home/tobias/doc/students/Bachelor_Michelle-Tavernaro/Results/neu/zweiSpieler/startposition/dreieck12.csv")

filter!(data) do x
    x.Linear < 4.4
end

colorlist = cs.get(reverse(cs.inferno), data.Stufen, :extrema);
# colorlist = ["#e6194b", "#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#46f0f0", "#f032e6", "#bcf60c", "#fabebe", "#008080", "#e6beff", "#9a6324", "#fffac8", "#800000", "#aaffc3", "#808000", "#ffd8b1", "#000075", "#808080", "#ffffff", "#00000"]
line = 1; cl = data[line, :]; col = colorlist[line];

plt = pl.plot(vcat(cl.x1, cl.x2, cl.x3), vcat(cl.y1, cl.y2, cl.y3), color=col, xlim=(0.0, 4.5), ylim=(0.0, 6.0), markershape=:auto)
for line in 2:df.nrow(data)#(line+1):(line+7 > df.nrow(data) ? df.nrow(data) : line+7)#2:df.nrow(data)
    cl = data[line, :]; col = colorlist[line]
    x_jit, y_jit = rand(2)/10
    pl.plot!(plt, vcat(cl.x1, cl.x2, cl.x3).+x_jit, vcat(cl.y1, cl.y2, cl.y3).+y_jit, color=col, xlim=(0.0, 4.5), ylim=(0.0, 6.0), markershape=:auto)
end
pl.gui(plt)
