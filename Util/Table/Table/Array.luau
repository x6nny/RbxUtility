--!strict
local array = {}

function array.hasIndex(t : {[number] : any}, ind : number) : boolean
	return t[ind] ~= nil
end

function array.randomIndex<T>(t : {[number] : T}) : T
	return t[math.random(1, #t)]
end

function array.getIndex<T>(t : {[number] : T}, value : T) : number?
	return table.find(t, value)
end

function array.removeIndex<T>(t : {[number] : T}, ind : number) : {[number] : T}
	table.remove(t, ind)
	return t
end

function array.insert<Value>(tbl: { Value }, value: Value)
	tbl[#tbl + 1] = value
	return tbl
end

function array.insertAt<T>(t : {[number] : T}, value : T, at : number) : T
	local inserted = {}
	local itemsInTable = #t

	if at > itemsInTable then
		table.insert(t, value)
		return t
	end

	for i = 1, at-1 do
		inserted[i] = t[i]
	end

	local new_order_values = {}
	for i = at, itemsInTable do
		local v = t[i]
		new_order_values[i+1] = v
	end

	inserted[at] = value

	for i, v in pairs(new_order_values) do
		inserted[i] = v
	end

	return inserted
end

return array
