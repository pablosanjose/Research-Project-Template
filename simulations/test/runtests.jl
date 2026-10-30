using Test
using MyPaperPackage

@testset "MyPaperPackage" begin
    model = build_model()
    @test observable(model, 0.0, 0.0) == 0.0
    @test observable(build_model(; disorder = 0.1), 0.5, 0.5) != observable(model, 0.5, 0.5)
end
