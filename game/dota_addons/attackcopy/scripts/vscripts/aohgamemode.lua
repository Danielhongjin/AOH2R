--[[
From
Holdout Example

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability

	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]
require("AOHGameRound")
require("AOHSpawner")
require("lib/my")
require("lib/atr_fix")
require("lib/timers")
require("lib/ai")
require("lib/chat_handler")
require("items/arcane_staff")
require("items/item_demon_talon")
require("lib/parsers")
require("lib/end_screen")
require("lib/data")
require("lib/notifications")

LinkLuaModifier("modifier_playerhelp_revive", "modifiers/modifier_playerhelp_revive.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss", "modifiers/modifier_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hard_mode_boss", "modifiers/modifier_hard_mode_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hard_mode_player", "modifiers/modifier_hard_mode_player.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_easy_mode_boss", "modifiers/modifier_easy_mode_boss.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_primary_controller", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_primary_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_summonbuff", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
if AOHGameMode == nil then
	_G.AOHGameMode = class({})
end



function AOHGameMode:InitGameMode()
	self._nRoundNumber = 37
	self._negativeRounds = 0
	self._currentRound = nil
	self._entAncient = Entities:FindByName(nil, "dota_goodguys_fort")
	if not self._entAncient then
		print( "Ancient entity not found!" )
	end
	self._hasVoted = {}
	AOHGameMode.numPhilo = {}
	AOHGameMode.isArcane = {}
	AOHGameMode.isTalon = {}
	AOHGameMode.talonCount = {}
	AOHGameMode.difficultycount = {}
	AOHGameMode.Players = {}
	AOHGameMode.damage_count = {}
	AOHGameMode.mag_damage = {}
	AOHGameMode.phys_damage = {}
	AOHGameMode.pure_damage = {}
	AOHGameMode.dps_tick = 0
	AOHGameMode.highest_dps = {}
	self._playerNumber = 0
	self._goldRatio = 1
	self._expRatio = 1
	self._ischeckingdefeat = false
	self._defeatcounter = 5
	self._difficulty = 0
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	Convars:SetInt("dota_max_physical_items_purchase_limit", 35)
	self:_ReadGameConfiguration()
	
	GameRules:SetCustomGameSetupAutoLaunchDelay(3.0)
	GameRules:SetTimeOfDay(0.75)
	GameRules:SetHeroRespawnEnabled(true)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:SetHeroSelectionTime(40.0)
	GameRules:SetPreGameTime(6.0)
	GameRules:SetStrategyTime(10.0)
	GameRules:SetPostGameTime(4000.0)
	GameRules:SetTreeRegrowTime(70.0)	
	GameRules:SetHeroMinimapIconScale(1.2)
	GameRules:SetCreepMinimapIconScale(1.2)
	GameRules:SetRuneMinimapIconScale(1.2)
	GameRules:SetStartingGold(0)
	GameRules:SetStartingGold(0)
	
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible(false)
	GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled(true)
	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled(true)
	GameRules:GetGameModeEntity():SetFixedRespawnTime(75.0)
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(900)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP,15)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN,0.2)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN,0.1)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(AOHGameMode, 'OnEntitySpawned'), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(AOHGameMode, 'OnEntityKilled'), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(AOHGameMode, "OnGameRulesStateChange"), self)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(AOHGameMode, 'OnItemPickedUp'), self)
	ListenToGameEvent("dota_holdout_revive_complete", Dynamic_Wrap(AOHGameMode, 'OnHoldoutReviveComplete'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(AOHGameMode, "OnPlayerChat"), self)
	CustomGameEventManager:RegisterListener("difficulty_clicked", Dynamic_Wrap(AOHGameMode, "DifficultyClicked"))
	GameRules:GetGameModeEntity():SetThink("OnThink", self, 0.75)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(AOHGameMode, 'OnDamageDealt'), self)
end


