# Get data from the web and save it to a file
include("get_data.jl")

train_data_root = joinpath(raw_data_root, "fomc-hawkish-dovish-main/training_data/test-and-training/")
train_dir = joinpath(train_data_root, "training_data")
test_dir = joinpath(train_data_root, "test_data")

# Training data:
df_train = Vector{DataFrame}()
for x in readdir(train_dir)
    contains(x, "combine") && continue
    _xf = XLSX.readxlsx(joinpath(train_dir, x))
    _m = _xf[1][:]
    _df = DataFrame(_m[2:end, :], _m[1, :])
    _df[!, "seed"] .= extract_digits(x)
    _df[!, "sentence_splitting"] .= contains(x, "split")
    _df[!, "event_type"] .= contains(x, "-sp-") ? "speech" : contains(x, "-pc-") ? "press conference" : "meeting minutes"
    push!(df_train, _df)
end
df_train = reduce(vcat, df_train, cols=:union)
df_train[!,"split"] .= "train"

# Test data:
df_test = Vector{DataFrame}()
for x in readdir(test_dir)
    contains(x, "combine") && continue
    _xf = XLSX.readxlsx(joinpath(test_dir, x))
    _m = _xf[1][:]
    _df = DataFrame(_m[2:end, :], _m[1, :])
    _df[!, "seed"] .= extract_digits(x)
    _df[!, "sentence_splitting"] .= contains(x, "split")
    _df[!, "event_type"] .= contains(x, "-sp-") ? "speech" : contains(x, "-pc-") ? "press conference" : "meeting minutes"
    push!(df_test, _df)
end
df_test = reduce(vcat, df_test, cols=:union)
df_test[!,"split"] .= "test"

# Merge:
df = vcat(df_train, df_test)
select!(df, Not([:orig_index]))
sort!(df, [:year, :seed, :event_type])

# Transform label column:
replace!(df.label, 0 => "dovish", 1 => "hawkish", 2 => "neutral")
df.label = categorical(df.label)

CSV.write("dev/data/cleaned/training_sentences.csv", df)
