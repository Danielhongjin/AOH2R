require("lib/timers")


function debug_print(a)
	--Say(nil, a, false)
	return
end


function value_if_scepter(caster, ifYes, ifNot)
	if caster:HasScepter() then
		return ifYes
	end
	return ifNot
end


function increase_modifier(caster, target, ability, modifier)
	if target:HasModifier(modifier) then
		local newCount = target:GetModifierStackCount(modifier, caster) + 1
        target:SetModifierStackCount(modifier, caster, newCount)
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
		target:SetModifierStackCount(modifier, caster, 1)
    end
end


function decrease_modifier(caster, target, modifier)
	if target:HasModifier(modifier) then
		local count = target:GetModifierStackCount(modifier, caster)

		if count > 1 then
			target:SetModifierStackCount(modifier, caster, count - 1)
		else 
			target:RemoveModifierByName(modifier)
		end
	end
end


function random_from_table(the_table)
	if #the_table < 1 then
		return nil
	end

	return the_table[RandomInt(1, #the_table)]
end


function kill_if_alive(unit)
	if unit:IsAlive() then
		unit:ForceKill(false)
	end
end


function clamp_value(value, min, max)
	return math.max(math.min(value, max), min)
end


function ability_start_true_cooldown(ability)
	ability:StartCooldown(ability_true_cooldown(ability))
end


function ability_true_cooldown(ability)
	local caster = ability:GetCaster()
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)

	local cooldown_reduct = 0
	local cooldown_reduct_stack = 0
	for k, v in pairs(caster:FindAllModifiers()) do
		print("Modifier  " .. v:GetName())
		if v[GetModifierPercentageCooldown] then
		  	cooldown_reduct = math.max(cooldown_reduct, v:GetModifierPercentageCooldown())
		end
		if v[GetModifierPercentageCooldownStacking] then
		  	cooldown_reduct_stack = cooldown_reduct_stack + v:GetModifierPercentageCooldownStacking()
		end
	end

	value = cooldown * math.max(0.01,(1 - (cooldown_reduct + cooldown_reduct_stack)*0.01))

	print("ability_true_cooldown original is " .. cooldown .. " reduction is " .. (cooldown_reduct + cooldown_reduct_stack) .. " new cd is " .. value)

	return value
end

function ability_true_cooldown_value(caster, value)
	local cooldown = value

	local cooldown_reduct = 0
	local cooldown_reduct_stack = 0
	for k, v in pairs(caster:FindAllModifiers()) do
		print("Modifier  " .. v:GetName())
		if v[GetModifierPercentageCooldown] then
		  	cooldown_reduct = math.max(cooldown_reduct, v:GetModifierPercentageCooldown())
		end
		if v[GetModifierPercentageCooldownStacking] then
		  	cooldown_reduct_stack = cooldown_reduct_stack + v:GetModifierPercentageCooldownStacking()
		end
	end

	value = cooldown * math.max(0.01,(1 - (cooldown_reduct + cooldown_reduct_stack)*0.01))

	print("ability_true_cooldown original is " .. cooldown .. " reduction is " .. (cooldown_reduct + cooldown_reduct_stack) .. " new cd is " .. value)

	return value
end


function ability_behavior_includes(ability, behavior)
	return bit.band(ability:GetBehavior(), behavior) == behavior
end


function find_item(caster, item_name)
    for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        local item = caster:GetItemInSlot(i)
		if item then
			if item:GetName() == item_name then
				return item
				
			end
		end
    end
    return nil
end

function find_item_total(caster, item_name)
    for i = DOTA_ITEM_SLOT_1, 10 do
        local item = caster:GetItemInSlot(i)
		if item then
			if item:GetName() == item_name then
				return item
				
			end
		end
    end
	for i = DOTA_STASH_SLOT_1, DOTA_STASH_SLOT_6 do
	local item = caster:GetItemInSlot(i)
	if item then
		if item:GetName() == item_name then
			return item
			
		end
	end
	end
    return nil
end

function has_item(caster, item_name)
    for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        local item = caster:GetItemInSlot(i)
		if item then
			if item:GetName() == item_name then
				return true
			end
		end
    end
    return nil
end


function refresh_players()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if not hero:IsAlive() then
				hero:RespawnUnit()
			end
			hero:AddNewModifier(hero, nil, "modifier_roundend_effect", {duration = 6})
		end
	end
end


function are_all_heroes_dead()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:HasSelectedHero(playerID) then
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if hero and hero:IsAlive() then
				return false
			end
		end
	end
	return true
	
end


-- Returns true if the item was removed.
function process_item_expire(item, expire_time)
	if item and not item:IsNull() then
		if item:GetCreationTime() >= expire_time then
			return false
		end

		local particle = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item)
		ParticleManager:SetParticleControl(particle, 0, item:GetOrigin())
		ParticleManager:SetParticleControl(particle, 1, Vector(35, 35, 25))
		ParticleManager:ReleaseParticleIndex(particle)
	
		local contained = item:GetContainedItem()
		if contained then
			UTIL_Remove(contained)
		end
		UTIL_Remove(item)

	end

	return true
