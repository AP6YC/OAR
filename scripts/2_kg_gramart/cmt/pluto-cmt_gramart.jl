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
	cd(joinpath(@__DIR__, "..", "..", ".."))
	using Pkg
	Pkg.activate(".")
	md"Activated the OAR project"
end

# ╔═╡ 2a779836-bce0-4896-9fd6-016494676485
begin
	using Revise
	using OAR
	using PlutoUI
	pluto_utils = "src/lib/utils/pluto.jl"
	include(pluto_utils)
	md"Setup complete"
end

# ╔═╡ 78f1b791-4209-470d-a047-60f2062c1af3
md"# _Pluto Template_

This notebook is a template with the preamble common to all Pluto notebooks used in the OAR project.
"

# ╔═╡ 35e178e3-64db-4d2e-b4a5-8516048ef76c
md"
## Preamble
"

# ╔═╡ 3bf3f923-e9e9-4336-876f-1ebe0ae8b817
TableOfContents(title="Experiments 🔬")

# ╔═╡ fcd2eb02-8791-46b3-92a0-055a6eeda694
md"## Experiments"

# ╔═╡ 0a8604fc-b961-4a70-8dfd-deeac545eda9
md"### 1: Cats and Dogs"

# ╔═╡ ab725b72-2d6a-4ed7-838f-ca14c36d1edb
begin
	dog_slider = @bind 🐶 Slider(1:10, default=5, show_value=true)
	cat_slider = @bind 🐱 Slider(11:20, default=12, show_value=true)

	md"""
	**How many pets do you have?**

	Dogs 🐶: $(dog_slider)

	Cats 😺: $(cat_slider)
	"""
end

# ╔═╡ 3a9d7e84-0004-4c59-8b34-374de428d3ef
md"
You have $🐶 dogs and $(🐱) cats
"

# ╔═╡ ab7800dd-de20-450e-afc0-307a5c81819b
md"### 2. Meaning of Life"

# ╔═╡ 95979252-f17a-41e8-a808-8e793607efe2
md"*What is the meaning of life?*

$(@bind x Slider(1:42, default=31, show_value=true))
"

# ╔═╡ 84eae36a-55f0-4be9-930c-d8764b4a183d
if x == 42
	correct(md"YOU HAVE FOUND THE ANSWER")
elseif 30 < x < 42
	almost(md"YOU HAVE ALMOST FOUND THE ANSWER")
else
	keep_working(md"THAT IS NOT THE ANSWER")
end

# ╔═╡ 7d9fc266-f0bc-41b6-907b-c3137b92d64b
hint(md"Don't forget to bring a towel")

# ╔═╡ Cell order:
# ╟─78f1b791-4209-470d-a047-60f2062c1af3
# ╟─35e178e3-64db-4d2e-b4a5-8516048ef76c
# ╠═861ef620-70c3-47f0-999f-8188006cb7e1
# ╠═2a779836-bce0-4896-9fd6-016494676485
# ╟─3bf3f923-e9e9-4336-876f-1ebe0ae8b817
# ╟─fcd2eb02-8791-46b3-92a0-055a6eeda694
# ╟─0a8604fc-b961-4a70-8dfd-deeac545eda9
# ╟─ab725b72-2d6a-4ed7-838f-ca14c36d1edb
# ╟─3a9d7e84-0004-4c59-8b34-374de428d3ef
# ╟─ab7800dd-de20-450e-afc0-307a5c81819b
# ╠═95979252-f17a-41e8-a808-8e793607efe2
# ╟─84eae36a-55f0-4be9-930c-d8764b4a183d
# ╟─7d9fc266-f0bc-41b6-907b-c3137b92d64b
