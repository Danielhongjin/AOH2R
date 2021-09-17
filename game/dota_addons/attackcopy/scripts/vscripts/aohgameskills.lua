require("modifiers/modifier_tier_1")
require("modifiers/modifier_tier_2")
require("modifiers/modifier_tier_3")
require("modifiers/modifier_tier_4")
require("modifiers/modifier_tier_5")






if AOHGameSkills == nil then
	_G.AOHGameSkills = class({})
	AOHGameSkills.value = 500
	AOHGameSkills.currency = {[0] = 0, 0, 0, 0, 0,}
	AOHGameSkills.credits_clicked = {[0] = false, false, false, false, false,}
	AOHGameSkills.chosen_skills = {[0] = 
	{[0] = {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,},}, 
	{[0] = {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,},}, 
	{[0] = {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,},}, 
	{[0] = {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,},}, 
	{[0] = {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,},},}
	AOHGameSkills._TIER_1_SKILLS = {
	[0] = "modifier_skill_dashcooldown", "modifier_skill_equalizer", "modifier_skill_dashimmunity", "modifier_skill_flashcaster",
	}
	AOHGameSkills._TIER_2_SKILLS = {
		[0] = "modifier_skill_minitalon", "modifier_skill_lightbones", "modifier_skill_atronach", "modifier_skill_overtuned",
	}
	AOHGameSkills._TIER_3_SKILLS = {
		[0] = "modifier_skill_trident", "modifier_skill_transfusion", "modifier_skill_dashdamage", "modifier_skill_flames",
	}
	AOHGameSkills._TIER_4_SKILLS = {
		[0] = "modifier_skill_noevil", "modifier_skill_jack", "modifier_skill_cardio", "modifier_skill_bloodmana",
	}
	AOHGameSkills._TIER_5_SKILLS = {
		[0] = "modifier_skill_midas", "modifier_skill_license", "modifier_skill_luck", "modifier_skill_wavedash",
	}
	AOHGameSkills._TIERS = {
		[0] = AOHGameSkills._TIER_1_SKILLS, AOHGameSkills._TIER_2_SKILLS, AOHGameSkills._TIER_3_SKILLS, AOHGameSkills._TIER_4_SKILLS, AOHGameSkills._TIER_5_SKILLS,
	}
end


function AOHGameSkills:Init()
	CustomGameEventManager:RegisterListener("skill_selected", Dynamic_Wrap(AOHGameSkills, "SkillSelected"))
	CustomGameEventManager:RegisterListener("credits_clicked", Dynamic_Wrap(AOHGameSkills, "CreditsClicked"))
	CustomGameEventManager:RegisterListener("credit_transaction", Dynamic_Wrap(AOHGameSkills, "Transaction"))
	for playerID = 0, DOTA_DEFAULT_MAX_TEAM - 1 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "skill_bar_init", {id = playerID, currency = AOHGameSkills.currency[playerID], value = AOHGameSkills.value})
			end
		end
	end
end

function AOHGameSkills:CreditsClicked(keys)
	EmitSoundOnClient("AOH.CreditsClicked", PlayerResource:GetPlayer(keys.id))
	if AOHGameSkills.credits_clicked[keys.id] == false or _G.AOHGameMode._debug then
		AOHGameSkills.credits_clicked[keys.id] = true
		AOHGameSkills.AddCurrency(keys.id, 1)
	end
end

function AOHGameSkills:Transaction(keys)
	local hero = PlayerResource:GetSelectedHeroEntity(keys.id)
	if keys.type == 0 then
		if hero:GetGold() >= AOHGameSkills.value then
			AOHGameSkills.AddCurrency(keys.id, 1)
			hero:SpendGold(AOHGameSkills.value, DOTA_ModifyGold_PurchaseItem)
			AOHGameSkills.value = AOHGameSkills.value + 50
			CustomGameEventManager:Send_ServerToAllClients("update_value", {value = AOHGameSkills.value})
		end
	else
		if AOHGameSkills.currency[keys.id] > 0 then
			AOHGameSkills.currency[keys.id] = AOHGameSkills.currency[keys.id] - 1
			AOHGameSkills.value = AOHGameSkills.value - 50
			hero:ModifyGold(AOHGameSkills.value, true, DOTA_ModifyGold_SellItem)
			if AOHGameSkills.value < 200 then
				AOHGameSkills.value = 200
			end
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.id), "update_currency", {currency = AOHGameSkills.currency[keys.id]})
			CustomGameEventManager:Send_ServerToAllClients("update_value", {value = AOHGameSkills.value})
		end
	end
