type State<T> = {
	value: T,
	previous: any?,
	listeners: { { listener: (current: any, previous: any) -> (), cleanup: () -> ()? } },
	computed_disconnect: () -> ()?,
}

type class<T, N> = {
	change: (state: State<T>, new: N, force: boolean?) -> (),
	subscribe : (state: State<T>, listener: (current: T, previous: T) -> (), cleanup: () -> ()?) -> () -> (),
	peek : (state: State<T>) -> T,
	cleanup : (state: State<T>) -> (),
}

export type state<T> = State<T>

local function none() end

local function peek<T>(state: State<T>) : T
	return state.value
end

local function change<T, N>(state: State<T | N>, new: N, force: boolean?)
	if not force and state.value == new then
		return
	end

	state.previous = state.value
	state.value = new

	local listeners = state.listeners
	for i = 1, #listeners do
		local listener = listeners[i]
		listener.listener(state.value, state.previous)
	end
end

local function subscribe<T>(state: State<T>, listener: (current: T, previous: T) -> (), cleanup: () -> ()?)
	local data = {
		listener = listener,
		cleanup = cleanup
	}

	table.insert(state.listeners, data)

	return function()
		local index = table.find(state.listeners, data)
		if index then
			table.remove(state.listeners, index)
		end

		if typeof(cleanup) == "function" then
			return cleanup()
		end

		return none()
	end
end

local function cleanup<T>(state: State<T>)
	if state.computed_disconnect then
		state.computed_disconnect()
		state.computed_disconnect = nil
	end

	for i, v in state.listeners do
		if v.cleanup then
			v.cleanup()
		end
	end

	table.clear(state.listeners)
	state.previous = nil
	state.value = nil :: any
end

local function new<T, N>(inital: T?) : State<T>
	return {
		value = inital,
		previous = nil,
		listeners = {},
	} :: State<T>
end

local function compute<R>(processor: (use: <T>(State<T>) -> T) -> R): State<R>
	local disconnects: {() -> ()} = {}
	local derived = new(nil)

	local function disconnect_all()
		for _, disconnect in disconnects do
			disconnect()
		end
		table.clear(disconnects)
	end

	local function run()
		disconnect_all()

		table.clear(disconnects)

		local function use<T>(source: State<T>): T
			local disconnect = subscribe(source, function()
				run()
			end)
			table.insert(disconnects, disconnect)
			return source.value
		end

		local result = processor(use)
		change(derived, result)
	end

	derived.computed_disconnect = disconnect_all
	run()
	return derived
end

return {
	new = new,
	peek = peek,
	change = change,
	subscribe = subscribe,
	compute = compute,
	cleanup = cleanup,
}
