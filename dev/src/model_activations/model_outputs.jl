using CUDA
using DataFrames
using Transformers
using TrillionDollarWords

# GPU:
@info "CUDA is functional: $(CUDA.functional())"
Transformers.enable_gpu()

# Load model and data:
@info "Loading model and data..."
mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

# Compute activations:
@info "Computing activations..."
n = 10
queries = df[1:n,:]
emb = layerwise_activations(mod, queries)
CSV.write("dev/data/activations/activations.csv", emb)