### A Pluto.jl notebook ###
# v0.19.47

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
	using PlutoUI
	md"Activated the OAR project"
end

# ╔═╡ 2a779836-bce0-4896-9fd6-016494676485
begin
	using Revise
	using OAR
	pluto_utils = "src/lib/utils/pluto.jl"
	include(pluto_utils)
	md"Setup complete"
end

# ╔═╡ 67070a1c-7123-424d-b934-e4027a28a56d
begin
	using ProgressMeter
	using DataFrames
	
	exp_top = "3_cmt"
	exp_name = "1_start.jl"
	
	# Input CSV file
	input_file = OAR.data_dir("cmt", "output_CMT_file.csv")
	data_dict_file = OAR.data_dir("cmt", "cmt_data_dict.csv")
	output_file = OAR.results_dir("3_cmt", "cmt_clusters.csv")
	md"!!! note
	
	Data locations:\
	\
	Input: $(input_file)\
	Data dictionary: $data_dict_file\
	Output file: $output_file
	"
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

# ╔═╡ c71e80db-6e9b-4461-aafa-ffc57331a333
md"## Experiments"

# ╔═╡ 102fa22c-6737-4f6a-a41d-9890b2ebdd00
md"### Load Charcot-Marie-Tooth csv"

# ╔═╡ 5866e5c9-3549-4c56-954f-a1d2e5890b3c
# Load the cmt file
df = OAR.load_cmt(input_file)

# ╔═╡ 618b4ec1-c6e9-4eae-ac14-e921bb3e2f9d
md"### Load CMT Feature Definition Dictionary"

# ╔═╡ 6d6c517e-d113-4649-889e-b51f7750a730
# Load the data definition dictionary
df_dict = OAR.load_cmt_dict(data_dict_file)

# ╔═╡ 21aad25f-0dc5-4c8e-9273-f7206633e0c3
md"### Parse to Trees"

# ╔═╡ a8857b8b-c579-4245-ad66-89b0a81726ae
ts = OAR.df_to_trees(df, df_dict)

# ╔═╡ c656defa-896a-49ea-ac61-dc9afbc5f699
md"### Generate Grammar from Trees"

# ╔═╡ 669d210d-9184-476e-8baf-69e3880c0b66
grammar = OAR.CMTCFG(ts)

# ╔═╡ 9b3d2858-c409-421d-bb50-b0213224dd7a
md"### Initialize START Module"

# ╔═╡ c74e3029-fae7-46de-ae7b-a471b7dea0dd
art = OAR.START(
    grammar,
    # rho=0.7,
    rho=0.6,
    terminated=false,
)

# ╔═╡ f98443d0-172e-4b94-94e8-45ff977313c2
md"### Train"

# ╔═╡ 9eeaeb01-ce6c-4c24-9067-937b12d972c7
@showprogress "Training" for tn in ts
    OAR.train!(art, tn)
end

# ╔═╡ 6549c698-23fb-4083-873f-0af7f5de2f75
md"### Test"

# ╔═╡ a0af67e2-8efb-4077-a3fd-6727343dea41
begin
clusters = Vector{Int}()
@showprogress "Classifying" for tn in ts
    cluster = OAR.classify(art, tn, get_bmu=true)
    push!(clusters, cluster)
end
	clusters
end

# ╔═╡ c5721728-7bae-416d-9381-77af0c3f319a
unique(clusters)

# ╔═╡ fcd2eb02-8791-46b3-92a0-055a6eeda694
md"## Demo Experiments"

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
# ╟─861ef620-70c3-47f0-999f-8188006cb7e1
# ╟─2a779836-bce0-4896-9fd6-016494676485
# ╟─3bf3f923-e9e9-4336-876f-1ebe0ae8b817
# ╟─c71e80db-6e9b-4461-aafa-ffc57331a333
# ╠═67070a1c-7123-424d-b934-e4027a28a56d
# ╟─102fa22c-6737-4f6a-a41d-9890b2ebdd00
# ╟─5866e5c9-3549-4c56-954f-a1d2e5890b3c
# ╟─618b4ec1-c6e9-4eae-ac14-e921bb3e2f9d
# ╠═6d6c517e-d113-4649-889e-b51f7750a730
# ╟─21aad25f-0dc5-4c8e-9273-f7206633e0c3
# ╠═a8857b8b-c579-4245-ad66-89b0a81726ae
# ╠═c656defa-896a-49ea-ac61-dc9afbc5f699
# ╠═669d210d-9184-476e-8baf-69e3880c0b66
# ╠═9b3d2858-c409-421d-bb50-b0213224dd7a
# ╠═c74e3029-fae7-46de-ae7b-a471b7dea0dd
# ╠═f98443d0-172e-4b94-94e8-45ff977313c2
# ╠═9eeaeb01-ce6c-4c24-9067-937b12d972c7
# ╠═6549c698-23fb-4083-873f-0af7f5de2f75
# ╠═a0af67e2-8efb-4077-a3fd-6727343dea41
# ╠═c5721728-7bae-416d-9381-77af0c3f319a
# ╠═fcd2eb02-8791-46b3-92a0-055a6eeda694
# ╟─0a8604fc-b961-4a70-8dfd-deeac545eda9
# ╟─ab725b72-2d6a-4ed7-838f-ca14c36d1edb
# ╟─3a9d7e84-0004-4c59-8b34-374de428d3ef
# ╟─ab7800dd-de20-450e-afc0-307a5c81819b
# ╠═95979252-f17a-41e8-a808-8e793607efe2
# ╠═84eae36a-55f0-4be9-930c-d8764b4a183d
# ╠═7d9fc266-f0bc-41b6-907b-c3137b92d64b
