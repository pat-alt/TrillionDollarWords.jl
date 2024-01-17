using Arrow
using CSV
using DataFrames
using Dates
using Tables
using TrillionDollarWords

# Merge:
@info "Merging activations..."
out_dir = "dev/data/activations/intermediate"
merge_dir = "dev/data/activations/merged"
ispath(merge_dir) || mkpath(merge_dir)
n_layers = 24
layer_dirs = [joinpath(merge_dir, "layer_$i") for i in 1:n_layers]
ispath.(layer_dirs) .|| mkpath.(layer_dirs)
writers = [open(Arrow.Writer, joinpath(i, "activations.arrow")) for i in layer_dirs]
files_sortperm = sortperm(parse.(Int, filter.(isdigit, readdir(out_dir)[contains.(readdir(out_dir), ".csv")])))
sorted_dir_files = readdir(out_dir)[contains.(readdir(out_dir), ".csv")][files_sortperm] |> unique
for x in sorted_dir_files
    df = CSV.read(joinpath(out_dir, x), DataFrame) |>
        x -> sort!(x, [:sentence_id, :layer, :activation_id])
    for layer in 1:n_layers
        writer = writers[layer]
        df_layer = df[df.layer .== layer, :]
        Arrow.write(writer, df_layer)
    end
end

# Upload: 
for layer in 1:n_layers
    layer_dir = layer_dirs[layer]
    artifact_id = artifact_from_directory(layer_dir)
    release = upload_to_release(artifact_id; tag="activations_$(today())")
    add_artifact!("Artifacts.toml", "activations_layer_$layer", release; force=true)
end