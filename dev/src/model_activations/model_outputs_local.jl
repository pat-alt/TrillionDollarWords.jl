using Base.Iterators: partition
using CSV
using DataFrames
using TrillionDollarWords

# Load model and data:
mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

# Path for intermediate activations:
out_dir = "dev/data/activations/intermediate"

function get_last_saved(out_dir::AbstractString)
    if ispath(out_dir)
        sentence_ids = readdir(out_dir) .|>
            x -> split(replace(x, ".csv" => ""), ":")[2] .|>
            x -> parse(Int, x)
        if length(sentence_ids) > 0
            return maximum(sentence_ids)
        end
    end
    return 0
end

function compute_activations(
    df::DataFrame, mod; 
    out_dir::AbstractString=out_dir, 
    last_saved::Int=get_last_saved(out_dir), 
    bs::Int=10,
    missing_ids::Union{Nothing,Vector{Int}}=Nothing
)
    n_thr = Threads.nthreads()
    n_per_chunk = bs * n_thr
    n = size(df, 1)
    if isnothing(missing_ids) 
        all_ids = 1:n
    else
        all_ids = missing_ids
    end
    for (i, chunk) in enumerate(partition(all_ids, n_per_chunk))
        @info "Processing chunk $i/$(ceil(Int, length(all_ids)/n_per_chunk))..."
        !all(chunk .<= last_saved) || !isnothing(missing_ids) || continue
        Threads.@threads for batch in collect(partition(chunk, bs))
            println("$batch on $(Threads.threadid())")
            queries = df[batch,:]
            emb = layerwise_activations(mod, queries)
            _sffx = "$(batch[1]):$(batch[end])"
            CSV.write(joinpath(out_dir, "activations_$(_sffx).csv"), emb)
        end
    end
end
