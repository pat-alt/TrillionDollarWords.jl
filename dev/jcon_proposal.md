# Trillion Dollar Words in Julia

**Abstract**: [TrillionDollarWorlds.jl](https://github.com/pat-alt/TrillionDollarWords.jl) streamlines access to a novel financial dataset and language model presented in this [ACL 2023 paper](https://arxiv.org/abs/2305.07972). It ships with essential functionality for model probing, an important aspect of mechanistic interpretability. 

## Description

In the wake of recent rapid advances in artificial intelligence (AI), it is more crucial than ever to ensure that the technologies we deploy are trustworthy. Efforts surrounding [Taija](https://github.com/JuliaTrustworthyAI) have so far centered around explainability and uncertainty quantification for supervised machine learning models. [CounterfactualExplanations.jl](https://github.com/JuliaTrustworthyAI/CounterfactualExplanations.jl), for example, is a comprehensive package for generating counterfactual explanations for models trained in [Flux.jl](https://fluxml.ai/Flux.jl/dev/), [MLJ.jl](https://alan-turing-institute.github.io/MLJ.jl/dev/) and more. 

### 🌐 Why supercomputing?

In practice, we are often required to generate many explanations for many individuals. A firm that is using a machine learning model to screen out job applicants, for example, might be required to explain to each unsuccessful applicant why they were not admitted to the interview stage. In a different context, researchers may need to generate many explanations for [evaluation](https://juliatrustworthyai.github.io/CounterfactualExplanations.jl/stable/tutorials/evaluation/) and [benchmarking](https://juliatrustworthyai.github.io/CounterfactualExplanations.jl/stable/tutorials/benchmarking/) purposes. In both cases, the involved computational tasks can be parallelized through multi-threading or distributed computing. 

### 🤔 How supercomputing?

For this purpose, we have recently released [TaijaParallel.jl](https://github.com/JuliaTrustworthyAI/TaijaParallel.jl): a lightweight package that adds custom support for [parallelization](https://juliatrustworthyai.github.io/CounterfactualExplanations.jl/stable/tutorials/parallelization/) to Taija packages. Our goal has been to minimize the burden on users by facilitating different forms of parallelization through a simple macro. To multi-process the evaluation of a large set of `counterfactuals` using the [MPI.jl](https://juliaparallel.org/MPI.jl/latest/) backend, for example, users can proceed as follows: firstly, load the backend and instantiate the `MPIParallelizer`,

```julia
using CounterfactualExplanations, TaijaParallel
import MPI
MPI.Init()
parallelizer = MPIParallelizer(MPI.COMM_WORLD)
```

and then just use the `@with_parallelizer` macro followed by the `parallelizer` object and the standard API call to evaluate counterfactuals:

```julia
@with_parallelizer parallelizer evaluate(counterfactuals)
```

Under the hood, we use standard [MPI.jl](https://juliaparallel.org/MPI.jl/latest/) routines for distributed computing. To avoid depending on [MPI.jl](https://juliaparallel.org/MPI.jl/latest/) we use [package extensions](https://www.youtube.com/watch?v=TiIZlQhFzyk). Similarly, the `ThreadsParallelizer` can be used for multi-threading where we rely on `Base.Threads` routines. It is also possible to combine both forms of parallelization.

### 🏅 Benchmarking Counterfactuals (case study)

This new functionality has already powered [research](https://arxiv.org/abs/2312.10648) that will be published at AAAI 2024. The project involved large benchmarks of counterfactual explanations that had to be run on a supercomputer. During the talk, we will use this as a case study to discuss the challenges we encountered along the way and the solutions we have come up with. 

### 🎯 What is next?

While we have so far focused on [CounterfactualExplanations.jl](), parallelization is also useful for other Taija packages. For example, some of the methods for predictive uncertainty quantification used by [ConformalPrediction.jl](https://github.com/JuliaTrustworthyAI/ConformalPrediction.jl) rely on repeated model training and prediction. This is currently done sequentially and represents an obvious opportunity for parallelization. 

### 👥 Who is this talk for?

This talk should be useful for anyone interested in either trustworthy AI or parallel computing or both. We are not experts in parallel computing, so the level of this talk should also be appropriate for beginners. 

## Notes