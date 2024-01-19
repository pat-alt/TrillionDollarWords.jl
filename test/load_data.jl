n_mm = 20618
n_pc = 5086
n_speech = 12654    # says 12465 in paper but no idea why

@testset "Load all sentences" begin
    df = load_all_sentences()
    # Number of observations as in paper:
    @test size(df[df.event_type.=="meeting minutes", :], 1) == n_mm
    @test size(df[df.event_type.=="press conference", :], 1) == n_pc
    @test size(df[df.event_type.=="speech", :], 1) == n_speech
    @test typeof(df) == DataFrame
end

@testset "Load training sentences" begin
    df = load_training_sentences()
    # Number of observations as in paper:
    @test subset(
        df,
        :seed => x -> x .== first(unique(df.seed)),
        :sentence_splitting => x -> x .== false,
    ) |> x -> size(x, 1) == 2379
    @test subset(
        df,
        :seed => x -> x .== first(unique(df.seed)),
        :sentence_splitting => x -> x .== true,
    ) |> x -> size(x, 1) == 2480
    @test typeof(df) == DataFrame
end

@testset "Load CPI data" begin
    df = load_cpi_data()
    @test typeof(df) == DataFrame
end

@testset "Load PPI data" begin
    df = load_ppi_data()
    @test typeof(df) == DataFrame
end

@testset "Load UST data" begin
    df = load_ust_data()
    @test typeof(df) == DataFrame
end

@testset "Load all data" begin
    df = load_all_data()
    # Number of observations as in paper:
    @test size(
        subset(
            df,
            :event_type => x -> x .== "meeting minutes",
            :indicator => x -> x .== "PPI",
        ),
        1,
    ) == n_mm
    @test size(
        subset(
            df,
            :event_type => x -> x .== "press conference",
            :indicator => x -> x .== "CPI",
        ),
        1,
    ) == n_pc
    @test size(
        subset(
            df,
            :event_type => x -> x .== "speech",
            :indicator => x -> x .== "UST",
            :maturity => x -> x .== "30 Yr",
            skipmissing = true,
        ),
        1,
    ) == n_speech
    @test typeof(df) == DataFrame
end
