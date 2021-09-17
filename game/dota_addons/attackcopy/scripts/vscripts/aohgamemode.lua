
require("AOHGameRound")
require("AOHSpawner")
require("AOHGameSkills")
require("DashManager")
require("lib/my")
require("lib/atr_fix")
require("lib/timers")
require("lib/ai")
require("lib/chat_handler")
require("lib/parsers")
require("lib/end_screen")
require("lib/data")
require("lib/notifications")

LinkLuaModifier("modifier_boss", "modifiers/modifier_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_main_boss", "modifiers/modifier_main_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hard_mode_boss", "modifiers/modifier_hard_mode_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hard_mode_player", "modifiers/modifier_hard_mode_player.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_laser_player", "modifiers/modifier_laser_player.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nightmare_player", "modifiers/modifier_nightmare_player.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_double_player", "modifiers/modifier_double_player.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_double_boss", "modifiers/modifier_double_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sudden_death_player", "modifiers/modifier_sudden_death_player.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_easy_mode_boss", "modifiers/modifier_easy_mode_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_summonbuff", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)

if AOHGameMode == nil then
	AOHGameMode = class({})
	AOHGameMode.difficultycount = {[0] = 1, 1, 1, 1, 1,}
	AOHGameMode.modifiercount = {[0] = {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0,},}
	AOHGameMode.modifier_total = {[0] = 0, 0, 0, 0,}
	AOHGameMode.player_settings = {[0] = {[0] = 0.14, 0, 0, 0,}, {[0] = 0.14, 0, 0, 0,}, {[0] = 0.14, 0, 0, 0,}, {[0] = 0.14, 0, 0, 0,}, {[0] = 0.14, 0, 0, 0,},}
	AOHGameMode.arcaneCount = {[0] = {[0] = 0, 0, 0}, {[0] = 0, 0, 0}, {[0] = 0, 0, 0}, {[0] = 0, 0, 0}, {[0] = 0, 0, 0},}
	AOHGameMode.nGoldIncome = 10
	AOHGameMode.numPhilo = {[0] = 0, 0, 0, 0, 0,}
	AOHGameMode.isArcane = {false, false, false, false, false}
	AOHGameMode.isTalon = {false, false, false, false, false}
	AOHGameMode.talonCount = {[0] = {[0] = 0, 0, 0}, {[0] = 0, 0, 0}, {[0] = 0, 0, 0}, {[0] = 0, 0, 0}, {[0] = 0, 0, 0},}
	AOHGameMode.Players = {}
	AOHGameMode.damage_count = {[0] = {[0] = 0, 0, 0, 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0, 0, 0, 0,}, {[0] = 0, 0, 0, 0, 0, 0, 0,},}
	AOHGameMode.mag_damage = {[0] = 1, 1, 1, 1, 1,}
	AOHGameMode.phys_damage = {[0] = 1, 1, 1, 1, 1,}
	AOHGameMode.pure_damage = {[0] = 1, 1, 1, 1, 1,}
	AOHGameMode.vote_override = false
	AOHGameMode.dps_tick = {[0] = 0, 0, 0, 0, 0,}
	AOHGameMode.highest_dps = {[0] = 0, 0, 0, 0, 0,}
	AOHGameMode._singlePlayer = false
	AOHGameMode._debug = false
	AOHGameMode._difficulty = 0
	AOHGameMode.player_count = 0
	AOHGameMode.player_array = {}
	AOHGameMode.dps_interval = 0.8
	AOHGameMode.update_index = 0
	_G.AOHGameMode = AOHGameMode
end