function AOHGameMode:AtRoundStart()
	local cost = 250 + 50 * self._nRoundNumber
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:HasSelectedHero(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                PlayerResource:SetCustomBuybackCost(playerID, cost)
            end
        end
    end
	
end

function AOHGameMode.SetArcane(PlayerID, bool)
	AOHGameMode.isArcane[PlayerID] = bool
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
	if AOHGameMode.talonCount[PlayerID][1] == 0 and AOHGameMode.talonCount[PlayerID][0] == 0 then
		AOHGameMode.isTalon[PlayerID] = nil
		local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
		hero:RemoveAbility("demon_talon_hidden")
	else 
		local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
		if hero:HasAbility("demon_talon_hidden") then
			AOHGameMode.isTalon[PlayerID] = hero:FindAbilityByName("demon_talon_hidden")
		else 
			AOHGameMode.isTalon[PlayerID] = PlayerResource:GetSelectedHeroEntity(PlayerID):AddAbility("demon_talon_hidden")
			AOHGameMode.isTalon[PlayerID]:SetLevel(1)
		end
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
				if AOHGameMode.isTalon[attackerPlayerId] then
					demon_talon_proc(AOHGameMode.isTalon[attackerPlayerId], attacker, victim, damageTable, AOHGameMode.talonCount[attackerPlayerId][0], AOHGameMode.talonCount[attackerPlayerId][1])
				end
				if victim and victim:GetDayTimeVisionRange() ~= 1337 then
					if AOHGameMode.isArcane[attackerPlayerId] then
						if damageTable.damagetype_const ~= 1 then
							arcane_staff_calculate_crit(attacker, victim, damageTable)
						end
					end
					if attackerPlayerId and attackerPlayerId >= 0 and attacker:IsOpposingTeam(victim:GetTeam()) then
						player_data_modify_value(attackerPlayerId, "bossDamage", damageTable.damage)
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
						player_data_modify_value(victimPlayerId, "damageTaken", damageTable.damage)
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

function AOHGameMode:DifficultyClicked(keys)
	EmitSoundOnClient("AOH.MenuSelection", PlayerResource:GetPlayer(keys.id))
	AOHGameMode.difficultycount[keys.id] = keys.choice
	CustomGameEventManager:Send_ServerToAllClients("vote_update", {id = keys.id, difficulty = AOHGameMode.difficultycount[keys.id]})
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
	self._vRounds = rounds_from_kv(kv["Rounds"], self)
end


-- Verify spawners if random is set
function AOHGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error("Attempt to choose a random spawn, but no random spawns are specified in the data.")
		return nil
	end
	return self._vRandomSpawnsList[RandomInt(1, #self._vRandomSpawnsList)]
end

function AOHGameMode:EndVote()
	EmitGlobalSound("AOH.MenuClose")
	local difficultyTotal = 0
	for playerID = 0, 4 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				difficultyTotal = difficultyTotal + AOHGameMode.difficultycount[playerID]
				CustomGameEventManager:Send_ServerToAllClients("vote_end", {id = playerID})
			end
		end
	end
	self._difficulty = math.floor((difficultyTotal / self._playerNumber) + 0.5)
	if self._difficulty == 0 then
		Notifications:TopToAll({text="#easy_label", style={color="green", ["font-size"]="130px"}, duration=5})
		self._negativeRounds = 2
	elseif self._difficulty == 1 then
		Notifications:TopToAll({text="#normal_label", style={color="white", ["font-size"]="130px"}, duration=5})
	elseif self._difficulty == 2 then
		Notifications:TopToAll({text="#hard_label", style={color="red", ["font-size"]="130px"}, duration=5})
		self._flPrepTimeBetweenRounds = 5
		
		for playerID = 0, 4 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				hero:AddNewModifier(hero, nil, "modifier_bonus_primary_controller", {})
				hero:AddNewModifier(hero, nil, "modifier_bonus_primary_token", {
					bonus = 12})
				hero:AddNewModifier(hero, nil, "modifier_hard_mode_player", {})
			end
		end
	end
	end
	
end
-- Initiates variables that need to be set to values
function AOHGameMode:InitVariables() 
	for playerID = 0, 4 do
		AOHGameMode.difficultycount[playerID] = 1
		AOHGameMode.talonCount[playerID] = {}
		AOHGameMode.isTalon[playerID] = nil
		AOHGameMode.isArcane[playerID] = false
		AOHGameMode.numPhilo[playerID] = 0
		AOHGameMode.highest_dps[playerID] = 0
		AOHGameMode.damage_count[playerID] = {}
		AOHGameMode.mag_damage[playerID] = 1
		AOHGameMode.phys_damage[playerID] = 1
		AOHGameMode.pure_damage[playerID] = 1
		for var = 0, 2 do
			self.talonCount[playerID][var] = 0
		end
		for var = 0, 9 do
			AOHGameMode.damage_count[playerID][var] = 0
		end
		if PlayerResource:IsValidPlayerID(playerID) then
			if PlayerResource:HasSelectedHero(playerID) then
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				hero:AddItemByName("item_black_king_bar_free")
				local courier_position = Entities:FindByName(nil, "dota_courier_spawn"):GetAbsOrigin() + Vector(RandomInt(-200, 200), RandomInt(-200, 200), 0)
				local callback = function(courier)
					courier:SetControllableByPlayer(hero:GetPlayerID(), true)
					courier:SetTeam(hero:GetTeamNumber())
					courier:SetOwner(hero)
				end
				local courier = CreateUnitByNameAsync("npc_courier_replacement", courier_position, true, hero, hero:GetOwner(), hero:GetTeamNumber(), callback)
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "vote_begin", {id = playerID})
				CustomGameEventManager:Send_ServerToAllClients("game_begin", {name = PlayerResource:GetSelectedHeroName(playerID), id = playerID})
				self._playerNumber = self._playerNumber + 1
				PlayerResource:SetCustomBuybackCooldown(playerID, 90)
				AOHGameMode.Players[playerID] = hero
				CustomGameEventManager:Send_ServerToAllClients("vote_name", {name = PlayerResource:GetSelectedHeroName(playerID), id = playerID})
			end
		end
	end
	self._goldRatio = 1 - 0.12 * (5 - self._playerNumber)
	self._expRatio = 1 - 0.12 * (5 - self._playerNumber)
	if self._playerNumber < 2 then
		self._goldRatio = 0.4
		self._expRatio = 0.4
		local playerHero = PlayerResource:GetPlayer(0):GetAssignedHero()
		self._nPlayerHelp = CreateUnitByName("npc_playerhelp", playerHero:GetAbsOrigin(), true, playerHero, playerHero:GetOwner(), playerHero:GetTeamNumber())
		self._nPlayerHelp:SetControllableByPlayer(playerHero:GetPlayerID(), true)
		self._nPlayerHelp:SetTeam(playerHero:GetTeamNumber())
		self._nPlayerHelp:SetOwner(playerHero)
		Notifications:TopToAll({text="It's dangerous to go alone! Take this.", duration=5})
	end
	EmitGlobalSound("AOH.MenuOpen")
	Timers:CreateTimer(
		function()
			for _, v in pairs(AOHGameMode.Players) do
				v:ModifyGold(10, true, DOTA_ModifyGold_GameTick)
			end
			return 7
		end
	)
	Timers:CreateTimer(
		10,
		function()
			self:EndVote()
		end
	)
	local totalGold = 3000 * self._goldRatio
	for _, v in pairs(AOHGameMode.Players) do
		v:ModifyGold(totalGold / self._playerNumber, true, DOTA_ModifyGold_GameTick)
	end
	
end

-- When game state changes set state in script
function AOHGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(playerID) then
				if not PlayerResource:HasSelectedHero(playerID) then
					PlayerResource:GetPlayer(playerID):MakeRandomHeroSelection()	
				end
			end
		end
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		self:_RevealShop()
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:GetGameModeEntity():SetThink("OnUpdateThink", self, 2)
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds + 8
		self:InitVariables() 
	elseif nNewState == DOTA_GAMERULES_STATE_POST_GAME then
		GameRules:SetSafeToLeave(true)
		end_screen_setup(self._entAncient and self._entAncient:IsAlive())
	end
end
-- Updates the damage meter UI for players
function AOHGameMode:OnUpdateThink()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(playerID) then
			local bossDamage = player_data_get_value(playerID, "bossDamage")
			CustomGameEventManager:Send_ServerToAllClients("damage_type_update", {physical = AOHGameMode.phys_damage[playerID],magical = AOHGameMode.mag_damage[playerID],pure = AOHGameMode.pure_damage[playerID],id = playerID})
			local dps = (bossDamage - AOHGameMode.damage_count[playerID][AOHGameMode.dps_tick]) / 6
			CustomGameEventManager:Send_ServerToAllClients("damage_update", {damage = formated_number(bossDamage), dps = formated_number(dps),damage_taken = formated_number(player_data_get_value(playerID, "damageTaken")), healing = formated_number(PlayerResource:GetHealing(playerID)), id = playerID})
			if dps > AOHGameMode.highest_dps[playerID] then
				AOHGameMode.highest_dps[playerID] = dps
			end
			AOHGameMode.damage_count[playerID][AOHGameMode.dps_tick] = bossDamage
		end
	end
	AOHGameMode.dps_tick = AOHGameMode.dps_tick + 1
	if AOHGameMode.dps_tick > 9 then
		AOHGameMode.dps_tick = 0
	end
	return 0.66
end

local chests = {[0] = "item_chest_1", 
"item_chest_2", 
"item_chest_3", 
"item_chest_4", 
"item_chest_5", 
}

-- Distributes chests based on round number
function AOHGameMode:DistributeChests()
	local temp = self._nRoundNumber / 6
	if temp > 0 and temp < 6 then
		local chestName = chests[temp - 1]
		Notifications:TopToAll({text="Trade your chest in for a tier " .. temp .. " neutral item", duration=5})
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:HasSelectedHero(playerID) then
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				if hero then
					hero:AddItemByName(chestName)
				end
			end
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
				if self._difficulty ~= 2 then
					refresh_players()
				end
				if self._nRoundNumber % 6 == 0 then
					self:DistributeChests()
				end
				self._nRoundNumber = self._nRoundNumber + 1
				if self._nRoundNumber <= #self._vRounds - self._negativeRounds then
					self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
				end
			end
		end
		
		if self._nRoundNumber > #self._vRounds - self._negativeRounds then
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
			return false
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 1
end


function AOHGameMode:_RevealShop()
	local shopPos = Entities:FindByName(nil, "the_shop"):GetAbsOrigin()
	AddFOWViewer(2, shopPos, 1000, 10000, true)
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
		Notifications:TopToAll({text=self._defeatcounter, duration=1})
		self._defeatcounter = self._defeatcounter - 1
		return 1
	else 
		if self._entAncient and self._entAncient:IsAlive() then
			if are_all_heroes_dead() then
				self._entAncient:ForceKill(false)
			else
				Notifications:TopToAll({text="CLEAR", duration=1})
				self._defeatcounter = 4
				self._ischeckingdefeat = false
				return nil
			end
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
		GameRules.GLOBAL_roundNumber = self._nRoundNumber  -- Set a global.
		self._currentRound = self._vRounds[self._nRoundNumber]
		self._currentRound:Begin(self._goldRatio, self._expRatio)
		self:AtRoundStart()
		return
	end

	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous("quest", { name = "PrepTime", title = "#DOTA_Quest_Holdout_PrepTime" })
		self._entPrepTimeQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber)
		local round = self._vRounds[self._nRoundNumber]
		round:Precache()
	end
	self._entPrepTimeQuest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime())
