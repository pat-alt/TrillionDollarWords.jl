# Meeting minutes data:
include("pre_process_mm.jl")

# Speech data:
include("pre_process_speech.jl")

# Press conference data:
include("pre_process_pc.jl")

# Merge:
df = vcat(df_mm, df_speech, df_pc, cols=:union)
df.date = Dates.Date.(df.date, "yyyymmdd")

# Transform label column
df.label = convert.(String, df.label)
df.label = categorical(df.label)
replace!(df.label, "LABEL_0" => "dovish", "LABEL_1" => "hawkish", "LABEL_2" => "neutral")

# Save:
CSV.write("$clean_dir/all_sentences.csv", df)

# Market data:
include("market_data.jl")

# Merge:
df = innerjoin(df, df_combined, on=:date) |>
    x -> sort!(x, [:date, :event_type]) 

# Save:
CSV.write("$clean_dir/all_data.csv", df)

