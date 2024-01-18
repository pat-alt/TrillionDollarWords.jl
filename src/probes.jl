function prepare_probe(
    outcome_data::DataFrame;
    layer::Int=24, 
)
    @assert layer in 1:24 "Layer must be between 1 and 24."
    @assert "sentence_id" in names(outcome_data) "Outcome data must have a sentence_id column."
    @assert length(unique(outcome_data.sentence_id)) == length(outcome_data.sentence_id) "The `sentence_id` column must have unique values."
    sort!(outcome_data, [:sentence_id])

    # Load activations:
    df_activations = LazyArtifacts.@artifact_str("activations_layer_$(1)") |>
        x -> Arrow.Table("$x/activations.arrow") |> DataFrame

    df_joined = innerjoin(outcome_data, df_activations, on=:sentence_id)
    gdf = groupby(df_joined, :sentence_id)
    X = vcat([reshape(x.activations, 1, maximum(x.activation_id)) for x in gdf]...)
    y = unique(select(df_joined, [:sentence_id, :value])).value

    return X, y
    
end