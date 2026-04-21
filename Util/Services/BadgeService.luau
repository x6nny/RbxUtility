--!strict
local BadgeService = game:GetService('BadgeService')

--> Class
local Badges = {}

--> types
type badgeInfo = {
	['Name']: string,
	['Description']: string,
	['IconImageId']: string,
	['IsEnabled']: boolean
}

--> Methods
function Badges.HasBadge(UserId : number, BadgeId : number) : boolean
	return BadgeService:UserHasBadgeAsync(UserId, BadgeId)
end

function Badges.AwardBadge(UserId : number, BadgeId : number)
	if Badges.HasBadge(UserId, BadgeId) == true then return end
	BadgeService:AwardBadgeAsync(UserId, BadgeId)
end

function Badges.CheckUserBadgesAsync(userId: number, badgeIds: {number}): {number}
	return BadgeService:CheckUserBadgesAsync(userId, badgeIds)
end

function Badges.GetBadgeInfoAsync(badgeId: number): badgeInfo?
	local succ, info = pcall(function()
		return BadgeService:GetBadgeInfoAsync(badgeId)
	end)

	if succ then
		return info
	end

	return nil
end

function Badges.AwardBulk(UserIds : number | {number}, BadgeId : {number})
	if type(UserIds) == 'number' then
		UserIds = { UserIds }
	end

	for _, badge in pairs(BadgeId) do
		for _, user : number in pairs(UserIds :: {number}) do
			if Badges.HasBadge(user, badge) == true then continue end
			Badges.AwardBadge(user, badge)
		end
	end
end

--> return
return Badges