end


function removed_expired_items(timeout)
	local expire_time = GameRules:GetGameTime() - timeout

	for _, item in pairs(Entities:FindAllByClassname("dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem:GetAbilityName() == "item_bag_of_gold" or item.Holdout_IsLootDrop then
			process_item_expire(item, expire_time)
		end
	end
end


function create_ressurection_tombstone(unit)
	local tombstone_item = CreateItem("item_tombstone", unit, unit)
	tombstone_item:SetPurchaseTime(0)
	tombstone_item:SetPurchaser(unit)

	local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
	tombstone:SetContainedItem(tombstone_item)
	tombstone:SetAngles(0, RandomFloat(0, 360), 0)

	FindClearSpaceForUnit(tombstone, unit:GetAbsOrigin(), true)
end


function create_item_drop(item_name, pos)
	local item = CreateItem(item_name, nil, nil)
	item:SetPurchaseTime(0)
	item:SetStacksWithOtherOwners(true)

	local drop = CreateItemOnPositionSync(pos, item)
	drop.Holdout_IsLootDrop = true
end


function max_all_abilities(unit)
	for slot = 0, 15 do
		local ability = unit:GetAbilityByIndex(slot)
		if ability ~= nil then
			ability:SetLevel(ability:GetMaxLevel())
		end
	end
end


function talent_value(caster, talent_name)
	local talent = caster:FindAbilityByName(talent_name)
	if talent and talent:GetLevel() > 0 then
		return talent:GetSpecialValueFor("value")
	end
	return 0
end


function kill_dummy(dummy)
	Timers:CreateTimer(
		0.01,
		function()
			if dummy and dummy:IsAlive() then
				dummy:ForceKill(false)
				return 0.01
			end
			return nil
		end
	)
end


function create_dummy(caster, pos)
	return CreateUnitByName("npc_dummy_unit", pos, false, caster, caster, caster:GetTeamNumber())
end


function get_item_true_cost(name)
	local cost = GetItemCost(name)
	if cost <= 0 then
		local item = CreateItem(name, nil, nil)
		if item then
			cost = item:GetCost()
			UTIL_Remove(item)
		else
			print("[get_item_true_cost] COULD NOT CREATE ITEM " .. name)
		end
	end
	return cost
end

LinkLuaModifier("modifier_roundend_effect", "lib/my.lua", LUA_MODIFIER_MOTION_NONE)
modifier_roundend_effect = class({})

function modifier_roundend_effect:IsBuff()
    return true
end

function modifier_roundend_effect:IsPurgable()
	return false
end

function modifier_roundend_effect:GetTexture()
    return "omniknight_guardian_angel"
end

function modifier_roundend_effect:RemoveOnDeath()
	return true
end

function modifier_roundend_effect:IsHidden()
	return false
end

function modifier_roundend_effect:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
    }
end

function modifier_roundend_effect:GetModifierHealthRegenPercentage()
    return 18.0	
end

function modifier_roundend_effect:GetModifierTotalPercentageManaRegen()
    return 18.0
end

function modifier_roundend_effect:OnCreated()
	local parent = self:GetParent()
	self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(
		self.fx,
		0,
		parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		parent:GetAbsOrigin(), -- unknown
		true -- unknown, true
	)
end

function modifier_roundend_effect:OnDestroy()
	ParticleManager:DestroyParticle(self.fx, false)
	ParticleManager:ReleaseParticleIndex(self.fx)
end