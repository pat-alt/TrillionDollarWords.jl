using CSV
using DataFrames
using LazyArtifacts

"""
    load_clean_data()

Load the clean data from the artifact. This is the complete dataset with sentences from press conferences, meeting minutes, and speeches. The labels are predicted by the model proposed in the paper.
"""
load_clean_data() = CSV.read(joinpath(artifact"clean_data","all_data.csv"), DataFrame)


load_training_data() = CSV.read(joinpath(artifact"clean_data","training_data.csv"), DataFrame)