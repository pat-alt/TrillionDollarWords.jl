using Transformers

tkr = Transformers.load_tokenizer("gtfintechlab/FOMC-RoBERTa")
model_name = "gtfintechlab/FOMC-RoBERTa"
cfg = Transformers.HuggingFace.HGFConfig(Transformers.load_config(model_name); kwrgs...)