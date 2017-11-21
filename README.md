# WebFunc
Instantly turn custom functions into HTTP endpoints

[![Build Status](https://travis-ci.org/mbesancon/WebFunc.jl.svg?branch=master)](https://travis-ci.org/mbesancon/WebFunc.jl)

[![Coverage Status](https://coveralls.io/repos/github/mbesancon/WebFunc.jl/badge.svg?branch=master)](https://coveralls.io/github/mbesancon/WebFunc.jl?branch=master)

[![codecov.io](http://codecov.io/github/mbesancon/WebFunc.jl/coverage.svg?branch=master)](http://codecov.io/github/mbesancon/WebFunc.jl?branch=master)

## Usage

### With `Dict` input

```julia
> import WebFunc
> m = WebFunc.Mapping()
# Dict{Base.Random.UUID,WebFunc.Lambda} with 0 entries
> f = input -> input["a"] * 2
(::#1) (generic function with 1 method)
> WebFunc.expose!(m,f)
# 35729b69-43e6-470d-86c2-ee00f1222a4d
WebFunc.serve(m, 8080)
# Listening on 0.0.0.0:8080...
```

In another terminal:
```bash
$ curl -X POST http://localhost:8080/35729b69-43e6-470d-86c2-ee00f1222a4d -d "{\"a\": 42}"
{"result":84}
```

### With a custom `struct`

```julia
import WebFunc

struct Language
	name::String
end

is_awesome = function(l::Language)
	l.name == "Julia" ? "Yep" : "We'll see about that"
end

m = WebFunc.Mapping()
# Giving the expected input type to convert incoming JSON data
WebFunc.expose!(m,is_awesome,Language)
# 4fbff4f3-27b4-4e86-b02f-a82f0aba3eda
WebFunc.serve(m, 8080)
```

On the client bash:
```bash
$ curl -X POST http://localhost:8080/4fbff4f3-27b4-4e86-b02f-a82f0aba3eda -d "{\"name\": \"Fortran\"}"
{"result":"We'll see about that"}

$ curl -X POST http://localhost:8080/4fbff4f3-27b4-4e86-b02f-a82f0aba3eda -d "{\"name\": \"Julia\"}"
{"result":"Yep"}
```


## Structure

The main object is `Mapping`, associating a unique identifier (UUID) to a function.
When launching the server, each function is exposed at host/function_id.
  
  
When adding a function to the mapping, its input type has to be provided, this
input type has to be convertible from a JSON payload (either a 
`Dict{String,T}` or a `struct`). The endpoint converts the body 
to this Input format, passes it to the function and returns 
the output wrapped in a Dict at the "result" key.

## Status and development

(Very) early, feedback is welcome.  
Features to come: improved type-safety, other data formats as input.