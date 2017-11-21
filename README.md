# WebFunc
Instantly turn custom functions into HTTP endpoints

[![Build Status](https://travis-ci.org/mbesancon/WebFunc.jl.svg?branch=master)](https://travis-ci.org/mbesancon/WebFunc.jl)

[![Coverage Status](https://coveralls.io/repos/github/mbesancon/WebFunc.jl/badge.svg?branch=master)](https://coveralls.io/github/mbesancon/WebFunc.jl?branch=master)

[![codecov.io](http://codecov.io/github/mbesancon/WebFunc.jl/coverage.svg?branch=master)](http://codecov.io/github/mbesancon/WebFunc.jl?branch=master)


## Usage

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