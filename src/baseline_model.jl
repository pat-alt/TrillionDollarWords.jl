using Transformers.TextEncoders: GPT2TextEncoder
using Transformers.HuggingFace:
    HGFRobertaModel, HGFRobertaForSequenceClassification, HGFConfig

"Struct for the baseline model (i.e. the model presented in the paper)."
struct BaselineModel
    tkr::GPT2TextEncoder
    mod::Union{HGFRobertaModel,HGFRobertaForSequenceClassification}
    cfg::HGFConfig
end

"""
    (mod::BaselineModel)(queries::Vector{String})

Computes a forward pass of the model on the given queries and returns either the logits or embeddings depending on whether or not the model was loaded with the head for classification.
"""
(mod::BaselineModel)(queries::Vector{String}) = mod(mod.mod, queries)

"""
    get_embeddings(mod::BaselineModel, queries::Vector{String})

Computes a forward pass of the model on the given queries and returns the embeddings.
"""
function get_embeddings(mod::BaselineModel, queries::Vector{String})
    tokens = Transformers.encode(mod.tkr, queries) |> Transformers.todevice
    get_embeddings(mod.mod, tokens)
end

"""
    (mod::BaselineModel)(atomic_model::HGFRobertaModel, queries::Vector{String})

Computes a forward pass of the model on the given queries and returns the embeddings.
"""
function (mod::BaselineModel)(atomic_model::HGFRobertaModel, queries::Vector{String})
    tokens = Transformers.encode(mod.tkr, queries) |> Transformers.todevice
    atomic_model = Transformers.todevice(atomic_model)
    embeddings = atomic_model(tokens)
    return embeddings
end

"""
    get_embeddings(atomic_model::HGFRobertaModel, tokens::NamedTuple)

Extends the `embeddings` function to `HGFRobertaModel`.
"""
get_embeddings(atomic_model::HGFRobertaModel, tokens::NamedTuple) = atomic_model(tokens)

"""
    (mod::BaselineModel)(atomic_model::HGFRobertaForSequenceClassification, queries::Vector{String})

Computes a forward pass of the model on the given queries and returns the logits.
"""
function (mod::BaselineModel)(
    atomic_model::HGFRobertaForSequenceClassification,
    queries::Vector{String},
)
    tokens = Transformers.encode(mod.tkr, queries) |> Transformers.todevice
    atomic_model = Transformers.todevice(atomic_model)
    embeddings = atomic_model.model(tokens)
    logits = atomic_model.cls(embeddings.hidden_state)
    return logits
end

"""
    get_embeddings(atomic_model::HGFRobertaForSequenceClassification, tokens::NamedTuple)

Extends the `embeddings` function to `HGFRobertaForSequenceClassification`.
"""
get_embeddings(atomic_model::HGFRobertaForSequenceClassification, tokens::NamedTuple) =
    atomic_model.model(tokens)

"""
    laywerwise_activations(mod::BaselineModel, queries::Vector{String})

Computes a forward pass of the model on the given queries and returns the layerwise activations for the `HGFRobertaModel`. If `output_hidden_states=false` was passed to `load_model` (default), only the last layer is returned. If `output_hidden_states=true` was passed to `load_model`, all layers are returned. Even if the model is loaded with the head for classification, the head is not used for computing the activations.
"""
function layerwise_activations(mod::BaselineModel, queries::Vector{String})
    embeddings = get_embeddings(mod, queries)
    pooler = Transformers.HuggingFace.FirstTokenPooler()
    if haskey(embeddings, :outputs)
        output = [pooler(x.hidden_state) for x in embeddings.outputs]
    else
        output = pooler(embeddings.hidden_state)
    end
    return output
end

"""
    layerwise_activations(mod::BaselineModel, queries::DataFrame)

Computes a forward pass of the model on the given queries and returns the layerwise activations in a `DataFrame` where activations are uniquely idendified by the `sentence_id`. If `output_hidden_states=false` was passed to `load_model` (default), only the last layer is returned. If `output_hidden_states=true` was passed to `load_model`, all layers are returned. The `layer` column indicates the layer number.

Each single activation receives its own cell to make it possible to save the output to a CSV file.
"""
function layerwise_activations(mod::BaselineModel, queries::DataFrame)
    @assert all([x ∈ names(queries) for x in ["sentence_id", "sentence"]]) "The DataFrame must have a columns named `sentence_id` and `sentence`."
    query_sentences = queries.sentence
    A = layerwise_activations(mod, query_sentences)
    if isa(A, Vector{<:AbstractArray})
        df = []
        for j = 1:length(A)
            _df = DataFrame(
                sentence_id = queries.sentence_id,
                activations = [A[j][:, i] for i = 1:size(A[j], 2)],
                layer = j,
            )
            push!(df, _df)
        end
        df = vcat(df...)
    else
        df = DataFrame(
            sentence_id = queries.sentence_id,
            activations = [A[:, i] for i = 1:size(A, 2)],
            layer = mod.cfg.num_hidden_layers,
        )
    end
    df =
        flatten(df, :activations) |>
        x -> transform(groupby(x, [:sentence_id, :layer]), eachindex => :activation_id)
    return df
end

"""
    load_model

Loads the model presented in the paper from HuggingFace. If `load_head` is `true`, the model is loaded with the head (i.e. the final layer) for classification. If `load_head` is `false`, the model is loaded without the head. The latter is useful for fine-tuning the model on a different task or in case the classification head is not needed. Accepts any additional keyword arguments that are accepted by `Transformers.HuggingFace.HGFConfig`.
"""
function load_model(; load_head = true, kwrgs...)
    tkr = Transformers.load_tokenizer("gtfintechlab/FOMC-RoBERTa")
    model_name = "gtfintechlab/FOMC-RoBERTa"
    cfg = Transformers.HuggingFace.HGFConfig(Transformers.load_config(model_name); kwrgs...)
    if load_head
        mod = Transformers.load_model(model_name, "ForSequenceClassification"; config = cfg)
    else
        mod = Transformers.load_model(model_name; config = cfg)
    end
    return BaselineModel(tkr, mod, cfg)
end
