type safecall = {
	logfn: (message: string) -> (),
	retry_config: {
		_amount: number,
		_delay: number,
	}
}

local function new(retryAmount: number?, retryDelay: number?, logfn: (message: string) -> ()?): safecall
	return {
		logfn = logfn or function(err)
			warn(`[SafeCall] : {err}`)
		end,
		retry_config = {
			_amount = retryAmount or 5,
			_delay = retryDelay or 0.25
		}
	}
end

local function call(safecall: safecall, fn: () -> (), ...): (boolean, any)
	local success, result = pcall(fn, ...)
	if not success then
		safecall.logfn(`[SafeCall]\n{result}\nScript : {debug.info(fn, 's')}\nFunction : {debug.info(fn, 'n')}\nLine : {debug.info(fn, 'l')}`)
	end
	return success, result
end

local function callWithRetry(safecall: safecall, fn: () -> (), ...): (boolean, any)
	for i = 1, safecall.retry_config._amount do
		local success, result = pcall(fn, ...)
		if success then
			return true, result
		end

		safecall.logfn(`[SafeCall Retry {i} / {safecall.retry_config._amount}]\n{result}\nScript : {debug.info(fn, 's')}\nFunction : {debug.info(fn, 'n')}\nLine : {debug.info(fn, 'l')}`)
		if i < safecall.retry_config._amount then
			task.wait(safecall.retry_config._delay)
		end
	end

	return false, 'All retry attempts failed'
end

return {
	new = new,
	call = call,
	callWithRetry = callWithRetry,
}
