# TrillionDollarWords

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://pat-alt.github.io/TrillionDollarWords.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://pat-alt.github.io/TrillionDollarWords.jl/dev/)
[![Build Status](https://github.com/pat-alt/TrillionDollarWords.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/pat-alt/TrillionDollarWords.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/pat-alt/TrillionDollarWords.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/pat-alt/TrillionDollarWords.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This is a small package that facilitates working with the data and model proposed in this ACL 2023 paper: [Trillion Dollar Words: A New Financial Dataset, Task & Market Analysis](https://arxiv.org/abs/2305.07972).

> [!NOTE]  
> I am not the author of that paper nor am I affiliated with the authors of the paper. This package was developed as a by-product of me working with the data and model in Julia.

## Install

The package is not yet registered. In the meantime, you can install it from GitHub:

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

The entire dataset of all available sentences use in the paper can be loaded as follows:

```julia
julia> using TrillionDollarWords
julia> load_all_sentences()
38358×8 DataFrame
   Row │ sentence_id  doc_id  date        event_type        label    sentence                           score     speaker 
       │ Int64        Int64   Date        String31          String7  String                             Float64   String? 
───────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     1 │           1       1  1996-01-30  meeting minutes   neutral  The Committee then turned to a d…  0.999848  missing 
     2 │           2       1  1996-01-30  meeting minutes   neutral  Consumer spending had expanded m…  0.999584  missing 
     3 │           3       1  1996-01-30  meeting minutes   dovish   Slower growth in final sales was…  0.79604   missing 
     4 │           4       1  1996-01-30  meeting minutes   hawkish  The demand for labor was still g…  0.985618  missing 
     5 │           5       1  1996-01-30  meeting minutes   neutral  The recent data on prices and wa…  0.999152  missing 
   ⋮   │      ⋮         ⋮         ⋮              ⋮             ⋮                     ⋮                     ⋮         ⋮
 38354 │       38354      63  2015-09-17  press conference  neutral  And, remember, we’re envisioning…  0.999758  missing 
 38355 │       38355      63  2015-09-17  press conference  neutral  It is true that interest rates a…  0.999809  missing 
 38356 │       38356      63  2015-09-17  press conference  dovish   To me, the main thing that an ac…  0.992719  missing 
 38357 │       38357      63  2015-09-17  press conference  hawkish  And since income inequality is s…  0.998597  missing 
 38358 │       38358      63  2015-09-17  press conference  neutral  There have been a number of stud…  0.999632  missing 
                                                                                                        38348 rows omitted
```

It is also possible to load a larger dataset that combines all sentences with market data used in the paper:

```julia
julia> load_all_data()
524395×11 DataFrame
    Row │ sentence_id  doc_id  date        event_type       label    sentence                           score     speaker                      value    indicator  maturity 
        │ Int64        Int64   Date        String31         String7  String                             Float64   String?                      Float64  String3    String7  
────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
      1 │           1       1  1996-01-30  meeting minutes  neutral  The Committee then turned to a d…  0.999848  missing                        154.7  CPI        missing  
      2 │           2       1  1996-01-30  meeting minutes  neutral  Consumer spending had expanded m…  0.999584  missing                        154.7  CPI        missing  
      3 │           3       1  1996-01-30  meeting minutes  dovish   Slower growth in final sales was…  0.79604   missing                        154.7  CPI        missing  
      4 │           4       1  1996-01-30  meeting minutes  hawkish  The demand for labor was still g…  0.985618  missing                        154.7  CPI        missing  
      5 │           5       1  1996-01-30  meeting minutes  neutral  The recent data on prices and wa…  0.999152  missing                        154.7  CPI        missing  
   ⋮    │      ⋮         ⋮         ⋮              ⋮            ⋮                     ⋮                     ⋮                   ⋮                  ⋮         ⋮         ⋮
 524391 │       29432     125  2022-10-12  speech           hawkish  If we do not see signs that infl…  0.999372  Governor Michelle W. Bowman      3.9  UST        30 Yr
 524392 │       29433     125  2022-10-12  speech           hawkish  However, if inflation starts to …  0.998617  Governor Michelle W. Bowman      3.9  UST        30 Yr
 524393 │       29434     125  2022-10-12  speech           hawkish  To bring inflation down in a con…  0.999456  Governor Michelle W. Bowman      3.9  UST        30 Yr
 524394 │       29435     125  2022-10-12  speech           hawkish  However, it is not yet clear how…  0.999502  Governor Michelle W. Bowman      3.9  UST        30 Yr
 524395 │       29436     125  2022-10-12  speech           hawkish  My general point is that inflati…  0.998271  Governor Michelle W. Bowman      3.9  UST        30 Yr
                                                                                                                                                         524385 rows omitted
```

Additional functionality is available (see [docs](https://www.paltmeyer.com/TrillionDollarWords.jl/dev/)).

### Loading the Model

The model can be loaded with or without the classifier head (below without the head). Under the hood, this function uses [Transformers.jl](https://github.com/chengchingwen/Transformers.jl) to retrieve the model from [HuggingFace](https://huggingface.co/gtfintechlab/FOMC-RoBERTa?text=A+very+hawkish+stance+excerted+by+the+doves). Any keyword arguments accepted by `Transformers.HuggingFace.HGFConfig` can also be passed.

```julia
julia> load_model(; load_head=false, output_hidden_states=true)
@Warn (Transformers.HuggingFacetokenizer_warn): fuse_unk is unsupported, the tokenization result might be slightly different in some cases.                                                                
  │                                                                                                                                                                                                        
  ╰──────────────────────────────────────────────── 
                       Tue, 16 Jan 2024 14:11:50 
 @Warn (Transformers.HuggingFacetokenizer_warn): match token `<mask>` require to match with space on either side but that is not implemented here, the tokenization result might be slightly different      
  │                                             in some cases.                                                                                                                                             
  │                                                                                                                                                                                                        
  ╰──────────────────────────────────────────────── 
                       Tue, 16 Jan 2024 14:11:50 
 BaselineModel(GPT2TextEncoder(
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
), HGFRobertaModel(Chain(CompositeEmbedding(token = Embed(1024, 50265), position = ApplyEmbed(.+, FixedLenPositionEmbed(1024, 514), Transformers.HuggingFace.roberta_pe_indices(1,)), segment = ApplyEmbed(.+, Embed(1024, 1), Transformers.HuggingFace.bert_ones_like)), DropoutLayer<nothing>(LayerNorm(1024, ϵ = 1.0e-5))), Transformer<24>(PostNormTransformerBlock(DropoutLayer<nothing>(SelfAttention(MultiheadQKVAttenOp(head = 16, p = nothing), Fork<3>(Dense(W = (1024, 1024), b = true)), Dense(W = (1024, 1024), b = true))), LayerNorm(1024, ϵ = 1.0e-5), DropoutLayer<nothing>(Chain(Dense(σ = NNlib.gelu, W = (1024, 4096), b = true), Dense(W = (4096, 1024), b = true))), LayerNorm(1024, ϵ = 1.0e-5))), Branch{(:pooled,) = (:hidden_state,)}(BertPooler(Dense(σ = NNlib.tanh_fast, W = (1024, 1024), b = true)))), Transformers.HuggingFace.HGFConfig{:roberta, JSON3.Object{Vector{UInt8}, Vector{UInt64}}, Dict{Symbol, Any}}(:use_cache => true, :torch_dtype => "float32", :vocab_size => 50265, :output_hidden_states => true, :hidden_act => "gelu", :num_hidden_layers => 24, :num_attention_heads => 16, :classifier_dropout => nothing, :type_vocab_size => 1, :intermediate_size => 4096…))
```

### Basic Model Inference

Using the model and data, layer-wise activations can be computed as below (here for the first 5 sentences). When called on a `DataFrame`, the `layerwise_activations` returns a data frame that links activations to sentence identifiers. This makes it possible to relate activations to market data by using the `sentence_id` key. Alternatively, `layerwise_activations` also accepts a vector of sentences.

```julia
julia> df = load_all_sentences();

julia> mod = load_model(; load_head=false, output_hidden_states=true);
@Warn (Transformers.HuggingFacetokenizer_warn): fuse_unk is unsupported, the tokenization result might be slightly different in some cases.                                                                
  │                                                                                                                                                                                                        
  ╰──────────────────────────────────────────────── 
                       Tue, 16 Jan 2024 14:15:46 
 @Warn (Transformers.HuggingFacetokenizer_warn): match token `<mask>` require to match with space on either side but that is not implemented here, the tokenization result might be slightly different      
  │                                             in some cases.                                                                                                                                             
  │                                                                                                                                                                                                        
  ╰──────────────────────────────────────────────── 
                       Tue, 16 Jan 2024 14:15:46 
 
julia> n = 5;

julia> queries = df[1:n, :];
julia> layerwise_activations(mod, queries)
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
   ⋮    │      ⋮            ⋮         ⋮          ⋮
 122875 │           5   0.0957697      24           1019
 122876 │           5   1.04358        24           1020
 122877 │           5   1.71445        24           1021
 122878 │           5   1.162          24           1022
 122879 │           5  -1.58513        24           1023
 122880 │           5  -1.01479        24           1024
                                      122868 rows omitted
```

## `dev` folder

The [dev](/dev/) folder contains source code used to preprocess data sourced from the paper's GitHub [repo](https://github.com/gtfintechlab/fomc-hawkish-dovish) and the HuggingFace model [repo](https://huggingface.co/gtfintechlab/FOMC-RoBERTa?text=A+very+hawkish+stance+excerted+by+the+doves). Preprocessed data is archived as artifacts and uploaded to GitHub releases to make it available to the package itself.
