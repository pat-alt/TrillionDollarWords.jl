# Meeting minutes data:
include("pre_process_mm.jl")

# Speech data:
include("pre_process_speech.jl")

# Press conference data:
include("pre_process_pc.jl")

# Merge:
df = vcat(df_mm, df_speech, df_pc, cols=:union)
df.date = Dates.Date.(df.date, "yyyymmdd")

# Save:
CSV.write("$clean_dir/all_sentences.csv", df)

# Market data:
include("market_data.jl")

# Merge:
df = vcat(df, df_combined, cols=:union)

