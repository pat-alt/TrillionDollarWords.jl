using CategoricalArrays
using DataFrames
using Dates
using Impute
using TrillionDollarWords


# Setup:
OVERWRITE = "overwrite" in ARGS
clean_dir = "dev/data/cleaned/"
isdir(clean_dir) || mkdir(clean_dir)

# Get data from the web and save it to a file
include("get_data.jl")

# Utils:
include("utils.jl")

# Full data:
include("full_data/full_data.jl")

# Training data:
include("training_data.jl")

# Model outputs:
include("model_outputs.jl")

# Artifacts:
artifact_id = artifact_from_directory("dev/data/cleaned")
release = upload_to_release(artifact_id)
add_artifact!("Artifacts.toml", "clean_data", release; force=true)