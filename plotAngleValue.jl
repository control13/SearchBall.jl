import CSV
import DataFrames; const df = DataFrames
import Plots; const pl = Plots
import ColorSchemes; const cs = ColorSchemes
pl.plotly()

path = "/home/tobias/doc/students/Bachelor_Michelle-Tavernaro/Results/27.11.18/winkel03/"
angles = 135:5:225
data = df.DataFrame[]
for (i, angle) in enumerate(angles)
    push!(data, CSV.read(path*string(angle)*".csv"))
end

oben_whk = map(x -> x[5,4], data)
mitte_whk = map(x -> x[9,4], data)
unten_whk = map(x -> x[13,4], data)

p = pl.plot([oben_whk])
pl.gui(p)
