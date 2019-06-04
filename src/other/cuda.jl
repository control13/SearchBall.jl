using BenchmarkTools, Test

N = 2^20
x = fill(1.0f0, N)  # a vector filled with 1.0 (Float32)
y = fill(2.0f0, N)  # a vector filled with 2.0

y .+= x             # increment each element of y with the corresponding element of x

@test all(y .== 3.0f0)

function sequential_add!(y, x)
    for i in eachindex(y, x)
        @inbounds y[i] += x[i]
    end
    return nothing
end

fill!(y, 2)
sequential_add!(y, x)
@test all(y .== 3.0f0)

function parallel_add!(y, x)
    Threads.@threads for i in eachindex(y, x)
        @inbounds y[i] += x[i]
    end
    return nothing
end

fill!(y, 2)
parallel_add!(y, x)
@test all(y .== 3.0f0)

@btime sequential_add!($y, $x)
@btime parallel_add!($y, $x)
@btime y .+= x             # increment each element of y with the corresponding element of x


using CuArrays

x_d = cufill(1.0f0, N)  # a vector stored on the GPU filled with 1.0 (Float32)
y_d = cufill(2.0f0, N)  # a vector stored on the GPU filled with 2.0

y_d .+= x_d
@test all(Array(y_d) .== 3.0f0)
@btime y_d .+= x_d

function add_broadcast!(y, x)
    CuArrays.@sync y .+= x
    return
end
@btime add_broadcast!(y_d, x_d)