function AOHGameMode:InitGameMode()
	AOHGameMode._nRoundNumber = 1
	self._negativeRounds = 0
	self._currentRound = nil
	self._entAncient = Entities:FindByName(nil, "dota_goodguys_fort")
	self._entAncient:AddAbility("global_damage_effects")
	if not self._entAncient then
		print( "Ancient entity not found!" )
	end
	self._hasVoted = {}
	self._goldRatio = 1	
	self._expRatio = 1
	self._ischeckingdefeat = false
	self._defeatcounter = 6
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	Convars:SetInt("dota_max_physical_items_purchase_limit", 35)
	self:_ReadGameConfiguration()
	GameRules:SetCustomGameSetupAutoLaunchDelay(3.0)
	GameRules:SetTimeOfDay(0.75)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroSelectionTime(40.0)
	GameRules:SetPreGameTime(7.0)
	GameRules:SetStrategyTime(5.0)
	GameRules:SetPostGameTime(4000.0)
	GameRules:SetTreeRegrowTime(70.0)	
	GameRules:SetHeroMinimapIconScale(1.2)
	GameRules:SetCreepMinimapIconScale(1.2)
	GameRules:SetRuneMinimapIconScale(1.2)
	GameRules:SetStartingGold(0)

	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible(false)
	GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled(true)
	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled(true)
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	local xpTable = {0, 230, 600, 1080, 1660, 2260, 2980, 3730, 4620, 5550, 6520, 7530, 8580, 9805, 11055, 12330, 13630, 14955, 16455, 18045, 19645, 21495, 23595, 25945, 28545, 32045, 36545, 42045, 48545, 56045}
    for i = 31, 50 do
        xpTable[i] = xpTable[i - 1] + (i * 250)
    end

    GameRules.xpTable = xpTable
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(xpTable)
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(10000)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_DAMAGE,1.25)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP,10)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN,0.25)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN,0.1)

	ListenToGameEvent("npc_spawned", Dynamic_Wrap(AOHGameMode, 'OnEntitySpawned'), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(AOHGameMode, 'OnEntityKilled'), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(AOHGameMode, "OnGameRulesStateChange"), self)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(AOHGameMode, 'OnItemPickedUp'), self)
	ListenToGameEvent("dota_holdout_revive_complete", Dynamic_Wrap(AOHGameMode, 'OnHoldoutReviveComplete'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(AOHGameMode, "OnPlayerChat"), self)
	GameRules:GetGameModeEntity():SetThink("OnThink", self, 0.75)

	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(AOHGameMode, 'OnDamageDealt'), self)

end


