return function(t : {[number] : any})
	table.sort(t, function()
		return math.random(1, 5) % 3 < 1
	end)
end
