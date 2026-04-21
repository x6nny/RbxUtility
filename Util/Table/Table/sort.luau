--!strict
local sort = {}

function sort.computed<T>(t : T, compute : (a : any, b : any) -> boolean) : T
	table.sort(t, compute)
	return t
end

function sort.reorder<T>(t : {[number] : T}, order : {number}) : T
	local reorder = {}

	--> insert any indexs not found in order
	for index, value in pairs(t) do
		if table.find(order, index) == nil then
			table.insert(order, index)
		end
	end

	for i, index in pairs(order) do
		reorder[i] = t[index]
	end

	return reorder
end

return sort
