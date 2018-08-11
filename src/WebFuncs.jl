module WebFuncs

export Mapping, expose!, serve, default_port

using HTTP
import JSON
import Unmarshal
import UUIDs

const default_port = 3000

struct Lambda
    func::Function
    Input::DataType
end

Mapping = Dict{UUIDs.UUID,Lambda}

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

function handle(map::Mapping)
    # dispatches the request with parsed req body to corresponding Lambda
    HTTP.listen() do request::HTTP.Request
        func_id = UUIDs.UUID(split(req.resource,'/')[2])
        if !(func_id in keys(map))
            return HTTP.Response(400)
        end
        lambda = map[func_id]
        input = parse_input(req.data, lambda.Input)
        result = Dict(["result" => lambda.func(input)])
        HTTP.Response(200, JSON.json(result))
    end
end

function serve(map::Mapping, port::Int)
    srv = Server(handle(map))
    run(srv, port)
end

function serve(map::Mapping)
    serve(map,default_port)
end

end
