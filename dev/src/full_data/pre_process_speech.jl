using CSV
using DataFrames
using XLSX

# Metadata (master file):
df = CSV.read(joinpath(raw_data_dir, "master_files/master_speech_final.csv"), DataFrame)

# Get the date from the URL:
df[!, "YYYYMMDD"] .= extract_digits.(df.Url)
df[!, "EventType"] .= "speech"

# Get labelled data:
labeled_dir = joinpath(raw_data_dir, "filtered_data/speech_labeled/")
df_labeled = []
for x in readdir(labeled_dir)
    _df = CSV.read(joinpath(labeled_dir, x), DataFrame, drop=[1])
    _df[!, "YYYYMMDD"] .= extract_digits(x)
    push!(df_labeled, _df)
end
df_labeled = vcat(df_labeled...)

# Merge:
df_speech = innerjoin(df, df_labeled, on=:YYYYMMDD) |>
    x -> select(x, [:YYYYMMDD, :EventType, :label, :sentence, :score, :Speaker]) |>
    x -> rename!(x, :YYYYMMDD => :date, :EventType => :event_type, :Speaker => :speaker)

df_speech.event_type .= "speech"