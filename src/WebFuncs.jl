module WebFuncs

export Mapping, expose!, run, default_port

import HTTP
import JSON
import Unmarshal
import UUIDs
using Sockets: localhost

const default_port = 3000

struct Lambda
    func::Function
    Input::DataType
end

const Mapping = Dict{UUIDs.UUID,Lambda}

function expose!(m::Mapping, func::Function, input_type::DataType=Dict{AbstractString,Any})
    key = UUIDs.uuid4()
    m[key] = Lambda(func, input_type)
    key
end

function expose!(m::Mapping, funcs::Vector{<:Function}, input_types::Vector{DataType})
    func_keys = [UUIDs.uuid4() for _ in 1:length(funcs)]
    for (k, f, t) in zip(func_keys, funcs, input_types)
        m[k] = Lambda(f, t)
    end
    func_keys
end

function expose!(m::Mapping, funcs::Vector{<:Function}, input_type::DataType=Dict{AbstractString,Any})
    type_vec = [input_type for _ in 1:length(funcs)]
    expose!(m, funcs, type_vec)
end

function parse_input(data::Vector{UInt8},DT::DataType=Dict{AbstractString,Any})
    parsed_dict = JSON.Parser.parse(join([Char(v) for v in data]))
	if DT <: Dict
		parsed_dict
	else
		Unmarshal.unmarshal(DT, parsed_dict)
	end
end

function run(m::Mapping, port::Int = default_port)
    # dispatches the request with parsed req body to corresponding Lambda
    r = HTTP.Router()
    for (k,f) in m
        HTTP.register!(r,string("/",k),_func_handler(f))
    end
    HTTP.register!(r, string(localhost), req::HTTP.Request -> HTTP.Response(200, "Hello WebFuncs"))
    server = HTTP.Server(r)
    HTTP.serve(server, localhost, port, verbose = true)
end

function _func_handler(lambda::Lambda)
    function(req::HTTP.Request)
        input = parse_input(req.body, lambda.Input)
        result = Dict(["result" => lambda.func(input)])
        HTTP.Response(200, JSON.json(result))        
    end
end

end
