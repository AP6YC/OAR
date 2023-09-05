using GraphRecipes
using Plots
default(size=(1000, 1000))

code = :(
function mysum(list)
    out = 0
    for value in list
        out += value
    end
    out
end
)

plot(
    code,
    fontsize=12,
    shorten=0.01,
    axis_buffer=0.15,
    nodeshape=:rect
)
