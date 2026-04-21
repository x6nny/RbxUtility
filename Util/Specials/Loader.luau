local runService = game:GetService('RunService')

local utility = script.Parent
local runTimes = require(utility.Parent.Services.Runtimes)

local DEFAULT_RUNTIME_CONNECTION = if runService:IsServer() then 'Heartbeat' else 'RenderStepped'

type modules = {
	modules: {
		[number]: {
			[any]: any
		}
	}
}

local function fromTable(modules: { ModuleScript }): modules
	local required = {}

	table.sort(modules, function(a, b)
		local ap = if a:GetAttribute('priority') then a:GetAttribute('priority') else 1
		local bp = if b:GetAttribute('priority') then b:GetAttribute('priority') else 0

		return ap < bp
	end)

	for i, v in modules do
		task.spawn(function()
			local returned = require(v)
			if returned ~= nil and typeof(returned) == 'table' then
				table.insert(required, returned)
			end
		end)
	end

	return {
		modules = required
	}
end

local function fromInstance(instance: Instance): modules
	local modules = instance:QueryDescendants('ModuleScript')
	return fromTable(modules)
end

local function call(modules: modules, method: string, async: boolean?, ...)
	for i, v in modules.modules do
		if v[method] and typeof(v[method]) == 'function' then
			if async then
				task.spawn(v[method], ...)
			else
				v[method](...)
			end
		end
	end
end

local function bind(modules: modules)
	for i, v in modules.modules do
		if v.onUpdate ~= nil and typeof(v.onUpdate) == 'function' then
			local mode = if v.updateMethod ~= nil then v.updateMethod else DEFAULT_RUNTIME_CONNECTION
			runTimes.Connect(mode, v.onUpdate)
		end
	end
end

return {
	fromTable = fromTable,
	fromInstance = fromInstance,
	call = call,
	bind = bind,
}
