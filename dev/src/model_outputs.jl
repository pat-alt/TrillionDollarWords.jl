tkr, mod = load_model(; load_head=false, output_hidden_states=true)
df = load_all_sentences()

# Press Conferences:
queries = subset(df, :event_type => x -> x .== "press conference").sentence
tokens = Transformers.encode(tkr, queries)
embeddings = mod(tokens)