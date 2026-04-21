--!strict
local function reconcile<T, V>(t1 : {[T] : T}, t2 : V) : T & V
	for key, value in pairs(t2) do
		if t1[key] ~= nil then
			if typeof(value) == 'table' then
				reconcile(t1[key], value)
			end
		elseif t1[key] == nil then
			t1[key] = value
		end
	end

	return t1
end

return reconcile
