using DataFrames
using TrillionDollarWords

# Load model and data:
mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

# Compute activations:
n = 1
queries = subset(df, :event_type => x -> x .== "press conference")[1:n,:]
emb = layerwise_activations(mod, queries)