function AOHGameMode:AtRoundStart()
	local cost = 150 + 40 * AOHGameMode._nRoundNumber
    for playerID = 0, DOTA_DEFAULT_MAX_TEAM - 1 do
        if PlayerResource:HasSelectedHero(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                PlayerResource:SetCustomBuybackCost(playerID, cost)
            end
        end
    end

end

function AOHGameMode.SetArcane(PlayerID, base, mult)
	AOHGameMode.arcaneCount[PlayerID][0] = AOHGameMode.arcaneCount[PlayerID][0] + base
	AOHGameMode.arcaneCount[PlayerID][1] = AOHGameMode.arcaneCount[PlayerID][1] + mult
	if AOHGameMode.arcaneCount[PlayerID][0] > 0 or AOHGameMode.arcaneCount[PlayerID][1] > 0 then
		AOHGameMode.isArcane[PlayerID] = true
	else
		AOHGameMode.isArcane[PlayerID] = false
	end
end

function AOHGameMode.AllowedPhilo(PlayerID)
	if AOHGameMode.numPhilo[PlayerID] < 2 then
		return true
	end
	return false
end

function AOHGameMode.SetTalon(PlayerID, physStack, magStack)
	AOHGameMode.talonCount[PlayerID][0] = AOHGameMode.talonCount[PlayerID][0] + physStack
	AOHGameMode.talonCount[PlayerID][1] = AOHGameMode.talonCount[PlayerID][1] + magStack
	if AOHGameMode.talonCount[PlayerID][0] < 0 then
		AOHGameMode.talonCount[PlayerID][0] = 0
	end
	if AOHGameMode.talonCount[PlayerID][1] < 0 then
		AOHGameMode.talonCount[PlayerID][1] = 0
	end
	if AOHGameMode.talonCount[PlayerID][1] == 0 and AOHGameMode.talonCount[PlayerID][0] == 0 then
		AOHGameMode.isTalon[PlayerID] = false
	else 
		AOHGameMode.isTalon[PlayerID] = true
	end
end

function AOHGameMode.AllowedPhilo(PlayerID)
	if AOHGameMode.numPhilo[PlayerID] < 2 then
		return true
	end
	return false
end

function AOHGameMode.IncrementPhilo(PlayerID)
	AOHGameMode.numPhilo[PlayerID] = AOHGameMode.numPhilo[PlayerID] + 1
end

function AOHGameMode:OnDamageDealt(damageTable)
	local attacker_index = damageTable.entindex_attacker_const
	local victim_index = damageTable.entindex_victim_const
	if attacker_index and victim_index then
		local attacker = EntIndexToHScript(attacker_index)
		local victim = EntIndexToHScript(victim_index)
		if attacker and victim then
			if attacker.GetPlayerOwnerID then
				local attackerPlayerId = attacker:GetPlayerOwnerID()
				if victim and victim:GetDayTimeVisionRange() ~= 1337 then
					if attackerPlayerId and attackerPlayerId >= 0 and attacker:IsOpposingTeam(victim:GetTeam()) then
						player_data_increment_value(attackerPlayerId, "bossDamage", damageTable.damage)
						if damageTable.damagetype_const == 2 then
							AOHGameMode.mag_damage[attackerPlayerId] = AOHGameMode.mag_damage[attackerPlayerId] + damageTable.damage
						elseif damageTable.damagetype_const == 1 then
							AOHGameMode.phys_damage[attackerPlayerId] = AOHGameMode.phys_damage[attackerPlayerId] + damageTable.damage
						else
							AOHGameMode.pure_damage[attackerPlayerId] = AOHGameMode.pure_damage[attackerPlayerId] + damageTable.damage
						end
					end
				end
				if attacker:IsCreature() and victim:IsRealHero() and victim.GetPlayerOwnerID then
					local victimPlayerId = victim:GetPlayerOwnerID()
					if victimPlayerId and victimPlayerId >= 0 then
						player_data_increment_value(victimPlayerId, "damageTaken", damageTable.damage)
					end
				end
			end
		end
	end
	return true
end


function AOHGameMode:OnItemPickedUp(keys)
	if keys.itemname == "item_bag_of_gold" then
		player_data_modify_value(keys.PlayerID, "goldBagsCollected", 1)
	end
end


function AOHGameMode:OnHoldoutReviveComplete(keys)
	local castingHero = EntIndexToHScript(keys.caster)
	if castingHero then
		local playerID = castingHero:GetPlayerOwnerID()
		player_data_modify_value(playerID, "saves", 1)
	end
end


-- Read and assign configurable keyvalues if applicable
function AOHGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues("scripts/config/aoh2_config.txt") or {}

	self._flPrepTimeBetweenRounds = tonumber(kv.PrepTimeBetweenRounds or 0)
	self._flItemExpireTime = tonumber(kv.ItemExpireTime or 10.0)

	self._vRandomSpawnsList = spawns_from_kv(kv["RandomSpawns"])
	self._vLootItemDropsList = items_from_kv(kv["ItemDrops"])
	self._vBossLootItemDropsList = items_from_kv(kv["BossItemDrops"])
	self._vRounds = rounds_from_kv(kv["Rounds"], self)
	for k, v in pairs(self._vRounds) do
		print(k, v)
	end
end


-- Verify spawners if random is set
function AOHGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error("Attempt to choose a random spawn, but no random spawns are specified in the data.")
		return nil
	end
	return self._vRandomSpawnsList[RandomInt(1, #self._vRandomSpawnsList)]
end

function AOHGameMode:DifficultyClicked(keys)
	EmitSoundOnClient("AOH.MenuSelection", PlayerResource:GetPlayer(keys.id))
	if keys.type == 0 then
		AOHGameMode.difficultycount[keys.id] = keys.choice
	else
		if AOHGameMode.modifiercount[keys.id][keys.choice] == 0 then
			AOHGameMode.modifiercount[keys.id][keys.choice] = 1
		else
			AOHGameMode.modifiercount[keys.id][keys.choice] = 0
		end
		CustomGameEventManager:Send_ServerToAllClients("vote_update", {id = keys.id, update_type = 1, choice = keys.choice, value = AOHGameMode.modifiercount[keys.id][keys.choice]})
	end
	CustomGameEventManager:Send_ServerToAllClients("vote_update", {id = keys.id, update_type = 0, difficulty = AOHGameMode.difficultycount[keys.id]})
end



function AOHGameMode:EndVote()
	EmitGlobalSound("AOH.MenuClose")
	local difficultyTotal = 0
	for playerID = 0, DOTA_DEFAULT_MAX_TEAM - 1 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				if not AOHGameMode.vote_override then
					difficultyTotal = difficultyTotal + AOHGameMode.difficultycount[playerID]
					for choice = 0, 3 do
						AOHGameMode.modifier_total[choice] = AOHGameMode.modifier_total[choice] + AOHGameMode.modifiercount[playerID][choice]
					end
				else
					if playerID == 0 then
						difficultyTotal = difficultyTotal + AOHGameMode.difficultycount[playerID] * AOHGameMode.player_count
						for choice = 0, 3 do

							AOHGameMode.modifier_total[choice] = AOHGameMode.modifiercount[playerID][choice] * AOHGameMode.player_count
						end
					end
				end
				CustomGameEventManager:Send_ServerToAllClients("vote_end", {id = playerID})
			end
		end
	end
	AOHGameMode.dps_interval = AOHGameMode.dps_interval / AOHGameMode.player_count
	GameRules:GetGameModeEntity():SetThink("OnUpdateThink", self, 2)
	CustomGameEventManager:UnregisterListener(AOHGameMode.difficulty_listener)
	AOHGameMode._difficulty = math.floor((difficultyTotal / AOHGameMode.player_count) + 0.5)
	for choice = 0, 3 do
		AOHGameMode.modifier_total[choice] = math.floor((AOHGameMode.modifier_total[choice] / AOHGameMode.player_count) + 0.5)
	end
	if AOHGameMode._difficulty == 0 then
		Notifications:TopToAll({text="#easy_label", style={color="green", ["font-size"]="130px"}, duration=6})
		self._negativeRounds = 2
	elseif AOHGameMode._difficulty == 1 then
		Notifications:TopToAll({text="#normal_label", style={color="white", ["font-size"]="130px"}, duration=6})
	else
		AOHGameMode._difficulty = 2
		Notifications:TopToAll({text="#hard_label", style={color="red", ["font-size"]="130px"}, duration=6})
		self._flPrepTimeBetweenRounds = 7
		for playerID = 0, 4 do
			if PlayerResource:IsValidPlayerID(playerID) then
				if PlayerResource:HasSelectedHero(playerID) then
					local hero = PlayerResource:GetSelectedHeroEntity(playerID)
					hero:AddNewModifier(hero, nil, "modifier_hard_mode_player", {})
				end
			end
		end
	end
	if AOHGameMode.modifier_total[0] == 1 then
		Notifications:TopToAll({text="#laser_chosen", style={color="yellow", ["font-size"]="50px"}, duration=6})
		Timers:CreateTimer(
		7,
		function()
			if not self._entPrepTimeQuest then
			local target = AOHGameMode.Players[RandomInt(0, AOHGameMode.player_count - 1)] or AOHGameMode.Players[0]
			if target then
				local point = target:GetAbsOrigin()
				local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, target)
				ParticleManager:SetParticleControl(fx, 0, point)
				ParticleManager:SetParticleControl(fx, 1, Vector(400, 1, 1))
				ParticleManager:SetParticleControl(fx, 2, Vector(3, 1, 1))
				ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
				ParticleManager:ReleaseParticleIndex(fx)
				Timers:CreateTimer(
					3, 
					function()
						target:EmitSound("Ability.LightStrikeArray")
						local fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_WORLDORIGIN, target )
						ParticleManager:SetParticleControl(fx, 0, point)
						ParticleManager:SetParticleControl(fx, 1, Vector(400, 1, 1))
						ParticleManager:ReleaseParticleIndex(fx)

						local targets = FindUnitsInRadius(
							target:GetTeamNumber(),	-- int, your team number
							point,	-- point, center point
							nil,	-- handle, cacheUnit. (not known)
							400,	-- float, radius. or use FIND_UNITS_EVERYWHERE
							DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
							DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
							0,	-- int, flag filter
							0,	-- int, order filter
							false	-- bool, can grow cache
						)

						for _,enemy in pairs(targets) do
							-- apply damage
							if not enemy:IsMagicImmune() then
								ApplyDamage({
									victim = enemy,
									attacker = self._entAncient,
									damage =  enemy:GetMaxHealth() * 0.35,
									damage_type = DAMAGE_TYPE_MAGICAL,
									damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
									ability = nil,}
								)
							end
						end
					end
				)
				end
			end
			return 4

		end
	)
	end
	if AOHGameMode.modifier_total[1] == 1 then
		Notifications:TopToAll({text="#nightmare_chosen", style={color="yellow", ["font-size"]="50px"}, duration=6})
		if self._nPlayerHelp then
			self._nPlayerHelp:AddNewModifier(self._nPlayerHelp, nil, "modifier_nightmare_player", {})
		end
	end
	if AOHGameMode.modifier_total[2] == 1 then
		Notifications:TopToAll({text="#double_chosen", style={color="yellow", ["font-size"]="50px"}, duration=6})
	end
	if AOHGameMode.modifier_total[3] == 1 then
		Notifications:TopToAll({text="#sudden_death_chosen", style={color="yellow", ["font-size"]="50px"}, duration=6})
	end
	for playerID = 0, 4 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)

				if AOHGameMode.modifier_total[0] == 1 then
					hero:AddNewModifier(hero, nil, "modifier_laser_player", {})
				end
				if AOHGameMode.modifier_total[1] == 1 then
					hero:AddNewModifier(hero, nil, "modifier_nightmare_player", {})
				end
				if AOHGameMode.modifier_total[2] == 1 then
					hero:AddNewModifier(hero, nil, "modifier_double_player", {})
				end
				if AOHGameMode.modifier_total[3] == 1 then
					hero:AddNewModifier(hero, nil, "modifier_sudden_death_player", {})
					AOHGameMode.nGoldIncome = 20
				end
			end
		end
	end

