local runService = game:GetService('RunService')

type methods = 'Stepped' | 'RenderStepped' | 'PreSimulation' | 'PostSimulation' | 'PreAnimation' | 'Heartbeat' | 'PreRender'

local methods = {
	Stepped = runService.Stepped,
	RenderStepped = runService.RenderStepped,
	PreSimulation = runService.PreSimulation,
	PostSimulation = runService.PostSimulation,
	PreAnimation = runService.PreAnimation,
	Heartbeat = runService.Heartbeat,
	PreRender = runService.PreRender
}

local currentConnections = { } :: { [string] : RBXScriptConnection }
local callBacks = { } :: { [string] : { (x : number) -> () } }

local function connect(method : methods, callBack : (x : number) -> ()) : () -> ()
	if callBacks[method] == nil then
		callBacks[method] = { }
	end

	table.insert(callBacks[method], callBack)

	if currentConnections[method] == nil then
		currentConnections[method] = methods[method]:Connect(function(...)
			for _, v in callBacks[method] do
				task.spawn(v, ...)
			end
		end)
	end

	return function()
		local index = table.find(callBacks[method], callBack)

		if index then
			table.remove(callBacks[method], index)

			if #callBacks[method] == 0 then
				callBacks[method] = nil

				if currentConnections[method] then
					currentConnections[method]:Disconnect()
					currentConnections[method] = nil
				end
			end
		end
	end
end

return {
	Connect = connect,
}
