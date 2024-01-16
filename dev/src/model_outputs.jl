mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

# Press Conferences:
n = 5
queries = subset(df, :event_type => x -> x .== "press conference").sentence
embeddings = mod(queries[1:n])