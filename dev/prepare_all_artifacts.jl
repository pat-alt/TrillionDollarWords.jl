using Dates

# Get data from the web and save it to a file
OVERWRITE = "overwrite" in ARGS
include("get_data.jl")

# Utils:
include("utils.jl")

# Full data:
include("full_data.jl")

# Training data:
include("training_data.jl")

# Artifacts:
artifact_id = artifact_from_directory("dev/data/cleaned")
release = upload_to_release(artifact_id)
add_artifact!("Artifacts.toml", "clean_data", release)