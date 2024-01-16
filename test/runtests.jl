using DataFrames
import Transformers
using TrillionDollarWords
using Test

@testset "TrillionDollarWords.jl" begin
    @testset "Load data" begin
        include("load_data.jl")
    end

    @testset "Load model" begin
        include("load_model.jl")
    end

end
