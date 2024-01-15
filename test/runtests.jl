using DataFrames
using TrillionDollarWords
using Test

@testset "TrillionDollarWords.jl" begin
    @testset "Load data" begin
        include("load_data.jl")
    end

end
