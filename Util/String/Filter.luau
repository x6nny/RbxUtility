local textService = game:GetService('TextService')

return function(text: string, player: Player, context: Enum.TextFilterContext?): TextFilterResult
	return textService:FilterStringAsync(text, player.UserId, context)
end
