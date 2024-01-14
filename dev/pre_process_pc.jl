using CSV
using DataFrames
using XLSX

# Metadata (master file):
xf = XLSX.readxlsx(joinpath(raw_data_dir, "master_files/master_pc_final.xlsx"))
m = xf[1][:]
df = DataFrame(m[2:end, :], m[1, :])

# Get the date from the URL:
df[!, "YYYYMMDD"] .= extract_digits.(df.Url)

# Get labelled data:
labeled_dir = joinpath(raw_data_dir, "filtered_data/press_conference_labeled/")
df_labeled = DataFrame()
for x in readdir(labeled_dir)
    _df = CSV.read(joinpath(labeled_dir, x), DataFrame, drop=[1])
    _df[!, "YYYYMMDD"] .= extract_digits(x)
    df_labeled = vcat(df_labeled, _df)
end

# Merge:
df_pc = innerjoin(df, df_labeled, on=:YYYYMMDD) |>
    x -> select(x, [:YYYYMMDD, :EventType, :label, :sentence, :score]) |>
    x -> rename!(x, :YYYYMMDD => :date, :EventType => :event_type) 

df_pc.event_type .= "press conference"