--!strict
local dict = {}

function dict.getEntires(dict : {[any] : any}) : number
	local indexs = 0

	for i, v in pairs(dict) do
		indexs += 1
	end

	return indexs
end

function dict.keysToIndex<I, V>(t : {[I] : V}) : {[number] : {key : I, value : V}}
	local indexs = {}

	local currentIndex = 1
	for k, v in pairs(t) do
		indexs[currentIndex] = {
			key = k,
			value = v
		}
		currentIndex += 1
	end

	return indexs
end

function dict.insert<I, V>(t : {[I] : V}, key : I, value : V) : {[I] : V}
	t[key] = value
	return t
end

return dict
