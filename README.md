# TrillionDollarWords


[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://pat-alt.github.io/TrillionDollarWords.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://pat-alt.github.io/TrillionDollarWords.jl/dev/) [![Build Status](https://github.com/pat-alt/TrillionDollarWords.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/pat-alt/TrillionDollarWords.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/pat-alt/TrillionDollarWords.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/pat-alt/TrillionDollarWords.jl) [![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This is a small package that facilitates working with the data and model proposed in this ACL 2023 paper: [Trillion Dollar Words: A New Financial Dataset, Task & Market Analysis](https://arxiv.org/abs/2305.07972) (Shah, Paturi, and Chava 2023).

> \[!NOTE\]  
> I am not the author of that paper nor am I affiliated with the authors of the paper. This package was developed as a by-product of me working with the data and model in Julia.

## Install

You can install the package from Julia’s general registry as follows:

``` julia
using Pkg
Pkg.add("TrillionDollarWords")
```

To install the development version, use the following command:

``` julia
using Pkg
Pkg.add(url="https://github.com/pat-alt/TrillionDollarWords.jl")
```

## Basic Functionality

The package provides the following functionality:

- Load pre-processed data.
- Load the model proposed in the paper.
- Basic model inference: compute forward passes and layer-wise activations.

The latter is particularly useful for downstream tasks related to [mechanistic interpretability](https://en.wikipedia.org/wiki/Large_language_model#Interpretation).

### Loading the Data

The entire dataset of all available sentences used in the paper can be loaded as follows:

``` julia
using TrillionDollarWords
load_all_sentences() |> show
```

    38358×8 DataFrame
       Row │ sentence_id  doc_id  date        event_type        label    sentence  ⋯
           │ Int64        Int64   Date        String31          String7  String    ⋯
    ───────┼────────────────────────────────────────────────────────────────────────
         1 │           1       1  1996-01-30  meeting minutes   neutral  The Commi ⋯
         2 │           2       1  1996-01-30  meeting minutes   neutral  Consumer
         3 │           3       1  1996-01-30  meeting minutes   dovish   Slower gr
         4 │           4       1  1996-01-30  meeting minutes   hawkish  The deman
         5 │           5       1  1996-01-30  meeting minutes   neutral  The recen ⋯
         6 │           6       1  1996-01-30  meeting minutes   neutral  Nonfarm p
         7 │           7       1  1996-01-30  meeting minutes   hawkish  Job growt
         8 │           8       1  1996-01-30  meeting minutes   hawkish  Elsewhere
         9 │           9       1  1996-01-30  meeting minutes   neutral  The outpu ⋯
        10 │          10       1  1996-01-30  meeting minutes   neutral  Recent in
        11 │          11       1  1996-01-30  meeting minutes   hawkish  Incoming
       ⋮   │      ⋮         ⋮         ⋮              ⋮             ⋮               ⋱
     38349 │       38349      63  2015-09-17  press conference  dovish   monetary
     38350 │       38350      63  2015-09-17  press conference  neutral  When we—w ⋯
     38351 │       38351      63  2015-09-17  press conference  neutral  It’s one
     38352 │       38352      63  2015-09-17  press conference  neutral  1 Chair Y
     38353 │       38353      63  2015-09-17  press conference  neutral  It remain
     38354 │       38354      63  2015-09-17  press conference  neutral  And, reme ⋯
     38355 │       38355      63  2015-09-17  press conference  neutral  It is tru
     38356 │       38356      63  2015-09-17  press conference  dovish   To me, th
     38357 │       38357      63  2015-09-17  press conference  hawkish  And since
     38358 │       38358      63  2015-09-17  press conference  neutral  There hav ⋯
                                                    3 columns and 38337 rows omitted

It is also possible to load a larger dataset that combines all sentences with market data used in the paper:

``` julia
load_all_data() |> show
```

    524395×11 DataFrame
        Row │ sentence_id  doc_id  date        event_type       label    sentence  ⋯
            │ Int64        Int64   Date        String31         String7  String    ⋯
    ────────┼───────────────────────────────────────────────────────────────────────
          1 │           1       1  1996-01-30  meeting minutes  neutral  The Commi ⋯
          2 │           2       1  1996-01-30  meeting minutes  neutral  Consumer
          3 │           3       1  1996-01-30  meeting minutes  dovish   Slower gr
          4 │           4       1  1996-01-30  meeting minutes  hawkish  The deman
          5 │           5       1  1996-01-30  meeting minutes  neutral  The recen ⋯
          6 │           6       1  1996-01-30  meeting minutes  neutral  Nonfarm p
          7 │           7       1  1996-01-30  meeting minutes  hawkish  Job growt
          8 │           8       1  1996-01-30  meeting minutes  hawkish  Elsewhere
          9 │           9       1  1996-01-30  meeting minutes  neutral  The outpu ⋯
         10 │          10       1  1996-01-30  meeting minutes  neutral  Recent in
         11 │          11       1  1996-01-30  meeting minutes  hawkish  Incoming
       ⋮    │      ⋮         ⋮         ⋮              ⋮            ⋮               ⋱
     524386 │       29435     125  2022-10-12  speech           hawkish  However,
     524387 │       29436     125  2022-10-12  speech           hawkish  My genera ⋯
     524388 │       29429     125  2022-10-12  speech           neutral  I will fo
     524389 │       29430     125  2022-10-12  speech           hawkish  Inflation
     524390 │       29431     125  2022-10-12  speech           neutral  At this p
     524391 │       29432     125  2022-10-12  speech           hawkish  If we do  ⋯
     524392 │       29433     125  2022-10-12  speech           hawkish  However,
     524393 │       29434     125  2022-10-12  speech           hawkish  To bring
     524394 │       29435     125  2022-10-12  speech           hawkish  However,
     524395 │       29436     125  2022-10-12  speech           hawkish  My genera ⋯
                                                   6 columns and 524374 rows omitted

Additional functionality for data loading is available (see [docs](https://www.paltmeyer.com/TrillionDollarWords.jl/dev/)).

### Loading the Model

The model can be loaded with or without the classifier head (below without the head). Under the hood, this function uses [Transformers.jl](https://github.com/chengchingwen/Transformers.jl) to retrieve the model from [HuggingFace](https://huggingface.co/gtfintechlab/FOMC-RoBERTa?text=A+very+hawkish+stance+excerted+by+the+doves). Any keyword arguments accepted by `Transformers.HuggingFace.HGFConfig` can also be passed.

``` julia
load_model(; load_head=false, output_hidden_states=true) |> show
```

    BaselineModel(AbstractTransformerTextEncoder(
    ├─ TextTokenizer(MatchTokenization(CodeNormalizer(BPETokenization(GPT2Tokenization, bpe = CachedBPE(BPE(50000 merges))), codemap = CodeMap{UInt8 => UInt16}(3 code-ranges)), 5 patterns)),
    ├─ vocab = Vocab{String, SizedArray}(size = 50265, unk = <unk>, unki = 4),
    ├─ codemap = CodeMap{UInt8 => UInt16}(3 code-ranges),
    ├─ startsym = <s>,
    ├─ endsym = </s>,
    ├─ padsym = <pad>,
    ├─ trunc = 256,
    └─ process = Pipelines:
      ╰─ target[token] := TextEncodeBase.nestedcall(string_getvalue, source)
      ╰─ target[token] := Transformers.TextEncoders.grouping_sentence(target.token)
      ╰─ target[(token, segment)] := SequenceTemplate{String}(<s>:<type=1> Input:<type=1> </s>:<type=1> (</s>:<type=1> Input:<type=1> </s>:<type=1>)...)(target.token)
      ╰─ target[attention_mask] := (NeuralAttentionlib.LengthMask ∘ Transformers.TextEncoders.getlengths(256))(target.token)
      ╰─ target[token] := TextEncodeBase.trunc_or_pad(256, <pad>, tail, tail)(target.token)
      ╰─ target[token] := TextEncodeBase.nested2batch(target.token)
      ╰─ target := (target.token, target.attention_mask)
    ), HGFRobertaModel(Chain(CompositeEmbedding(token = Embed(1024, 50265), position = ApplyEmbed(.+, FixedLenPositionEmbed(1024, 514), Transformers.HuggingFace.roberta_pe_indices(1,)), segment = ApplyEmbed(.+, Embed(1024, 1), Transformers.HuggingFace.bert_ones_like)), DropoutLayer<nothing>(LayerNorm(1024, ϵ = 1.0e-5))), Transformer<24>(PostNormTransformerBlock(DropoutLayer<nothing>(SelfAttention(MultiheadQKVAttenOp(head = 16, p = nothing), Fork<3>(Dense(W = (1024, 1024), b = true)), Dense(W = (1024, 1024), b = true))), LayerNorm(1024, ϵ = 1.0e-5), DropoutLayer<nothing>(Chain(Dense(σ = NNlib.gelu, W = (1024, 4096), b = true), Dense(W = (4096, 1024), b = true))), LayerNorm(1024, ϵ = 1.0e-5))), Branch{(:pooled,) = (:hidden_state,)}(BertPooler(Dense(σ = NNlib.tanh_fast, W = (1024, 1024), b = true)))), Transformers.HuggingFace.HGFConfig{:roberta, JSON3.Object{Vector{UInt8}, Vector{UInt64}}, Dict{Symbol, Any}}(:use_cache => true, :torch_dtype => "float32", :vocab_size => 50265, :output_hidden_states => true, :hidden_act => "gelu", :num_hidden_layers => 24, :num_attention_heads => 16, :classifier_dropout => nothing, :type_vocab_size => 1, :intermediate_size => 4096, :max_position_embeddings => 514, :model_type => "roberta", :layer_norm_eps => 1.0e-5, :id2label => Dict(0 => "LABEL_0", 2 => "LABEL_2", 1 => "LABEL_1"), :_name_or_path => "roberta-large", :hidden_size => 1024, :transformers_version => "4.21.2", :attention_probs_dropout_prob => 0.1, :bos_token_id => 0, :problem_type => "single_label_classification", :eos_token_id => 2, :initializer_range => 0.02, :hidden_dropout_prob => 0.1, :label2id => Dict("LABEL_1" => 1, "LABEL_2" => 2, "LABEL_0" => 0), :pad_token_id => 1, :position_embedding_type => "absolute", :architectures => ["RobertaForSequenceClassification"]))

### Basic Model Inference

Using the model and data, layer-wise activations can be computed as below (here for the first 5 sentences). When called on a `DataFrame`, the `layerwise_activations` returns a data frame that links activations to sentence identifiers. This makes it possible to relate activations to market data by using the `sentence_id` key. Alternatively, `layerwise_activations` also accepts a vector of sentences.

``` julia
df = load_all_sentences()
mod = load_model(; load_head=false, output_hidden_states=true)
n = 5
queries = df[1:n, :]
layerwise_activations(mod, queries) |> show
```

    122880×4 DataFrame
        Row │ sentence_id  activations  layer  activation_id 
            │ Int64        Float32      Int64  Int64         
    ────────┼────────────────────────────────────────────────
          1 │           1   0.202931        1              1
          2 │           1  -0.00693996      1              2
          3 │           1   0.12731         1              3
          4 │           1  -0.0129803       1              4
          5 │           1   0.122843        1              5
          6 │           1   0.258675        1              6
          7 │           1   0.0466324       1              7
          8 │           1   0.0318548       1              8
          9 │           1   1.18888         1              9
         10 │           1  -0.0386651       1             10
         11 │           1  -0.116031        1             11
       ⋮    │      ⋮            ⋮         ⋮          ⋮
     122871 │           5  -0.769513       24           1015
     122872 │           5   0.834678       24           1016
     122873 │           5   0.212098       24           1017
     122874 │           5  -0.556661       24           1018
     122875 │           5   0.0957697      24           1019
     122876 │           5   1.04358        24           1020
     122877 │           5   1.71445        24           1021
     122878 │           5   1.162          24           1022
     122879 │           5  -1.58513        24           1023
     122880 │           5  -1.01479        24           1024
                                          122859 rows omitted

## Probe Findings

For our own [research](https://arxiv.org/abs/2402.03962) (Altmeyer et al. 2024), we have been interested in probing the model. This involves using linear models to estimate the relationship between layer-wise transformer embeddings and some outcome variable of interest (Alain and Bengio 2018). To do this, we first had to run a single forward pass for each sentence through the RoBERTa model and store the layerwise emeddings. As we have seen above, the package ships with functionality for doing just that, but to save others valuable GPU hours we have archived activations of the hidden state on the first entity token for each layer as [artifacts](https://github.com/pat-alt/TrillionDollarWords.jl/releases/tag/activations_2024-01-17). To download the last-layer activations in an interactive Julia session, for example, users can proceed as follows:

``` julia
using LazyArtifacts

julia> artifact"activations_layer_24"
```

We have found that despite the small sample size, the RoBERTa model appears to have distilled useful representations for downstream tasks that it was not explicitly trained for. The chart below shows the average out-of-sample root mean squared error for predicting various market indicators from layer activations. Consistent with findings in related work (Alain and Bengio 2018), we find that performance typically improves for layers closer to the final output layer of the transformer model. The measured performance is at least on par with baseline autoregressive models.

![](https://raw.githubusercontent.com/pat-alt/TrillionDollarWords.jl/11-activations-for-cls-head/dev/juliacon/rmse_pca_128.png)

## Intended Purpose and Goals

We hope that this small package may be useful to members of the Julia community who are interested in the interplay between Economics, Finance and Artificial Intelligence. It should serve as a good starting point for the following ideas:

- Fine-tune additional models on the classification task or other tasks of interest.
- Further model probing, e.g. using other market indicators not discussed in the original paper.
- Improve and extend the label annotations.

Any contributions are very much welcome.

## `dev` folder

The [dev](/dev/) folder contains source code used to preprocess data sourced from the paper’s GitHub [repo](https://github.com/gtfintechlab/fomc-hawkish-dovish) and the HuggingFace model [repo](https://huggingface.co/gtfintechlab/FOMC-RoBERTa?text=A+very+hawkish+stance+excerted+by+the+doves). Preprocessed data is archived as artifacts and uploaded to GitHub releases to make it available to the package itself.

## References

Alain, Guillaume, and Yoshua Bengio. 2018. “Understanding Intermediate Layers Using Linear Classifier Probes.” <https://arxiv.org/abs/1610.01644>.

Altmeyer, Patrick, Andrew M. Demetriou, Antony Bartlett, and Cynthia C. S. Liem. 2024. “Position Paper: Against Spurious Sparks-Dovelating Inflated AI Claims.” <https://arxiv.org/abs/2402.03962>.

Shah, Agam, Suvan Paturi, and Sudheer Chava. 2023. “Trillion Dollar Words: A New Financial Dataset, Task & Market Analysis.” <https://arxiv.org/abs/2305.07972>.
