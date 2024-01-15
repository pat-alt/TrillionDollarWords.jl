using CSV
using DataFrames
using LazyArtifacts

"""
    load_all_data()

Load the dataset with all sentences from the artifact. This is the complete dataset with sentences from press conferences, meeting minutes, and speeches. The labels are predicted by the model proposed in the paper.
"""
load_all_sentences() = CSV.read(joinpath(artifact"clean_data","all_sentences.csv"), DataFrame)


load_training_sentences() = CSV.read(joinpath(artifact"clean_data","training_sentences.csv"), DataFrame)