--!strict
return function<T>(t : T) : T
	local flat = {}

	local function recurse(tbl)
		for _, v in tbl do
			if type(v) == "table" then
				recurse(v)
			else
				table.insert(flat, v)
			end
		end
	end

	recurse(t)
	return flat
end