end


function AOHGameMode:OnEntitySpawned(event)
	-- Fix for str magic res and more.
	local unit = EntIndexToHScript(event.entindex)
	if unit and unit:IsHero() then
		fix_atr_for_hero(unit)
	end

	Timers:CreateTimer(
		0.1,
		function()
			if not unit:IsHero() then
				if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
					unit:AddNewModifier(unit, nil, "modifier_boss", {})
					if self._difficulty == 2 then
						unit:AddNewModifier(unit, nil, "modifier_hard_mode_boss", {})
					elseif self._difficulty == 0 then
						unit:AddNewModifier(unit, nil, "modifier_easy_mode_boss", {})
					end
				elseif unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
					unit:AddNewModifier(unit, nil, "modifier_summonbuff", {id = unit:GetPlayerOwnerID()})
				end
			end
		end
	)
	
end


function AOHGameMode:OnEntityKilled(event)
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	if killedUnit and killedUnit:IsRealHero()  then
		create_ressurection_tombstone(killedUnit)
	end
	if killedUnit:GetUnitName() == "npc_playerhelp" then
		if not killedUnit:IsIllusion() and killedUnit:IsControllableByAnyPlayer() then
			local playerHero = PlayerResource:GetPlayer(0):GetAssignedHero()
			playerHero:AddNewModifier(playerHero, nil, "modifier_playerhelp_revive", {duration = 15})
			GameRules:GetGameModeEntity():SetThink("RevivePlayerHelp", self, 15)
		end
	end
