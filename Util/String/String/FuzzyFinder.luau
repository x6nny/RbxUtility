--!strict
local FuzzyFinder = {}

--[[
    @param search (string): The user's input.
    @param candidates (table): A list of strings to search through.
    @param sortByLength (boolean): Sorts the results by the length of the strings.
    @return (table, table): A list of filtered strings that match the pattern, and a table of filtered strings that don't match the pattern.
]]
function FuzzyFinder.match(search : string, candidates : {string}, sortByLength : boolean?) : ({string}, {string})
	if search == "" then return candidates, {} end

	local results = {}
	local dontMatch = {}

	search = search:lower()

	local pattern = ""
	for i = 1, #search do
		local char = search:sub(i, i)

		if char:match("[%^%$%(%)%%%.%[%]%*%+%-%?]") then
			char = "%" .. char
		end
		pattern = pattern .. char .. ".*"
	end

	for _, candidate in ipairs(candidates) do
		local lowerCandidate = candidate:lower()

		if lowerCandidate:find(pattern) then
			table.insert(results, candidate)
		elseif not lowerCandidate:find(pattern) then
			table.insert(dontMatch, candidate)
		end
	end

	if sortByLength then
		table.sort(results, function(a : string, b : string)
			return #a < #b
		end)
		table.sort(dontMatch, function(a : string, b : string)
			return #a < #b
		end)
	end

	return results, dontMatch
end

return FuzzyFinder
