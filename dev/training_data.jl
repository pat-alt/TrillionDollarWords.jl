# Get data from the web and save it to a file
include("get_data.jl")

train_data_root = joinpath(raw_data_root, "fomc-hawkish-dovish-main/training_data/test-and-training/")
train_dir = joinpath(train_data_root, "training_data")
test_dir = joinpath(train_data_root, "test_data")

# Training data:
df_train = Vector{DataFrame}()
for x in readdir(train_dir)
    xf = XLSX.readxlsx(joinpath(train_dir, x))
    m = xf[1][:]
    df = DataFrame(m[2:end, :], m[1, :])
    df[!, "seed"] .= extract_digits(x)
    push!(df_train, df)
end
df_train = reduce(vcat, df_train, cols=:union)
df_train[!,"split"] .= "train"

# Test data:
df_test = Vector{DataFrame}()
for x in readdir(test_dir)
    xf = XLSX.readxlsx(joinpath(test_dir, x))
    m = xf[1][:]
    df = DataFrame(m[2:end, :], m[1, :])
    df[!, "seed"] .= extract_digits(x)
    push!(df_test, df)
end
df_test = reduce(vcat, df_test, cols=:union)
df_test[!,"split"] .= "test"

# Merge:
df = vcat(df_train, df_test)
CSV.write("dev/data/cleaned/training_data.csv", df)