end

-- Revives player help in single player mode
function AOHGameMode:RevivePlayerHelp()
	local playerHero = PlayerResource:GetPlayer(0):GetAssignedHero()
	self._nPlayerHelp = CreateUnitByName("npc_playerhelp", playerHero:GetAbsOrigin(), true, playerHero, playerHero:GetOwner(), playerHero:GetTeamNumber())
	self._nPlayerHelp:SetControllableByPlayer(playerHero:GetPlayerID(), true)
	self._nPlayerHelp:SetTeam(playerHero:GetTeamNumber())
	self._nPlayerHelp:SetOwner(playerHero)
end

function AOHGameMode:CheckForLootItemDrop(killedUnit)
	for _, itemDropInfo in pairs(self._vLootItemDropsList) do
		if RollPercentage(itemDropInfo.nChance) then
			create_item_drop(itemDropInfo.szItemName, killedUnit:GetAbsOrigin())
		end
	end
end

function AOHGameMode:OnPlayerChat(keys)
	if keys.text == "-refresh" then
		AOHGameMode.phys_damage[keys.playerid] = 1
		AOHGameMode.mag_damage[keys.playerid] = 1
		AOHGameMode.pure_damage[keys.playerid] = 1
	end
	if keys.text == "-renew" then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerid), "delete", {})
		for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
			if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasSelectedHero(playerID) then
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerid), "game_begin", {name = PlayerResource:GetSelectedHeroName(playerID), id = playerID})
			end
		end
	end
end