end
-- Initiates variables that need to be set to values
function AOHGameMode:InitVariables() 
	AOHGameMode.difficulty_listener = CustomGameEventManager:RegisterListener("difficulty_clicked", Dynamic_Wrap(AOHGameMode, "DifficultyClicked"))
	AOHGameSkills:Init()

	for playerID = 0, DOTA_DEFAULT_MAX_TEAM - 1 do
		player_data_set_value(playerID, "bossDamage", 0)
		player_data_set_value(playerID, "damageTaken", 0)
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				AOHGameMode.player_array[AOHGameMode.player_count] = playerID
				AOHGameMode.player_count = AOHGameMode.player_count + 1
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				local courier_position = Entities:FindByName(nil, "dota_courier_spawn"):GetAbsOrigin() + Vector(RandomInt(-200, 200), RandomInt(-200, 200), 0)

				local courier = CreateUnitByName("npc_courier_replacement", courier_position, true, hero, nil, hero:GetTeamNumber())
				courier:SetControllableByPlayer(hero:GetPlayerID(), true)
				courier:SetTeam(hero:GetTeamNumber())
				courier:SetOwner(hero)
				PlayerResource:SetCustomBuybackCooldown(playerID, 25)
				AOHGameMode.Players[playerID] = hero
			end
		end
	end
	CustomGameEventManager:Send_ServerToAllClients("game_begin", {players = AOHGameMode.player_array})
	CustomGameEventManager:Send_ServerToAllClients("dps_init", {players = AOHGameMode.player_array})
	self._goldRatio = 1 - 0.12 * (5 - AOHGameMode.player_count)
	self._expRatio = 1 - 0.12 * (5 - AOHGameMode.player_count)
	if AOHGameMode.player_count < 2 then
		self._goldRatio = 0.4
		self._expRatio = 0.4
		local playerHero = PlayerResource:GetPlayer(0):GetAssignedHero()
		self._nPlayerHelp = CreateUnitByName("npc_playerhelp", playerHero:GetAbsOrigin(), true, playerHero, playerHero:GetOwner(), playerHero:GetTeamNumber())
		self._nPlayerHelp:SetControllableByPlayer(playerHero:GetPlayerID(), true)
		self._nPlayerHelp:SetTeam(playerHero:GetTeamNumber())
		self._nPlayerHelp:SetOwner(playerHero)
		AOHGameMode._singlePlayer = true
		Notifications:TopToAll({text="It's dangerous to go alone! Take this.", duration=5})
	end
	Timers:CreateTimer(
		0.15,
		function()
			DashManager:Init()
			for _, hero in pairs(AOHGameMode.Players) do
				fix_atr_for_hero(hero)
				if hero:GetUnitName() == "npc_dota_hero_skeleton_king" then
					hero:FindAbilityByName("skeleton_king_hidden_skeleton"):SetLevel(1)
				end
				if hero:GetUnitName() == "npc_dota_hero_windrunner" then
					hero:FindAbilityByName("windrunner_force_fire_toggle"):SetLevel(1)
				end
			end
		end
	)
	EmitGlobalSound("AOH.MenuOpen")
	Timers:CreateTimer(
		10,
		function()
			self:EndVote()
		end
	)
	local totalGold = 3000 * self._goldRatio
	for _, v in pairs(AOHGameMode.Players) do
		v:SetGold(totalGold / AOHGameMode.player_count, true)
	end
	GameRules:GetGameModeEntity():SetThink("GoldIncome", self, 1)

