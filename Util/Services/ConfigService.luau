local configService = game:GetService('ConfigService')
local snapshot = configService:GetConfigAsync()

type configChange = (value: any) -> ()
type onChange = (property: string) -> ()

type trackedConfigChanged = {
	[string]: {
		connection: RBXScriptConnection,
		callbacks: {configChange}
	}
}

type trackedOnChange = {(property: string) -> ()}

local trackedConfigChanged = {} :: trackedConfigChanged
local trackedOnChange = {} :: trackedOnChange

local ConfigService = {}

function ConfigService.getConfigValue(config: string)
	return snapshot:GetValue(config)
end

function ConfigService.onConfigChanged(config: string, callback: configChange): () -> ()
	if trackedConfigChanged[config] == nil then
		trackedConfigChanged[config] = {
			callbacks = {},
			connection = snapshot:GetValueChangedSignal(config):Connect(function(value)
				for _, v in trackedConfigChanged[config].callbacks do
					task.spawn(v)
				end
			end)
		}

		table.insert(trackedConfigChanged[config].callbacks, callback)

		return function()
			local index = table.find(trackedConfigChanged[config].callbacks, callback)
			if index then
				table.remove(trackedConfigChanged[config].callbacks, index)
			end
		end
	else
		table.insert(trackedConfigChanged[config].callbacks, callback)

		return function()
			local index = table.find(trackedConfigChanged[config].callbacks, callback)
			if index then
				table.remove(trackedConfigChanged[config].callbacks, index)
			end
		end
	end
end

function ConfigService.onChange(callback: onChange): () -> ()
	table.insert(trackedOnChange, callback)

	return function()
		local index = table.find(trackedOnChange, callback)
		if index then
			table.remove(trackedOnChange, index)
		end
	end
end

function ConfigService.forceRefresh()
	snapshot:Refresh()
end

function ConfigService.setTestingValue(key: string, value: any)
	configService:SetTestingValue(key, value)
end

function ConfigService.getPlayerConfig(player: Player): ConfigSnapshot
	return configService:GetConfigForPlayerAsync(player)
end

function ConfigService.clearTestingValue(key: string)
	configService:ClearTestingValue(key)
end

snapshot.UpdateAvailable:Connect(function()
	snapshot:Refresh()
end)

return ConfigService
