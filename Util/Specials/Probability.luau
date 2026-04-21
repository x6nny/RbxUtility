type rarity = {
	name: string,
	percentage: number,
}

type rarities = {rarity}

type self = {
	luck: number,
	highest: rarity,
	rarities: rarities
}

type struct = {
	SetLuck: (self: struct, luck: number?) -> (),
	Roll: (self: struct, amount: number) -> rarities
}

local Probability = {}
Probability.__index = Probability

function Probability.new(tbl: rarities)
	assert(typeof(tbl) == "table", "rarities must be a table")

	local highest do
		local temp = 0
		for i = 1, #tbl do
			local item = tbl[i]
			if item.percentage > temp then
				temp = item.percentage
				highest = item
			end
		end
	end

	return setmetatable({
		luck = 1,
		highest = highest,
		rarities = tbl or {},
	}, Probability)
end

function Probability.SetLuck(self: self, luck: number?)
	self.luck = luck or 1
end

function Probability.Roll(self: self, amount: number)
	local returned = {}

	local rarities = self.rarities
	local luck = self.luck
	local highest = self.highest

	for i = 1, amount do
		local roll = math.random() * 100
		local cumulative = 0
		local found = false

		for r = 1, #rarities do
			local selection = rarities[r]
			if not selection then selection = highest end

			local percentage = math.clamp(selection.percentage * luck, 0, 100)
			cumulative = cumulative + percentage
			if roll <= cumulative then
				table.insert(returned, selection)
				found = true
				break
			end
		end

		if not found then
			table.insert(returned, highest)
		end
	end

	return returned
end

return Probability :: {
	new: (tbl: rarities) -> struct
}
