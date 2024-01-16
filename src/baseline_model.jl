using Transformers.TextEncoders: AbstractTransformerTextEncoder
using Transformers.HuggingFace: HGFPreTrainedModel

"Struct for the baseline model (i.e. the model presented in the paper)."
struct BaselineModel{T<:AbstractTransformerTextEncoder,M<:HGFPreTrainedModel}
    tkr::T
    mod::M
end

"""
    (mod::BaselineModel)(queries::Vector{String})

Computes a forward pass of the model on the given queries and returns the embeddings.
"""
function (mod::BaselineModel)(queries::Vector{String})
    tokens = Transformers.encode(mod.tkr, queries)
    embeddings = mod.mod(tokens)
    return embeddings
end

"""
    laywerwise_activations(mod::BaselineModel, queries::Vector{String})

Computes a forward pass of the model on the given queries and returns the layerwise activations. If `output_hidden_states=false` was passed to `load_model` (default), only the last layer is returned. If `output_hidden_states=true` was passed to `load_model`, all layers are returned.
"""
function laywerwise_activations(mod::BaselineModel, queries::Vector{String})
    embeddings = mod(queries)
    pooler = Transformers.HuggingFace.FirstTokenPooler()
    if haskey(embeddings, :outputs)
        output = [pooler(x.hidden_state) for x in embeddings.outputs]
    else
        output = pooler(embeddings.hidden_state)
    end
    return output
end

"""
    load_model

Loads the model presented in the paper from HuggingFace. If `load_head` is `true`, the model is loaded with the head (i.e. the final layer) for classification. If `load_head` is `false`, the model is loaded without the head. The latter is useful for fine-tuning the model on a different task or in case the classification head is not needed. Accepts any additional keyword arguments that are accepted by `Transformers.HuggingFace.HGFConfig`.
"""
function load_model(; load_head=true, kwrgs...)
    tkr = Transformers.load_tokenizer("gtfintechlab/FOMC-RoBERTa")
    model_name = "gtfintechlab/FOMC-RoBERTa"
    cfg = Transformers.HuggingFace.HGFConfig(Transformers.load_config(model_name); kwrgs...)
    if load_head
        mod = Transformers.load_model(model_name, "ForSequenceClassification"; config=cfg)
    else
        mod = Transformers.load_model(model_name; config=cfg)
    end
    return BaselineModel(tkr, mod)
end