using CSV
using CUDA
using DataFrames
using Transformers
using TrillionDollarWords

# Paths:
out_dir = "dev/data/activations/intermediate"
ispath(out_dir) || mkpath(out_dir)
if isdir("dev/data/activations/merged")
    df_activations = CSV.read("dev/data/activations/merged/activations.csv")
    last_saved = maximum(df_activations.sentence_id)
else
    last_saved = 0
end

# GPU:
@info "CUDA is functional: $(CUDA.functional())"
Transformers.enable_gpu()

# Load model and data:
@info "Loading model and data..."
mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

# Compute activations:
@info "Computing activations..."
bs = 50
n = size(df, 1)
for (i, batch) in enumerate(partition(1:n, bs))
    @info "Processing batch $i/$(ceil(Int, n/bs))..."
    !all(batch .<= last_saved) || continue
    queries = df[batch,:]
    emb = layerwise_activations(mod, queries)
    CSV.write(joinpath(out_dir, "activations_$batch.csv"), emb)
end

# Merge:
@info "Merging activations..."
df_activations = []
for x in readdir(out_dir)[contains.(readdir(out_dir), ".csv")]
    push!(df_activations, CSV.read(joinpath(out_dir, x), DataFrame))
end
df_activations = vcat(df_activations...) |>
    x -> sort!(x, [:sentence_id, :layer, :activation_id])
CSV.write("dev/data/activations/activations.csv", df_activations)

queries = df[1:n,:]
emb = @time layerwise_activations(mod, queries)
CSV.write("dev/data/activations/activations.csv", emb)