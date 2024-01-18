"""
    prepare_probe(outcome_data::DataFrame; layer::Int=24, value_var::Symbol=:value)

Prepare data for a linear probe. The `outcome_data` should be a `DataFrame` with a `sentence_id` column, which should contain unique values. There should also be a column containing the outcome variable. By default, this column is assumed to be called `value`, but this can be changed with the `value_var` argument. The `layer` argument indicates which layer to use for the probe. The default is the last layer (24).
"""
function prepare_probe(
    outcome_data::DataFrame;
    layer::Int=24, 
    value_var::Symbol=:value
)
    @assert layer in 1:24 "Layer must be between 1 and 24."
    @assert "sentence_id" in names(outcome_data) "Outcome data must have a sentence_id column."
    @assert length(unique(outcome_data.sentence_id)) == length(outcome_data.sentence_id) "The `sentence_id` column must have unique values."
    sort!(outcome_data, [:sentence_id])

    # Load activations:
    df_activations = LazyArtifacts.@artifact_str("activations_layer_$(layer)") |>
        x -> Arrow.Table("$x/activations.arrow") |> DataFrame

    df_joined = innerjoin(outcome_data, df_activations, on=:sentence_id)
    gdf = groupby(df_joined, :sentence_id)
    X = vcat([reshape(x.activations, 1, maximum(x.activation_id)) for x in gdf]...)
    y = unique(select(df_joined, [:sentence_id, value_var])) |>
        x -> select(x, value_var) |>
        x -> x[:, 1] |> vec

    return X, y
    
end