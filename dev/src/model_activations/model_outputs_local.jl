using Base.Iterators: partition
using CSV
using DataFrames
using TrillionDollarWords

# Load model and data:
mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

if isdir("dev/data/activations")
    df_activations = CSV.read("dev/data/activations/activations.csv")
    last_saved = maximum(df_activations.sentence_id)
else
    last_saved = 0
end

# Compute activations:
bs = 10
n_thr = Threads.nthreads()
n_per_chunk = bs * n_thr
n = size(df, 1)
out_dir = tempdir()
for (i, chunk) in enumerate(partition(1:n, n_per_chunk))
    @info "Processing chunk $i/$(ceil(Int, n/n_per_chunk))..."
    !all(chunk .<= last_saved) || continue
    Threads.@threads for batch in collect(partition(chunk, bs))
        println("$batch on $(Threads.threadid())")
        queries = df[batch,:]
        emb = layerwise_activations(mod, queries)
        CSV.write(joinpath(out_dir, "activations_$batch.csv"), emb)
    end
end

# Merge:
df_activations = []
for x in readdir(out_dir)[contains.(readdir(out_dir), ".csv")]
    push!(df_activations, CSV.read(joinpath(out_dir, x), DataFrame))
end
df_activations = vcat(df_activations...) |>
    x -> sort!(x, [:sentence_id, :layer, :activation_id]) 
CSV.write("dev/data/activations/activations.csv", df_activations)