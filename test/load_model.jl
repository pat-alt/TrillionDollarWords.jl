@testset "Model" begin

    @testset "with head" begin
        mod_cls = load_model()
        @test typeof(mod_cls) == BaselineModel
        @test typeof(mod_cls.tkr) <: Transformers.TextEncoders.GPT2TextEncoder
        @test typeof(mod_cls.mod) <: Transformers.HuggingFace.HGFRobertaForSequenceClassification
        @test hasfield(typeof(mod_cls.mod), :cls)
    end

    @testset "without head" begin
        mod = load_model(;load_head=false)
        @test typeof(mod) == BaselineModel
        @test typeof(mod.tkr) <: Transformers.TextEncoders.GPT2TextEncoder
        @test typeof(mod.mod) <: Transformers.HuggingFace.HGFRobertaModel
        @test !hasfield(typeof(mod.mod), :cls)
    end

end

@testset "Outputs" begin
    df = load_all_sentences()
    n = 2
    queries = df[1:n, :]
    @testset "Simple forward pass" begin
        emb = mod(queries.sentence)
        @test haskey(emb, :pooled)
        @test size(emb.pooled, 2) == n
        logits = mod_cls(queries.sentence)
        @test size(logits.logit) == (3, n)
    end

    @testset "Activations" begin
        
        @testset "To array" begin
            A = layerwise_activations(mod, queries.sentence)
            @test size(A, 2) == n
            A_cls = layerwise_activations(mod_cls, queries.sentence)
            @test size(A_cls, 2) == n
            @test isequal(A, A_cls)
        end

        @testset "To data frame" begin
            A = layerwise_activations(mod, queries)
            A_cls = layerwise_activations(mod_cls, queries)
            @test isequal(A, A_cls)
        end

    end
end