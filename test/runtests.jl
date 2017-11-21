import WebFunc
using Base.Test

f = d -> sqrt(d["a"])

@test length(WebFunc.Mapping()) == 0

m = WebFunc.Mapping()
u = WebFunc.expose!(m, f, Number)
@test Base.Random.uuid_version(u) == 4
@test length(m) == 1