end

function AOHGameMode:GoldIncome()
	for _, v in pairs(AOHGameMode.Players) do
		v:ModifyGold(AOHGameMode.nGoldIncome, true, DOTA_ModifyGold_GameTick)
	end
	return 7
end

-- When game state changes set state in script
function AOHGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		for playerID = 0, DOTA_DEFAULT_MAX_TEAM - 1 do
			if PlayerResource:IsValidPlayerID(playerID) then
				if not PlayerResource:HasSelectedHero(playerID) then
					PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()	
				end
			end
		end
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		self:_RevealShop()
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds + 8
		self:InitVariables() 
	elseif nNewState == DOTA_GAMERULES_STATE_POST_GAME then
		GameRules:SetSafeToLeave(true)
		end_screen_setup(self._entAncient and self._entAncient:IsAlive())
	end
end
-- Updates the damage meter UI for players
function AOHGameMode:OnUpdateThink()
	local currentPlayer = AOHGameMode.player_array[AOHGameMode.update_index]
	local bossDamage = player_data_get_value(currentPlayer, "bossDamage")
	local dps = (bossDamage - AOHGameMode.damage_count[currentPlayer][AOHGameMode.dps_tick[currentPlayer]]) / 5.6
	CustomNetTables:SetTableValue("damage_stats", tostring(currentPlayer), {damage = bossDamage, dps = dps, damage_taken = player_data_get_value(currentPlayer, "damageTaken"), healing = PlayerResource:GetHealing(currentPlayer), physical = AOHGameMode.phys_damage[currentPlayer],magical = AOHGameMode.mag_damage[currentPlayer], pure = AOHGameMode.pure_damage[currentPlayer]})
	if dps > AOHGameMode.highest_dps[currentPlayer] then
		AOHGameMode.highest_dps[currentPlayer] = dps
	end
	AOHGameMode.damage_count[currentPlayer][AOHGameMode.dps_tick[currentPlayer]] = bossDamage
	AOHGameMode.dps_tick[currentPlayer] = AOHGameMode.dps_tick[currentPlayer] + 1
	if AOHGameMode.dps_tick[currentPlayer] > 6 then
		AOHGameMode.dps_tick[currentPlayer] = 0
	end
	AOHGameMode.update_index = AOHGameMode.update_index + 1
	if AOHGameMode.update_index >= AOHGameMode.player_count then
		AOHGameMode.update_index = 0
	end
	return AOHGameMode.dps_interval
