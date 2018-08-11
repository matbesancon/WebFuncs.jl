module WebFuncs

export Mapping, expose!, serve, default_port

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

function expose!(map::Mapping, func::Function, input_type::DataType=Dict{AbstractString,Any})
    key = UUIDs.uuid4()
    map[key] = Lambda(func, input_type)
    key
end

function expose!(map::Mapping, funcs::Vector{<:Function}, input_types::Vector{DataType})
    func_keys = [UUIDs.uuid4() for _ in 1:length(funcs)]
    for (k, f, t) in zip(func_keys, funcs, input_types)
        map[k] = Lambda(f, t)
    end
    func_keys
end

function expose!(map::Mapping,funcs::Vector{<:Function}, input_type::DataType=Dict{AbstractString,Any})
    input_type_copy = [input_type for _ in 1:length(funcs)]
    expose!(map, funcs, input_type_copy)
end


function parse_input(data::Vector{UInt8},DT::DataType=Dict{AbstractString,Any})
    parsed_dict = JSON.Parser.parse(join([Char(v) for v in data]))
	if DT <: Dict
		parsed_dict
	else
		Unmarshal.unmarshal(DT, parsed_dict)
	end
end

function run(map::Mapping, port::Int = default_port)
    # dispatches the request with parsed req body to corresponding Lambda
    function handler(req::HTTP.Request,res::HTTP.Response)
        println("Got there")
        split_res = split(req.resource,'/')
        if length(split_res) <= 1
            return HTTP.Response(200, "Hello")
        end
        if !(func_id in keys(map))
            return HTTP.Response(400)
            func_id = UUIDs.UUID(split_res[2])
        end
        lambda = map[func_id]
        input = parse_input(req.data, lambda.Input)
        result = Dict(["result" => lambda.func(input)])
        return HTTP.Response(200, JSON.json(result))
    end
    server = HTTP.Server(handler)
    HTTP.serve(server, localhost, port)
end

end
