"""
    drwatson.jl

# Description
This file extends DrWatson workflow functionality such as by adding additional custom directory functions.
"""

# -----------------------------------------------------------------------------
# "DECORATORS
# -----------------------------------------------------------------------------

# macro log_calls(defun)
#     def = splitdef(defun)
#     name = def[:name]
#     body = def[:body]

#     # $name is interpolated in the strings, which will be
#     # interpolated into the generated expression
#     # => it's easier to do this in two steps
#     enter = "calling $name"
#     leave = "called $name"

#     # Surround the original body with @info messages
#     def[:body] = quote
#         @info $enter
#         mkpath($body)
#         @info "Made some garbage"
#         $body
#         @info $leave
#     end

#     # Recombine the function definition and output it (escaped!)
#     esc(combinedef(def))
# end


# macro log_calls(func)
#     name = func.args[1].args[1]
#     hiddenname = gensym()
#     func.args[1].args[1] = hiddenname
#     @info "decorating $name" hiddenname

#     _decorator(f) = (args...) -> begin
#         @info "calling $(name)"
#         ret = f(args...)
#         @info "called $(name)"
#         ret
#     end

#     quote
#         $func
#         $(esc(name)) = $_decorator($hiddenname)
#     end
# end

# macro does_nothing(arg)
#     return arg
# end

# -----------------------------------------------------------------------------
# CUSTOM DRWATSON DIRECTORY DEFINITIONS
# -----------------------------------------------------------------------------

# macro makesdir(dir_func)
#     # mkpath(dir_func())
#     :(mkpath($dir_func()))
#     return dir_func
# end

# function makesdir(dir_func)
#     mkpath(dir_func())
#     return dir_func
# end

"""
Points to the work directory containing raw datasets, processed datasets, and results.
"""
function work_dir(args...)
    newdir(args...) = projectdir("work", args...)
    mkpath(newdir())
    return newdir(args...)
end
# work_dir(args...) = makesdir(projectdir("work", args...))
# work_dir(args...) = projectdir("work", args...)
# function work_dir(args...)
#     dirname = "work"

#     return project_dir(dirname, args...)
# end

"""
Points to the results directory.
"""
function results_dir(args...)
    newdir(args...) = work_dir("results", args...)
    mkpath(newdir())
    return newdir(args...)
end

# @log_calls function results_dir(args...)
#     return work_dir("results", args...)
# end
# results_dir(args...) = @log_calls work_dir("results", args...)
# results_dir(args...) = projectdir("work", "results", experiment_top, args...)
