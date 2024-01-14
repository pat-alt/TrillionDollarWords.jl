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
isdir("dev/data/cleaned/") || mkdir("dev/data/cleaned/")
CSV.write("dev/data/cleaned/all_data.csv", df)