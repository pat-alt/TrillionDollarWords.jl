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
    return tkr, mod
end