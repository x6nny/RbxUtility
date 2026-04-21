--!strict
local function copyShallow<T>(t : T) : T
	return table.clone(t)
end

local function copyDeep<T>(t : T) : T
	local copy = {}

	for i, v in pairs(t) do
		if typeof(v) == 'table' then
			copy[i] = copyDeep(v)
		else
			copy[i] = v :: any
		end
	end

	return copy
end

return function<T>(t : T) : T
	local isDeep = false

	for i, v in pairs(t) do
		if typeof(v) == 'table' then
			isDeep = true
			break
		end
	end

	return if isDeep == true then copyDeep(t) else copyShallow(t)
end
