--!strict
local InviteOptions = Instance.new("ExperienceInviteOptions")

local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer :: Player

type timeType = {
	Year : number,
	Month : number,
	Day : number,
	Hour : number,
	Minute : number,
	Second : number,
	Millisecond : number,
}
type eventInfo = {
	Description : string,
	EndTime : timeType,
	HasEnded : boolean,
	HasStarted : boolean,
	Id : string,
	StartTime : timeType,
	Status : Enum.ExperienceEventStatus,
	Title : string,
	UserRsvpStatus : Enum.RsvpStatus
}

local Social = {}

function Social.InviteSpecific(reciever: number, message: string): boolean
	InviteOptions.InviteUser = reciever
	InviteOptions.PromptMessage = message

	local success: boolean, sendable: boolean = pcall(function()
		return SocialService:CanSendGameInviteAsync(LocalPlayer, reciever)
	end)

	if success and sendable then
		local sent: boolean = pcall(function()
			SocialService:PromptGameInvite(LocalPlayer, InviteOptions)
		end)

		return sent
	else
		return false
	end

end

function Social.InviteAll(message: string): boolean
	InviteOptions.PromptMessage = message

	local success: boolean, sendable: boolean = pcall(function()
		return SocialService:CanSendGameInviteAsync(LocalPlayer)
	end)

	if success and sendable then
		local sent: boolean = pcall(function()
			SocialService:PromptGameInvite(LocalPlayer, InviteOptions)
		end)

		return sent
	else
		return false
	end
end

function Social.isFriendsWith(player : Player, user : number | Player) : boolean
	if typeof(user) == 'Instance' then
		user = user.UserId
	end

	return player:IsFriendsWithAsync(user :: number) :: boolean
end

function Social.getEventStatus(eventId : string) : Enum.RsvpStatus
	return SocialService:GetEventRsvpStatusAsync(eventId)
end

function Social.getEventInfo(eventId : string) : eventInfo?
	local succ, result = pcall(function()
		return SocialService:GetExperienceEventAsync(eventId) :: any
	end)

	if succ then
		return result
	end

	return nil
end

function Social.promptFollowEvent(eventId : string)
	pcall(function()
		SocialService:PromptRsvpToEventAsync(eventId)
	end)
end

return Social
