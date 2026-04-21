type callback_func = (player: Player) -> ()
type data = {
	specificPlayer :  {Player?} | Player?,
	func : callback_func
}

type self = {
	Instance: Instance,
	Players: {Player},

	_Enabled: boolean,
	_OnEnter: {data},
	_OnExit: {data}
}

export type struct = {
	OnEnter: (self: struct, func: callback_func, specificPlayer : {Player?} | Player?) -> () -> (),
	OnExit: (self: struct, func: callback_func, specificPlayer : {Player?} | Player?) -> () -> (),
	Enabled: (self: struct, enabled: boolean) -> () -> (),
	FetchPlayers: (self: struct) -> (),
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BasicZone = {}
BasicZone.__index = BasicZone

local RootParts = {} :: {[Player] : any}
local ActiveZones = {}

local Params = OverlapParams.new()
Params.MaxParts = 200
Params.FilterType = Enum.RaycastFilterType.Include

function BasicZone.new(zone: BasePart): struct

	local self = {
		Instance = zone,
		Players = {},

		_Enabled = true,
		_OnEnter = {},
		_OnExit = {},
	}

	local meta = setmetatable(self, BasicZone)
	table.insert(ActiveZones, meta)

	return meta :: any
end

function BasicZone.OnEnter(self: self, func: callback_func, specificPlayer : {Player?} | Player?)
	local specific = specificPlayer

	if specific ~= nil then
		if typeof(specific) ~= 'table' then
			specific = {specific}
		end
	end

	local data = {
		specificPlayer = specific,
		func = func
	}

	table.insert(self._OnEnter, data)

	return function()
		local index = table.find(self._OnEnter, data)
		if not index then return end

		table.remove(self._OnEnter, index)
	end
end

function BasicZone.OnExit(self: self, func: callback_func, specificPlayer : {Player?} | Player?)
	local specific = specificPlayer

	if specific ~= nil then
		if typeof(specific) ~= 'table' then
			specific = {specific}
		end
	end

	local data = {
		specificPlayer = specific,
		func = func
	}

	table.insert(self._OnExit, data)

	return function()
		local index = table.find(self._OnExit, data)
		if not index then return end

		table.remove(self._OnExit, index)
	end
end

function BasicZone.Enabled(self: self, enabled: boolean)
	self._Enabled = enabled
end

function BasicZone.FetchPlayers(self: self)
	return self.Players
end

RunService.Heartbeat:Connect(function()

	local roots = {} do
		for _, root in RootParts do
			table.insert(roots, root)
		end
	end

	Params.FilterDescendantsInstances = roots :: any

	for z = 1, #ActiveZones do
		local zone = ActiveZones[z]
		if not zone._Enabled then continue end

		local result = workspace:GetPartsInPart(zone.Instance, Params)

		for r = 1, #result do
			local player = Players:GetPlayerFromCharacter(result[r].Parent)

			if player and not table.find(zone.Players, player) then
				table.insert(zone.Players, player)
				for i = 1, #zone._OnEnter do
					if zone._OnEnter[i].specificPlayer == nil or (zone._OnEnter[i].specificPlayer ~= nil and table.find(zone._OnEnter[i].specificPlayer, player) ~= nil) then
						task.spawn(zone._OnEnter[i].func, player)
					end
				end
			end
		end

		for p = #zone.Players, 1, -1 do
			local player = zone.Players[p]
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if not root then continue end

			if not table.find(result, root) then
				table.remove(zone.Players, p)
				for i = 1, #zone._OnExit do
					if zone._OnExit[i].specificPlayer == nil or (zone._OnExit[i].specificPlayer ~= nil and  table.find(zone._OnExit[i].specificPlayer, player) ~= nil) then
						task.spawn(zone._OnExit[i].func, player)
					end
				end
			end
		end

	end

end)

local function retrieve_root(player: Player)

	if player.Character then
		local root_part = player.Character:WaitForChild("HumanoidRootPart")

		if root_part then
			RootParts[player] = root_part
		end
	end

	player.CharacterAdded:Connect(function(character: Model)
		local root_part = character:WaitForChild("HumanoidRootPart", 5)

		if root_part then
			RootParts[player] = root_part
		end
	end)
end

Players.PlayerAdded:Connect(retrieve_root)

Players.PlayerRemoving:Connect(function(player : Player)
	if RootParts[player] then
		RootParts[player] = nil
	end

	for _, zone in ActiveZones do
		local index = table.find(zone.Players, player)
		if index then
			table.remove(zone.Players, index)
		end
	end
end)

for _, player in Players:GetPlayers() do
	retrieve_root(player)
end

return BasicZone :: {
	new: (zone: BasePart) -> struct
}
