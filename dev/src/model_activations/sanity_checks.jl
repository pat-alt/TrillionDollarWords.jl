# Post-process:
table = Arrow.Table(joinpath(merge_dir, "activations.arrow"))

# Check that all sentences are present:
df_all = load_all_data()
all_ids = unique(df_all.sentence_id) |> sort
q = table.sentence_id |> @unique()
missing_ids = setdiff(all_ids, q)
@assert length(missing_ids) == 0 "The following sentence IDs are missing: $missing_ids."