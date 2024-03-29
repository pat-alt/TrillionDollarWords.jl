using CSV
using DataFrames
using XLSX

# Metadata (master file):
xf = XLSX.readxlsx(joinpath(raw_data_dir, "master_files/master_mm_final.xlsx"))
m = xf[1][:]
df = DataFrame(m[2:end, :], m[1, :])

# Get the date from the URL:
df[!, "YYYYMMDD"] .= extract_digits.(df.Url)

# Get labelled data:
labeled_dir = joinpath(raw_data_dir, "filtered_data/meeting_minutes_labeled/")
df_labeled = []
for x in readdir(labeled_dir)
    _df = CSV.read(joinpath(labeled_dir, x), DataFrame, drop = [1])
    _df[!, "YYYYMMDD"] .= extract_digits(x)
    push!(df_labeled, _df)
end
df_labeled = vcat(df_labeled...)

# Merge:
df_mm =
    innerjoin(df, df_labeled, on = :YYYYMMDD) |>
    x ->
        transform!(groupby(x, :Url), groupindices => :doc_id) |>
        x ->
            select(x, [:doc_id, :YYYYMMDD, :EventType, :label, :sentence, :score]) |>
            x -> rename!(x, :YYYYMMDD => :date, :EventType => :event_type)

df_mm.event_type .= "meeting minutes"
