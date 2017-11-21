module WebFunc

export Mapping, expose!, serve, default_port

using HttpServer
import JSON
import Unmarshal
import Base.Random

const default_port = 3000

struct Lambda
    func::Function
    Input::DataType
end

Mapping = Dict{Random.UUID,Lambda}

function expose!(map::Mapping, func::Function, input_type::DataType)
    key = Random.uuid4()
    map[key] = Lambda(func, input_type)
    key
end

function expose!(map::Mapping, funcs::Vector{<:Function}, input_types::Vector{DataType})
    func_keys = [Random.uuid4() for _ in 1:length(funcs)]
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
		Unmarshal.unmarshal(DT, parsed_data)
	end
end

function handle(map::Mapping)
    # dispatches the request with parsed req body to corresponding Lambda
    HttpHandler() do req::Request, res::Response
        func_id = Random.UUID(split(req.resource,'/')[1])
        if !(func_id in map.mapping)
            Response(400)
        else
            lambda = map[func_id]
            input = parse_input(req.data, lambda.Input)
            result = Dict(["result" => lambda.func(input)])
            Response(200, JSON.json(result))
        end
    end
end

function serve(map::Mapping, port::Int)
    srv = Server(handle(map))
    run(srv, port)
end

function serve(map::Mapping)
    run(map,default_port)
end

end
