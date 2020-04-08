-- Lib wrote by me.
require("lib/my")


function ai_all_heroes()
	local heroes = {}

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if hero then
				table.insert(heroes, hero)
			end
		end
	end

	return heroes
end


function ai_alive_heroes()
	local heroes_alive = {}

	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if hero:IsAlive() then
				table.insert(heroes_alive, hero)
			end
		end
	end

	return heroes_alive
end


function ai_random_alive_hero()
	return random_from_table(ai_alive_heroes())
end

function ai_weakest_alive_hero_current()

	local function get_weakest(hero1, hero2)
		if hero1:GetHealth() > hero2:GetHealth() then
			return hero2
		end
		return hero1
	end

	local heroes = ai_alive_heroes()

	if #heroes < 1 then
		return nil
	end

	local weakest = nil

	for i, hero in ipairs(heroes) do
		if weakest == nil then
			weakest = hero
		else
			weakest = get_weakest(weakest, hero)
		end
	end

	return weakest
end

function ai_weakest_alive_hero()

	local function get_weakest(hero1, hero2)
		if hero1:GetMaxHealth() > hero2:GetMaxHealth() then
			return hero2
		end
		return hero1
	end

	local heroes = ai_alive_heroes()

	if #heroes < 1 then
		return nil
	end

	local weakest = nil

	for i, hero in ipairs(heroes) do
		if weakest == nil then
			weakest = hero
		else
			weakest = get_weakest(weakest, hero)
		end
	end

	return weakest
end

