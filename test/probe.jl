# All data:
all_data = load_all_data()

# Inflation:
indicator = "PPI"
mkt_data = subset(all_data, :indicator => x -> x .== indicator)

X, y = prepare_probe(mkt_data, value_var=:value)

@test true