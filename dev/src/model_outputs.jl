mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

# Press Conferences:
n = 20
queries = subset(df, :event_type => x -> x .== "press conference")[1:n,:]
emb = layerwise_activations(mod, queries)
CSV.write("/Users/paltmeyer/Desktop/test.csv", emb)