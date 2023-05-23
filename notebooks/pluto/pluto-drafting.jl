### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 861ef620-70c3-47f0-999f-8188006cb7e1
begin
	cd(joinpath(@__DIR__, "..", ".."))
	using Pkg
	Pkg.activate(".")
end

# ╔═╡ 2a779836-bce0-4896-9fd6-016494676485
begin
	using Revise
	using OAR
	using PlutoUI
	include("src/lib/pluto.jl")
end

# ╔═╡ 78f1b791-4209-470d-a047-60f2062c1af3
md"# _Pluto Demo_

Pluto is a notebook environment unique to the Julia programming language, updating code as you write it (with computer magic ✨).

Coming from the IPython Jupyter notebook landscape, some things are familiar and some are different.
For example, Pluto notebooks are just Julia scripts (*.jl) with special comment markings to support reactive compilation, running, live documentation, and more while still being able to be run normally in the REPL.
"

# ╔═╡ 35e178e3-64db-4d2e-b4a5-8516048ef76c
md"
Lets activate the local environment.
Despite the fact that this is a DrWatson project, we will activate and load our dependencies manually:
"

# ╔═╡ 3bf3f923-e9e9-4336-876f-1ebe0ae8b817
TableOfContents()

# ╔═╡ 95979252-f17a-41e8-a808-8e793607efe2
@bind x Slider(1:42, default=31, show_value=true)

# ╔═╡ 84eae36a-55f0-4be9-930c-d8764b4a183d
if x == 42
	correct("THE ANSWER")
elseif 30 < x < 42
	almost("ALMOST")
else
	keep_working("NO")
end

# ╔═╡ 4b07c22c-7532-4ae9-8d14-fda2689237cb
md"Then "

# ╔═╡ Cell order:
# ╟─78f1b791-4209-470d-a047-60f2062c1af3
# ╟─35e178e3-64db-4d2e-b4a5-8516048ef76c
# ╠═861ef620-70c3-47f0-999f-8188006cb7e1
# ╠═2a779836-bce0-4896-9fd6-016494676485
# ╠═3bf3f923-e9e9-4336-876f-1ebe0ae8b817
# ╠═95979252-f17a-41e8-a808-8e793607efe2
# ╟─84eae36a-55f0-4be9-930c-d8764b4a183d
# ╠═4b07c22c-7532-4ae9-8d14-fda2689237cb