end

local chests = {[0] = "item_chest_1", 
"item_chest_2", 
"item_chest_3", 
"item_chest_4", 
"item_chest_5", 
}

-- Distributes chests based on round number
function AOHGameMode:DistributeChests()
	local temp = AOHGameMode._nRoundNumber / 6
	if temp > 0 and temp < 6 then
		local chestName = chests[temp - 1]
		Notifications:TopToAll({text="Trade your chest in for a tier " .. temp .. " neutral item", duration=5})
		for playerID = 0, DOTA_DEFAULT_MAX_TEAM - 1 do
			if PlayerResource:HasSelectedHero(playerID) then
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				if hero then
					hero:AddItemByName(chestName)
				end
			end
		end
	end
end

function AOHGameMode:TeamAddCurrency()
	for playerID = 0, DOTA_DEFAULT_MAX_TEAM - 1 do
		if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
			AOHGameSkills.AddCurrency(playerID, 1)
		end
	end
end

local round_end_sounds = {[0] = "AOH.Horn1", 
"AOH.Horn2", 
"AOH.Horn3", 
"AOH.Horn4",
}
-- Evaluate the state of the game
function AOHGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:_CheckForDefeat()
		removed_expired_items(self._flItemExpireTime)
		if self._flPrepTimeEnd ~= nil then
	self:_ThinkPrepTime()
