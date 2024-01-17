using Base.Iterators: partition
using CSV
using CUDA
using DataFrames
using Transformers
using TrillionDollarWords

# Path for intermediate activations:
out_dir = "dev/data/activations/intermediate"
last_saved = 0
if ispath(out_dir)
    sentence_ids = readdir(out_dir) .|>
        x -> split(replace(x, ".csv" => ""), ":")[2] .|>
        x -> parse(Int, x)
    if length(sentence_ids) > 0
        last_saved = maximum(sentence_ids)
    end
else
    mkpath(out_dir) 
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
    emb = @time layerwise_activations(mod, queries)
    CSV.write(joinpath(out_dir, "activations_$batch.csv"), emb)
end

# Merge:
@info "Merging activations..."
merge_dir = "dev/data/activations/merged"
df_activations = []
for x in readdir(out_dir)[contains.(readdir(out_dir), ".csv")]
    push!(df_activations, CSV.read(joinpath(out_dir, x), DataFrame))
end
df_activations = vcat(df_activations...) |>
    x -> sort!(x, [:sentence_id, :layer, :activation_id])
CSV.write("$merge_dir/activations.csv", df_activations)