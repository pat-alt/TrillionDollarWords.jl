using Base.Iterators: partition
using CSV
using DataFrames
using TrillionDollarWords

# Load model and data:
mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

# Path for intermediate activations:
out_dir = "dev/data/activations/intermediate"
if ispath(out_dir)
    sentence_ids = readdir(out_dir) .|> 
        x -> split(replace(x, ".csv" => ""), ":")[2] .|> 
        x -> parse(Int, x) 
    last_saved = maximum(sentence_ids)
else 
    mkpath(out_dir)
    last_saved = 0
end

# Compute activations:
bs = 10
n_thr = Threads.nthreads()
n_per_chunk = bs * n_thr
n = size(df, 1)
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
@info "Merging activations..."
merge_dir = "dev/data/activations/merged"
ispath(merge_dir) || mkpath(merge_dir)
df_activations = []
for x in readdir(out_dir)[contains.(readdir(out_dir), ".csv")]
    push!(df_activations, CSV.read(joinpath(out_dir, x), DataFrame))
end
df_activations = vcat(df_activations...) |>
    x -> sort!(x, [:sentence_id, :layer, :activation_id]) 
CSV.write("$merge_dir/activations.csv", df_activations)