elseif self._currentRound ~= nil then
	self._currentRound:Think()
	if self._currentRound:IsFinished() then
		self._currentRound:End()
		self._currentRound = nil
		EmitGlobalSound(round_end_sounds[RandomInt(0, 3)])
		if AOHGameMode._difficulty ~= 2 then
			refresh_players()
		end
		if AOHGameMode._nRoundNumber % 6 == 0 then
			self:DistributeChests()
			self:TeamAddCurrency()
		end
		-- if (AOHGameMode._nRoundNumber - 3) % 6 == 0 then
		if AOHGameMode._nRoundNumber == 3 or AOHGameMode._nRoundNumber == 9 or AOHGameMode._nRoundNumber == 15 or AOHGameMode._nRoundNumber == 21 or AOHGameMode._nRoundNumber == 27 then
			AOHGameSkills:UnlockSkills((AOHGameMode._nRoundNumber + 3) / 6)
			self:TeamAddCurrency()
		end
		AOHGameMode._nRoundNumber = AOHGameMode._nRoundNumber + 1
		GameRules.GLOBAL_roundNumber = AOHGameMode._nRoundNumber
		if AOHGameMode._nRoundNumber <= #self._vRounds - self._negativeRounds then
			self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
		end
	end
end
if AOHGameMode._nRoundNumber > #self._vRounds - self._negativeRounds then
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
			return false
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 1.1
end


function AOHGameMode:_RevealShop()
	local shopPos = Entities:FindByName(nil, "the_shop"):GetAbsOrigin()
	AddFOWViewer(2, shopPos, 750, 10000, true)
end


function AOHGameMode:_CheckForDefeat()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if self._entAncient and self._entAncient:IsAlive() then
			if are_all_heroes_dead() and not self._ischeckingdefeat then
				GameRules:GetGameModeEntity():SetThink("CheckForDefeatDelay", self, 0.5)
				self._ischeckingdefeat = true
			end
		else
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		end
	end
end

function AOHGameMode:CheckForDefeatDelay()
	if self._defeatcounter > 0 then
		if are_all_heroes_dead() then
			local color = "rgb(252 ," .. self._defeatcounter * 40 .. ", " ..  self._defeatcounter * 40 .. ")"
			Notifications:TopToAll({text=self._defeatcounter, style={color=color}, duration=1})
			self._defeatcounter = self._defeatcounter - 1
			return 1
		else
			Notifications:TopToAll({text="CLEAR", style={color="green"}, duration=1})
			self._defeatcounter = 6
			self._ischeckingdefeat = false
			return nil
		end

	else 
		if are_all_heroes_dead() then
			self._entAncient:ForceKill(false)
		else
			Notifications:TopToAll({text="CLEAR", style={color="green"}, duration=1})
			self._defeatcounter = 6
			self._ischeckingdefeat = false
			return nil
		end
	end
end

function AOHGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
		self._flPrepTimeEnd = nil
		if self._entPrepTimeQuest then
			UTIL_Remove(self._entPrepTimeQuest)
			self._entPrepTimeQuest = nil
		end
		self._currentRound = self._vRounds[AOHGameMode._nRoundNumber]
		self._currentRound:Begin(self._goldRatio, self._expRatio)
		self:AtRoundStart()
		return
	end

	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous("quest", { name = "PrepTime", title = "#DOTA_Quest_Holdout_PrepTime" })
		self._entPrepTimeQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_ROUND, AOHGameMode._nRoundNumber)
		local round = self._vRounds[AOHGameMode._nRoundNumber]
		round:Precache()
	end
	self._entPrepTimeQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime())
end

function AOHGameMode:OnEntitySpawned(event)
	local unit = EntIndexToHScript(event.entindex)
	if unit and not unit:IsHero() then
		if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			unit:AddNewModifier(unit, nil, "modifier_boss", {})
			if AOHGameMode._difficulty == 2 then
				unit:AddNewModifier(unit, nil, "modifier_hard_mode_boss", {})
			elseif AOHGameMode._difficulty == 0 then
				unit:AddNewModifier(unit, nil, 	"modifier_easy_mode_boss", {})
			end
			if AOHGameMode.modifier_total[2] == 1 then
				unit:AddNewModifier(unit, nil, "modifier_double_boss", {})
			end
			if unit:GetUnitLabel() == "main_boss" then
				unit:AddNewModifier(unit, nil, "modifier_main_boss", {round = AOHGameMode._nRoundNumber})
			end
		elseif unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
            if unit:GetPlayerOwnerID() ~= -1 then
                unit:AddNewModifier(unit, nil, "modifier_summonbuff", {id = unit:GetPlayerOwnerID()})
            end
			if AOHGameMode.modifier_total[1] == 1 then
				unit:AddNewModifier(unit, nil, "modifier_nightmare_player", {})
			end
		end
	end
