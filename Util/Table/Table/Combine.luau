--!strict
return function<T, V>(t1 : T, t2 : V) : T & V
	local t3 = { } :: T & V

	for i, v in pairs(t1) do
		if typeof(i) == 'number' then
			table.insert(t3, v)
		elseif typeof(i) ~= 'number' then
			(t3 :: any)[i] = v
		end
	end

	for i, v in pairs(t2) do
		if typeof(i) == 'number' then
			table.insert(t3, v)
		elseif typeof(i) ~= 'number' then
			(t3 :: any)[i] = v
		end
	end

	return t3
end
