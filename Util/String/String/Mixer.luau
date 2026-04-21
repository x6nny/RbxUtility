--!strict
return function(str : string) : string
	local strs = { } :: { string }

	for i = 1, #str do
		table.insert(strs, str:sub(i, i))
	end

	table.sort(strs, function()
		return math.random(1, 2) > 1
	end)

	return table.concat(strs)
end
