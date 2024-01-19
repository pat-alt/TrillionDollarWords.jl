market_data_dir = joinpath(raw_data_dir, "market_analysis_data")
clean_market_data_dir = joinpath(clean_dir, "market_data")
isdir(clean_market_data_dir) || mkdir(clean_market_data_dir)

# CPI data:
df_cpi =
    CSV.read("$market_data_dir/CPIAUCSL.csv", DataFrame) |>
    x -> rename!(x, :DATE => :date, :CPIAUCSL => :value)
df_cpi.indicator .= "CPI"
# CPI data is monthly, so we need to fill in the missing dates:
df_cpi = sort(outerjoin(ALL_EVENT_TIMES, df_cpi, on = :date), :date)
transform!(df_cpi, names(df_cpi) .=> Impute.locf, renamecols = false)
CSV.write("$clean_market_data_dir/cpi.csv", df_cpi)

# PPI data:
df_ppi =
    CSV.read("$market_data_dir/PPIACO.csv", DataFrame) |>
    x -> rename!(x, :DATE => :date, :PPIACO => :value)
df_ppi.indicator .= "PPI"
# PPI data is monthly, so we need to fill in the missing dates:
df_ppi = sort(outerjoin(ALL_EVENT_TIMES, df_ppi, on = :date), :date)
transform!(df_ppi, names(df_ppi) .=> Impute.locf, renamecols = false)
CSV.write("$clean_market_data_dir/ppi.csv", df_ppi)

# Treasury yield data:
df_ust =
    CSV.read("$market_data_dir/daily-treasury-rates.csv", DataFrame) |>
    x ->
        rename!(x, :Date => :date) |>
        x ->
            transform(x, :date => ByRow(x -> replace(x, "/" => "-")) => :date) |>
            x ->
                transform(x, :date => ByRow(x -> Date(x, "mm-dd-yyyy")) => :date) |>
                x -> stack(x, Not(:date), variable_name = :maturity, value_name = :value)
df_ust.indicator .= "UST"
# UST data is daily, but may not be available on weekends, so we need to fill in the missing dates:
df_ust = sort(outerjoin(ALL_EVENT_TIMES, df_ust, on = :date), :date)
transform!(df_ust, names(df_ust) .=> Impute.locf, renamecols = false)
CSV.write("$clean_market_data_dir/ust.csv", df_ust)

df_combined = vcat(df_cpi, df_ppi, df_ust, cols = :union)
CSV.write("$clean_market_data_dir/combined.csv", df_combined)
