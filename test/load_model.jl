@testset "Model" begin

    @testset "with head" begin
        tkr, mod = load_model()
        @test typeof(tkr) <: Transformers.TextEncoders.GPT2TextEncoder
        @test typeof(mod) <: Transformers.HuggingFace.HGFRobertaForSequenceClassification
        @test hasfield(typeof(mod), :cls)
    end

    @testset "without head" begin
        tkr, mod = load_model(load_head=false)
        @test typeof(tkr) <: Transformers.TextEncoders.GPT2TextEncoder
        @test typeof(mod) <: Transformers.HuggingFace.HGFRobertaModel
        @test !hasfield(typeof(mod), :cls)
    end

end

@testset "Outputs" begin
    @test true
end