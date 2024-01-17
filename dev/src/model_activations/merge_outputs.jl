using Arrow
using CSV
using DataFrames
using Tables
using TrillionDollarWords

# Merge:
@info "Merging activations..."
out_dir = "dev/data/activations/intermediate"
merge_dir = "dev/data/activations/merged"
ispath(merge_dir) || mkpath(merge_dir)
writer = open(Arrow.Writer, joinpath(merge_dir, "activations.arrow"))
files_sortperm = sortperm(parse.(Int, filter.(isdigit, readdir(out_dir)[contains.(readdir(out_dir), ".csv")])))
sorted_dir_files = readdir(out_dir)[contains.(readdir(out_dir), ".csv")][files_sortperm] |> unique
for x in sorted_dir_files
    df = CSV.read(joinpath(out_dir, x), DataFrame) |>
        x -> sort!(x, [:sentence_id, :layer, :activation_id])
    Arrow.write(writer, df)
end

# Post-process:
table = Arrow.Table(joinpath(merge_dir, "activations.arrow"))

# Check that all sentences are present:
df_all = load_all_data()
all_ids = unique(df_all.sentence_id) |> sort
q = table.sentence_id |> @unique()
missing_ids = setdiff(all_ids, q)
@assert length(missing_ids) == 0 "The following sentence IDs are missing: $missing_ids."


