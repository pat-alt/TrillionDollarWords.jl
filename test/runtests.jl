using DataFrames
import Transformers
using TrillionDollarWords
using Test

ENV["JULIA_SSL_NO_VERIFY_HOSTS"] = "github.com"

@testset "TrillionDollarWords.jl" begin
    @testset "Load data" begin
        include("load_data.jl")
    end

    @testset "Load model" begin
        include("load_model.jl")
    end

    @testset "Probing" begin
        include("probe.jl")
    end

end
