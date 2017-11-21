import WebFunc
using Base.Test

f = d -> sqrt(d["a"])
f1 = d -> d["a"] * d["a"]
fadd = d -> d["a"] + d["a"]

input_f = Dict("a" => 0.42)
test_input = Dict("a" => 4)

@test length(WebFunc.Mapping()) == 0

m = WebFunc.Mapping()
u = WebFunc.expose!(m, f, Dict{String,Number})
@test Base.Random.uuid_version(u) == 4
@test length(m) == 1

multi_func_map = WebFunc.Mapping()
ids = WebFunc.expose!(multi_func_map, [f, f1], Dict{String,Number})
@test length(ids) == 2
@test length(multi_func_map) == 2
## expose preserves order, first func should be sqrt
@test multi_func_map[ids[1]].func(test_input) ≈ 2
@test multi_func_map[ids[2]].func(test_input) ≈ 16		

multi_func_types = WebFunc.Mapping()
ids2 = WebFunc.expose!(
	multi_func_types, 
	[fadd, fadd]::Vector{<:Function},
	[Dict{String,Int}, Dict{String,Real}],
)


@test multi_func_types[ids2[1]].func(test_input) == 8
@test multi_func_types[ids2[2]].func(input_f) ≈ 0.84