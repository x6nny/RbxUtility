--!strict
local function reverse<T>(t : {[number] : T}) : T
	local reversed = {}

	for i = #t, 1, -1 do
		if typeof(t[i]) == 'table' then
			local rvs = reverse(t[i])
			table.insert(reversed, rvs)
		else
			table.insert(reversed, t[i])
		end
	end

	return reversed
end

return function<T>(t : {[number] : T}) : T
	return reverse(t)
end
