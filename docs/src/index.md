# SearchBall Documentation

This a 2d simulator for general multi robot/multi agent simulation,
but with special focus on NAO-Robots in the SPL Soccer League.
The simulator written in the Julia language.

## Why Julia?

[Julia](https://julialang.org/) claims to be a highly productive language that runs fast.
Julia looks in many ways like python. But python has some main disadvantages.
Julia has a typesystem, which offers the compiler the possibility to optimize the code und to check the input
for correctness. Julia does not use the indention for blocks and you don't need to write time cirtical code in C.
There are other languages, that might be right for this project. Matlab for example has a very richt ecosystem
and is very fast. But you need a license for it. C/C++ are very powerful languages with maybe the best ability to
optimize the code. But they leak a repl have not the high-level functionality for simply write small scripts in science.
Julia is designed for living code and I can assure you, in science your code is not for eternity.

Currently, there are only two disadvanteges, I will warn you:
The first startup of a programm is very long, because all functions must be compiled. I stongly recommand
[Revise.jl](https://github.com/timholy/Revise.jl) for developing.
The packagesystem is rich, but not as rich as compared to other languages. This is changing, because Julia
is a very young language (is still not version 1).

I'm pretty sure, that the language will improove througe time and we will have even nicer
features without the disadvanteges.

## Helpful packages

- [Revise.jl](https://github.com/timholy/Revise.jl) may help to get rid of the currently very long first start up time. This [blog entry](https://tpapp.github.io/post/julia-workflow/) may help to set up everthing right.
- [IJulia.jl](https://github.com/JuliaLang/IJulia.jl) provides IPython notebooks just for julia. And additional
- [Interact.jl](https://github.com/JuliaGizmos/Interact.jl) offers nice features for interactive work with your code.
You may also want plot somthing with
- [Plots.jl](https://github.com/JuliaPlots/Plots.jl)
- You can use [Coverage.jl](https://github.com/JuliaCI/Coverage.jl) for checking the tests and detection memory leaks.
Julia offers a stochastic profiler by the core language. To visualize the resultes use
- [ProfileView.jl](https://github.com/timholy/ProfileView.jl).
Debugging is currently under development.
- [Gallium.jl](https://github.com/Keno/Gallium.jl) offers a simple command line debugger for julia. The atom editor has an experimental support for this debugger in it's julia plugin.
