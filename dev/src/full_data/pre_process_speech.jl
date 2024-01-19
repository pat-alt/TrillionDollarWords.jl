using CSV
using DataFrames
using XLSX

# Metadata (master file):
df = CSV.read(joinpath(raw_data_dir, "master_files/master_speech_final.csv"), DataFrame)

# Get the date from the URL:
df = df[length.(extract_digits.(df.LocalPath)).>=8, :]
df[!, "YYYYMMDD"] .= [extract_digits(x)[1:8] for x in df.LocalPath]
transform!(
    df,
    :LocalPath =>
        ByRow(x -> length(extract_digits(x)) == 8 ? "1" : extract_digits(x)[9]) =>
            :date_suffix,
)
df[!, "EventType"] .= "speech"

# Get labelled data:
labeled_dir = joinpath(raw_data_dir, "filtered_data/speech_labeled/")
df_labeled = []
for x in readdir(labeled_dir)
    _df = CSV.read(joinpath(labeled_dir, x), DataFrame, drop = [1])
    _df[!, "YYYYMMDD"] .= extract_digits(x)[1:8]
    _df[!, "date_suffix"] .= length(extract_digits(x)) == 8 ? "1" : extract_digits(x)[9]
    push!(df_labeled, _df)
end
df_labeled = vcat(df_labeled...)

# Subset to 'select' speeches:
selected_path =
    readdir("dev/data/raw/fomc-hawkish-dovish-main/data/raw_data/speech/html/select/")
df = df[[any([contains(x, y) for y in selected_path]) for x in df.LocalPath], :]
df = unique(df, :LocalPath)

# Merge:
df_speech =
    innerjoin(df, df_labeled, on = [:YYYYMMDD, :date_suffix]) |>
    x ->
        transform!(groupby(x, :LocalPath), groupindices => :doc_id) |>
        x ->
            select(
                x,
                [:doc_id, :YYYYMMDD, :EventType, :label, :sentence, :score, :Speaker],
            ) |>
            x ->
                rename!(
                    x,
                    :YYYYMMDD => :date,
                    :EventType => :event_type,
                    :Speaker => :speaker,
                ) |> unique

df_speech.event_type .= "speech"
