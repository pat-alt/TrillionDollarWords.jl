using DataFrames
using TrillionDollarWords

mod = load_model(; load_head=true, output_hidden_states=true)
df = load_all_sentences()

# Press Conferences:
n = 1
queries = subset(df, :event_type => x -> x .== "press conference")[1:n,:]
emb = layerwise_activations(mod, queries)
CSV.write("/Users/paltmeyer/Desktop/test.csv", emb)