end

function AOHGameMode:OnEntityKilled(event)
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	if killedUnit and killedUnit:IsRealHero()  then
		create_ressurection_tombstone(killedUnit)
	end
end

function AOHGameMode:CheckForLootItemDrop(killedUnit)
	for _, itemDropInfo in pairs(self._vLootItemDropsList) do
		if RollPercentage(itemDropInfo.nChance) then
			create_item_drop(itemDropInfo.szItemName, killedUnit:GetAbsOrigin())
		end
	end
	if killedUnit:GetUnitLabel() == "main_boss" then
		for _, itemDropInfo in pairs(self._vBossLootItemDropsList) do
			if RollPercentage(itemDropInfo.nChance) then
				create_item_drop(itemDropInfo.szItemName, killedUnit:GetAbsOrigin())
			end
		end
	end
end

 -- Deprecated, now takes place in javascript file.
function AOHGameMode:SettingsUpdate(keys)
	EmitSoundOnClient("ui_generic_button_click", PlayerResource:GetPlayer(keys.id))
	AOHGameMode.player_settings[keys.id][0] = keys.dash_value
end

function AOHGameMode:OnPlayerChat(keys)
	if keys.text == "-refresh" then
		AOHGameMode.phys_damage[keys.playerid] = 1
		AOHGameMode.mag_damage[keys.playerid] = 1
		AOHGameMode.pure_damage[keys.playerid] = 1
	end
	if keys.text == "-renew" then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerid), "delete", {})
		AOHGameSkills:Renew(keys.playerid)
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerid), "dps_init", {players = AOHGameMode.player_array})

	end
	if keys.text == "-override" then
		if keys.playerid == 0 and not AOHGameMode.vote_override then
			AOHGameMode.vote_override = true
			Notifications:TopToAll({text="#vote_override", style={color="yellow", ["font-size"]="130px"}, duration=6})
		end
	end
	if GameRules:IsCheatMode() then
		if AOHGameMode._debug == false and keys.text == "-debug" then
			AOHGameMode._debug = true
			local playerHero = PlayerResource:GetPlayer(0):GetAssignedHero()
		for var = 0, 27 do
			playerHero:HeroLevelUp(false)
		end
			AOHGameSkills:UnlockSkills(1)
			AOHGameSkills:UnlockSkills(2)
			AOHGameSkills:UnlockSkills(3)
			AOHGameSkills:UnlockSkills(4)
			AOHGameSkills:UnlockSkills(5)
			playerHero:ModifyGold(99999, true, DOTA_ModifyGold_GameTick)
			CreateUnitByName("npc_punching_bag", playerHero:GetAbsOrigin(), true, playerHero, playerHero:GetOwner(), DOTA_TEAM_GOODGUYS)
			CreateUnitByName("npc_punching_bag", playerHero:GetAbsOrigin(), true, playerHero, playerHero:GetOwner(), DOTA_TEAM_BADGUYS)
			playerHero:AddItemByName("item_dev_dagon")
			playerHero:AddItemByName("item_dev_heart")
			playerHero:AddItemByName("item_dev_25")
			playerHero:AddItemByName("item_dev_manafill")
			playerHero:AddItemByName("item_dev_octarine_core")
			Notifications:TopToAll({text="Debug Mode", style={color="green", ["font-size"]="130px"}, duration=2})
		end
		if AOHGameMode._debug == true and keys.text == "-debugend" then
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		end
		if AOHGameMode._debug == true and string.sub(keys.text,1, 4) == "-rnd" then
			local rnd = tonumber(string.sub(keys.text, 6, keys.text:len()))
			Notifications:TopToAll({text=rnd, style={color="green", ["font-size"]="130px"}, duration=2})
			if self._currentRound == nil then
				AOHGameMode._nRoundNumber = rnd
			else
				AOHGameMode._nRoundNumber = rnd - 1
			end
			local hero = PlayerResource:GetPlayer(0):GetAssignedHero()
			local units = FindUnitsInRadius(hero:GetTeam(), hero:GetAbsOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
			for _, unit in ipairs(units) do
				if unit then
					unit:ForceKill(false)
				end
			end
		end
	end
end

											