end

function AOHGameSkills.AddCurrency(playerID, value)
	AOHGameSkills.currency[playerID] = AOHGameSkills.currency[playerID] + value
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	local particle = ParticleManager:CreateParticle("particles/diamond_indicator.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
	ParticleManager:SetParticleControlEnt(particle, 0, hero, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", hero:GetAbsOrigin(), true)
	local fx = ParticleManager:CreateParticleForPlayer("particles/diamond_player.vpcf", PATTACH_RENDERORIGIN_FOLLOW, hero, hero:GetPlayerOwner())
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "update_currency", {currency = AOHGameSkills.currency[playerID]})
	EmitSoundOnClient("AOH.Reward", PlayerResource:GetPlayer(playerID))
end

function AOHGameSkills:UnlockSkills(tier)
	CustomGameEventManager:Send_ServerToAllClients("skill_bar_unlock", {tier = math.floor(tier)})
	EmitGlobalSound("AOH.PerkUnlocked")
end

function AOHGameSkills:Renew(playerID)
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "skill_bar_init", {id = playerID, currency = AOHGameSkills.currency[playerID], value = AOHGameSkills.value})
	if _G.AOHGameMode._nRoundNumber >= 4 then
		CustomGameEventManager:Send_ServerToAllClients("skill_bar_unlock", {tier = 1})
		if _G.AOHGameMode._nRoundNumber >= 10 then
			CustomGameEventManager:Send_ServerToAllClients("skill_bar_unlock", {tier = 2})
			if _G.AOHGameMode._nRoundNumber >= 16 then
				CustomGameEventManager:Send_ServerToAllClients("skill_bar_unlock", {tier = 3})
				if _G.AOHGameMode._nRoundNumber >= 22 then
					CustomGameEventManager:Send_ServerToAllClients("skill_bar_unlock", {tier = 4})
					if _G.AOHGameMode._nRoundNumber >= 28 then
						CustomGameEventManager:Send_ServerToAllClients("skill_bar_unlock", {tier = 5})
					end
				end
			end
		end
	end
end

function AOHGameSkills:SkillSelected(keys)
	if (((_G.AOHGameMode._nRoundNumber + 2) / 6) >= (keys.tier) and math.floor((keys.tier) / 2 + 0.55) <= AOHGameSkills.currency[keys.id] and PlayerResource:GetSelectedHeroEntity(keys.id):IsAlive())or AOHGameSkills.chosen_skills[keys.id][keys.tier - 1][keys.choice] == 1 or _G.AOHGameMode._debug then
		local hero = PlayerResource:GetSelectedHeroEntity(keys.id)
		if AOHGameSkills.chosen_skills[keys.id][keys.tier - 1][keys.choice] == 0 then
			AOHGameSkills.currency[keys.id] = AOHGameSkills.currency[keys.id] - math.floor((keys.tier) / 2 + 0.55)
			AOHGameSkills.chosen_skills[keys.id][keys.tier - 1][keys.choice] = 1
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.id), "skill_purchase_success", {transaction = 1, currency = AOHGameSkills.currency[keys.id], tier = keys.tier, choice = keys.choice})
			hero:AddNewModifier(hero, nil, AOHGameSkills._TIERS[keys.tier - 1][keys.choice], {duration = -1})
		else
			AOHGameSkills.currency[keys.id] = AOHGameSkills.currency[keys.id] + math.floor((keys.tier) / 2 + 0.55)
			AOHGameSkills.chosen_skills[keys.id][keys.tier - 1][keys.choice] = 0
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.id), "skill_purchase_success", {transaction = 0, currency = AOHGameSkills.currency[keys.id], tier = keys.tier, choice = keys.choice})
			hero:RemoveModifierByName(AOHGameSkills._TIERS[keys.tier - 1][keys.choice])
		end
		EmitSoundOnClient("AOH.PerkSelected", PlayerResource:GetPlayer(keys.id))
	end
end