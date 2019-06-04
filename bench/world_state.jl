using BenchmarkTools
import SearchBall
sb = SearchBall

pos = sb.Posture([0.0, 0.0], 0.0)
pos[1]

p = rand(2)
a = rand()
@benchmark pos = sb.Posture(p, a)

@benchmark pos = sb.Posture(rand(2), rand())

@benchmark pos[Int(round(rand())) + 1]

function getVal(i::Int, pos::sb.Posture)
    pos[i]
end

getVal(1, pos)

@benchmark getVal(2, pos)
