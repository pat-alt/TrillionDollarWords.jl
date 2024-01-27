# Trillion Dollar Words in Julia

# 💰 Trillion Dollar Words in Julia

**Abstract**: [TrillionDollarWorlds.jl](https://github.com/pat-alt/TrillionDollarWords.jl) provides access to a novel financial dataset and large language model fine-tuned for classifying central bank communications as either ‘hawkish’, ‘dovish’ or ‘neutral’. It ships with essential functionality for model probing, an important aspect of mechanistic interpretability.

## Description

In the age of forward guidance, central bankers spend a great deal of time thinking about how their communications are perceived by markets. What if there was a way to predict the impact of communications on financial markets directly from text? Shah, Paturi, and Chava (2023) attempt to do just that in their [ACL 2023 paper](https://arxiv.org/abs/2305.07972) (which the author of this package is not affiliated with).

### Background

The authors of the paper have collected and preprocessed a corpus of around 40,000 time-stamped sentences from meeting minutes, press conferences and speeches by members of the Federal Open Market Committee (FOMC). The total sample period spans from January, 1996, to October, 2022. In order to train various rule-based models and large language models (LLM) to classify sentences as either ‘hawkish’, ‘dovish’ or ‘neutral’, they have manually annotated a subset of around 2,500 sentences. The best performing model, a large RoBERTa model with around 355 million parameters, was open-sourced on [HuggingFace](https://huggingface.co/gtfintechlab/FOMC-RoBERTa?text=A+very+hawkish+stance+excerted+by+the+doves).

### Data

While the authors of the paper did publish their data, much of it is unfortunately scattered across CSV and Excel files stored in a public GitHub repo. We have collected and merged that data, yielding a combined dataset with indexed sentences and additional metadata that may be useful for downstream tasks.

``` julia
julia> using TrillionDollarWords
julia> load_all_sentences() |> names
8-element Vector{String}:
 "sentence_id"
 "doc_id"
 "date"
 "event_type"
 "label"
 "sentence"
 "score"
 "speaker"
```

In addition to the sentences, market data about price inflation and the US Treasury yield curve can also be loaded. All datasets are loaded as `DataFrame`s and share common keys that make it possible to join them. Alternatively, a complete dataset combining the corpus of sentences with market data can also be loaded with `load_all_data()`.

### Loading the Model

The model can be loaded with or without the classifier head. Under the hood, we use [Transformers.jl](https://github.com/chengchingwen/Transformers.jl) to retrieve the model from HuggingFace. Any keyword arguments accepted by `Transformers.HuggingFace.HGFConfig` can also be passed. For example, to load the model without the classifier head and enable access to layer-wise activations, the following command can be used: `load_model(; load_head=false, output_hidden_states=true)`.

### Model Inference

For our own research, we have been interested in probing the model. This involves using linear models to estimate the relationship between layer-wise transformer embeddings and some outcome variable of interest (Alain and Bengio 2018). To do this, we first had to run a single forward pass for each sentence through the RoBERTa model and store the layerwise emeddings. The package ships with functionality for doing just that, but to save others valuable GPU hours we have archived activations of the hidden state on the first entity token for each layer as [artifacts](https://github.com/pat-alt/TrillionDollarWords.jl/releases/tag/activations_2024-01-17). To download the last-layer activations in an interactive Julia session, for example, users can proceed as follows:

``` julia
julia> using LazyArtifacts

julia> artifact"activations_layer_24"
"$HOME/.julia/artifacts/1785c2c64e603af5e6b79761150b1cc15d03f525"
```

We have found that despite the small sample size, the RoBERTa model appears to have distilled useful representations for downstream tasks that it was not explicitly trained for. The chart below shows the average out-of-sample root mean squared error for predicting various market indicators from layer activations. Consistent with findings in related work (Alain and Bengio 2018), we find that performance typically improves for layers closer to the final output layer of the transformer model. The measured performance is at least on par with baseline autoregressive models.

![](https://raw.githubusercontent.com/pat-alt/TrillionDollarWords.jl/11-activations-for-cls-head/dev/juliacon/rmse_pca_128.png)

### Intended Purpose

We hope that this small package may be useful to members of the Julia community who are interested in the interplay between Economics, Finance and Artificial Intelligence. It should, for example, be straight-forward to use this package in combination with Transformers.jl to fine-tune additional models on the classification task or other tasks of interest. Any contributions are very much welcome.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-alain2018understanding" class="csl-entry">

Alain, Guillaume, and Yoshua Bengio. 2018. “Understanding Intermediate Layers Using Linear Classifier Probes.” <https://arxiv.org/abs/1610.01644>.

</div>

<div id="ref-shah2023trillion" class="csl-entry">

Shah, Agam, Suvan Paturi, and Sudheer Chava. 2023. “Trillion Dollar Words: A New Financial Dataset, Task & Market Analysis.” <https://arxiv.org/abs/2305.07972>.

</div>

</div>
