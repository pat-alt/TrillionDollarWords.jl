# TrillionDollarWords

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://pat-alt.github.io/TrillionDollarWords.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://pat-alt.github.io/TrillionDollarWords.jl/dev/)
[![Build Status](https://github.com/pat-alt/TrillionDollarWords.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/pat-alt/TrillionDollarWords.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/pat-alt/TrillionDollarWords.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/pat-alt/TrillionDollarWords.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

This is a small package that facilitates working with the data and model proposed in this ACL 2023 paper: [Trillion Dollar Words: A New Financial Dataset, Task & Market Analysis](https://arxiv.org/abs/2305.07972).

> [!NOTE]  
> I am not the author of that paper nor am I affiliated with the authors of the paper. This package was developed as a by-product of me workign with the data and model in Julia.

## Install

The package is not yet registered. In the meantime, you can install it from GitHub:

``` julia
using Pkg
Pkg.add(url="https://github.com/pat-alt/TrillionDollarWords.jl")
```

## `dev` folder

The [dev](/dev/) folder contains source code used to preprocess data sourced from the paper's GitHub [repo](https://github.com/gtfintechlab/fomc-hawkish-dovish) and the HuggingFace model [repo](https://huggingface.co/gtfintechlab/FOMC-RoBERTa?text=A+very+hawkish+stance+excerted+by+the+doves). Preprocessed data is archived as artifacts and uploaded to GitHub releases to make it available to the package itself.